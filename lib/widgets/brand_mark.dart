import 'package:flutter/material.dart';

class BrandMark extends StatelessWidget {
  const BrandMark({this.size = 72, super.key});

  final double size;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Semantics(
      image: true,
      label: 'PuzzleForge',
      child: SizedBox.square(
        dimension: size,
        child: CustomPaint(painter: _BrandMarkPainter(scheme)),
      ),
    );
  }
}

class _BrandMarkPainter extends CustomPainter {
  _BrandMarkPainter(this.scheme);

  final ColorScheme scheme;

  @override
  void paint(Canvas canvas, Size size) {
    final background = Paint()..color = scheme.primary;
    final tile = Paint()..color = scheme.onPrimary;
    final spark = Paint()..color = const Color(0xfff97316);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Offset.zero & size,
        Radius.circular(size.width * 0.24),
      ),
      background,
    );
    final unit = size.width / 7;
    for (final position in const <Offset>[
      Offset(1.2, 1.25),
      Offset(3.7, 1.25),
      Offset(1.2, 3.75),
    ]) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(
            position.dx * unit,
            position.dy * unit,
            2.05 * unit,
            2.05 * unit,
          ),
          Radius.circular(unit * 0.35),
        ),
        tile,
      );
    }
    final center = Offset(size.width * 0.72, size.height * 0.73);
    final path = Path()
      ..moveTo(center.dx, center.dy - unit)
      ..lineTo(center.dx + unit * 0.3, center.dy - unit * 0.3)
      ..lineTo(center.dx + unit, center.dy)
      ..lineTo(center.dx + unit * 0.3, center.dy + unit * 0.3)
      ..lineTo(center.dx, center.dy + unit)
      ..lineTo(center.dx - unit * 0.3, center.dy + unit * 0.3)
      ..lineTo(center.dx - unit, center.dy)
      ..lineTo(center.dx - unit * 0.3, center.dy - unit * 0.3)
      ..close();
    canvas.drawPath(path, spark);
  }

  @override
  bool shouldRepaint(_BrandMarkPainter oldDelegate) =>
      oldDelegate.scheme != scheme;
}
