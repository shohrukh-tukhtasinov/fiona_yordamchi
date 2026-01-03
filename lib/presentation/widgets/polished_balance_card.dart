import 'package:flutter/material.dart';
import '../../core/constants/app_constants.dart';
import '../../core/themes/app_theme.dart';

class PolishedBalanceCard extends StatelessWidget {
  final double balance;
  final double totalIncome;
  final double totalExpense;

  const PolishedBalanceCard({
    super.key,
    required this.balance,
    required this.totalIncome,
    required this.totalExpense,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(AppConstants.mediumPadding),
      child: _BalanceCard(
        balance: balance,
        totalIncome: totalIncome,
        totalExpense: totalExpense,
      ),
    );
  }
}

class _BalanceCard extends StatefulWidget {
  final double balance;
  final double totalIncome;
  final double totalExpense;

  const _BalanceCard({
    required this.balance,
    required this.totalIncome,
    required this.totalExpense,
  });

  @override
  State<_BalanceCard> createState() => _BalanceCardState();
}

class _BalanceCardState extends State<_BalanceCard> 
    with SingleTickerProviderStateMixin {
  late AnimationController _shimmerController;
  late Animation<double> _shimmerAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _shimmerController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    
    _shimmerAnimation = Tween<double>(
      begin: -1.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _shimmerController,
      curve: Curves.easeInOut,
    ));

    _scaleAnimation = Tween<double>(
      begin: 0.95,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _shimmerController,
      curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
    ));

    _shimmerController.forward();
  }

  @override
  void didUpdateWidget(_BalanceCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.balance != widget.balance ||
        oldWidget.totalIncome != widget.totalIncome ||
        oldWidget.totalExpense != widget.totalExpense) {
      _shimmerController.reset();
      _shimmerController.forward();
    }
  }

  @override
  void dispose() {
    _shimmerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _shimmerController,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppConstants.extraLargeRadius),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Theme.of(context).colorScheme.primary.withOpacity(0.9),
                  Theme.of(context).colorScheme.primary.withOpacity(0.7),
                  Theme.of(context).colorScheme.secondary.withOpacity(0.5),
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.4),
                  blurRadius: 24,
                  offset: const Offset(0, 12),
                  spreadRadius: -2,
                ),
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Stack(
              children: [
                _ShimmerEffect(
                  animation: _shimmerAnimation,
                ),
                Padding(
                  padding: const EdgeInsets.all(AppConstants.largePadding),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Jami Balans',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: Colors.white.withOpacity(0.9),
                          fontWeight: FontWeight.w500,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: AppConstants.smallPadding),
                      _AnimatedBalanceDisplay(
                        balance: widget.balance,
                      ),
                      const SizedBox(height: AppConstants.largePadding),
                      _SummaryRow(
                        income: widget.totalIncome,
                        expense: widget.totalExpense,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _ShimmerEffect extends StatelessWidget {
  final Animation<double> animation;

  const _ShimmerEffect({required this.animation});

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppConstants.extraLargeRadius),
        child: AnimatedBuilder(
          animation: animation,
          builder: (context, child) {
            return Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment(-1.0 + animation.value * 2, -0.5),
                  end: Alignment(1.0 + animation.value * 2, 0.5),
                  colors: [
                    Colors.transparent,
                    Colors.white.withOpacity(0.1),
                    Colors.transparent,
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _AnimatedBalanceDisplay extends StatelessWidget {
  final double balance;

  const _AnimatedBalanceDisplay({required this.balance});

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0.0, end: balance),
      duration: AppConstants.mediumAnimation,
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Text(
          '\$${value.abs().toStringAsFixed(2)}',
          key: ValueKey(value),
          style: Theme.of(context).textTheme.headlineLarge?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w800,
            letterSpacing: -1.0,
            height: 1.1,
          ),
        );
      },
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final double income;
  final double expense;

  const _SummaryRow({
    required this.income,
    required this.expense,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _SummaryItem(
            label: 'Daromad',
            amount: income,
            color: AppTheme.incomeColor,
            isPositive: true,
          ),
        ),
        Container(
          width: 1,
          height: 40,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.white.withOpacity(0.4),
                Colors.white.withOpacity(0.1),
              ],
            ),
          ),
        ),
        Expanded(
          child: _SummaryItem(
            label: 'Xarajat',
            amount: expense,
            color: AppTheme.expenseColor,
            isPositive: false,
          ),
        ),
      ],
    );
  }
}

class _SummaryItem extends StatelessWidget {
  final String label;
  final double amount;
  final Color color;
  final bool isPositive;

  const _SummaryItem({
    required this.label,
    required this.amount,
    required this.color,
    required this.isPositive,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppConstants.mediumPadding),
      child: Column(
        children: [
          Row(
            children: [
              AnimatedContainer(
                duration: AppConstants.shortAnimation,
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: color.withOpacity(0.3),
                      blurRadius: 4,
                      offset: const Offset(0, 1),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Text(
                label,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.white.withOpacity(0.9),
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.3,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          TweenAnimationBuilder<double>(
            tween: Tween<double>(begin: 0.0, end: amount),
            duration: AppConstants.mediumAnimation,
            curve: Curves.easeOutCubic,
            builder: (context, value, child) {
              return Text(
                '\$${value.toStringAsFixed(2)}',
                key: ValueKey('${label}_$value'),
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.5,
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
