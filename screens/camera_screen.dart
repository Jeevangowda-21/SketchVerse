import 'package:flutter/material.dart';

class CameraScreen extends StatelessWidget {
  const CameraScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Capture Your Wall'),
      ),
      body: const Center(
        child: Text(
          'Camera will be implemented here.',
          style: TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}