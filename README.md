# Remove Background Tool

一个简单且功能强大的图像背景移除工具，基于 **Flutter** 和 **Python** 构建。该应用提供用户友好的图形界面，支持选择输入文件和输出目录，并自动调用 Python 脚本进行图像处理。

## ✨ 项目特点

- **用户友好的界面**：基于 Flutter 构建，界面现代且简洁。
- **自动检测 Python 环境**：启动时检查是否安装 Python，并在安装 Python 后自动安装所需依赖。
- **调用 Python 脚本**：使用 Python 脚本对图像进行背景移除处理。
- **实时反馈**：显示处理状态和结果提示，支持错误提示和解决方案指导。

## 📋 依赖

### Flutter 依赖

在项目中使用以下 Flutter 插件：

- `file_picker`: 用于选择输入文件和输出目录。
- `url_launcher`: 用于在未检测到 Python 时，打开浏览器引导用户下载安装 Python。

在 `pubspec.yaml` 中添加以下依赖：

```yaml
dependencies:
  flutter:
    sdk: flutter
  file_picker: ^5.0.0
  url_launcher: ^6.1.7
```

### Python 依赖

Python 脚本使用以下库，请确保安装：

```plaintext
torch>=2.0.0
torchvision>=0.15.0
Pillow>=9.0.0
matplotlib>=3.5.0
transformers>=4.30.0
```

你可以在项目根目录的 `requirements.txt` 中找到这些依赖，并使用以下命令安装：

```bash
pip install -r requirements.txt
```

## 🚀 安装和运行

### 1. 克隆项目

```bash
git clone https://github.com/yourusername/remove-bg-flutter.git
cd remove-bg-flutter
```

### 2. 安装 Flutter 依赖

```bash
flutter pub get
```

### 3. 检查 Python 环境并安装依赖

项目会在启动时自动检测 Python 环境，并安装所需依赖。如果你想手动安装依赖，可以运行以下命令：

```bash
pip install -r requirements.txt
```

### 4. 运行应用

```bash
flutter run
```

## 🎯 使用指南

1. **选择输入文件**：点击界面上的 **"点击选择文件"** 按钮，选择你要处理的图像文件（支持 JPG、PNG 格式）。
2. **选择输出目录**：点击 **"选择输出目录"** 按钮，选择处理后图像的保存位置。
3. **开始处理**：点击 **"开始处理"** 按钮，应用会调用 Python 脚本移除图像背景，并显示处理结果。
4. **处理完成**：成功处理后，会弹出提示框显示 **"处理成功"**。

## 🚠 常见问题

### 1. **未检测到 Python 环境**

**问题**：启动应用时提示未安装 Python。

**解决方案**：请访问 [Python 官网](https://www.python.org/downloads/) 下载并安装 Python，安装后重新启动应用。

### 2. **安装 Python 依赖失败**

**问题**：应用提示安装 Python 依赖失败。

**解决方案**：

- 请检查你的网络连接，确保可以正常访问 Python 包管理器 (PyPI)。
- 你也可以手动运行以下命令安装依赖：

  ```bash
  pip install -r requirements.txt
  ```

### 3. **调用 Python 脚本失败**

**问题**：点击 **"开始处理"** 后，提示调用 Python 脚本失败。

**解决方案**：

- 请确保 Python 环境中安装了所有必要的依赖。
- 检查输入文件路径和输出目录路径是否正确。
- 在终端中手动运行以下命令进行调试：

  ```bash
  python remove_cli.py path/to/your/image.jpg -o path/to/output/folder
  ```

## 🔧 技术细节

- 应用基于 Flutter 构建，提供跨平台支持（Windows、macOS、Linux）。
- 后端使用 Python 脚本处理图像，依赖于 RMBG-2.0 模型进行背景移除。

## 📜 许可证

本项目基于 MIT 许可证发布，详细信息请参见 [LICENSE](LICENSE) 文件。

## 🙏 致谢

- 感谢 Flutter 和 Dart 社区提供的支持。
- RMBG-2.0 模型来自 [BriaAI](https://bria.ai)。
- 感谢所有使用和贡献本项目的开发者。

```



```
