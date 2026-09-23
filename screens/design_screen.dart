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
          Expanded(
            child: kIsWeb
                ? Image.network(
                    image.path,
                    width: double.infinity,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) {
                      return const Center(
                        child: Text(
                          'Unable to display wall image',
                          style: TextStyle(fontSize: 18),
                        ),
                      );
                    },
                  )
                : FutureBuilder<Uint8List>(
                    future: image.readAsBytes(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState ==
                          ConnectionState.waiting) {
                        return const Center(
                          child: CircularProgressIndicator(),
                        );
                      }

                      if (snapshot.hasError || !snapshot.hasData) {
                        return const Center(
                          child: Text(
                            'Unable to load wall image',
                          ),
                        );
                      }

                      return Image.memory(
                        snapshot.data!,
                        width: double.infinity,
                        fit: BoxFit.contain,
                      );
                    },
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
