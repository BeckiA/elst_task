import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/formatters.dart';
import '../../domain/entities/asset.dart';
import '../../domain/entities/confirm_buy_summary.dart';

const Color _kSheetBackground = Color(0xFFF5FBFF);

/// Matches asset detail header top tint ([AssetDetailPage] `_kHeaderTopColor`).
const Color _kSheetHeaderTopColor = Color(0xFFE5F4FA);

/// Subtle off-white behind percentage row + keypad ([user spec] ~`#F9F9F9`).

/// Portion of screen height for the sheet (tall card, similar emphasis to a full header region).
const double _kSheetHeightFraction = 0.88;

/// Opens the Buy flow bottom sheet for [asset] at [spotPrice] with optional [cashBalance].
/// Returns a [ConfirmBuySummary] when the user taps Continue.
Future<ConfirmBuySummary?> showBuyCryptoBottomSheet(
  BuildContext context, {
  required Asset asset,
  required double spotPrice,
  double cashBalance = 10_000_000,
}) {
  return showModalBottomSheet<ConfirmBuySummary?>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (ctx) {
      final viewPadding = MediaQuery.paddingOf(ctx);
      final maxH = MediaQuery.sizeOf(ctx).height - viewPadding.top;
      final sheetH = (MediaQuery.sizeOf(ctx).height * _kSheetHeightFraction)
          .clamp(480.0, maxH);
      return Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.viewInsetsOf(ctx).bottom,
        ),
        child: SizedBox(
          height: sheetH,
          child: ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            child: Material(
              color: _kSheetBackground,
              child: BuyCryptoBottomSheet(
                asset: asset,
                spotPrice: spotPrice,
                cashBalance: cashBalance,
              ),
            ),
          ),
        ),
      );
    },
  );
}

class BuyCryptoBottomSheet extends StatefulWidget {
  const BuyCryptoBottomSheet({
    super.key,
    required this.asset,
    required this.spotPrice,
    required this.cashBalance,
  });

  final Asset asset;
  final double spotPrice;
  final double cashBalance;

  @override
  State<BuyCryptoBottomSheet> createState() => _BuyCryptoBottomSheetState();
}

class _BuyCryptoBottomSheetState extends State<BuyCryptoBottomSheet> {
  /// Primary editing buffer: digits-only rupiah string in fiat mode.
  String _fiatBuffer = '';

  /// Editing buffer in crypto mode (optional single `.`).
  String _cryptoBuffer = '';

  bool _fiatInputMode = true;

  int get _maxIdR {
    return widget.cashBalance.floor().clamp(0, 999999999999);
  }

  int get _idRAmount {
    if (_fiatInputMode) {
      if (_fiatBuffer.isEmpty) return 0;
      final v = int.tryParse(_fiatBuffer) ?? 0;
      return math.min(v, _maxIdR);
    }
    final c = double.tryParse(_cryptoBuffer) ?? 0.0;
    if (c <= 0 || widget.spotPrice <= 0) return 0;
    final idr = (c * widget.spotPrice).round();
    return math.min(idr, _maxIdR);
  }

  double get _cryptoAmount {
    if (widget.spotPrice <= 0) return 0;
    return _idRAmount / widget.spotPrice;
  }

  void _toggleInputMode() {
    setState(() {
      if (_fiatInputMode) {
        final idr = _idRAmount;
        final crypto = idr / widget.spotPrice;
        _cryptoBuffer = _formatCryptoInput(crypto);
        _fiatInputMode = false;
      } else {
        _fiatBuffer = _idRAmount == 0 ? '' : _idRAmount.toString();
        _fiatInputMode = true;
      }
    });
  }

  String _formatCryptoInput(double v) {
    if (v == 0) return '';
    var s = v.toStringAsFixed(8);
    s = s.replaceAll(RegExp(r'0+$'), '');
    s = s.replaceAll(RegExp(r'\.$'), '');
    return s;
  }

  void _onDigit(String d) {
    setState(() {
      if (_fiatInputMode) {
        if (_fiatBuffer == '0' && d != '0') {
          _fiatBuffer = d;
        } else {
          final next = _fiatBuffer + d;
          final parsed = int.tryParse(next) ?? 0;
          if (parsed <= _maxIdR) {
            _fiatBuffer = next;
          } else {
            _fiatBuffer = _maxIdR.toString();
          }
        }
      } else {
        if (d == '.') {
          if (_cryptoBuffer.contains('.')) return;
          _cryptoBuffer = _cryptoBuffer.isEmpty ? '0.' : '$_cryptoBuffer.';
          return;
        }
        final next = _cryptoBuffer + d;
        if (_wouldExceedBalance(next)) return;
        _cryptoBuffer = next;
      }
    });
  }

