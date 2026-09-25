import 'dart:typed_data';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

enum DrawingTool {
  pencil,
  pen,
  line,
  rectangle,
  circle,
}

class DrawingScreen extends StatefulWidget {
  final XFile image;

  const DrawingScreen({
    super.key,
    required this.image,
  });

  @override
  State<DrawingScreen> createState() => _DrawingScreenState();
}

class _DrawingScreenState extends State<DrawingScreen> {
  final List<DrawingAction> _actions = [];
  final List<DrawingAction> _redoStack = [];

  DrawingTool _selectedTool = DrawingTool.pen;

  Color _selectedColor = Colors.red;

  Offset? _startPoint;
  Offset? _currentPoint;

  Uint8List? _imageBytes;

  final List<Color> _colors = [
    Colors.red,
    Colors.blue,
    Colors.green,
    Colors.yellow,
    Colors.white,
    Colors.black,
    Colors.orange,
    Colors.purple,
  ];

  @override
  void initState() {
    super.initState();
    _loadImage();
  }

  Future<void> _loadImage() async {
    final bytes = await widget.image.readAsBytes();

    if (!mounted) return;

    setState(() {
      _imageBytes = bytes;
    });
  }

  // -----------------------------
  // START DRAWING
  // -----------------------------

  void _onPanStart(DragStartDetails details) {
    final point = details.localPosition;

    setState(() {
      _startPoint = point;
      _currentPoint = point;

      if (_selectedTool == DrawingTool.pencil ||
          _selectedTool == DrawingTool.pen) {
        _actions.add(
          DrawingAction.freehand(
            points: [point],
            color: _selectedColor,
            strokeWidth: _selectedTool == DrawingTool.pencil ? 2.0 : 4.0,
          ),
        );

        _redoStack.clear();
      }
    });
  }

  // -----------------------------
  // DRAWING
  // -----------------------------

  void _onPanUpdate(DragUpdateDetails details) {
    final point = details.localPosition;

    setState(() {
      _currentPoint = point;

      if (_selectedTool == DrawingTool.pencil ||
          _selectedTool == DrawingTool.pen) {
        if (_actions.isNotEmpty &&
            _actions.last.type == DrawingActionType.freehand) {
          _actions.last.points!.add(point);
        }
      }
    });
  }

  // -----------------------------
  // FINISH DRAWING
  // -----------------------------

  void _onPanEnd(DragEndDetails details) {
    if (_startPoint == null || _currentPoint == null) {
      return;
    }

    if (_selectedTool == DrawingTool.line ||
        _selectedTool == DrawingTool.rectangle ||
        _selectedTool == DrawingTool.circle) {
      setState(() {
        _actions.add(
          DrawingAction.shape(
            shapeType: _selectedTool,
            start: _startPoint!,
            end: _currentPoint!,
            color: _selectedColor,
          ),
        );

        _redoStack.clear();
      });
    }

    setState(() {
      _startPoint = null;
      _currentPoint = null;
    });
  }

  // -----------------------------
  // UNDO
  // -----------------------------

  void _undo() {
    if (_actions.isEmpty) return;

    setState(() {
      final action = _actions.removeLast();
      _redoStack.add(action);
    });
  }

  // -----------------------------
  // REDO
  // -----------------------------

  void _redo() {
    if (_redoStack.isEmpty) return;

    setState(() {
      final action = _redoStack.removeLast();
      _actions.add(action);
    });
  }

  // -----------------------------
  // CLEAR
  // -----------------------------

  void _clearDrawing() {
    if (_actions.isEmpty) return;

    setState(() {
      _redoStack.addAll(_actions);
      _actions.clear();
    });
  }

  // -----------------------------
  // TOOL BUTTON
  // -----------------------------

