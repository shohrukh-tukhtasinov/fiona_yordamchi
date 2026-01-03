import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_constants.dart';
import '../../core/themes/app_theme.dart';
import '../../core/enums/currency_type.dart';
import '../state/transaction_view_model.dart';

class CurrencyBalanceCard extends StatelessWidget {
  const CurrencyBalanceCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(AppConstants.mediumPadding),
      child: _BalanceCard(),
    );
  }
}

class _BalanceCard extends StatefulWidget {
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
    _shimmerController.reset();
    _shimmerController.forward();
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
                  padding: const EdgeInsets.all(AppConstants.mediumPadding),
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
                      _AnimatedBalanceDisplay(),
                      const SizedBox(height: AppConstants.mediumPadding),
                      _CurrencyToggle(),
                      const SizedBox(height: AppConstants.smallPadding),
                      _SummaryRow(),
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
  @override
  Widget build(BuildContext context) {
    return Consumer<TransactionViewModel>(
      builder: (context, viewModel, child) {
        return TweenAnimationBuilder<double>(
          tween: Tween<double>(begin: 0.0, end: viewModel.balance.abs()),
          duration: AppConstants.mediumAnimation,
          curve: Curves.easeOutCubic,
          builder: (context, value, child) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  viewModel.formatAmount(viewModel.balance),
                  key: ValueKey('balance_${viewModel.displayCurrency.code}'),
                  style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -1.0,
                    height: 1.1,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _getConvertedAmount(viewModel),
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.white.withOpacity(0.8),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  String _getConvertedAmount(TransactionViewModel viewModel) {
    if (viewModel.displayCurrency == CurrencyType.usd) {
      final uzsAmount = viewModel.balance * viewModel.usdToUzsRate;
      return '~${uzsAmount.toStringAsFixed(0)} so\'m';
    } else {
      final usdAmount = viewModel.balance / viewModel.usdToUzsRate;
      return '~\$${usdAmount.toStringAsFixed(2)}';
    }
  }
}

class _CurrencyToggle extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<TransactionViewModel>(
      builder: (context, viewModel, child) {
        return Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.15),
            borderRadius: BorderRadius.circular(AppConstants.mediumRadius),
          ),
          child: Row(
            children: [
              Expanded(
                child: _CurrencyButton(
                  isSelected: viewModel.displayCurrency == CurrencyType.usd,
                  text: 'USD',
                  onTap: () => viewModel.setDisplayCurrency(CurrencyType.usd),
                ),
              ),
              Expanded(
                child: _CurrencyButton(
                  isSelected: viewModel.displayCurrency == CurrencyType.uzs,
                  text: 'UZS',
                  onTap: () => viewModel.setDisplayCurrency(CurrencyType.uzs),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _CurrencyButton extends StatelessWidget {
  final bool isSelected;
  final String text;
  final VoidCallback onTap;

  const _CurrencyButton({
    required this.isSelected,
    required this.text,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: AppConstants.shortAnimation,
        margin: const EdgeInsets.all(4),
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white.withOpacity(0.3) : Colors.transparent,
          borderRadius: BorderRadius.circular(AppConstants.smallRadius),
        ),
        child: Center(
          child: Text(
            text,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: isSelected ? Colors.white : Colors.white.withOpacity(0.7),
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<TransactionViewModel>(
      builder: (context, viewModel, child) {
        return Row(
          children: [
            Expanded(
              child: _SummaryItem(
                label: 'Daromad',
                amount: viewModel.totalIncome,
                currency: viewModel.displayCurrency,
                isPositive: true,
                exchangeRate: viewModel.usdToUzsRate,
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
                amount: viewModel.totalExpense,
                currency: viewModel.displayCurrency,
                isPositive: false,
                exchangeRate: viewModel.usdToUzsRate,
              ),
            ),
          ],
        );
      },
    );
  }
}

class _SummaryItem extends StatelessWidget {
  final String label;
  final double amount;
  final CurrencyType currency;
  final bool isPositive;
  final double exchangeRate;

  const _SummaryItem({
    required this.label,
    required this.amount,
    required this.currency,
    required this.isPositive,
    required this.exchangeRate,
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
                  color: isPositive ? AppTheme.incomeColor : AppTheme.expenseColor,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: (isPositive ? AppTheme.incomeColor : AppTheme.expenseColor).withOpacity(0.3),
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
                _formatAmount(value),
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

  String _formatAmount(double amount) {
    switch (currency) {
      case CurrencyType.usd:
        return '\$${amount.toStringAsFixed(2)}';
      case CurrencyType.uzs:
        return '${amount.toStringAsFixed(0)} so\'m';
    }
  }
}
