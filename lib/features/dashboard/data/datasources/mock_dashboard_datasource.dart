import 'dart:math';

import '../models/dashboard_stats_model.dart';
import '../models/asset_model.dart';
import '../models/asset_detail_model.dart';
import '../models/news_article_model.dart';
import '../../domain/entities/asset_detail.dart';
import '../../domain/entities/candlestick.dart';
import '../../domain/entities/portfolio_chart_data.dart';
import '../../domain/value_objects/chart_timeframe.dart';
import '../../domain/value_objects/filter_values.dart';
import '../../../../core/utils/formatters.dart';

abstract class DashboardDataSource {
  Future<DashboardStatsModel> getDashboardStats();
  Future<List<AssetModel>> getAssets({AssetFilterCategory? category});
  Future<AssetDetailModel> getAssetDetail(
    String assetId, {
    required ChartTimeframe timeframe,
  });
  Future<PortfolioChartData> getPortfolioChartData({
    TimeRange range = TimeRange.month,
  });
  Future<List<NewsArticleModel>> getNews();
}

class MockDashboardDataSource implements DashboardDataSource {
  final _random = Random(42);

  @override
  Future<DashboardStatsModel> getDashboardStats() async {
    await Future.delayed(const Duration(milliseconds: 800));
    return const DashboardStatsModel(
      portfolioValue: 8040215,
      totalReturn: 632987,
      returnPercentage: 4.2,
      cryptoBalance: 6289045,
      cashBalance: 1756903,
    );
  }

  List<AssetModel> _allMockAssets() {
    return [
      AssetModel(
        id: '1',
        name: 'Bitcoin',
        ticker: 'BTC',
        iconUrl: 'bitcoin',
        price: 1977644908,
        priceChange: 26036163,
        changePercentage: 4.2,
        sparklineData: _generateSparkline(true),
      ),
      AssetModel(
        id: '2',
        name: 'Tether',
        ticker: 'USDT',
        iconUrl: 'tether',
        price: 16234,
        priceChange: -89,
        changePercentage: -0.55,
        sparklineData: _generateSparkline(false),
      ),
      AssetModel(
        id: '3',
        name: 'Ripple',
        ticker: 'XRP',
        iconUrl: 'xrp',
        price: 46616,
        priceChange: 632987,
        changePercentage: 4.2,
        sparklineData: _generateSparkline(true),
      ),
      AssetModel(
        id: '4',
        name: 'Binance',
        ticker: 'BNB',
        iconUrl: 'binance',
        price: 2850000,
        priceChange: 98500,
        changePercentage: 3.58,
        sparklineData: _generateSparkline(true),
      ),
    ];
  }

  @override
  Future<List<AssetModel>> getAssets({AssetFilterCategory? category}) async {
    await Future.delayed(const Duration(milliseconds: 600));

    final allAssets = _allMockAssets();

    switch (category ?? AssetFilterCategory.trending) {
      case AssetFilterCategory.trending:
        return List<AssetModel>.from(allAssets);
      case AssetFilterCategory.gainers:
        return allAssets.where((a) => a.changePercentage > 0).toList()
          ..sort((a, b) => b.changePercentage.compareTo(a.changePercentage));
      case AssetFilterCategory.losers:
        return allAssets.where((a) => a.changePercentage < 0).toList()
          ..sort((a, b) => a.changePercentage.compareTo(b.changePercentage));
      case AssetFilterCategory.newCoin:
        return allAssets.take(2).toList();
    }
  }

  @override
  Future<AssetDetailModel> getAssetDetail(
    String assetId, {
    required ChartTimeframe timeframe,
  }) async {
    await Future.delayed(const Duration(milliseconds: 450));

    final assets = _allMockAssets();
    final index = assets.indexWhere((a) => a.id == assetId);
    if (index < 0) {
      throw StateError('Unknown asset id: $assetId');
    }
    final asset = assets[index];
    final candles = _buildCandles(asset, timeframe);

    double minY = double.infinity;
    double maxY = double.negativeInfinity;
    for (final c in candles) {
      if (c.low < minY) minY = c.low;
      if (c.high > maxY) maxY = c.high;
    }
    final span = (maxY - minY).abs();
    final pad = span < 1e-6 ? asset.price * 0.02 : span * 0.06;
    final chartMin = minY - pad;
    final chartMax = maxY + pad;

    final chartRangeStart = candles.first.time;
    final chartRangeEnd = candles.last.time;

    final totalAssetValue = asset.price * 5.42;
    final detailStats = _detailStatsFor(asset);
    final aboutText = _aboutForAsset(asset);

    return AssetDetailModel(
      asset: asset,
      candles: candles,
      chartMin: chartMin,
      chartMax: chartMax,
      chartRangeStart: chartRangeStart,
      chartRangeEnd: chartRangeEnd,
      totalAssetValue: totalAssetValue,
      detailStats: detailStats,
      aboutText: aboutText,
    );
  }

