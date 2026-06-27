import 'package:flutter/material.dart';

class TCustomCurvedEdges extends CustomClipper<Path> {
  final double progress; // قيمة بين 0.0 و 1.0

  TCustomCurvedEdges({this.progress = 1.0});

  @override
  Path getClip(Size size) {
    var path = Path();
    path.lineTo(0, size.height);

    // الارتفاع الفعلي للمنحنى يتأثر بالـ progress
    final double curveHeight = 20 * progress;

    final firstCurve = Offset(0, size.height - curveHeight);
    final lastCurve = Offset(30, size.height - curveHeight);
    path.quadraticBezierTo(
      firstCurve.dx,
      firstCurve.dy,
      lastCurve.dx,
      lastCurve.dy,
    );

    final secondFirstCurve = Offset(0, size.height - curveHeight);
    final secondLastCurve = Offset(size.width - 30, size.height - curveHeight);
    path.quadraticBezierTo(
      secondFirstCurve.dx,
      secondFirstCurve.dy,
      secondLastCurve.dx,
      secondLastCurve.dy,
    );

    final thirdFirstCurve = Offset(size.width, size.height - curveHeight);
    final thirdLastCurve = Offset(size.width, size.height);
    path.quadraticBezierTo(
      thirdFirstCurve.dx,
      thirdFirstCurve.dy,
      thirdLastCurve.dx,
      thirdLastCurve.dy,
    );

    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant TCustomCurvedEdges oldClipper) =>
      oldClipper.progress != progress;
}
