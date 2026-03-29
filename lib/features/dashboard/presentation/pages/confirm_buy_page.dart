import 'dart:ui' show ImageFilter;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/formatters.dart';
import '../../domain/entities/confirm_buy_summary.dart';
import '../helpers/crypto_asset_helper.dart';

/// Page background (user spec).
const Color _kPageBackground = Color(0xFFFCFFFE);

/// Same light blue as [AssetDetailPage] header (`_kHeaderTopColor`).
const Color _kHeaderTopColor = Color(0xFFE5F4FA);

/// Slide panel gradient (bottom-left → top-right).
const Color _kSlideGradientStart = Color(0xFF169FD0);
const Color _kSlideGradientEnd = Color(0xFF0DCBED);

const double _kSuccessHeaderCurve = 28;
const double _kSuccessHeaderOverlap = 14;

String _formatCryptoAmount(double v) {
  if (v == 0) return '0';
  var s = v.toStringAsFixed(8);
  s = s.replaceAll(RegExp(r'0+$'), '');
  s = s.replaceAll(RegExp(r'\.$'), '');
  return s;
}

class ConfirmBuyPage extends StatefulWidget {
  const ConfirmBuyPage({super.key, required this.summary});

  final ConfirmBuySummary summary;

  static Route<void> route(ConfirmBuySummary summary) {
    return MaterialPageRoute<void>(
      builder: (context) => ConfirmBuyPage(summary: summary),
    );
  }

  @override
  State<ConfirmBuyPage> createState() => _ConfirmBuyPageState();
}

class _ConfirmBuyPageState extends State<ConfirmBuyPage> {
  bool _showSuccess = false;

  @override
  Widget build(BuildContext context) {
    if (_showSuccess) {
      return _OrderSuccessView(
        summary: widget.summary,
        onDone: () => Navigator.of(context).pop(),
      );
    }

    final topInset = MediaQuery.paddingOf(context).top;
    final bodyTopPadding = topInset + kToolbarHeight + AppSpacing.xl;

    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: _kPageBackground,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        leading: IconButton(
          icon: Icon(LucideIcons.moveLeft, color: AppColors.textPrimary),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        title: Text(
          'Confirm Buy',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 17,
            fontWeight: FontWeight.w700,
          ),
        ),
        centerTitle: true,
      ),
      body: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              _kHeaderTopColor,
              Color.lerp(_kHeaderTopColor, _kPageBackground, 0.45)!,
              _kPageBackground,
            ],
            stops: const [0.0, 0.14, 0.28],
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(
                  AppSpacing.xl,
                  bodyTopPadding,
                  AppSpacing.xl,
                  AppSpacing.lg,
                ),
                child: Column(
                  children: [
                    CryptoAssetHelper.cryptoIcon(widget.summary.ticker, size: 88),
                    const SizedBox(height: AppSpacing.xxl),
                    Text(
                      'Buy ${widget.summary.ticker}',
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xxxl),
                    _SummaryCard(summary: widget.summary),
                    const SizedBox(height: AppSpacing.lg),
                    Text(
                      'I understand that I won\'t be able to withdraw this purchase for 72 hours.',
                      textAlign: TextAlign.start,
                      style: TextStyle(
                        color: AppColors.textTertiary,
                        fontSize: 12,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xxl),
                  ],
                ),
              ),
            ),
            SlideToConfirmPanel(
              onConfirmed: () {
                setState(() => _showSuccess = true);
              },
            ),
          ],
        ),
      ),
    );
  }
}

/// Order success: cyan curved header, pale sheet, Indodax watermark, bowl + glass blur behind [success.svg].
class _OrderSuccessView extends StatelessWidget {
  const _OrderSuccessView({
    required this.summary,
    required this.onDone,
  });

  final ConfirmBuySummary summary;
  final VoidCallback onDone;

