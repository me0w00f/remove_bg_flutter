import os
os.environ['PYTORCH_ENABLE_MPS_FALLBACK'] = '1'

import argparse
import urllib.request
from pathlib import Path
from typing import List, Union
from remove import remove_background, initialize_model

def download_image(url: str, download_path: Path) -> str:
    """Download image from URL to specified path."""
    try:
        filename = os.path.join(download_path, url.split('/')[-1])
        urllib.request.urlretrieve(url, filename)
        return filename
    except Exception as e:
        print(f"Failed to download {url}: {e}")
        return None

def process_input(input_path: Union[str, List[str]], output_dir: str, model, device) -> None:
    """Process input paths (files/directories/URLs) and remove backgrounds."""
    output_dir = Path(output_dir)
    output_dir.mkdir(parents=True, exist_ok=True)
    
    paths = input_path if isinstance(input_path, list) else [input_path]

    for path in paths:
        try:
            if path.startswith(('http://', 'https://')):
                # Handle URLs
                temp_dir = Path('temp_downloads')
                temp_dir.mkdir(exist_ok=True)
                downloaded_path = download_image(path, temp_dir)
                if downloaded_path:
                    output_file = output_dir / f"{Path(downloaded_path).stem}.png"
                    print(f"Processing {downloaded_path} -> {output_file}")
                    remove_background(downloaded_path, str(output_file), model, device)
                    os.remove(downloaded_path)
            else:
                path = Path(path)
                if path.is_file() and path.suffix.lower() in ['.jpg', '.jpeg', '.png', '.webp']:
                    output_file = output_dir / f"{path.stem}.png"
                    print(f"Processing {path} -> {output_file}")
                    remove_background(str(path), str(output_file), model, device)
                elif path.is_dir():
                    for img_path in path.glob('*'):
                        if img_path.suffix.lower() in ['.jpg', '.jpeg', '.png', '.webp']:
                            output_file = output_dir / f"{img_path.stem}.png"
                            print(f"Processing {img_path} -> {output_file}")
                            remove_background(str(img_path), str(output_file), model, device)
        except Exception as e:
            print(f"Error processing {path}: {e}")

def main():
    parser = argparse.ArgumentParser(description='Remove background from images using RMBG-2.0 model')
    parser.add_argument('input', nargs='+', help='Input image file(s), directory, or URL(s)')
    parser.add_argument('-o', '--output', default='output', help='Output directory (default: output)')
    
    args = parser.parse_args()

    # Initialize model and device
    model, device = initialize_model()

    try:
        process_input(args.input, args.output, model, device)
        print("Background removal completed successfully!")
    except Exception as e:
        print(f"An error occurred: {e}")

if __name__ == "__main__":
    main()
