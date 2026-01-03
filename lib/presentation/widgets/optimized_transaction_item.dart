import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../domain/entities/transaction.dart';
import '../../core/constants/app_constants.dart';
import '../../core/themes/app_theme.dart';

class OptimizedTransactionItem extends StatelessWidget {
  final Transaction transaction;
  final VoidCallback? onDelete;

  const OptimizedTransactionItem({
    super.key,
    required this.transaction,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: ValueKey(transaction.id),
      direction: DismissDirection.endToStart,
      background: _DismissibleBackground(),
      onDismissed: (_) => onDelete?.call(),
      child: Card(
        margin: const EdgeInsets.symmetric(
          horizontal: AppConstants.mediumPadding,
          vertical: AppConstants.smallPadding,
        ),
        elevation: 2,
        child: InkWell(
          onTap: null, // No tap action needed for now
          borderRadius: BorderRadius.circular(AppConstants.mediumRadius),
          child: Padding(
            padding: const EdgeInsets.all(AppConstants.mediumPadding),
            child: Row(
              children: [
                _TransactionIcon(isIncome: transaction.isIncome),
                const SizedBox(width: AppConstants.mediumPadding),
                Expanded(
                  child: _TransactionDetails(
                    note: transaction.note,
                    date: transaction.date,
                  ),
                ),
                _TransactionAmount(
                  amount: transaction.amount,
                  isIncome: transaction.isIncome,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _DismissibleBackground extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
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
    );
  }
}

class _TransactionIcon extends StatelessWidget {
  final bool isIncome;

  const _TransactionIcon({required this.isIncome});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: (isIncome ? AppTheme.incomeColor : AppTheme.expenseColor)
            .withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppConstants.mediumRadius),
      ),
      child: Icon(
        isIncome ? Icons.arrow_downward_rounded : Icons.arrow_upward_rounded,
        color: isIncome ? AppTheme.incomeColor : AppTheme.expenseColor,
        size: 24,
      ),
    );
  }
}

class _TransactionDetails extends StatelessWidget {
  final String note;
  final DateTime date;

  const _TransactionDetails({
    required this.note,
    required this.date,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          note.isEmpty ? 'Tranzaksiya' : note,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 4),
        Text(
          _formatDate(date),
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
          ),
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    return DateFormat('MMM dd, yyyy • hh:mm a').format(date);
  }
}

class _TransactionAmount extends StatelessWidget {
  final double amount;
  final bool isIncome;

  const _TransactionAmount({
    required this.amount,
    required this.isIncome,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: AppConstants.shortAnimation,
      child: Text(
        '${isIncome ? '+' : '-'}\$${amount.toStringAsFixed(2)}',
        key: ValueKey('${amount}_${isIncome}'),
        style: Theme.of(context).textTheme.titleLarge?.copyWith(
          color: isIncome ? AppTheme.incomeColor : AppTheme.expenseColor,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
