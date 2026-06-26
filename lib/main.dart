 import 'package:flutter/material.dart';
import 'package:flutter_drawing_board/drwaing_models.dart';
import 'package:flutter_drawing_board/whiteboard_UI.dart';     
import 'whiteboard_painter.dart';  


void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: WhiteBoardUI(),
    );
  }
}

