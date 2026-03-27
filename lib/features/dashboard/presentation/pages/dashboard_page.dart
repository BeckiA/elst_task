import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../../core/theme/app_theme.dart';
import '../../domain/value_objects/dashboard_view_mode.dart';
import '../bloc/dashboard_bloc.dart';
import '../bloc/dashboard_event.dart';
import '../bloc/dashboard_state.dart';
import '../widgets/portfolio_header.dart';
import '../widgets/quick_actions_grid.dart';
import '../widgets/balance_summary_cards.dart';
import '../widgets/promo_banner.dart';
import '../widgets/asset_filter_chips.dart';
import '../widgets/asset_list_tile.dart';
import '../widgets/dashboard_skeleton.dart';
import '../widgets/dashboard_bottom_nav_bar.dart';
import '../widgets/dashboard_news_section.dart';
import 'asset_detail_page.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage>
    with TickerProviderStateMixin {
  int _currentNavIndex = 0;

  // Staggered animation controllers
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  // Individual stagger controllers for sections
  late List<AnimationController> _staggerControllers;
  late List<Animation<double>> _staggerFadeAnimations;
  late List<Animation<Offset>> _staggerSlideAnimations;

  static const int _sectionCount = 6;
  static const double _floatingNavReserve =
      72 + AppSpacing.md * 2; // pill + vertical padding

  @override
  void initState() {
    super.initState();

    // Main page fade + slide
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _slideController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    );
    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.05), end: Offset.zero).animate(
          CurvedAnimation(parent: _slideController, curve: Curves.easeOutCubic),
        );

    // Staggered section animations
    _staggerControllers = List.generate(
      _sectionCount,
      (i) => AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 500),
      ),
    );

    _staggerFadeAnimations = _staggerControllers
        .map((c) => CurvedAnimation(parent: c, curve: Curves.easeOut))
        .toList();

    _staggerSlideAnimations = _staggerControllers
        .map(
          (c) => Tween<Offset>(
            begin: const Offset(0, 0.08),
            end: Offset.zero,
          ).animate(CurvedAnimation(parent: c, curve: Curves.easeOutCubic)),
        )
        .toList();

    context.read<DashboardBloc>().add(const LoadDashboard());
  }

  void _playStaggeredAnimations() {
    _fadeController.forward();
    _slideController.forward();

    for (int i = 0; i < _sectionCount; i++) {
      Future.delayed(Duration(milliseconds: 100 + (i * 80)), () {
        if (mounted) {
          _staggerControllers[i].forward();
        }
      });
    }
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    for (final c in _staggerControllers) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: BlocConsumer<DashboardBloc, DashboardState>(
        listener: (context, state) {
          if (state is DashboardLoaded) {
            _playStaggeredAnimations();
          }
        },
        builder: (context, state) {
          if (state is DashboardLoading || state is DashboardInitial) {
            return const DashboardSkeleton();
          }

          if (state is DashboardError) {
            return _buildErrorView(state.message);
          }

          if (state is DashboardLoaded) {
            return _buildLoadedDashboard(state);
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildErrorView(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xxxl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppColors.negative.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                LucideIcons.alertCircle,
                color: AppColors.negative,
                size: 40,
              ),
            ),
            const SizedBox(height: AppSpacing.xxl),
            Text(
              'Something went wrong',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 20,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
            ),
            const SizedBox(height: AppSpacing.xxl),
            ElevatedButton.icon(
              onPressed: () {
                context.read<DashboardBloc>().add(const LoadDashboard());
              },
              icon: const Icon(LucideIcons.refreshCcw),
              label: const Text('Try Again'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.xxl,
                  vertical: AppSpacing.md,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppRadius.full),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<QuickActionItem> _quickActionsForMode(DashboardViewMode mode) {
    switch (mode) {
      case DashboardViewMode.lite:
        return [
          const QuickActionItem(
            icon: LucideIcons.graduationCap,
            label: 'Academy',
          ),
          const QuickActionItem(
            icon: LucideIcons.calendarCheck,
            label: 'Recurring',
          ),
          const QuickActionItem(
            icon: LucideIcons.headphones,
            label: 'Live Chat',
          ),
          const QuickActionItem(
            icon: LucideIcons.messagesSquare,
            label: 'Chat Room',
          ),
        ];
      case DashboardViewMode.pro:
        return [
          const QuickActionItem(icon: LucideIcons.wallet, label: 'Deposit'),
          const QuickActionItem(
            icon: Icons.monetization_on_outlined,
            label: 'Earn',
          ),
          const QuickActionItem(
            icon: LucideIcons.graduationCap,
            label: 'Academy',
          ),
          const QuickActionItem(icon: LucideIcons.calendar, label: 'Recurring'),
          const QuickActionItem(
            icon: Icons.receipt_long_rounded,
            label: 'History',
          ),
          const QuickActionItem(icon: LucideIcons.users, label: 'Referral'),
          const QuickActionItem(
            icon: LucideIcons.headphones,
            label: 'Live Chat',
          ),
          const QuickActionItem(
            icon: LucideIcons.messagesSquare,
            label: 'Chat Room',
          ),
        ];
    }
  }

  Widget _buildLoadedDashboard(DashboardLoaded state) {
    final bottomSafe = MediaQuery.paddingOf(context).bottom;
    final scrollBottomPad = bottomSafe + _floatingNavReserve + AppSpacing.xl;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        Positioned.fill(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: SlideTransition(
              position: _slideAnimation,
              child: RefreshIndicator(
                onRefresh: () async {
                  context.read<DashboardBloc>().add(const RefreshDashboard());
                  await Future.delayed(const Duration(seconds: 1));
                },
                color: AppColors.primary,
                child: CustomScrollView(
                  physics: const BouncingScrollPhysics(
                    parent: AlwaysScrollableScrollPhysics(),
                  ),
                  slivers: [
                    // Portfolio Header with Quick Actions
                    SliverToBoxAdapter(
                      child: _staggeredSection(
                        0,
                        PortfolioHeader(
                          stats: state.stats,
                          chartData: state.chartData,
                          isBalanceVisible: state.isBalanceVisible,
                          onToggleVisibility: () {
                            context.read<DashboardBloc>().add(
                              const ToggleBalanceVisibility(),
                            );
                          },
                          viewMode: state.viewMode,
                          onViewModeChanged: (mode) {
                            context.read<DashboardBloc>().add(
                              SetDashboardViewMode(mode),
                            );
                          },
                          onTopUp: () {},
                          child: QuickActionsGrid(
                            layout: state.viewMode == DashboardViewMode.lite
                                ? QuickActionsLayout.liteFixedRow
                                : QuickActionsLayout.standard,
                            actions: _quickActionsForMode(state.viewMode),
                          ),
                        ),
                      ),
                    ),

                    // Promo Banner (handles its own overlapping)
                    SliverToBoxAdapter(
                      child: _staggeredSection(
                        1,
                        PromoBanner(
                          title: 'Get a reward of Rp3,000,000',
                          subtitle: 'by reviewing INDODAX on the App Store',
                          actionText: 'Try Now',
                          viewMode: state.viewMode,
                        ),
                      ),
                    ),

                    // Balance Cards
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.only(top: AppSpacing.xxl),
                        child: _staggeredSection(
                          2,
                          BalanceSummaryCards(
                            cryptoBalance: state.stats.cryptoBalance,
                            cashBalance: state.stats.cashBalance,
                            isVisible: state.isBalanceVisible,
                          ),
                        ),
                      ),
                    ),

                    // Asset List Header + Filters
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.only(top: AppSpacing.xxl),
                        child: _staggeredSection(
                          3,
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: AppSpacing.xl,
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'Asset List',
                                      style: TextStyle(
                                        color: AppColors.textPrimary,
                                        fontSize: 24,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                    TextButton(
                                      onPressed: () {},
                                      child: Text(
                                        'See All',
                                        style: TextStyle(
                                          color: AppColors.textSecondary,
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: AppSpacing.sm),
                              AssetFilterChips(
                                selectedCategory: state.selectedCategory,
                                onCategorySelected: (category) {
                                  context.read<DashboardBloc>().add(
                                    FilterAssets(category),
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    // Asset List
                    SliverList(
                      delegate: SliverChildBuilderDelegate((context, index) {
                        final asset = state.assets[index];
                        return _staggeredSection(
                          4,
                          AssetListTile(
                            asset: asset,
                            onTap: () {
                              Navigator.of(context).push(
                                AssetDetailPage.route(asset),
                              );
                            },
                          ),
                        );
                      }, childCount: state.assets.length),
                    ),

                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.only(top: AppSpacing.xxl),
                        child: _staggeredSection(
                          5,
                          DashboardNewsSection(articles: state.news),
                        ),
                      ),
                    ),

                    SliverToBoxAdapter(
                      child: SizedBox(height: scrollBottomPad),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        Positioned(
          left: AppSpacing.xl,
          right: AppSpacing.xl,
          bottom: bottomSafe + AppSpacing.md,
          child: DashboardBottomNavBar(
            currentIndex: _currentNavIndex,
            onTap: (index) {
              setState(() => _currentNavIndex = index);
            },
          ),
        ),
      ],
    );
  }

  Widget _staggeredSection(int index, Widget child) {
    if (index >= _sectionCount) return child;
    return FadeTransition(
      opacity: _staggerFadeAnimations[index],
      child: SlideTransition(
        position: _staggerSlideAnimations[index],
        child: child,
      ),
    );
  }
}
