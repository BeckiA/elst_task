import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/formatters.dart';
import '../../domain/entities/asset.dart';
import '../../domain/entities/asset_detail.dart';
import '../../domain/usecases/get_asset_detail.dart';
import '../../domain/value_objects/asset_market_tab.dart';
import '../../domain/value_objects/chart_display_mode.dart';
import '../../domain/value_objects/chart_timeframe.dart';
import '../bloc/asset_detail_bloc.dart';
import '../bloc/asset_detail_event.dart';
import '../bloc/asset_detail_state.dart';
import '../helpers/crypto_asset_helper.dart';
import '../widgets/asset_candlestick_chart.dart';
import '../widgets/buy_crypto_bottom_sheet.dart';
import 'confirm_buy_page.dart';

/// Header area (behind transparent app bar + title block) uses this at scroll offset 0,
/// then lerps to [AppColors.surface] as the user scrolls.
const Color _kHeaderTopColor = Color(0xFFE5F4FA);
const double _kHeaderColorScrollExtent = 96;

class AssetDetailPage extends StatefulWidget {
  const AssetDetailPage({super.key});

  static Route<void> route(Asset asset) {
    return MaterialPageRoute<void>(
      builder: (context) => BlocProvider(
        create: (_) => AssetDetailBloc(
          getAssetDetail: GetAssetDetail(dashboardRepository),
        )..add(LoadAssetDetail(asset)),
        child: const AssetDetailPage(),
      ),
    );
  }

  @override
  State<AssetDetailPage> createState() => _AssetDetailPageState();
}

