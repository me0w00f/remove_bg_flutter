import os
os.environ['PYTORCH_ENABLE_MPS_FALLBACK'] = '1'

import torch
from PIL import Image
import matplotlib.pyplot as plt
from torchvision import transforms
from transformers import AutoModelForImageSegmentation

SUPPORTED_EXTENSIONS = ['.jpg', '.jpeg', '.png', '.webp']

def get_device():
    if torch.cuda.is_available():
        return 'cuda'
    elif hasattr(torch.backends, 'mps') and torch.backends.mps.is_available():
        return 'mps'
    return 'cpu'

def initialize_model():
    device = get_device()
    print(f"Using device: {device}")
    model = AutoModelForImageSegmentation.from_pretrained(
        'briaai/RMBG-2.0', trust_remote_code=True
    ).to(device)
    model.eval()
    if device == 'cuda':
        torch.set_float32_matmul_precision('high')
    return model, device

def transform_image(image):
    image_size = (1024, 1024)
    transform = transforms.Compose([
        transforms.Resize(image_size, transforms.InterpolationMode.BICUBIC),
        transforms.ToTensor(),
        transforms.Normalize([0.485, 0.456, 0.406], [0.229, 0.224, 0.225])
    ])
    return transform(image)

def remove_background(image_path, output_path, model, device):
    try:
        output_dir = os.path.dirname(output_path)
        if output_dir:
            os.makedirs(output_dir, exist_ok=True)

        image = Image.open(image_path).convert("RGB")

        input_images = transform_image(image).unsqueeze(0).to(device)

        with torch.no_grad():
            preds = model(input_images)[-1].sigmoid().cpu()
            pred = preds[0].squeeze()
            pred_pil = transforms.ToPILImage()(pred)
            mask = pred_pil.resize(image.size)

        image.putalpha(mask)

        if output_path.lower().endswith('.jpg') or output_path.lower().endswith('.jpeg'):
            rgb_image = Image.new('RGB', image.size, (255, 255, 255))
            rgb_image.paste(image, mask=image.split()[3])
            rgb_image.save(output_path, 'JPEG')
        else:
            final_output_path = output_path.replace('.jpg', '.png').replace('.jpeg', '.png').replace('.webp', '.png')
            print(f"Saving to: {final_output_path}")
            image.save(final_output_path, 'PNG')
    except Exception as e:
        print(f"Error processing {image_path}: {e}")

if __name__ == "__main__":
    model, device = initialize_model()

    input_folder = "img"
    output_folder = "img_no_bg"
    os.makedirs(output_folder, exist_ok=True)

    for file in os.listdir(input_folder):
        if file.lower().endswith(tuple(SUPPORTED_EXTENSIONS)):
            input_path = os.path.join(input_folder, file)
            output_file = f"{os.path.splitext(file)[0]}.png"
            output_path = os.path.join(output_folder, output_file)
            print(f"Processing {input_path} -> {output_path}")
            remove_background(input_path, output_path, model, device)
