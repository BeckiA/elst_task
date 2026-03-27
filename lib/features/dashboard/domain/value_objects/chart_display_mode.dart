enum ChartDisplayMode {
  candlestick,
  line,
}

extension ChartDisplayModeX on ChartDisplayMode {
  String get label {
    switch (this) {
      case ChartDisplayMode.candlestick:
        return 'Candlestick';
      case ChartDisplayMode.line:
        return 'Line';
    }
  }
}
