import 'package:flutter/material.dart';
import 'capture_screen.dart';
import 'quiz_e2c_screen.dart';
import 'quiz_c2e_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('拍照背单词')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildMenuButton(
              context,
              icon: Icons.camera_alt,
              label: '拍照录入单词',
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const CaptureScreen()),
              ),
            ),
            const SizedBox(height: 24),
            _buildMenuButton(
              context,
              icon: Icons.translate,
              label: '英译中背诵',
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const QuizE2CScreen()),
              ),
            ),
            const SizedBox(height: 24),
            _buildMenuButton(
              context,
              icon: Icons.edit_note,
              label: '中译英背诵',
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const QuizC2EScreen()),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuButton(BuildContext context,
      {required IconData icon, required String label, required VoidCallback onTap}) {
    return SizedBox(
      width: double.infinity,
      height: 80,
      child: ElevatedButton.icon(
        onPressed: onTap,
        icon: Icon(icon, size: 32),
        label: Text(label, style: const TextStyle(fontSize: 20)),
        style: ElevatedButton.styleFrom(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
      ),
    );
  }
}
