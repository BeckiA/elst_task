import '../../domain/entities/asset.dart';

class AssetModel extends Asset {
  const AssetModel({
    required super.id,
    required super.name,
    required super.ticker,
    required super.iconUrl,
    required super.price,
    required super.priceChange,
    required super.changePercentage,
    required super.sparklineData,
  });

  factory AssetModel.fromJson(Map<String, dynamic> json) {
    return AssetModel(
      id: json['id'] as String,
      name: json['name'] as String,
      ticker: json['ticker'] as String,
      iconUrl: json['icon_url'] as String,
      price: (json['price'] as num).toDouble(),
      priceChange: (json['price_change'] as num).toDouble(),
      changePercentage: (json['change_percentage'] as num).toDouble(),
      sparklineData: (json['sparkline_data'] as List<dynamic>)
          .map((e) => (e as num).toDouble())
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'ticker': ticker,
      'icon_url': iconUrl,
      'price': price,
      'price_change': priceChange,
      'change_percentage': changePercentage,
      'sparkline_data': sparklineData,
    };
  }
}
