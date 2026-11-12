import 'package:flutter/material.dart';

/// Rutea's location glyph, intentionally distinct from route and POI markers.
class RuteaLocationMarker extends StatelessWidget {
  const RuteaLocationMarker({
    super.key,
    this.semanticsLabel = 'Ubicación actual',
  });

  final String semanticsLabel;

  @override
  Widget build(BuildContext context) => Semantics(
    label: semanticsLabel,
    image: true,
    child: ExcludeSemantics(
      child: CustomPaint(
        size: Size(32, 38),
        painter: _RuteaLocationMarkerPainter(),
      ),
    ),
  );
}

class _RuteaLocationMarkerPainter extends CustomPainter {
  const _RuteaLocationMarkerPainter();

  static const _violet = Color(0xFF6427C8);
  static const _deepViolet = Color(0xFF3F128F);

  @override
  void paint(Canvas canvas, Size size) {
    final scaleX = size.width / 32;
    final scaleY = size.height / 38;
    canvas.save();
    canvas.scale(scaleX, scaleY);

    final pin = Path()
      ..moveTo(16, 2)
      ..cubicTo(8.3, 2, 2, 8.2, 2, 15.7)
      ..cubicTo(2, 24.2, 11.8, 32.3, 15.1, 35.2)
      ..cubicTo(15.6, 35.7, 16.4, 35.7, 16.9, 35.2)
      ..cubicTo(20.2, 32.3, 30, 24.2, 30, 15.7)
      ..cubicTo(30, 8.2, 23.7, 2, 16, 2)
      ..close();

    canvas.drawShadow(pin, const Color(0x660F1020), 3, true);
    canvas.drawPath(
      pin,
      Paint()
        ..color = Colors.white
        ..style = PaintingStyle.fill,
    );
    canvas.save();
    canvas.clipPath(pin);
    canvas.drawPath(
      pin,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [_violet, _deepViolet],
        ).createShader(const Rect.fromLTWH(0, 0, 32, 38)),
    );

    final mountainAndRoad = Path()
      ..moveTo(7.2, 20.4)
      ..lineTo(12.1, 14.2)
      ..lineTo(15.3, 18.1)
      ..lineTo(19.2, 13.5)
      ..lineTo(24.9, 20.5)
      ..cubicTo(25.7, 21.4, 25.3, 22.5, 24, 22.7)
      ..lineTo(18.5, 23.4)
      ..cubicTo(14.8, 23.9, 13.7, 26, 14.3, 29.1);
    canvas.drawPath(
      mountainAndRoad,
      Paint()
        ..color = Colors.white
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.35
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round,
    );
    canvas.restore();
    canvas.drawPath(
      pin,
      Paint()
        ..color = const Color(0xFFDED2F8)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.15,
    );
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