  List<Candlestick> _buildCandles(AssetModel asset, ChartTimeframe tf) {
    final seed = asset.id.hashCode + tf.index * 997;
    final rnd = Random(seed);
    final (count, spanDays) = switch (tf) {
      ChartTimeframe.oneDay => (24, 1),
      ChartTimeframe.oneWeek => (28, 7),
      ChartTimeframe.oneMonth => (30, 30),
      ChartTimeframe.threeMonths => (48, 90),
      ChartTimeframe.other => (16, 14),
    };

    final end = DateTime.now();
    final start = end.subtract(Duration(days: spanDays));
    final startMs = start.millisecondsSinceEpoch;
    final endMs = end.millisecondsSinceEpoch;
    final rangeMs = (endMs - startMs).clamp(1, 1 << 62);

    final candles = <Candlestick>[];
    double lastClose = asset.price * (0.94 + rnd.nextDouble() * 0.08);

    for (int i = 0; i < count; i++) {
      final frac = count <= 1 ? 1.0 : i / (count - 1);
      final t = DateTime.fromMillisecondsSinceEpoch(
        (startMs + rangeMs * frac).round(),
      );

      final drift = (rnd.nextDouble() - 0.5) * asset.price * 0.035;
      final open = lastClose;
      var close = open + drift;
      final band = asset.price * 0.12;
      close = close.clamp(asset.price - band, asset.price + band);

      final bodyHigh = max(open, close);
      final bodyLow = min(open, close);
      final high = bodyHigh + rnd.nextDouble() * asset.price * 0.012;
      final low = bodyLow - rnd.nextDouble() * asset.price * 0.012;

      candles.add(
        Candlestick(
          time: t,
          open: open,
          high: high,
          low: low,
          close: close,
        ),
      );
      lastClose = close;
    }

    return candles;
  }

  List<DetailStatRow> _detailStatsFor(AssetModel asset) {
    final cap = CurrencyFormatter.formatRupiah(asset.price * 12_400);
    final vol = CurrencyFormatter.formatRupiah(asset.price * 920);
    return [
      DetailStatRow(label: 'Market cap', value: cap),
      DetailStatRow(label: 'Volume (24h)', value: vol),
      DetailStatRow(label: 'Circulating supply', value: '52,5B ${asset.ticker}'),
      DetailStatRow(
        label: 'All-time high',
        value: CurrencyFormatter.formatRupiah(asset.price * 1.18),
      ),
    ];
  }

  String _aboutForAsset(AssetModel asset) {
    if (asset.ticker == 'XRP') {
      return 'XRP is the native digital asset of the XRP Ledger, an open-source '
          'blockchain engineered for fast, low-cost settlement. Ripple uses XRP '
          'in cross-border liquidity products; prices shown are illustrative mock data.';
    }
    return '${asset.name} (${asset.ticker}) is a digital asset you can trade on '
        'this platform. The information on this screen is mock data for demonstration.';
  }

