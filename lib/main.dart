import 'package:flutter/material.dart';
import 'screens/home_screen.dart';

void main() {
  runApp(const WordMemorizerApp());
}

class WordMemorizerApp extends StatelessWidget {
  const WordMemorizerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '拍照背单词',
      theme: ThemeData(
        primarySwatch: Colors.indigo,
        useMaterial3: true,
      ),
      home: const HomeScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
