enum ChartTimeframe {
  oneDay,
  oneWeek,
  oneMonth,
  threeMonths,
  other,
}

extension ChartTimeframeX on ChartTimeframe {
  String get label {
    switch (this) {
      case ChartTimeframe.oneDay:
        return '1D';
      case ChartTimeframe.oneWeek:
        return '1W';
      case ChartTimeframe.oneMonth:
        return '1M';
      case ChartTimeframe.threeMonths:
        return '3M';
      case ChartTimeframe.other:
        return 'Other';
    }
  }
}