  @override
  Future<PortfolioChartData> getPortfolioChartData({
    TimeRange range = TimeRange.month,
  }) async {
    await Future.delayed(const Duration(milliseconds: 700));

    // Hardcoded shape factors matching the user's precise snippet exactly
    const shapeFactors = [
      0.20,
      0.18,
      0.22,
      0.19,
      0.15,
      0.23,
      0.27,
      0.35,
      0.40,
      0.45,
      0.40,
      0.48,
      0.50,
      0.42,
      0.46,
      0.43,
      0.40,
      0.38,
      0.45,
      0.41,
      0.39,
      0.42,
      0.48,
      0.50,
      0.48,
      0.52,
      0.50,
      0.49,
      0.46,
      0.43,
      0.75,
      0.78,
      0.60,
      0.58,
      0.58,
      0.75,
      0.72,
      0.78,
      0.83,
      0.70,
      0.78,
      0.75,
      0.80,
      0.75,
      0.78,
      0.82,
      0.78,
      0.80,
      0.81,
      1.00,
      1.10,
      1.15,
      0.95,
      0.95,
      0.85,
      0.88,
      0.75,
      0.50,
      0.55,
      0.48,
      0.55,
      0.56,
      0.55,
      0.88,
      0.85,
      0.88,
      0.80,
      0.82,
      0.92,
      0.94,
      0.20,
      0.18,
      0.22,
      0.19,
      0.15,
      0.23,
      0.27,
      0.35,
      0.40,
      0.45,
      0.40,
      0.48,
      0.50,
      0.42,
      0.46,
      0.43,
      0.40,
      0.38,
      0.45,
      0.41,
      0.39,
      0.42,
      0.48,
      0.50,
      0.48,
      0.52,
      0.50,
      0.49,
      0.46,
      0.43,
      0.75,
      0.78,
      0.60,
      0.58,
      0.58,
      0.75,
      0.72,
      0.78,
      0.83,
      0.70,
      0.78,
      0.75,
      0.80,
      0.75,
      0.78,
      0.82,
      0.78,
      0.80,
      0.81,
      1.00,
      1.10,
      1.15,
      0.95,
      0.95,
      0.85,
      0.88,
      0.75,
      0.50,
      0.55,
      0.48,
      0.55,
      0.56,
      0.55,
      0.88,
      0.85,
      0.88,
      0.80,
      0.82,
      0.92,
      0.94,
    ];

    final int pointCount = shapeFactors.length;
    final points = <PortfolioChartPoint>[];

    // Scale shape to a portfolio value path
    final double startValue = 8040215 - 632987; // Current value - total return
    final double variance = 1000000; // Total height variance

    double minVal = double.infinity;
    double maxVal = double.negativeInfinity;

    for (int i = 0; i < pointCount; i++) {
      // Create a value that perfectly follows the shape array
      final baseValue = startValue + (shapeFactors[i] * variance);

      final date = DateTime.now().subtract(Duration(days: pointCount - i));

      points.add(PortfolioChartPoint(date: date, value: baseValue));
      if (baseValue < minVal) minVal = baseValue;
      if (baseValue > maxVal) maxVal = baseValue;
    }

    return PortfolioChartData(
      points: points,
      minValue: minVal,
      maxValue: maxVal,
    );
  }

  @override
  Future<List<NewsArticleModel>> getNews() async {
    await Future.delayed(const Duration(milliseconds: 400));
    return [
      NewsArticleModel(
        id: 'news-1',
        title: 'Rally Bitcoin Belum Selesai, Target Berikutnya \$150 Ribu',
        imageUrl: 'assets/images/bitcoin_news.png',
        badgeLabel: 'ACADEMY',
        imageCaption: 'Analis: Rally Bitcoin Belum Selesai,',
        imageCaptionLine2: r'Target Berikutnya $150 Ribu',
        publishedAt: DateTime(2025, 9, 15),
      ),
      NewsArticleModel(
        id: 'news-2',
        title: 'INDODAX Market Signal',
        imageUrl: 'assets/images/bull_image.png',
        imageCaption: 'Market outlook minggu ini',
        imageCaptionLine2: 'Fokus pada volatilitas ETH',
        publishedAt: DateTime(2025, 9, 12),
      ),
      NewsArticleModel(
        id: 'news-3',
        title: 'Regulasi Kripto Indonesia: PDNS dan Aset Digital',
        imageUrl: 'https://picsum.photos/seed/id3/400/225',
        imageCaption: 'Update regulasi aset kripto',
        publishedAt: DateTime(2025, 9, 8),
      ),
      NewsArticleModel(
        id: 'news-4',
        title: 'Stablecoin dan Adopsi Institusi di Asia Tenggara',
        imageUrl: 'https://picsum.photos/seed/sea4/400/225',
        imageCaption: 'Tren adoption 2025',
        imageCaptionLine2: 'Institusi menambah eksposur',
        publishedAt: DateTime(2025, 9, 3),
      ),
    ];
  }

  List<double> _generateSparkline(bool uptrend) {
    final points = <double>[];
    double value = 50 + _random.nextDouble() * 50;
    for (int i = 0; i < 20; i++) {
      final change = (_random.nextDouble() - (uptrend ? 0.4 : 0.6)) * 10;
      value += change;
      if (value < 10) value = 10 + _random.nextDouble() * 5;
      if (value > 100) value = 95 - _random.nextDouble() * 5;
      points.add(value);
    }
    return points;
  }
}
