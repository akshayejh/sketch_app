import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:sketch_app/draw_point.dart';

class SketchCanvas extends CustomPainter {
  List<DrawPoint> drawPoints;

  SketchCanvas({this.drawPoints});

  @override
  void paint(Canvas canvas, Size size) {
    // For each drawPoint in drawPoints list
    for (int i = 0; i < drawPoints.length; i++) {
      if (i == 0) {
        // Draw a point for the very first Pan event
        canvas.drawPoints(
          PointMode.points,
          [drawPoints[i].position],
          drawPoints[i].paint,
        );
      } else if (drawPoints[i - 1] != null && drawPoints[i] != null) {
        // Check if the current item or the pervious is not null, then draw
        // a line between each points.
        canvas.drawLine(
          drawPoints[i - 1].position,
          drawPoints[i].position,
          drawPoints[i].paint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