  @override
  Widget build(BuildContext context) {
    const pillHeight = 45.0;
    final amountStr = _formatCryptoAmount(summary.cryptoAmount);
    final topPad = MediaQuery.paddingOf(context).top;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: AppColors.liteHeaderGradientTop,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: AppColors.liteHeaderGradientBottom,
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              width: double.infinity,
              padding: EdgeInsets.only(top: topPad, bottom: 20),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    AppColors.liteHeaderGradientTop,
                    AppColors.liteHeaderGradientBottom,
                  ],
                ),
                borderRadius: BorderRadius.vertical(
                  bottom: Radius.circular(_kSuccessHeaderCurve),
                ),
              ),
              child: const SizedBox(height: 4),
            ),
            Expanded(
              child: Transform.translate(
                offset: const Offset(0, -_kSuccessHeaderOverlap),
                child: ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(_kSuccessHeaderCurve),
                  ),
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          _kHeaderTopColor,
                          Color.lerp(_kHeaderTopColor, _kPageBackground, 0.55)!,
                          _kPageBackground,
                        ],
                        stops: const [0.0, 0.38, 1.0],
                      ),
                    ),
                    child: Stack(
                      children: [
                        Positioned(
                          top: MediaQuery.sizeOf(context).height * 0.04,
                          left: 0,
                          right: 0,
                          child: IgnorePointer(
                            child: Opacity(
                              opacity: 0.1,
                              child: Center(
                                child: Image.asset(
                                  'assets/icons/indodax_logo.png',
                                  width: 280,
                                  fit: BoxFit.contain,
                                ),
                              ),
                            ),
                          ),
                        ),
                        Column(
                          children: [
                            Expanded(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const _GlassSuccessIcon(),
                                  const SizedBox(height: AppSpacing.xxl),
                                  Text(
                                    'Order Successful',
                                    style: TextStyle(
                                      color: AppColors.textPrimary,
                                      fontSize: 22,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                  const SizedBox(height: AppSpacing.md),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: AppSpacing.xl,
                                    ),
                                    child: Text(
                                      'You bought $amountStr worth of ${summary.ticker}',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        color: AppColors.textSecondary,
                                        fontSize: 15,
                                        fontWeight: FontWeight.w500,
                                        height: 1.35,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: AppSpacing.xl,
                              ),
                              child: SizedBox(
                                width: double.infinity,
                                height: pillHeight,
                                child: DecoratedBox(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(
                                      pillHeight / 2,
                                    ),
                                    gradient: const LinearGradient(
                                      colors: [
                                        AppColors.primaryDark,
                                        AppColors.primary,
                                        AppColors.primaryLight,
                                      ],
                                      begin: Alignment.centerLeft,
                                      end: Alignment.centerRight,
                                    ),
                                  ),
                                  child: Material(
                                    color: Colors.transparent,
                                    child: InkWell(
                                      onTap: onDone,
                                      borderRadius: BorderRadius.circular(
                                        pillHeight / 2,
                                      ),
                                      child: const Center(
                                        child: Text(
                                          'Done',
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
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GlassSuccessIcon extends StatelessWidget {
  const _GlassSuccessIcon();

  static const double _diameter = 150;
  static const double _bowlWidth = 300;
  static const double _bowlHeight = 172;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: _diameter,
      height: _diameter,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.topCenter,
        children: [
          Positioned(
            top: -10,
            left: 0,
            right: 0,
            height: _bowlHeight,
              child: ClipPath(
                clipper: ShapeBorderClipper(shape: CircleBorder()),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        AppColors.primary.withValues(alpha: 0.52),
                        AppColors.primary.withValues(alpha: 0.26),
                        AppColors.primaryLight.withValues(alpha: 0.14),
                        Colors.white.withValues(alpha: 0.22),
                      ],
                      stops: const [0.0, 0.35, 0.65, 1.0],
                    ),
                  ),
                ),
              ),
            ),
          ),
          SizedBox(
            width: _diameter,
            height: _diameter,
            child: Stack(
              alignment: Alignment.center,
              clipBehavior: Clip.none,
              children: [
                
                ClipOval(
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
                    child: Container(
                      width: _diameter,
                      height: _diameter,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withValues(alpha: 0.4),
                      ),
                    ),
                  ),
                ),
                SvgPicture.asset(
                  'assets/svgs/success.svg',
                  width: 88,
                  height: 88,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}



class _SummaryCard extends StatelessWidget {
  const _SummaryCard({required this.summary});

  final ConfirmBuySummary summary;

  @override
  Widget build(BuildContext context) {
    final cryptoStr = _formatCryptoAmount(summary.cryptoAmount);
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.xl,
        vertical: AppSpacing.xl,
      ),
      child: Column(
        children: [
          _row(
            'Number of ${summary.ticker}',
            cryptoStr,
            valueBold: true,
            labelMuted: false,
          ),
          const SizedBox(height: AppSpacing.md),
          _row(
            'Buy Price',
            CurrencyFormatter.formatRupiah(summary.buyPricePerUnitIdr),
            valueBold: true,
            labelMuted: false,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
            child: Divider(height: 1, color: AppColors.divider),
          ),
          _row(
            'Amount',
            CurrencyFormatter.formatRupiah(summary.amountIdr.toDouble()),
            labelMuted: true,
          ),
          const SizedBox(height: AppSpacing.md),
          _row(
            'Transaction Fee',
            CurrencyFormatter.formatRupiah(summary.transactionFeeIdr),
            labelMuted: true,
          ),
          const SizedBox(height: AppSpacing.md),
          _row(
            'Tax',
            CurrencyFormatter.formatRupiah(summary.taxIdr),
            labelMuted: true,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
            child: Divider(height: 1, color: AppColors.divider),
          ),
          _row(
            'To Be Paid',
            CurrencyFormatter.formatRupiah(summary.totalToPayIdr),
            valueBold: true,
            valueColor: AppColors.primary,
            labelMuted: false,
          ),
        ],
      ),
    );
  }

  Widget _row(
    String label,
    String value, {
    bool valueBold = false,
    bool labelMuted = false,
    Color? valueColor,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              color: labelMuted ? AppColors.textTertiary : AppColors.textPrimary,
              fontSize: 14,
              fontWeight: labelMuted ? FontWeight.w500 : FontWeight.w600,
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: TextStyle(
              color: valueColor ?? AppColors.textPrimary,
              fontSize: 14,
              fontWeight: valueBold ? FontWeight.w800 : FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}

/// Pull upward to reveal gradient; complete past threshold or fast fling to confirm.
class SlideToConfirmPanel extends StatefulWidget {
  const SlideToConfirmPanel({
    super.key,
    required this.onConfirmed,
  });

  final VoidCallback onConfirmed;

  @override
  State<SlideToConfirmPanel> createState() => _SlideToConfirmPanelState();
}

class _SlideToConfirmPanelState extends State<SlideToConfirmPanel>
    with SingleTickerProviderStateMixin {
  double _progress = 0;
  bool _didConfirm = false;
  late AnimationController _snapController;
  double _snapStart = 0;
  double _snapEnd = 0;

  static const double _minHeight = 80;
  static const double _dragSensitivity = 150;
  static const double _confirmThreshold = 0.88;
  static const double _flingVelocity = 750;

  double _maxExtraHeight(BuildContext context) {
    final h = MediaQuery.sizeOf(context).height;
    return (h - _minHeight).clamp(0.0, double.infinity);
  }

  @override
  void initState() {
    super.initState();
    _snapController = AnimationController(vsync: this)
      ..addListener(_onSnapTick)
      ..addStatusListener(_onSnapStatus);
  }

  void _onSnapTick() {
    if (!mounted) return;
    final t = Curves.easeOutCubic.transform(_snapController.value);
    setState(() {
      _progress = _snapStart + (_snapEnd - _snapStart) * t;
    });
  }

  void _onSnapStatus(AnimationStatus status) {
    if (status != AnimationStatus.completed) return;
    if ((_snapEnd - 1.0).abs() < 0.001 && !_didConfirm) {
      _didConfirm = true;
      widget.onConfirmed();
    }
  }

  void _animateProgressTo(double target) {
    _snapStart = _progress;
    _snapEnd = target.clamp(0.0, 1.0);
    final delta = (_snapEnd - _snapStart).abs();
    final durationMs = (delta * 280 + 120).round().clamp(180, 280);
    _snapController.duration = Duration(milliseconds: durationMs);
    _snapController.forward(from: 0);
  }

  @override
  void dispose() {
    _snapController
      ..removeListener(_onSnapTick)
      ..removeStatusListener(_onSnapStatus)
      ..dispose();
    super.dispose();
  }

  void _onDragUpdate(DragUpdateDetails d) {
    if (_snapController.isAnimating) {
      _snapController.stop();
    }
    setState(() {
      _progress =
          (_progress - d.delta.dy / _dragSensitivity).clamp(0.0, 1.0);
    });
  }

  void _onDragEnd(DragEndDetails d) {
    if (_didConfirm) return;
    final v = d.velocity.pixelsPerSecond.dy;
    final fastUpFling = v < -_flingVelocity;
    final shouldCommit = _progress >= _confirmThreshold || fastUpFling;

    if (shouldCommit) {
      _animateProgressTo(1.0);
    } else {
      _animateProgressTo(0.0);
    }
  }

  @override
  Widget build(BuildContext context) {
    final extra = _maxExtraHeight(context);
    final h = _minHeight + _progress * extra;

    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      child: SizedBox(
        height: h,
        width: double.infinity,
        child: GestureDetector(
          onVerticalDragUpdate: _onDragUpdate,
          onVerticalDragEnd: _onDragEnd,
          behavior: HitTestBehavior.opaque,
          child: DecoratedBox(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.bottomLeft,
                end: Alignment.topRight,
                colors: [
                  _kSlideGradientStart,
                  _kSlideGradientEnd,
                ],
              ),
            ),
            child: SafeArea(
              top: false,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    LucideIcons.chevronsUp,
                    color: Colors.white.withValues(alpha: 0.95),
                    size: 18,
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Text(
                    'Slide to Confirm',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.98),
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
