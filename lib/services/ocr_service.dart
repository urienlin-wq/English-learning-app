import 'dart:io';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

/// 使用设备端 ML Kit 做中英文手写/印刷文字识别（离线，免费，无需联网）
class OCRService {
  final TextRecognizer _recognizer = TextRecognizer(script: TextRecognitionScript.latin);
  final TextRecognizer _chineseRecognizer = TextRecognizer(script: TextRecognitionScript.chinese);

  Future<String> recognizeEnglish(File imageFile) async {
    final inputImage = InputImage.fromFile(imageFile);
    final RecognizedText result = await _recognizer.processImage(inputImage);
    return result.text;
  }

  Future<String> recognizeChinese(File imageFile) async {
    final inputImage = InputImage.fromFile(imageFile);
    final RecognizedText result = await _chineseRecognizer.processImage(inputImage);
    return result.text;
  }

  void dispose() {
    _recognizer.close();
    _chineseRecognizer.close();
  }
}