  bool _wouldExceedBalance(String cryptoDraft) {
    if (cryptoDraft == '.' || cryptoDraft.isEmpty) return false;
    final c = double.tryParse(cryptoDraft.endsWith('.')
            ? '${cryptoDraft}0'
            : cryptoDraft) ??
        0;
    if (c <= 0) return false;
    final idr = (c * widget.spotPrice).round();
    return idr > _maxIdR;
  }

  void _onBackspace() {
    setState(() {
      if (_fiatInputMode) {
        if (_fiatBuffer.isEmpty) return;
        _fiatBuffer = _fiatBuffer.substring(0, _fiatBuffer.length - 1);
      } else {
        if (_cryptoBuffer.isEmpty) return;
        _cryptoBuffer =
            _cryptoBuffer.substring(0, _cryptoBuffer.length - 1);
      }
    });
  }

  void _applyPercent(double p) {
    setState(() {
      final idr = (widget.cashBalance * p).round().clamp(0, _maxIdR);
      if (_fiatInputMode) {
        _fiatBuffer = idr == 0 ? '' : idr.toString();
      } else {
        if (widget.spotPrice <= 0) {
          _cryptoBuffer = '';
        } else {
          final c = idr / widget.spotPrice;
          _cryptoBuffer = _formatCryptoInput(c);
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final ticker = widget.asset.ticker;
    final primaryStyle = TextStyle(
      color: AppColors.textPrimary,
      fontSize: 36,
      fontWeight: FontWeight.w800,
      letterSpacing: -0.5,
    );
    final secondaryStyle = TextStyle(
      color: AppColors.textTertiary,
      fontSize: 15,
      fontWeight: FontWeight.w500,
    );

    final idr = _idRAmount;
    final crypto = _cryptoAmount;

    final primaryLine = _fiatInputMode
        ? CurrencyFormatter.formatRupiah(idr.toDouble())
        : '${_formatCryptoDisplay(crypto)} $ticker';

    final secondaryLine = _fiatInputMode
        ? '≈ ${_formatCryptoDisplay(crypto)} $ticker'
        : '≈ ${CurrencyFormatter.formatRupiah(idr.toDouble())}';

    const pillHeight = 52.0;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            width: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  _kSheetHeaderTopColor,
                  _kSheetBackground,
                ],
                stops: [0.0, 1.0],
              ),
            ),
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.sm,
              AppSpacing.md,
              AppSpacing.sm,
              AppSpacing.lg,
            ),
            child: SizedBox(
              height: 96,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: AppColors.textTertiary.withValues(alpha: 0.35),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      Align(
                        alignment: Alignment.centerLeft,
                        child: IconButton(
                          visualDensity: VisualDensity.compact,
                          icon: Icon(
                            LucideIcons.x,
                            color: AppColors.textPrimary,
                            size: 22,
                          ),
                          onPressed: () => Navigator.of(context).pop(),
                        ),
                      ),
                      Text(
                        'Buy $ticker',
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.lg,
                  AppSpacing.md,
                  AppSpacing.lg,
                  AppSpacing.lg,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(
                                primaryLine,
                                textAlign: TextAlign.center,
                                style: primaryStyle,
                              ),
                              const SizedBox(height: AppSpacing.xs),
                              Text(
                                secondaryLine,
                                textAlign: TextAlign.center,
                                style: secondaryStyle,
                              ),
                            ],
                          ),
                        ),
                        InkWell(
                          onTap: _toggleInputMode,
                          borderRadius: BorderRadius.circular(AppRadius.md),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.sm,
                              vertical: AppSpacing.xs,
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  LucideIcons.arrowUpDown,
                                  color: AppColors.primary,
                                  size: 22,
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  ticker,
                                  style: TextStyle(
                                    color: AppColors.primary,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    Text(
                      'Balance: ${CurrencyFormatter.formatRupiah(widget.cashBalance)}',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(AppSpacing.md),
                      decoration: BoxDecoration(
                        color: _kSheetBackground,
                        borderRadius: BorderRadius.circular(AppRadius.lg),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: _PercentPill(
                                  label: '25%',
                                  onTap: () => _applyPercent(0.25),
                                ),
                              ),
                              const SizedBox(width: 6),
                              Expanded(
                                child: _PercentPill(
                                  label: '50%',
                                  onTap: () => _applyPercent(0.5),
                                ),
                              ),
                              const SizedBox(width: 6),
                              Expanded(
                                child: _PercentPill(
                                  label: '75%',
                                  onTap: () => _applyPercent(0.75),
                                ),
                              ),
                              const SizedBox(width: 6),
                              Expanded(
                                child: _PercentPill(
                                  label: '100%',
                                  onTap: () => _applyPercent(1.0),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: AppSpacing.lg),
                          _NumericKeypad(
                            fiatMode: _fiatInputMode,
                            onDigit: _onDigit,
                            onBackspace: _onBackspace,
                            surfaceColor: _kSheetBackground,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    SizedBox(
                      height: pillHeight,
                      width: double.infinity,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          borderRadius:
                              BorderRadius.circular(pillHeight / 2),
                          gradient: const LinearGradient(
                            colors: [
                              AppColors.primaryDark,
                              AppColors.primary,
                              AppColors.primaryLight,
                            ],
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primary
                                  .withValues(alpha: 0.28),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () {
                              final summary = ConfirmBuySummary.fromInputs(
                                asset: widget.asset,
                                spotPrice: widget.spotPrice,
                                amountIdr: _idRAmount,
                              );
                              Navigator.of(context).pop(summary);
                            },
                            borderRadius:
                                BorderRadius.circular(pillHeight / 2),
                            child: const Center(
                              child: Text(
                                'Continue',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatCryptoDisplay(double v) {
    if (v == 0) return '0';
    if (v >= 1) {
      return v.toStringAsFixed(4).replaceFirst(RegExp(r'\.?0+$'), '');
    }
    return v.toStringAsFixed(6).replaceFirst(RegExp(r'\.?0+$'), '');
  }
}

class _PercentPill extends StatelessWidget {
  const _PercentPill({
    required this.label,
    required this.onTap,
  });

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: _kSheetBackground,
      elevation: 0,
      shape: StadiumBorder(
        side: BorderSide(color: AppColors.border.withValues(alpha: 0.6)),
      ),
      child: InkWell(
        onTap: onTap,
        customBorder: const StadiumBorder(),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w700,
                fontSize: 14,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _NumericKeypad extends StatelessWidget {
  const _NumericKeypad({
    required this.fiatMode,
    required this.onDigit,
    required this.onBackspace,
    this.surfaceColor = _kSheetBackground,
  });

  final bool fiatMode;
  final void Function(String) onDigit;
  final VoidCallback onBackspace;
  final Color surfaceColor;

  static const double _keyH = 52;

  @override
  Widget build(BuildContext context) {
    const dividerColor = AppColors.divider;

    Widget keyCell(Widget child) => Expanded(
          child: SizedBox(
            height: _keyH,
            child: Material(
              color: surfaceColor,
              child: child,
            ),
          ),
        );

    return Container(
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: dividerColor.withValues(alpha: 0.5)),
      ),
      clipBehavior: Clip.hardEdge,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (var row = 0; row < 3; row++) ...[
            Row(
              children: [
                for (var col = 0; col < 3; col++) ...[
                  if (col > 0)
                    Container(width: 0.5, height: _keyH, color: dividerColor.withValues(alpha: 0.45)),
                  keyCell(
                    InkWell(
                      onTap: () => onDigit('${row * 3 + col + 1}'),
                      child: Center(
                        child: Text(
                          '${row * 3 + col + 1}',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
            Container(
              height: 0.5,
              color: dividerColor.withValues(alpha: 0.45),
            ),
          ],
          Row(
            children: [
              keyCell(
                fiatMode
                    ? ColoredBox(color: _kSheetBackground)
                    : InkWell(
                        onTap: () => onDigit('.'),
                        child: Center(
                          child: Text(
                            '.',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ),
                      ),
              ),
              Container(width: 0.5, height: _keyH, color: dividerColor.withValues(alpha: 0.45)),
              keyCell(
                InkWell(
                  onTap: () => onDigit('0'),
                  child: Center(
                    child: Text(
                      '0',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                ),
              ),
              Container(width: 0.5, height: _keyH, color: dividerColor.withValues(alpha: 0.45)),
              keyCell(
                InkWell(
                  onTap: onBackspace,
                  child: Center(
                    child: Icon(
                      LucideIcons.delete,
                      color: AppColors.textSecondary,
                      size: 22,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
