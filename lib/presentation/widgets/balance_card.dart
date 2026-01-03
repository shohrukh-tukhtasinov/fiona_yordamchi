import 'package:flutter/material.dart';
import '../../core/constants/app_constants.dart';
import '../../core/themes/app_theme.dart';

class BalanceCard extends StatelessWidget {
  final double balance;
  final double totalIncome;
  final double totalExpense;

  const BalanceCard({
    super.key,
    required this.balance,
    required this.totalIncome,
    required this.totalExpense,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(AppConstants.mediumPadding),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppConstants.extraLargeRadius),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Theme.of(context).colorScheme.primary.withOpacity(0.8),
            Theme.of(context).colorScheme.primary.withOpacity(0.6),
            Theme.of(context).colorScheme.secondary.withOpacity(0.4),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.largePadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Total Balance',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Colors.white.withOpacity(0.9),
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: AppConstants.smallPadding),
            AnimatedSwitcher(
              duration: AppConstants.mediumAnimation,
              child: Text(
                '\$${balance.toStringAsFixed(2)}',
                key: ValueKey(balance),
                style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const SizedBox(height: AppConstants.largePadding),
            Row(
              children: [
                Expanded(
                  child: _buildInfoItem(
                    context,
                    'Income',
                    '\$${totalIncome.toStringAsFixed(2)}',
                    AppTheme.incomeColor,
                  ),
                ),
                Container(
                  width: 1,
                  height: 40,
                  color: Colors.white.withOpacity(0.3),
                ),
                Expanded(
                  child: _buildInfoItem(
                    context,
                    'Expense',
                    '\$${totalExpense.toStringAsFixed(2)}',
                    AppTheme.expenseColor,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoItem(
    BuildContext context,
    String label,
    String amount,
    Color color,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppConstants.mediumPadding),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                label,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.white.withOpacity(0.9),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          AnimatedSwitcher(
            duration: AppConstants.mediumAnimation,
            child: Text(
              amount,
              key: ValueKey(amount),
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
