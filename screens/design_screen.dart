import 'dart:io';

import 'package:flutter/material.dart';

class DesignScreen extends StatelessWidget {
  final String imagePath;

  const DesignScreen({
    super.key,
    required this.imagePath,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Design Your Wall'),
      ),
      body: Column(
        children: [
          Expanded(
            child: Image.file(
              File(imagePath),
              width: double.infinity,
              fit: BoxFit.contain,
            ),
          ),

          const Padding(
            padding: EdgeInsets.all(20),
            child: Text(
              'Next: Draw your cabinet design on the wall.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
