import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../domain/entities/transaction.dart';
import '../../core/constants/app_constants.dart';
import '../../core/themes/app_theme.dart';

class TransactionItem extends StatelessWidget {
  final Transaction transaction;
  final VoidCallback? onTap;
  final VoidCallback? onSwipe;

  const TransactionItem({
    super.key,
    required this.transaction,
    this.onTap,
    this.onSwipe,
  });

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key(transaction.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: AppConstants.mediumPadding),
        decoration: BoxDecoration(
          color: AppTheme.expenseColor,
          borderRadius: BorderRadius.circular(AppConstants.mediumRadius),
        ),
        child: const Icon(
          Icons.delete_outline,
          color: Colors.white,
          size: 24,
        ),
      ),
      onDismissed: (direction) {
        onSwipe?.call();
      },
      child: Card(
        margin: const EdgeInsets.symmetric(
          horizontal: AppConstants.mediumPadding,
          vertical: AppConstants.smallPadding,
        ),
        elevation: 2,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppConstants.mediumRadius),
          child: Padding(
            padding: const EdgeInsets.all(AppConstants.mediumPadding),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: transaction.isIncome
                        ? AppTheme.incomeColor.withOpacity(0.1)
                        : AppTheme.expenseColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(AppConstants.mediumRadius),
                  ),
                  child: Icon(
                    transaction.isIncome
                        ? Icons.arrow_downward_rounded
                        : Icons.arrow_upward_rounded,
                    color: transaction.isIncome
                        ? AppTheme.incomeColor
                        : AppTheme.expenseColor,
                    size: 24,
                  ),
                ),
                const SizedBox(width: AppConstants.mediumPadding),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        transaction.note.isEmpty ? 'No note' : transaction.note,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        DateFormat('MMM dd, yyyy • hh:mm a').format(transaction.date),
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    AnimatedSwitcher(
                      duration: AppConstants.shortAnimation,
                      child: Text(
                        '${transaction.isIncome ? '+' : '-'}\$${transaction.amount.toStringAsFixed(2)}',
                        key: ValueKey('${transaction.id}_${transaction.amount}'),
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: transaction.isIncome
                              ? AppTheme.incomeColor
                              : AppTheme.expenseColor,
                          fontWeight: FontWeight.w700,
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
    );
  }
}
