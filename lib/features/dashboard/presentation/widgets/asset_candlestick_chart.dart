import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../../domain/entities/candlestick.dart';

/// Candlestick series with optional horizontal reference line (e.g. last close).
class AssetCandlestickChart extends StatelessWidget {
  final List<Candlestick> candles;
  final double minY;
  final double maxY;
  final double referenceY;

  const AssetCandlestickChart({
    super.key,
    required this.candles,
    required this.minY,
    required this.maxY,
    required this.referenceY,
  });

  @override
  Widget build(BuildContext context) {
    if (candles.isEmpty) {
      return const SizedBox.expand();
    }
    return CustomPaint(
      painter: _CandlestickPainter(
        candles: candles,
        minY: minY,
        maxY: maxY,
        referenceY: referenceY,
        upColor: AppColors.positive,
        downColor: AppColors.negative,
        refColor: AppColors.primary,
      ),
    );
  }
}

class _CandlestickPainter extends CustomPainter {
  _CandlestickPainter({
    required this.candles,
    required this.minY,
    required this.maxY,
    required this.referenceY,
    required this.upColor,
    required this.downColor,
    required this.refColor,
  });

  final List<Candlestick> candles;
  final double minY;
  final double maxY;
  final double referenceY;
  final Color upColor;
  final Color downColor;
  final Color refColor;

  double _yOf(double v, double chartH, double pad) {
    if (maxY <= minY) return pad + chartH / 2;
    return pad + chartH * (1 - (v - minY) / (maxY - minY));
  }

  @override
  void paint(Canvas canvas, Size size) {
    const pad = 6.0;
    final chartH = size.height - pad * 2;
    final chartW = size.width - pad * 2;

    final yRef = _yOf(referenceY, chartH, pad);
    _drawDashedLine(
      canvas,
      Offset(pad, yRef),
      Offset(size.width - pad, yRef),
      refColor,
    );

    final n = candles.length;
    if (n == 0) return;
    final slot = chartW / n;
    final bodyW = math.max(2.0, slot * 0.5);

    for (var i = 0; i < n; i++) {
      final c = candles[i];
      final cx = pad + slot * i + slot / 2;
      final yHigh = _yOf(c.high, chartH, pad);
      final yLow = _yOf(c.low, chartH, pad);
      final yOpen = _yOf(c.open, chartH, pad);
      final yClose = _yOf(c.close, chartH, pad);
      final color = c.isUp ? upColor : downColor;
      final wick = Paint()
        ..color = color
        ..strokeWidth = 1.2
        ..strokeCap = StrokeCap.round;
      canvas.drawLine(Offset(cx, yHigh), Offset(cx, yLow), wick);

      var top = math.min(yOpen, yClose);
      var bottom = math.max(yOpen, yClose);
      if ((bottom - top) < 1) {
        bottom = top + 1;
      }
      final rect = Rect.fromLTRB(cx - bodyW / 2, top, cx + bodyW / 2, bottom);
      canvas.drawRect(rect, Paint()..color = color);
    }
  }

  void _drawDashedLine(Canvas canvas, Offset start, Offset end, Color color) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1
      ..strokeCap = StrokeCap.round;
    final dx = end.dx - start.dx;
    final dy = end.dy - start.dy;
    final len = math.sqrt(dx * dx + dy * dy);
    if (len < 1e-6) return;
    final ux = dx / len;
    final uy = dy / len;
    const dash = 6.0;
    const gap = 4.0;
    var t = 0.0;
    while (t < len) {
      final t2 = math.min(t + dash, len);
      canvas.drawLine(
        Offset(start.dx + ux * t, start.dy + uy * t),
        Offset(start.dx + ux * t2, start.dy + uy * t2),
        paint,
      );
      t = t2 + gap;
    }
  }

  @override
  bool shouldRepaint(covariant _CandlestickPainter oldDelegate) {
    return oldDelegate.candles.length != candles.length ||
        oldDelegate.minY != minY ||
        oldDelegate.maxY != maxY ||
        oldDelegate.referenceY != referenceY;
  }
}
