 
import 'package:flutter/material.dart';
import 'package:flutter_drawing_board/drwaing_models.dart';

class WhiteBoardPainter extends CustomPainter {
  final List<DrawingPath> penLines;
  final List<Offset> currentLinePoints;
  final List<DrawingRect> rectangles;
  final List<DrawingCircle> circles;
  final List<DrawingTriangle> triangles;

  final Offset? startPoint;
  final Offset? currentPoint;
  final String selectedTool;
  final Color selectedColor;
  final double strokeWidth;

  WhiteBoardPainter({
    required this.penLines,
    required this.currentLinePoints,
    required this.rectangles,
    required this.circles,
    required this.triangles,
    this.startPoint,
    this.currentPoint,
    required this.selectedTool,
    required this.selectedColor,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    
   
    for (var r in rectangles) {
      final paint = Paint()
        ..color = r.color
        ..strokeWidth = r.width
        ..style = PaintingStyle.stroke;
      canvas.drawRect(r.rect, paint);
    }

    for (var c in circles) {
      final paint = Paint()
        ..color = c.color
        ..strokeWidth = c.width
        ..style = PaintingStyle.stroke;
      canvas.drawCircle(c.center, c.radius, paint);
    }

   
    for (var t in triangles) {
      final paint = Paint()
        ..color = t.color
        ..strokeWidth = t.width
        ..style = PaintingStyle.stroke;
      var path = Path()
        ..moveTo(t.p1.dx, t.p1.dy)
        ..lineTo(t.p2.dx, t.p2.dy)
        ..lineTo(t.p3.dx, t.p3.dy)
        ..close();
      canvas.drawPath(path, paint);
    }

   
    for (var line in penLines) {
      final paint = Paint()
        ..color = line.color
        ..strokeWidth = line.width
        ..strokeCap = StrokeCap.round
        ..style = PaintingStyle.stroke;
      for (int i = 0; i < line.points.length - 1; i++) {
        canvas.drawLine(line.points[i], line.points[i + 1], paint);
      }
    }

    
    final livePaint = Paint()
      ..color = selectedColor
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    if ((selectedTool == 'pen' || selectedTool == 'eraser') && currentLinePoints.isNotEmpty) {
      for (int i = 0; i < currentLinePoints.length - 1; i++) {
        canvas.drawLine(currentLinePoints[i], currentLinePoints[i + 1], livePaint);
      }
    } else if (selectedTool == 'rectangle' && startPoint != null && currentPoint != null) {
      canvas.drawRect(Rect.fromPoints(startPoint!, currentPoint!), livePaint);
    } else if (selectedTool == 'circle' && startPoint != null && currentPoint != null) {
      double radius = (currentPoint! - startPoint!).distance;
      canvas.drawCircle(startPoint!, radius, livePaint);
    } else if (selectedTool == 'triangle' && startPoint != null && currentPoint != null) {
      var path = Path()
        ..moveTo((startPoint!.dx + currentPoint!.dx) / 2, startPoint!.dy)
        ..lineTo(startPoint!.dx, currentPoint!.dy)
        ..lineTo(currentPoint!.dx, currentPoint!.dy)
        ..close();
      canvas.drawPath(path, livePaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
