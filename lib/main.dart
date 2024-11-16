import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:url_launcher/url_launcher.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Remove Background Tool',
      theme: ThemeData(
        brightness: Brightness.dark,
        primarySwatch: Colors.blue,
        cardColor: Colors.blueGrey.shade800,
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            foregroundColor: Colors.white,
            backgroundColor: Colors.blueAccent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String? inputFilePath;
  String? outputDirectory;
  bool isPythonInstalled = false;

  @override
  void initState() {
    super.initState();
    checkPythonInstallation();
  }

  // 检查是否安装 Python，并安装依赖
  Future<void> checkPythonInstallation() async {
    try {
      final result = await Process.run('python', ['--version']);
      if (result.exitCode == 0) {
        setState(() {
          isPythonInstalled = true;
        });
        await installPythonDependencies();
      } else {
        setState(() {
          isPythonInstalled = false;
        });
      }
    } catch (e) {
      setState(() {
        isPythonInstalled = false;
      });
    }
  }

  // 安装 Python 依赖
  Future<void> installPythonDependencies() async {
    try {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("正在安装 Python 依赖...")),
      );

      final result =
          await Process.run('pip', ['install', '-r', 'requirements.txt']);

      if (result.exitCode == 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Python 依赖安装成功！")),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("安装依赖失败：${result.stderr}")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("无法安装 Python 依赖：$e")),
      );
    }
  }

  // 提示用户安装 Python
  void showPythonInstallationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Python 未安装"),
        content: const Text(
          "检测到您的系统未安装 Python，请先安装 Python 才能使用本应用。",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text("关闭"),
          ),
          TextButton(
            onPressed: () async {
              const url = 'https://www.python.org/downloads/';
              if (await canLaunchUrl(Uri.parse(url))) {
                await launchUrl(Uri.parse(url),
                    mode: LaunchMode.externalApplication);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("无法打开浏览器，请手动访问 Python 官网。")),
                );
              }
            },
            child: const Text("前往下载"),
          ),
        ],
      ),
    );
  }

  // 选择输入文件
  Future<void> selectInputFile() async {
    final result = await FilePicker.platform.pickFiles();
    if (result != null) {
      setState(() {
        inputFilePath = result.files.single.path;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("已选择文件：${inputFilePath!}")),
      );
    }
  }

  // 清除选中的文件
  void clearInputFile() {
    setState(() {
      inputFilePath = null;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("输入文件已清除")),
    );
  }

  // 选择输出目录
  Future<void> selectOutputDirectory() async {
    final result = await FilePicker.platform.getDirectoryPath();
    if (result != null) {
      setState(() {
        outputDirectory = result;
      });
    }
  }

  // 显示 "正在处理" 弹窗
  Future<void> showProcessingDialog(BuildContext context) async {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: const [
              CircularProgressIndicator(),
              SizedBox(height: 20),
              Text("正在处理，请稍候..."),
            ],
          ),
        );
      },
    );
  }

  // 调用 Python 脚本
  Future<void> startProcessing() async {
    if (!isPythonInstalled) {
      showPythonInstallationDialog(context);
      return;
    }

    if (inputFilePath == null || outputDirectory == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("请先选择输入文件和输出目录")),
      );
      return;
    }

    try {
      showProcessingDialog(context);

      final process = await Process.run(
        'python',
        ['remove_cli.py', inputFilePath!, '-o', outputDirectory!],
      );

      Navigator.of(context).pop();

      if (process.exitCode == 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("处理成功！")),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("处理失败：${process.stderr}")),
        );
      }
    } catch (e) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("调用脚本出错：$e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Remove Background Tool"),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            GestureDetector(
              onTap: selectInputFile,
              child: Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListTile(
                  leading: const Icon(Icons.upload_file),
                  title: inputFilePath != null
                      ? Text("已选择文件：$inputFilePath")
                      : const Text("点击选择文件"),
                ),
              ),
            ),
            const SizedBox(height: 20),
            GestureDetector(
              onTap: selectOutputDirectory,
              child: Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListTile(
                  leading: const Icon(Icons.folder_open),
                  title: const Text("选择输出目录"),
                  subtitle: outputDirectory != null
                      ? Text(outputDirectory!)
                      : const Text("未选择目录"),
                ),
              ),
            ),
            const SizedBox(height: 40),
            ElevatedButton.icon(
              icon: const Icon(Icons.play_arrow),
              label: const Text("开始处理"),
              onPressed: startProcessing,
            ),
          ],
        ),
      ),
    );
  }
}
