
import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class DesignScreen extends StatelessWidget {
  final XFile image;

  const DesignScreen({
    super.key,
    required this.image,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Design Your Wall'),
      ),

      body: Column(
        children: [
          // ==========================================
          // WALL IMAGE
          // ==========================================
          Expanded(
            child: _buildImage(),
          ),

          // ==========================================
          // INSTRUCTIONS
          // ==========================================
          const Padding(
            padding: EdgeInsets.fromLTRB(20, 15, 20, 10),
            child: Text(
              'Your wall image is ready.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              'Tap the button below to detect objects on your wall.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 15,
                color: Colors.grey,
              ),
            ),
          ),

          // ==========================================
          // DETECT OBJECTS BUTTON
          // ==========================================
          Padding(
            padding: const EdgeInsets.all(20),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  _showDetectionMessage(context);
                },
                icon: const Icon(Icons.search),
                label: const Text(
                  'Detect Objects',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    vertical: 17,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ================================================
  // IMAGE DISPLAY
  // ================================================
  Widget _buildImage() {
    // Flutter Web
    if (kIsWeb) {
      return Image.network(
        image.path,
        width: double.infinity,
        fit: BoxFit.contain,
        errorBuilder: (
          BuildContext context,
          Object error,
          StackTrace? stackTrace,
        ) {
          return const Center(
            child: Text(
              'Unable to display wall image',
              style: TextStyle(
                fontSize: 18,
              ),
            ),
          );
        },
      );
    }

    // Android / iOS
    return FutureBuilder<Uint8List>(
      future: image.readAsBytes(),
      builder: (
        BuildContext context,
        AsyncSnapshot<Uint8List> snapshot,
      ) {
        // Loading
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        // Error
        if (snapshot.hasError || !snapshot.hasData) {
          return const Center(
            child: Text(
              'Unable to load wall image',
              style: TextStyle(
                fontSize: 18,
              ),
            ),
          );
        }

        // Display image
        return Image.memory(
          snapshot.data!,
          width: double.infinity,
          fit: BoxFit.contain,
        );
      },
    );
  }

  // ================================================
  // TEMPORARY DETECTION MESSAGE
  // ================================================
  void _showDetectionMessage(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Object Detection'),
          content: const Text(
            'YOLO object detection will be connected here next.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }
}
