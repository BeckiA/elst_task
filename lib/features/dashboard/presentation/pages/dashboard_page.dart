import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_theme.dart';
import '../bloc/dashboard_bloc.dart';
import '../bloc/dashboard_event.dart';
import '../bloc/dashboard_state.dart';
import '../widgets/portfolio_header.dart';
import '../widgets/quick_actions_grid.dart';
import '../widgets/balance_summary_cards.dart';
import '../widgets/promo_banner.dart';
import '../widgets/asset_filter_chips.dart';
import '../widgets/asset_list_tile.dart';
import '../widgets/activity_list_section.dart';
import '../widgets/dashboard_skeleton.dart';
import '../widgets/dashboard_bottom_nav_bar.dart';

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
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.05),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));

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
        .map((c) => Tween<Offset>(
              begin: const Offset(0, 0.08),
              end: Offset.zero,
            ).animate(CurvedAnimation(parent: c, curve: Curves.easeOutCubic)))
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
      bottomNavigationBar: DashboardBottomNavBar(
        currentIndex: _currentNavIndex,
        onTap: (index) {
          setState(() => _currentNavIndex = index);
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
                Icons.error_outline_rounded,
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
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: AppSpacing.xxl),
            ElevatedButton.icon(
              onPressed: () {
                context.read<DashboardBloc>().add(const LoadDashboard());
              },
              icon: const Icon(Icons.refresh_rounded),
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

  Widget _buildLoadedDashboard(DashboardLoaded state) {
    return FadeTransition(
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
                      context
                          .read<DashboardBloc>()
                          .add(const ToggleBalanceVisibility());
                    },
                    child: QuickActionsGrid(
                      actions: [
                        QuickActionItem(icon: Icons.account_balance_wallet_outlined, label: 'Deposit'),
                        QuickActionItem(icon: Icons.monetization_on_outlined, label: 'Earn'),
                        QuickActionItem(icon: Icons.school_outlined, label: 'Academy'),
                        QuickActionItem(icon: Icons.calendar_today_rounded, label: 'Recurring'),
                        QuickActionItem(icon: Icons.receipt_long_rounded, label: 'History'),
                        QuickActionItem(icon: Icons.people_outline_rounded, label: 'Referral'),
                        QuickActionItem(icon: Icons.headset_mic_outlined, label: 'Live Chat'),
                        QuickActionItem(icon: Icons.chat_bubble_outline_rounded, label: 'Chat Room'),
                      ],
                    ),
                  ),
                ),
              ),

              // Promo Banner (handles its own overlapping)
              SliverToBoxAdapter(
                child: _staggeredSection(
                  1,
                  const PromoBanner(
                    title: 'Get a reward of Rp3,000,000',
                    subtitle: 'by reviewing INDODAX on the App Store',
                    actionText: 'Try Now',
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
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Asset List',
                                style: TextStyle(
                                  color: AppColors.textPrimary,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              TextButton(
                                onPressed: () {},
                                child: Text(
                                  'See All',
                                  style: TextStyle(
                                    color: AppColors.primary,
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
                            context
                                .read<DashboardBloc>()
                                .add(FilterAssets(category));
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // Asset List
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final asset = state.assets[index];
                    return _staggeredSection(
                      4,
                      AssetListTile(
                        asset: asset,
                        index: index,
                        onTap: () {},
                      ),
                    );
                  },
                  childCount: state.assets.length,
                ),
              ),

              // Activity List
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.only(top: AppSpacing.xxl),
                  child: ActivityListSection(activities: state.activities),
                ),
              ),

              // Bottom spacing
              const SliverToBoxAdapter(
                child: SizedBox(height: AppSpacing.xxxl),
              ),
            ],
          ),
        ),
      ),
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
