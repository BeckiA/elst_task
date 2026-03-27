enum AssetMarketTab {
  market,
  orderBook,
  trades,
  transactions,
  extra,
}

extension AssetMarketTabX on AssetMarketTab {
  String get label {
    switch (this) {
      case AssetMarketTab.market:
        return 'Market';
      case AssetMarketTab.orderBook:
        return 'Order Book';
      case AssetMarketTab.trades:
        return 'Trades';
      case AssetMarketTab.transactions:
        return 'Transactions';
      case AssetMarketTab.extra:
        return 'Extra';
    }
  }
}
