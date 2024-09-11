import 'package:doodle/models/touch_points.dart';
import 'package:flutter/material.dart';
import 'dart:ui' as ui;


class MyCustomPainter extends CustomPainter {
  MyCustomPainter({required this.pointsList});
  List<TouchPoints> pointsList;
  List<Offset> offsetPoints = [];

  @override
  void paint(Canvas canvas, Size size) {
    Paint background = Paint()..color = Colors.white;
    Rect rect = Rect.fromLTWH(0, 0, size.width, size.height);
    canvas.drawRect(rect, background);
    canvas.clipRect(rect);

    // Logic for points, if theres a point, we need to display point
    // if there is line, we need to connect the points

    for(int i=0; i<pointsList.length -1 ; i++) {
      // This is a line
      canvas.drawLine(pointsList[i].points, pointsList[i+1].points, pointsList[i].paint);
        }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate)  => true;
}