class _AssetDetailPageState extends State<AssetDetailPage> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() => setState(() {});

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  Color _headerSurfaceColor(AssetDetailState state) {
    if (state is! AssetDetailLoaded) return _kHeaderTopColor;
    if (!_scrollController.hasClients) return _kHeaderTopColor;
    final t = (_scrollController.offset / _kHeaderColorScrollExtent)
        .clamp(0.0, 1.0);
    return Color.lerp(_kHeaderTopColor, AppColors.surface, t)!;
  }

  BoxDecoration _headerSectionDecoration(Color topColor) {
    return BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          topColor,
          Color.lerp(topColor, AppColors.surface, 0.35)!,
          AppColors.surface,
        ],
        stops: const [0.0, 0.55, 1.0],
      ),
    );
  }

  EdgeInsets _headerSectionPadding(BuildContext context) {
    return EdgeInsets.fromLTRB(
      AppSpacing.xl,
      MediaQuery.paddingOf(context).top + kToolbarHeight,
      AppSpacing.xl,
      AppSpacing.lg,
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AssetDetailBloc, AssetDetailState>(
      builder: (context, state) {
        final asset = _assetForState(state);
        return Scaffold(
          extendBodyBehindAppBar: true,
          backgroundColor: AppColors.surface,
          appBar: _appBar(context, state),
          body: asset == null
              ? const Center(child: CircularProgressIndicator())
              : _body(context, state, asset),
        );
      },
    );
  }

  Asset? _assetForState(AssetDetailState state) {
    return switch (state) {
      AssetDetailLoading(:final asset) => asset,
      AssetDetailLoaded(:final detail) => detail.asset,
      AssetDetailError(:final asset) => asset,
      _ => null,
    };
  }

  PreferredSizeWidget _appBar(BuildContext context, AssetDetailState state) {
    final isFav = state is AssetDetailLoaded && state.isFavorite;
    return AppBar(
      backgroundColor: Colors.transparent,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
      systemOverlayStyle: SystemUiOverlayStyle.dark,
      leading: IconButton(
        icon: Icon(LucideIcons.moveLeft, color: AppColors.textPrimary),
        onPressed: () => Navigator.of(context).maybePop(),
      ),
      actions: [
        IconButton(
          icon: Icon(LucideIcons.fileSearch2, color: AppColors.textPrimary),
          onPressed: () {},
        ),
        IconButton(
          icon: Icon(LucideIcons.externalLink, color: AppColors.textPrimary),
          onPressed: () {},
        ),
        IconButton(
          icon: Icon(
            isFav ? Icons.star_rounded : LucideIcons.star,
            color: isFav ? AppColors.warning : AppColors.textPrimary,
          ),
          onPressed: () {
            context.read<AssetDetailBloc>().add(const ToggleAssetFavorite());
          },
        ),
        const SizedBox(width: AppSpacing.sm),
      ],
    );
  }

  Widget _body(
    BuildContext context,
    AssetDetailState state,
    Asset asset,
  ) {
    return switch (state) {
      AssetDetailLoading() => _loadingLayout(context, state),
      AssetDetailLoaded() => _loadedLayout(context, state),
      AssetDetailError(:final message) => _errorLayout(context, asset, message),
      _ => const SizedBox.shrink(),
    };
  }

  Widget _loadingLayout(BuildContext context, AssetDetailLoading state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          width: double.infinity,
          decoration: _headerSectionDecoration(_headerSurfaceColor(state)),
          padding: _headerSectionPadding(context),
          child: _headerBlock(state.asset),
        ),
        const Expanded(
          child: ColoredBox(
            color: AppColors.surface,
            child: Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            ),
          ),
        ),
      ],
    );
  }

  Widget _errorLayout(BuildContext context, Asset asset, String message) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xxl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(LucideIcons.alertCircle, color: AppColors.negative, size: 48),
            const SizedBox(height: AppSpacing.lg),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
            ),
            const SizedBox(height: AppSpacing.xl),
            FilledButton(
              onPressed: () {
                context.read<AssetDetailBloc>().add(LoadAssetDetail(asset));
              },
              child: const Text('Try again'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _loadedLayout(BuildContext context, AssetDetailLoaded state) {
    final d = state.detail;
    final bottomInset = MediaQuery.paddingOf(context).bottom;

    return Stack(
      children: [
        SingleChildScrollView(
          controller: _scrollController,
          padding: EdgeInsets.only(bottom: 120 + bottomInset),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                width: double.infinity,
                decoration:
                    _headerSectionDecoration(_headerSurfaceColor(state)),
                padding: _headerSectionPadding(context),
                child: _headerBlock(d.asset),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: AppSpacing.lg),
                    _marketTabs(context, state),
                    const SizedBox(height: AppSpacing.lg),
                    if (state.selectedTab == AssetMarketTab.market)
                      _marketSection(context, state)
                    else
                      _placeholderTab(state.selectedTab.label),
                    const SizedBox(height: AppSpacing.xl),
                    _expandableSections(context, state),
                  ],
                ),
              ),
            ],
          ),
        ),
        Positioned(
          left: AppSpacing.xl,
          right: AppSpacing.xl,
          bottom: AppSpacing.lg + bottomInset,
          child: _buySellRow(context, d.asset),
        ),
      ],
    );
  }

  Widget _headerBlock(Asset asset) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${asset.name} (${asset.ticker})',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                CurrencyFormatter.formatRupiah(asset.price),
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 32,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                '${CurrencyFormatter.formatChange(asset.priceChange)} (${CurrencyFormatter.formatPercentage(asset.changePercentage)})',
                style: TextStyle(
                  color: asset.isPositive ? AppColors.positive : AppColors.negative,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        CryptoAssetHelper.cryptoIcon(asset.ticker, size: 56),
      ],
    );
  }

  Widget _marketTabs(BuildContext context, AssetDetailLoaded state) {
    final tabs = AssetMarketTab.values;
    return SizedBox(
      height: 40,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: tabs.length,
        separatorBuilder: (context, _) => const SizedBox(width: AppSpacing.lg),
        itemBuilder: (context, i) {
          final tab = tabs[i];
          final selected = state.selectedTab == tab;
          return GestureDetector(
            onTap: () {
              context.read<AssetDetailBloc>().add(SelectAssetMarketTab(tab));
            },
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  tab.label,
                  style: TextStyle(
                    color: selected
                        ? AppColors.textPrimary
                        : AppColors.textTertiary,
                    fontSize: 14,
                    fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 6),
                Container(
                  height: 3,
                  width: 56,
                  decoration: BoxDecoration(
                    color: selected ? AppColors.primary : Colors.transparent,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _marketSection(BuildContext context, AssetDetailLoaded state) {
    final d = state.detail;
    final refY = d.candles.isNotEmpty ? d.candles.last.close : d.asset.price;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Stack(
          children: [
            Container(
              height: 220,
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(AppRadius.lg),
                border: Border.all(color: AppColors.divider),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(AppRadius.lg),
                child: Padding(
                  padding: const EdgeInsets.only(
                    top: 28,
                    bottom: 8,
                    left: 8,
                    right: 8,
                  ),
                  child: state.chartMode == ChartDisplayMode.candlestick
                      ? AssetCandlestickChart(
                          candles: d.candles,
                          minY: d.chartMin,
                          maxY: d.chartMax,
                          referenceY: refY,
                        )
                      : _lineChart(state.detail),
                ),
              ),
            ),
            Positioned(
              left: AppSpacing.md,
              top: AppSpacing.sm,
              child: Text(
                'Max: ${CurrencyFormatter.formatRupiah(d.chartMax)}',
                style: TextStyle(
                  color: AppColors.textTertiary,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Positioned(
              left: AppSpacing.md,
              bottom: AppSpacing.sm,
              child: Text(
                'Min: ${CurrencyFormatter.formatRupiah(d.chartMin)}',
                style: TextStyle(
                  color: AppColors.textTertiary,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Positioned(
              right: AppSpacing.sm,
              top: AppSpacing.sm,
              child: IconButton(
                visualDensity: VisualDensity.compact,
                icon: Icon(LucideIcons.maximize2, color: AppColors.textTertiary, size: 20),
                onPressed: () {},
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        Row(
          children: [
            _chartModeChip(
              context,
              label: ChartDisplayMode.candlestick.label,
              selected: state.chartMode == ChartDisplayMode.candlestick,
              onTap: () => context.read<AssetDetailBloc>().add(
                    const SetAssetChartDisplayMode(ChartDisplayMode.candlestick),
                  ),
            ),
            const SizedBox(width: AppSpacing.sm),
            _chartModeChip(
              context,
              label: ChartDisplayMode.line.label,
              selected: state.chartMode == ChartDisplayMode.line,
              onTap: () => context.read<AssetDetailBloc>().add(
                    const SetAssetChartDisplayMode(ChartDisplayMode.line),
                  ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        Wrap(
          spacing: AppSpacing.sm,
          runSpacing: AppSpacing.sm,
          children: ChartTimeframe.values.map((tf) {
            final selected = state.timeframe == tf;
            return ChoiceChip(
              label: Text(tf.label),
              selected: selected,
              onSelected: (_) {
                context.read<AssetDetailBloc>().add(
                      ChangeAssetDetailTimeframe(tf),
                    );
              },
              selectedColor: AppColors.surface,
              labelStyle: TextStyle(
                color: selected ? AppColors.filterChipSelected : AppColors.textSecondary,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
              shape: StadiumBorder(
                side: BorderSide(
                  color: selected ? AppColors.filterChipSelected : AppColors.border,
                  width: selected ? 1.5 : 1,
                ),
              ),
              backgroundColor: AppColors.surface,
              padding: const EdgeInsets.symmetric(horizontal: 4),
            );
          }).toList(),
        ),
        const SizedBox(height: AppSpacing.sm),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              DateFormatter.formatChartAxisDay(d.chartRangeStart),
              style: TextStyle(color: AppColors.textTertiary, fontSize: 11),
            ),
            Text(
              DateFormatter.formatChartAxisDay(d.chartRangeEnd),
              style: TextStyle(color: AppColors.textTertiary, fontSize: 11),
            ),
          ],
        ),
      ],
    );
  }

  Widget _lineChart(AssetDetail d) {
    final candles = d.candles;
    if (candles.isEmpty) return const SizedBox.expand();
    return LineChart(
      LineChartData(
        gridData: const FlGridData(show: false),
        titlesData: const FlTitlesData(show: false),
        borderData: FlBorderData(show: false),
        minX: 0,
        maxX: (candles.length - 1).toDouble(),
        minY: d.chartMin,
        maxY: d.chartMax,
        lineBarsData: [
          LineChartBarData(
            spots: [
              for (var i = 0; i < candles.length; i++)
                FlSpot(i.toDouble(), candles[i].close),
            ],
            color: AppColors.primary,
            barWidth: 2,
            dotData: const FlDotData(show: false),
            belowBarData: BarAreaData(
              show: true,
              gradient: LinearGradient(
                colors: [
                  AppColors.primary.withValues(alpha: 0.2),
                  AppColors.primary.withValues(alpha: 0),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
        ],
        lineTouchData: const LineTouchData(enabled: false),
      ),
      duration: Duration.zero,
    );
  }

  Widget _chartModeChip(
    BuildContext context, {
    required String label,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.full),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary.withValues(alpha: 0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(AppRadius.full),
          border: Border.all(
            color: selected ? AppColors.primary : AppColors.border,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? AppColors.primary : AppColors.textSecondary,
            fontWeight: FontWeight.w600,
            fontSize: 13,
          ),
        ),
      ),
    );
  }

  Widget _placeholderTab(String title) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xxxl),
      alignment: Alignment.center,
      child: Text(
        '$title — coming soon',
        style: TextStyle(color: AppColors.textTertiary, fontSize: 14),
      ),
    );
  }

  Widget _expandableSections(BuildContext context, AssetDetailLoaded state) {
    final d = state.detail;
    final aboutTitle = 'About ${d.asset.ticker}';

    return Column(
      children: [
        _expandTile(
          context,
          title: 'Total Asset',
          expanded: state.totalAssetExpanded,
          sectionId: 'total',
          child: Text(
            CurrencyFormatter.formatRupiah(d.totalAssetValue),
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        const Divider(height: 1, color: AppColors.divider),
        _expandTile(
          context,
          title: 'Details Stats',
          expanded: state.detailStatsExpanded,
          sectionId: 'stats',
          child: Column(
            children: d.detailStats
                .map(
                  (row) => Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          row.label,
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 14,
                          ),
                        ),
                        Text(
                          row.value,
                          style: TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
                .toList(),
          ),
        ),
        const Divider(height: 1, color: AppColors.divider),
        _expandTile(
          context,
          title: aboutTitle,
          expanded: state.aboutExpanded,
          sectionId: 'about',
          child: Text(
            d.aboutText,
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 14,
              height: 1.45,
            ),
          ),
        ),
      ],
    );
  }

  Widget _expandTile(
    BuildContext context, {
    required String title,
    required bool expanded,
    required String sectionId,
    required Widget child,
  }) {
    return Column(
      children: [
        InkWell(
          onTap: () {
            context.read<AssetDetailBloc>().add(
                  ToggleAssetDetailSection(sectionId),
                );
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                Icon(
                  expanded ? LucideIcons.chevronUp : LucideIcons.chevronDown,
                  color: AppColors.textTertiary,
                  size: 22,
                ),
              ],
            ),
          ),
        ),
        if (expanded)
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.lg),
            child: Align(
              alignment: Alignment.centerLeft,
              child: child,
            ),
          ),
      ],
    );
  }

  Widget _buySellRow(BuildContext context, Asset asset) {
    const pillHeight = 45.0;
    final cardVerticalPadding = AppSpacing.md;
    final cardOuterRadius = (pillHeight + cardVerticalPadding * 2) / 2;
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: cardVerticalPadding,
      ),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.96),
        borderRadius: BorderRadius.circular(cardOuterRadius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.07),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: SizedBox(
              height: pillHeight,
              child: OutlinedButton(
                onPressed: () {},
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.primary,
                  side: const BorderSide(color: AppColors.primary, width: 1.5),
                  padding: EdgeInsets.zero,
                  minimumSize: const Size(0, pillHeight),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  shape: const StadiumBorder(),
                ),
                child: const Text(
                  'Sell',
                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
                ),
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: SizedBox(
              height: pillHeight,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(pillHeight / 2),
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
                    onTap: () async {
                      final summary = await showBuyCryptoBottomSheet(
                        context,
                        asset: asset,
                        spotPrice: asset.price,
                      );
                      if (!context.mounted || summary == null) return;
                      await Navigator.of(context).push(
                        ConfirmBuyPage.route(summary),
                      );
                    },
                    borderRadius: BorderRadius.circular(pillHeight / 2),
                    child: const Center(
                      child: Text(
                        'Buy',
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
    );
  }
}
