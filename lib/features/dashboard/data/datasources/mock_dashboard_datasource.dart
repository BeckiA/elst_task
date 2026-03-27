import 'dart:math';

import '../models/dashboard_stats_model.dart';
import '../models/asset_model.dart';
import '../models/activity_model.dart';
import '../../domain/entities/activity.dart';
import '../../domain/entities/portfolio_chart_data.dart';
import '../../domain/value_objects/filter_values.dart';

abstract class DashboardDataSource {
  Future<DashboardStatsModel> getDashboardStats();
  Future<List<AssetModel>> getAssets({AssetFilterCategory? category});
  Future<List<ActivityModel>> getRecentActivities({
    int page = 0,
    int limit = 20,
  });
  Future<PortfolioChartData> getPortfolioChartData({
    TimeRange range = TimeRange.month,
  });
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

  @override
  Future<List<AssetModel>> getAssets({AssetFilterCategory? category}) async {
    await Future.delayed(const Duration(milliseconds: 600));

    final allAssets = [
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
        name: 'Ethereum',
        ticker: 'ETH',
        iconUrl: 'ethereum',
        price: 48250000,
        priceChange: 1250000,
        changePercentage: 2.66,
        sparklineData: _generateSparkline(true),
      ),
      AssetModel(
        id: '3',
        name: 'Solana',
        ticker: 'SOL',
        iconUrl: 'solana',
        price: 2850000,
        priceChange: -125000,
        changePercentage: -4.2,
        sparklineData: _generateSparkline(false),
      ),
      AssetModel(
        id: '4',
        name: 'Cardano',
        ticker: 'ADA',
        iconUrl: 'cardano',
        price: 9500,
        priceChange: 320,
        changePercentage: 3.49,
        sparklineData: _generateSparkline(true),
      ),
      AssetModel(
        id: '5',
        name: 'Polygon',
        ticker: 'MATIC',
        iconUrl: 'polygon',
        price: 14200,
        priceChange: -580,
        changePercentage: -3.92,
        sparklineData: _generateSparkline(false),
      ),
      AssetModel(
        id: '6',
        name: 'Ripple',
        ticker: 'XRP',
        iconUrl: 'ripple',
        price: 8900,
        priceChange: 156,
        changePercentage: 1.78,
        sparklineData: _generateSparkline(true),
      ),
      AssetModel(
        id: '7',
        name: 'Dogecoin',
        ticker: 'DOGE',
        iconUrl: 'dogecoin',
        price: 1250,
        priceChange: 95,
        changePercentage: 8.23,
        sparklineData: _generateSparkline(true),
      ),
      AssetModel(
        id: '8',
        name: 'Avalanche',
        ticker: 'AVAX',
        iconUrl: 'avalanche',
        price: 552000,
        priceChange: -12400,
        changePercentage: -2.19,
        sparklineData: _generateSparkline(false),
      ),
    ];

    if (category == null || category == AssetFilterCategory.trading) {
      return allAssets;
    }

    switch (category) {
      case AssetFilterCategory.gainers:
        return allAssets.where((a) => a.changePercentage > 0).toList()
          ..sort((a, b) => b.changePercentage.compareTo(a.changePercentage));
      case AssetFilterCategory.losers:
        return allAssets.where((a) => a.changePercentage < 0).toList()
          ..sort((a, b) => a.changePercentage.compareTo(b.changePercentage));
      case AssetFilterCategory.newCoin:
        return allAssets.take(3).toList();
      default:
        return allAssets;
    }
  }

  @override
  Future<List<ActivityModel>> getRecentActivities({
    int page = 0,
    int limit = 20,
  }) async {
    await Future.delayed(const Duration(milliseconds: 500));
    final now = DateTime.now();

    return [
      ActivityModel(
        id: '1',
        title: 'Bought Bitcoin',
        description: 'Market order executed',
        amount: 500000,
        timestamp: now.subtract(const Duration(minutes: 30)),
        type: ActivityType.buy,
        assetTicker: 'BTC',
      ),
      ActivityModel(
        id: '2',
        title: 'Sold Ethereum',
        description: 'Limit order filled',
        amount: 250000,
        timestamp: now.subtract(const Duration(hours: 2)),
        type: ActivityType.sell,
        assetTicker: 'ETH',
      ),
      ActivityModel(
        id: '3',
        title: 'Deposit',
        description: 'Bank transfer received',
        amount: 1000000,
        timestamp: now.subtract(const Duration(hours: 5)),
        type: ActivityType.deposit,
      ),
      ActivityModel(
        id: '4',
        title: 'Staking Reward',
        description: 'SOL staking reward',
        amount: 15000,
        timestamp: now.subtract(const Duration(days: 1)),
        type: ActivityType.reward,
        assetTicker: 'SOL',
      ),
      ActivityModel(
        id: '5',
        title: 'Bought Cardano',
        description: 'Market order executed',
        amount: 100000,
        timestamp: now.subtract(const Duration(days: 1, hours: 4)),
        type: ActivityType.buy,
        assetTicker: 'ADA',
      ),
      ActivityModel(
        id: '6',
        title: 'Withdrawal',
        description: 'To external wallet',
        amount: 300000,
        timestamp: now.subtract(const Duration(days: 2)),
        type: ActivityType.withdraw,
      ),
      ActivityModel(
        id: '7',
        title: 'Bought Ripple',
        description: 'Market order executed',
        amount: 75000,
        timestamp: now.subtract(const Duration(days: 3)),
        type: ActivityType.buy,
        assetTicker: 'XRP',
      ),
      ActivityModel(
        id: '8',
        title: 'Referral Reward',
        description: 'Referral bonus credited',
        amount: 50000,
        timestamp: now.subtract(const Duration(days: 4)),
        type: ActivityType.reward,
      ),
    ];
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
