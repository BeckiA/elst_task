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
    // CustomPaint with no child defaults to minimum size (~0×0); expand to fill the chart area.
    return SizedBox.expand(
      child: CustomPaint(
        painter: _CandlestickPainter(
          candles: candles,
          minY: minY,
          maxY: maxY,
          referenceY: referenceY,
          upColor: AppColors.positive,
          downColor: AppColors.negative,
          refColor: AppColors.primary,
        ),
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

  static const double _pad = 4;
  static const double _wickWidth = 2.25;
  static const double _bodyWidthFactor = 0.68;

  double _yOf(double v, double chartH, double pad) {
    if (maxY <= minY) return pad + chartH / 2;
    return pad + chartH * (1 - (v - minY) / (maxY - minY));
  }

  @override
  void paint(Canvas canvas, Size size) {
    final chartH = size.height - _pad * 2;
    final chartW = size.width - _pad * 2;

    final yRef = _yOf(referenceY, chartH, _pad);
    _drawDashedLine(
      canvas,
      Offset(_pad, yRef),
      Offset(size.width - _pad, yRef),
      refColor,
    );

    final n = candles.length;
    if (n == 0) return;
    final slot = chartW / n;
    final bodyW = math.min(
      math.max(3.5, slot * _bodyWidthFactor),
      slot * 0.92,
    );

    for (var i = 0; i < n; i++) {
      final c = candles[i];
      final cx = _pad + slot * i + slot / 2;
      final yHigh = _yOf(c.high, chartH, _pad);
      final yLow = _yOf(c.low, chartH, _pad);
      final yOpen = _yOf(c.open, chartH, _pad);
      final yClose = _yOf(c.close, chartH, _pad);
      final color = c.isUp ? upColor : downColor;

      final wick = Paint()
        ..color = color
        ..strokeWidth = _wickWidth
        ..strokeCap = StrokeCap.round
        ..isAntiAlias = true;
      canvas.drawLine(Offset(cx, yHigh), Offset(cx, yLow), wick);

      var top = math.min(yOpen, yClose);
      var bottom = math.max(yOpen, yClose);
      final bodyHeight = (bottom - top).abs();
      if (bodyHeight < 2.5) {
        final mid = (top + bottom) / 2;
        top = mid - 1.25;
        bottom = mid + 1.25;
      }

      final rect = Rect.fromLTRB(cx - bodyW / 2, top, cx + bodyW / 2, bottom);
      final fill = Paint()
        ..color = color
        ..isAntiAlias = true;
      canvas.drawRRect(
        RRect.fromRectAndRadius(rect, const Radius.circular(1.2)),
        fill,
      );
    }
  }

  void _drawDashedLine(Canvas canvas, Offset start, Offset end, Color color) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.25
      ..strokeCap = StrokeCap.round
      ..isAntiAlias = true;
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
