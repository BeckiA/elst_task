import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';

/// Visual assets and brand colors for the dashboard’s supported cryptocurrencies.
class CryptoAssetHelper {
  CryptoAssetHelper._();

  /// Tickers shown in the asset list, in display order.
  static const List<String> listOrder = ['BTC', 'USDT', 'XRP', 'SOL'];

  static String? iconAssetPath(String ticker) {
    switch (ticker.toUpperCase()) {
      case 'BTC':
        return 'assets/icons/bitcoin_icon.png';
      case 'USDT':
        return 'assets/icons/tether_icon.png';
      case 'XRP':
        return 'assets/icons/xrp_icon.png';
      case 'SOL':
        return 'assets/icons/solana_icon.png';
      case 'BNB':
        return 'assets/icons/binance_icon.png';
      default:
        return null;
    }
  }

  /// Accent used when the icon image is missing (letter fallback).
  static Color brandColor(String ticker) {
    switch (ticker.toUpperCase()) {
      case 'BTC':
        return const Color(0xFFF7931A);
      case 'USDT':
        return const Color(0xFF26A17B);
      case 'XRP':
        return const Color(0xFF23292F);
      case 'SOL':
        return const Color(0xFF9945FF);
      default:
        return AppColors.textSecondary;
    }
  }

  static Widget cryptoIcon(String ticker, {double size = 44}) {
    final path = iconAssetPath(ticker);
    if (path != null) {
      return ClipOval(
        child: Image.asset(
          path,
          width: size,
          height: size,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) =>
              _letterFallback(ticker, size),
        ),
      );
    }
    return _letterFallback(ticker, size);
  }

  static Widget _letterFallback(String ticker, double size) {
    final symbol = ticker.isEmpty
        ? '?'
        : ticker.substring(0, ticker.length.clamp(1, 2)).toUpperCase();
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: brandColor(ticker).withValues(alpha: 0.12),
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: Text(
        symbol,
        style: TextStyle(
          color: brandColor(ticker),
          fontSize: size * 0.32,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
