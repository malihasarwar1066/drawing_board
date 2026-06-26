import 'package:flutter/material.dart';
import 'package:flutter_drawing_board/drwaing_models.dart';
import 'package:flutter_drawing_board/whiteboard_painter.dart';

class WhiteBoardUI extends StatefulWidget {
  const WhiteBoardUI({super.key});

  @override
  State<StatefulWidget> createState() => _WhiteBoardUIState();
}

class _WhiteBoardUIState extends State<WhiteBoardUI> {
  final List<DrawingPath> penLines = [];
  List<Offset> currentLinePoints = [];
  final List<DrawingRect> rectangles = [];
  final List<DrawingCircle> circles = [];
  final List<DrawingTriangle> triangles = [];
  Offset? startPoint;
  Offset? currentPoint;

  final List<String> actionHistory = [];
  final List<dynamic> redoStack = [];
  final List<String> redoActionHistory = [];

  String selectedTool = 'pen';
  Color selectedColor = Colors.black;
  double strokeWidth = 5.0;
  bool showShapesMenu = false;

  final List<Color> colorsList = [
    Colors.red,
    Colors.blue,
    Colors.green,
    Colors.yellow,
    Colors.black,
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 5,
        title: const Text(
          'WhiteBoard',
          style: TextStyle(color: Colors.black, fontSize: 16),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.undo, color: Colors.black),
            onPressed: actionHistory.isEmpty
                ? null
                : () {
                    setState(() {
                      String lastAction = actionHistory.removeLast();
                      redoActionHistory.add(lastAction);
                      if (lastAction == 'pen') {
                        redoStack.add(penLines.removeLast());
                      } else if (lastAction == 'rect') {
                        redoStack.add(rectangles.removeLast());
                      } else if (lastAction == 'circle') {
                        redoStack.add(circles.removeLast());
                      } else if (lastAction == 'triangle') {
                        redoStack.add(triangles.removeLast());
                      }
                    });
                  },
          ),
          IconButton(
            icon: const Icon(Icons.redo, color: Colors.black),
            onPressed: redoStack.isEmpty
                ? null
                : () {
                    setState(() {
                      String standardAction = redoActionHistory.removeLast();
                      actionHistory.add(standardAction);
                      var element = redoStack.removeLast();
                      if (standardAction == 'pen') {
                        penLines.add(element as DrawingPath);
                      } else if (standardAction == 'rect') {
                        rectangles.add(element as DrawingRect);
                      } else if (standardAction == 'circle') {
                        circles.add(element as DrawingCircle);
                      } else if (standardAction == 'triangle') {
                        triangles.add(element as DrawingTriangle);
                      }
                    });
                  },
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.red),
            onPressed: () {
              setState(() {
                penLines.clear();
                rectangles.clear();
                circles.clear();
                triangles.clear();
                actionHistory.clear();
                redoStack.clear();
                redoActionHistory.clear();
              });
            },
          ),
        ],
      ),
      body: Stack(
        children: [
         
          GestureDetector(
            onPanStart: (details) {
              setState(() {
                startPoint = details.localPosition;
                currentPoint = details.localPosition;
                if (selectedTool == 'pen' || selectedTool == 'eraser') {
                  currentLinePoints = [details.localPosition];
                }
              });
            },
            onPanUpdate: (details) {
              setState(() {
                currentPoint = details.localPosition;
                if (selectedTool == 'pen' || selectedTool == 'eraser') {
                  currentLinePoints.add(details.localPosition);
                }
              });
            },
            onPanEnd: (_) {
              setState(() {
                if (selectedTool == 'pen' || selectedTool == 'eraser') {
                  if (currentLinePoints.isNotEmpty) {
                    penLines.add(
                      DrawingPath(
                        points: List.from(currentLinePoints),
                        color: selectedTool == 'eraser'
                            ? Colors.white
                            : selectedColor,
                        width: selectedTool == 'eraser'
                            ? (strokeWidth * 3.0)
                            : strokeWidth,
                      ),
                    );
                    actionHistory.add('pen');
                  }
                  currentLinePoints = [];
                } else if (selectedTool == 'rectangle' &&
                    startPoint != null &&
                    currentPoint != null) {
                  rectangles.add(
                    DrawingRect(
                      rect: Rect.fromPoints(startPoint!, currentPoint!),
                      color: selectedColor,
                      width: strokeWidth,
                    ),
                  );
                  actionHistory.add('rect');
                } else if (selectedTool == 'circle' &&
                    startPoint != null &&
                    currentPoint != null) {
                  double radius = (currentPoint! - startPoint!).distance;
                  circles.add(
                    DrawingCircle(
                      center: startPoint!,
                      radius: radius,
                      color: selectedColor,
                      width: strokeWidth,
                    ),
                  );
                  actionHistory.add('circle');
                } else if (selectedTool == 'triangle' &&
                    startPoint != null &&
                    currentPoint != null) {
                  triangles.add(
                    DrawingTriangle(
                      p1: Offset(
                        (startPoint!.dx + currentPoint!.dx) / 2,
                        startPoint!.dy,
                      ),
                      p2: Offset(startPoint!.dx, currentPoint!.dy),
                      p3: currentPoint!,
                      color: selectedColor,
                      width: strokeWidth,
                    ),
                  );
                  actionHistory.add('triangle');
                }

                startPoint = null;
                currentPoint = null;
                redoStack.clear();
                redoActionHistory.clear();
              });
            },
            child: CustomPaint(
              size: Size.infinite,
              painter: WhiteBoardPainter(
                penLines: penLines,
                currentLinePoints: currentLinePoints,
                rectangles: rectangles,
                circles: circles,
                triangles: triangles,
                selectedTool: selectedTool,
                
                selectedColor: selectedTool == 'eraser'
                    ? Colors.white
                    : selectedColor,
                strokeWidth: selectedTool == 'eraser'
                    ? (strokeWidth * 4.0) 
                    : strokeWidth,
              ),
            ),
          ),

          
          Positioned(
            bottom: 20, 
            right: 20,  
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start, 
              mainAxisSize: MainAxisSize.min,
              children: [
                
                if (showShapesMenu) ...[
                  Material(
                    elevation: 5,
                    borderRadius: BorderRadius.circular(12),
                    color: Colors.white,
                    child: Padding(
                      padding: const EdgeInsets.all(4),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.crop_square),
                            onPressed: () => setState(() {
                              selectedTool = 'rectangle';
                              showShapesMenu = false;
                            }),
                          ),
                          IconButton(
                            icon: const Icon(Icons.radio_button_unchecked),
                            onPressed: () => setState(() {
                              selectedTool = 'circle';
                              showShapesMenu = false;
                            }),
                          ),
                          IconButton(
                            icon: const Icon(Icons.change_history),
                            onPressed: () => setState(() {
                              selectedTool = 'triangle';
                              showShapesMenu = false;
                            }),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 8), 
                ],

               
                Material(
                  elevation: 4,
                  borderRadius: BorderRadius.circular(30),
                  color: Colors.grey[50],
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    height: 60,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: Icon(Icons.category,
                              color: (selectedTool == 'circle' ||
                                      selectedTool == 'rectangle' ||
                                      selectedTool == 'triangle')
                                  ? Colors.blue
                                  : Colors.black),
                          onPressed: () =>
                              setState(() => showShapesMenu = !showShapesMenu),
                        ),
                        IconButton(
                          icon: Icon(Icons.edit,
                              color: selectedTool == 'pen'
                                  ? Colors.blue
                                  : Colors.black),
                          onPressed: () => setState(() {
                            selectedTool = 'pen';
                            showShapesMenu = false;
                          }),
                        ),
                        IconButton(
                          icon: Icon(Icons.cleaning_services_outlined,
                              color: selectedTool == 'eraser'
                                  ? Colors.blue
                                  : Colors.black),
                          onPressed: () => setState(() {
                            selectedTool = 'eraser';
                            showShapesMenu = false;
                          }),
                        ),
                        const VerticalDivider(width: 15),
                        ...colorsList.map((color) => GestureDetector(
                              onTap: () => setState(() => selectedColor = color),
                              child: Container(
                                margin: const EdgeInsets.symmetric(horizontal: 4),
                                width: 18,
                                height: 18,
                                decoration: BoxDecoration(
                                  color: color,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                      color: selectedColor == color
                                          ? Colors.black
                                          : Colors.transparent,
                                      width: 2),
                                ),
                              ),
                            )),
                        const VerticalDivider(width: 15),
                        IconButton(
                            icon: const Icon(Icons.horizontal_rule, size: 12),
                            onPressed: () => setState(() => strokeWidth = 3.0)),
                        IconButton(
                            icon: const Icon(Icons.fiber_manual_record, size: 14),
                            onPressed: () => setState(() => strokeWidth = 7.0)),
                        IconButton(
                            icon: const Icon(Icons.fiber_manual_record, size: 20),
                            onPressed: () => setState(() => strokeWidth = 15.0)),
                      ],
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
}