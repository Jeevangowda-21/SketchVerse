import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'drawing_screen.dart';
import 'design_screen.dart';

class ImagePreviewScreen extends StatelessWidget {
  final XFile image;

  const ImagePreviewScreen({
    super.key,
    required this.image,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,

      appBar: AppBar(
        title: const Text('Wall Preview'),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
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
          // BUTTONS
          // ==========================================

          Padding(
            padding: const EdgeInsets.all(20),

            child: Column(
              children: [
                // ======================================
                // DRAW DESIGN BUTTON
                // ======================================

                SizedBox(
                  width: double.infinity,

                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,

                        MaterialPageRoute(
                          builder: (context) =>
                              DrawingScreen(
                            image: image,
                          ),
                        ),
                      );
                    },

                    icon: const Icon(
                      Icons.draw,
                    ),

                    label: const Text(
                      'Draw Design',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    style:
                        ElevatedButton.styleFrom(
                      backgroundColor:
                          Colors.deepPurple,

                      foregroundColor:
                          Colors.white,

                      padding:
                          const EdgeInsets.symmetric(
                        vertical: 17,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                // ======================================
                // ANALYZE IMAGE BUTTON
                // ======================================

                SizedBox(
                  width: double.infinity,

                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,

                        MaterialPageRoute(
                          builder: (context) =>
                              DesignScreen(
                            image: image,
                          ),
                        ),
                      );
                    },

                    icon: const Icon(
                      Icons.auto_awesome,
                    ),

                    label: const Text(
                      'Analyze Image',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    style:
                        ElevatedButton.styleFrom(
                      padding:
                          const EdgeInsets.symmetric(
                        vertical: 17,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                // ======================================
                // CHOOSE ANOTHER IMAGE
                // ======================================

                SizedBox(
                  width: double.infinity,

                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },

                    style:
                        OutlinedButton.styleFrom(
                      foregroundColor:
                          Colors.white,

                      side:
                          const BorderSide(
                        color: Colors.white,
                      ),

                      padding:
                          const EdgeInsets.symmetric(
                        vertical: 16,
                      ),
                    ),

                    child: const Text(
                      'Choose Another Image',

                      style: TextStyle(
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
              ],
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
              'Unable to display image',

              style: TextStyle(
                color: Colors.white,
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
        if (snapshot.connectionState ==
            ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(
              color: Colors.white,
            ),
          );
        }

        // Error
        if (snapshot.hasError ||
            !snapshot.hasData) {
          return const Center(
            child: Text(
              'Unable to load image',

              style: TextStyle(
                color: Colors.white,
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
}
