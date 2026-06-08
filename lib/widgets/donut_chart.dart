/// A donut (ring) chart for the warranty status breakdown.
///
/// Drawn with a CustomPainter — no chart dependency. Renders one rounded arc
/// segment per non-zero value, with the total shown in the center.
library;

import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../theme.dart';

class DonutSegment {
  const DonutSegment(this.value, this.color);
  final int value;
  final Color color;
}

class DonutChart extends StatelessWidget {
  const DonutChart({
    super.key,
    required this.segments,
    required this.centerValue,
    required this.centerLabel,
    this.size = 150,
    this.strokeWidth = 18,
  });

  final List<DonutSegment> segments;
  final String centerValue;
  final String centerLabel;
  final double size;
  final double strokeWidth;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CustomPaint(
            size: Size(size, size),
            painter: _DonutPainter(segments: segments, strokeWidth: strokeWidth),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                centerValue,
                style: const TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.w800,
                  color: kInk,
                  height: 1.0,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                centerLabel,
                style: const TextStyle(
                    fontSize: 12, color: kMuted, fontWeight: FontWeight.w500),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _DonutPainter extends CustomPainter {
  _DonutPainter({required this.segments, required this.strokeWidth});

  final List<DonutSegment> segments;
  final double strokeWidth;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final center = rect.center;
    final radius = (size.width - strokeWidth) / 2;

    // Track (background ring).
    final track = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..color = const Color(0xFFEFF1F5);
    canvas.drawCircle(center, radius, track);

    final total =
        segments.fold<int>(0, (sum, s) => sum + s.value);
    if (total == 0) return;

    const gap = 0.045; // radians of spacing between segments
    var start = -math.pi / 2; // start at top
    final arcRect = Rect.fromCircle(center: center, radius: radius);

    for (final seg in segments) {
      if (seg.value == 0) continue;
      final fraction = seg.value / total;
      final sweep = fraction * 2 * math.pi - gap;
      if (sweep <= 0) {
        start += fraction * 2 * math.pi;
        continue;
      }
      final paint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round
        ..color = seg.color;
      canvas.drawArc(arcRect, start + gap / 2, sweep, false, paint);
      start += fraction * 2 * math.pi;
    }
  }

  @override
  bool shouldRepaint(_DonutPainter old) =>
      old.segments != segments || old.strokeWidth != strokeWidth;
}