  Widget _toolButton({
    required IconData icon,
    required String label,
    required DrawingTool tool,
  }) {
    final selected = _selectedTool == tool;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedTool = tool;
        });
      },
      child: Container(
        width: 72,
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: selected
              ? Colors.blue.withValues(alpha: 0.25)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected ? Colors.blue : Colors.transparent,
            width: 1.5,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: selected ? Colors.blue : Colors.white,
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: selected ? Colors.blue : Colors.white,
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // -----------------------------
  // COLOR BUTTON
  // -----------------------------

  Widget _colorButton(Color color) {
    final selected = _selectedColor == color;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedColor = color;
        });
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 5),
        width: 30,
        height: 30,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: Border.all(
            color: selected ? Colors.white : Colors.grey.shade700,
            width: selected ? 3 : 1,
          ),
          boxShadow: selected
              ? [
                  const BoxShadow(
                    color: Colors.white54,
                    blurRadius: 8,
                  ),
                ]
              : null,
        ),
      ),
    );
  }

  // -----------------------------
  // BUILD UI
  // -----------------------------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF101216),
      appBar: AppBar(
        backgroundColor: const Color(0xFF171A21),
        foregroundColor: Colors.white,
        title: const Text(
          'SketchVerse Drawing',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            tooltip: 'Undo',
            onPressed: _actions.isEmpty ? null : _undo,
            icon: const Icon(Icons.undo),
          ),
          IconButton(
            tooltip: 'Redo',
            onPressed: _redoStack.isEmpty ? null : _redo,
            icon: const Icon(Icons.redo),
          ),
          IconButton(
            tooltip: 'Clear',
            onPressed: _actions.isEmpty ? null : _clearDrawing,
            icon: const Icon(Icons.delete_outline),
          ),
        ],
      ),

      body: Column(
        children: [
          // ----------------------------------
          // IMAGE + DRAWING CANVAS
          // ----------------------------------

          Expanded(
            child: _imageBytes == null
                ? const Center(
                    child: CircularProgressIndicator(),
                  )
                : Center(
                    child: AspectRatio(
                      aspectRatio: 1,
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          // Original room image
                          Image.memory(
                            _imageBytes!,
                            fit: BoxFit.contain,
                          ),

                          // Drawing layer
                          GestureDetector(
                            behavior: HitTestBehavior.translucent,
                            onPanStart: _onPanStart,
                            onPanUpdate: _onPanUpdate,
                            onPanEnd: _onPanEnd,
                            child: CustomPaint(
                              painter: DrawingPainter(
                                actions: _actions,
                                previewTool: _selectedTool,
                                previewStart: _startPoint,
                                previewEnd: _currentPoint,
                                previewColor: _selectedColor,
                              ),
                              size: Size.infinite,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
          ),

          // ----------------------------------
          // TOOL PANEL
          // ----------------------------------

          Container(
            decoration: const BoxDecoration(
              color: Color(0xFF171A21),
              border: Border(
                top: BorderSide(
                  color: Colors.white12,
                ),
              ),
            ),
            child: SafeArea(
              top: false,
              child: Column(
                children: [
                  const SizedBox(height: 8),

                  // Tools
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _toolButton(
                          icon: Icons.edit,
                          label: 'Pencil',
                          tool: DrawingTool.pencil,
                        ),
                        _toolButton(
                          icon: Icons.brush,
                          label: 'Pen',
                          tool: DrawingTool.pen,
                        ),
                        _toolButton(
                          icon: Icons.horizontal_rule,
                          label: 'Line',
                          tool: DrawingTool.line,
                        ),
                        _toolButton(
                          icon: Icons.crop_square,
                          label: 'Rectangle',
                          tool: DrawingTool.rectangle,
                        ),
                        _toolButton(
                          icon: Icons.circle_outlined,
                          label: 'Circle',
                          tool: DrawingTool.circle,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 10),

                  // Colors
                  SizedBox(
                    height: 45,
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          const SizedBox(width: 12),
                          const Icon(
                            Icons.palette_outlined,
                            color: Colors.white70,
                          ),
                          const SizedBox(width: 8),
                          ..._colors.map(_colorButton),
                          const SizedBox(width: 8),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 8),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ======================================================
// DRAWING ACTION
// ======================================================

enum DrawingActionType {
  freehand,
  shape,
}

class DrawingAction {
  final DrawingActionType type;

  final List<Offset>? points;

  final DrawingTool? shapeType;

  final Offset? start;
  final Offset? end;

  final Color color;

  final double strokeWidth;

  DrawingAction.freehand({
    required this.points,
    required this.color,
    required this.strokeWidth,
  })  : type = DrawingActionType.freehand,
        shapeType = null,
        start = null,
        end = null;

  DrawingAction.shape({
    required this.shapeType,
    required this.start,
    required this.end,
    required this.color,
  })  : type = DrawingActionType.shape,
        points = null,
        strokeWidth = 3.0;
}

// ======================================================
// PAINTER
// ======================================================

class DrawingPainter extends CustomPainter {
  final List<DrawingAction> actions;

  final DrawingTool previewTool;

  final Offset? previewStart;
  final Offset? previewEnd;

  final Color previewColor;

  DrawingPainter({
    required this.actions,
    required this.previewTool,
    required this.previewStart,
    required this.previewEnd,
    required this.previewColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Draw completed actions
    for (final action in actions) {
      final paint = Paint()
        ..color = action.color
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round
        ..strokeWidth = action.strokeWidth
        ..isAntiAlias = true;

      // -------------------------------
      // FREEHAND
      // -------------------------------

      if (action.type == DrawingActionType.freehand) {
        final points = action.points;

        if (points == null || points.isEmpty) {
          continue;
        }

        final path = Path();

        path.moveTo(
          points.first.dx,
          points.first.dy,
        );

        for (int i = 1; i < points.length; i++) {
          path.lineTo(
            points[i].dx,
            points[i].dy,
          );
        }

        canvas.drawPath(path, paint);
      }

      // -------------------------------
      // SHAPES
      // -------------------------------

      if (action.type == DrawingActionType.shape) {
        _drawShape(
          canvas,
          paint,
          action.shapeType!,
          action.start!,
          action.end!,
        );
      }
    }

    // -----------------------------------
    // LIVE SHAPE PREVIEW
    // -----------------------------------

    if (previewStart != null &&
        previewEnd != null &&
        (previewTool == DrawingTool.line ||
            previewTool == DrawingTool.rectangle ||
            previewTool == DrawingTool.circle)) {
      final previewPaint = Paint()
        ..color = previewColor.withValues(alpha: 0.75)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round
        ..isAntiAlias = true;

      _drawShape(
        canvas,
        previewPaint,
        previewTool,
        previewStart!,
        previewEnd!,
      );
    }
  }

  void _drawShape(
    Canvas canvas,
    Paint paint,
    DrawingTool tool,
    Offset start,
    Offset end,
  ) {
    if (tool == DrawingTool.line) {
      canvas.drawLine(
        start,
        end,
        paint,
      );
    }

    if (tool == DrawingTool.rectangle) {
      final rect = Rect.fromPoints(
        start,
        end,
      );

      canvas.drawRect(
        rect,
        paint,
      );
    }

    if (tool == DrawingTool.circle) {
      final rect = Rect.fromPoints(
        start,
        end,
      );

      final radius = rect.shortestSide / 2;

      final center = rect.center;

      canvas.drawCircle(
        center,
        radius,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(
    covariant DrawingPainter oldDelegate,
  ) {
    return true;
  }
}
