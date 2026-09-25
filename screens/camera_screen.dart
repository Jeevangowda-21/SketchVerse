import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:gal/gal.dart';

import 'image_preview_screen.dart';

class CameraScreen extends StatefulWidget {
  const CameraScreen({super.key});

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  CameraController? _controller;

  bool _isInitialized = false;
  bool _isTakingPicture = false;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    try {
      final cameras = await availableCameras();

      if (cameras.isEmpty) {
        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No camera found on this device.'),
          ),
        );

        return;
      }

      final camera = cameras.first;

      final controller = CameraController(
        camera,
        ResolutionPreset.high,
        enableAudio: false,
      );

      await controller.initialize();

      if (!mounted) {
        await controller.dispose();
        return;
      }

      setState(() {
        _controller = controller;
        _isInitialized = true;
      });
    } on CameraException catch (e) {
      debugPrint('Camera error: ${e.code}');
      debugPrint('Description: ${e.description}');

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Camera error: ${e.description ?? e.code}',
          ),
        ),
      );
    } catch (e) {
      debugPrint('Camera initialization error: $e');

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Unable to initialize camera.'),
        ),
      );
    }
  }

  // ---------------------------------------------------------
  // CAPTURE + SAVE IMAGE
  // ---------------------------------------------------------

  Future<void> _takePicture() async {
    if (_controller == null ||
        !_controller!.value.isInitialized ||
        _isTakingPicture) {
      return;
    }

    setState(() {
      _isTakingPicture = true;
    });

    try {
      // Capture image
      final XFile image = await _controller!.takePicture();

      debugPrint('Image captured: ${image.path}');

      // Save image automatically to Gallery/Photos
      try {
        final bytes = await image.readAsBytes();

        final hasPermission = await Gal.hasAccess();

        if (!hasPermission) {
          await Gal.requestAccess();
        }

        await Gal.putImageBytes(
          bytes,
          album: 'AI Interior Designer',
          name: 'wall_${DateTime.now().millisecondsSinceEpoch}',
        );

        debugPrint('Image saved successfully!');
      } on GalException catch (e) {
        debugPrint('Gallery error: ${e.type.message}');

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Image captured, but could not save: ${e.type.message}',
              ),
            ),
          );
        }
      } catch (e) {
        debugPrint('Save error: $e');

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Image captured, but could not save to gallery.',
              ),
            ),
          );
        }
      }

      if (!mounted) return;

      // Go to preview screen
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ImagePreviewScreen(
            image: image,
          ),
        ),
      );
    } on CameraException catch (e) {
      debugPrint('Capture error: ${e.code}');
      debugPrint('Description: ${e.description}');

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Could not capture image: ${e.description ?? e.code}',
          ),
        ),
      );
    } catch (e) {
      debugPrint('Capture error: $e');

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Could not capture image.'),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isTakingPicture = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,

      appBar: AppBar(
        title: const Text('Capture Your Wall'),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
      ),

      body: !_isInitialized || _controller == null
          ? const Center(
              child: CircularProgressIndicator(
                color: Colors.white,
              ),
            )
          : Stack(
              children: [
                // Camera preview
                Positioned.fill(
                  child: CameraPreview(_controller!),
                ),

                // Instruction
                Positioned(
                  top: 25,
                  left: 20,
                  right: 20,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black54,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      'Point the camera at an empty wall',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),

                // Wall guide
                Positioned(
                  left: 35,
                  right: 35,
                  top: 120,
                  bottom: 150,
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: Colors.white70,
                        width: 2,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),

                // Capture button
                Positioned(
                  bottom: 35,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: GestureDetector(
                      onTap: _isTakingPicture
                          ? null
                          : _takePicture,
                      child: Container(
                        width: 78,
                        height: 78,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white,
                          border: Border.all(
                            color: Colors.grey,
                            width: 5,
                          ),
                        ),
                        child: _isTakingPicture
                            ? const Padding(
                                padding: EdgeInsets.all(20),
                                child: CircularProgressIndicator(
                                  strokeWidth: 3,
                                ),
                              )
                            : const Icon(
                                Icons.camera_alt,
                                color: Colors.black,
                                size: 32,
                              ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}
