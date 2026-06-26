import 'package:flutter/animation.dart';

class DrawingPath{
  final List <Offset>points;
  final Color color;
  final double width;
  DrawingPath({required this.points,required this.color,required this.width});
  
}
class DrawingRect{
  final Rect rect;
  final Color color;
  final double width;
  DrawingRect({required this.rect,required this.color,required this.width});
}

class DrawingCircle{
  final Offset center;
  final double radius;
  final Color color;
  final double width;
  DrawingCircle({required this.center,required this.radius,required this.color,required this.width});
}
 class DrawingTriangle{
  final Offset p1;
  final Offset p2;
  final Offset p3;
  final Color color;
  final double width;
  DrawingTriangle({required this.p1,required this.p2,required this.p3,required this.color,required this.width});
 }

