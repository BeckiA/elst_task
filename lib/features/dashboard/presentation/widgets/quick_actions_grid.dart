import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';

class QuickActionItem {
  final IconData icon;
  final String label;
  final VoidCallback? onTap;

  const QuickActionItem({
    required this.icon,
    required this.label,
    this.onTap,
  });
}

class QuickActionsGrid extends StatefulWidget {
  final List<QuickActionItem> actions;

  const QuickActionsGrid({super.key, required this.actions});

  @override
  State<QuickActionsGrid> createState() => _QuickActionsGridState();
}

class _QuickActionsGridState extends State<QuickActionsGrid> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    // In compact mode, show actions skipping the first one (Deposit),
    // and replace the 4th with 'Lainnya'
    final List<QuickActionItem> displayActions = _isExpanded
        ? widget.actions
        : [
            ...widget.actions.skip(1).take(3),
            QuickActionItem(
              icon: Icons.grid_view_rounded,
              label: 'Lainnya',
              onTap: () => setState(() => _isExpanded = true),
            ),
          ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: displayActions
                .take(4)
                .map((action) => Expanded(child: _QuickActionButton(item: action)))
                .toList(),
          ),
          if (_isExpanded && widget.actions.length > 4) ...[
            const SizedBox(height: AppSpacing.xl),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: widget.actions
                  .skip(4)
                  .take(4)
                  .map((action) => Expanded(child: _QuickActionButton(item: action)))
                  .toList(),
            ),
          ],
          if (_isExpanded) ...[
            const SizedBox(height: AppSpacing.xxl),
            _buildHideButton(),
          ],
          const SizedBox(height: AppSpacing.xxl),
        ],
      ),
    );
  }

  Widget _buildHideButton() {
    return GestureDetector(
      onTap: () {
        setState(() {
          _isExpanded = false;
        });
      },
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Hide',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(width: AppSpacing.xs),
          Icon(
            Icons.keyboard_arrow_up_rounded,
            color: Colors.white70,
            size: 18,
          ),
        ],
      ),
    );
  }
}

class _QuickActionButton extends StatefulWidget {
  final QuickActionItem item;

  const _QuickActionButton({required this.item});

  @override
  State<_QuickActionButton> createState() => _QuickActionButtonState();
}

class _QuickActionButtonState extends State<_QuickActionButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.9).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) {
        _controller.reverse();
        widget.item.onTap?.call();
      },
      onTapCancel: () => _controller.reverse(),
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.15),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(
                widget.item.icon,
                color: Colors.white,
                size: 24,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              widget.item.label,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
