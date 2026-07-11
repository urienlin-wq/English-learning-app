import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../models/word_entry.dart';
import '../services/db_service.dart';
import '../services/ocr_service.dart';
import '../services/dictionary_service.dart';

class CaptureScreen extends StatefulWidget {
  const CaptureScreen({super.key});

  @override
  State<CaptureScreen> createState() => _CaptureScreenState();
}

class _CaptureScreenState extends State<CaptureScreen> {
  final ImagePicker _picker = ImagePicker();
  final OCRService _ocr = OCRService();
  final DictionaryService _dict = DictionaryService();
  final DBService _db = DBService();

  File? _image;
  String _rawText = '';
  bool _loading = false;

  final List<String> _localWordBank = [
    'abandon', 'ability', 'benefit', 'category', 'diligent', 'efficient',
    'genuine', 'hesitate', 'illustrate', 'jeopardy', 'knowledge', 'legitimate',
  ];

  List<_ParsedWord> _parsedWords = [];

  Future<void> _takePhoto() async {
    final picked = await _picker.pickImage(source: ImageSource.camera, imageQuality: 90);
    if (picked == null) return;
    setState(() {
      _image = File(picked.path);
      _loading = true;
      _parsedWords = [];
    });
    await _processImage(_image!);
    setState(() => _loading = false);
  }

  Future<void> _pickFromGallery() async {
    final picked = await _picker.pickImage(source: ImageSource.gallery, imageQuality: 90);
    if (picked == null) return;
    setState(() {
      _image = File(picked.path);
      _loading = true;
      _parsedWords = [];
    });
    await _processImage(_image!);
    setState(() => _loading = false);
  }

  Future<void> _processImage(File img) async {
    final english = await _ocr.recognizeEnglish(img);
    final chinese = await _ocr.recognizeChinese(img);
    _rawText = 'EN: $english
CN: $chinese';

    final enLines = english.split('
').where((l) => l.trim().isNotEmpty).toList();
    final cnLines = chinese.split('
').where((l) => l.trim().isNotEmpty).toList();

    final List<_ParsedWord> results = [];
    final int n = enLines.length > cnLines.length ? enLines.length : cnLines.length;
    for (int i = 0; i < n; i++) {
      String en = i < enLines.length ? enLines[i].trim() : '';
      String cn = i < cnLines.length ? cnLines[i].trim() : '';

      bool corrected = false;
      if (en.replaceAll(RegExp(r'[^a-zA-Z]'), '').length < 2) {
        final match = _dict.findClosestMatch(en, _localWordBank);
        if (match != null) {
          en = match;
          corrected = true;
        }
      }

      final pos = await _dict.lookupPartsOfSpeech(en);
      results.add(_ParsedWord(
        english: en,
        chinese: cn,
        partOfSpeech: pos.isNotEmpty ? pos.first : 'unknown',
        corrected: corrected,
      ));
    }
    setState(() => _parsedWords = results);
  }

  Future<void> _saveAll() async {
    for (final w in _parsedWords) {
      if (w.english.isEmpty || w.chinese.isEmpty) continue;
      await _db.insertWord(WordEntry(
        english: w.english,
        chinese: w.chinese,
        partOfSpeech: w.partOfSpeech,
        createdAt: DateTime.now(),
      ));
    }
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('已保存 ${_parsedWords.length} 个单词')),
      );
      Navigator.pop(context);
    }
  }

  @override
  void dispose() {
    _ocr.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('拍照录入单词')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _takePhoto,
                    icon: const Icon(Icons.camera_alt),
                    label: const Text('拍照'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _pickFromGallery,
                    icon: const Icon(Icons.photo_library),
                    label: const Text('从相册选择'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (_loading) const CircularProgressIndicator(),
            if (_image != null && !_loading)
              Expanded(
                child: ListView(
                  children: [
                    Image.file(_image!, height: 200),
                    const SizedBox(height: 12),
                    ..._parsedWords.map((w) => Card(
                          child: ListTile(
                            title: Text('${w.english}  [${w.partOfSpeech}]'),
                            subtitle: Text(w.chinese),
                            trailing: w.corrected
                                ? const Icon(Icons.auto_fix_high, color: Colo
