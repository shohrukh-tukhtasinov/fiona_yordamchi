import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../domain/entities/transaction.dart';
import '../../core/constants/app_constants.dart';
import '../../core/themes/app_theme.dart';

class PolishedTransactionItem extends StatefulWidget {
  final Transaction transaction;
  final VoidCallback? onDelete;
  final Animation<double> animation;

  const PolishedTransactionItem({
    super.key,
    required this.transaction,
    this.onDelete,
    required this.animation,
  });

  @override
  State<PolishedTransactionItem> createState() => _PolishedTransactionItemState();
}

class _PolishedTransactionItemState extends State<PolishedTransactionItem>
    with SingleTickerProviderStateMixin {
  late AnimationController _slideController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _slideController = AnimationController(
      duration: AppConstants.mediumAnimation,
      vsync: this,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(1.0, 0.0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: const Interval(0.3, 1.0, curve: Curves.easeOut),
    ));

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
    ));

    _slideController.forward();
  }

  @override
  void dispose() {
    _slideController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: _slideAnimation,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: ScaleTransition(
          scale: _scaleAnimation,
          child: SizeTransition(
            sizeFactor: widget.animation,
            child: _TransactionCard(
              transaction: widget.transaction,
              onDelete: widget.onDelete,
            ),
          ),
        ),
      ),
    );
  }
}

class _TransactionCard extends StatefulWidget {
  final Transaction transaction;
  final VoidCallback? onDelete;

  const _TransactionCard({
    required this.transaction,
    this.onDelete,
  });

  @override
  State<_TransactionCard> createState() => _TransactionCardState();
}

class _TransactionCardState extends State<_TransactionCard> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final isIncome = widget.transaction.isIncome;
    final color = isIncome ? AppTheme.incomeColor : AppTheme.expenseColor;
    
    return AnimatedContainer(
      duration: AppConstants.shortAnimation,
      margin: const EdgeInsets.symmetric(
        horizontal: AppConstants.mediumPadding,
        vertical: AppConstants.smallPadding,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppConstants.mediumRadius),
        color: Theme.of(context).colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(_isPressed ? 0.15 : 0.08),
            blurRadius: _isPressed ? 8 : 12,
            offset: Offset(0, _isPressed ? 2 : 4),
          ),
          if (_isPressed)
            BoxShadow(
              color: color.withOpacity(0.2),
              blurRadius: 16,
              offset: const Offset(0, 0),
              spreadRadius: -4,
            ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(AppConstants.mediumRadius),
          onTap: () {},
          onTapDown: (_) => setState(() => _isPressed = true),
          onTapUp: (_) => setState(() => _isPressed = false),
          onTapCancel: () => setState(() => _isPressed = false),
          child: Dismissible(
            key: ValueKey(widget.transaction.id),
            direction: DismissDirection.endToStart,
            background: _DismissibleBackground(color: color),
            onDismissed: (_) => widget.onDelete?.call(),
            child: Padding(
              padding: const EdgeInsets.all(AppConstants.mediumPadding),
              child: Row(
                children: [
                  _TransactionIcon(
                    isIncome: isIncome,
                    color: color,
                  ),
                  const SizedBox(width: AppConstants.mediumPadding),
                  Expanded(
                    child: _TransactionDetails(
                      transaction: widget.transaction,
                    ),
                  ),
                  const SizedBox(width: AppConstants.smallPadding),
                  _TransactionAmount(
                    amount: widget.transaction.amount,
                    isIncome: isIncome,
                    color: color,
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

class _DismissibleBackground extends StatelessWidget {
  final Color color;

  const _DismissibleBackground({required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.centerRight,
      padding: const EdgeInsets.only(right: AppConstants.mediumPadding),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(AppConstants.mediumRadius),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.delete_outline,
            color: Colors.white,
            size: 28,
          ),
          const SizedBox(height: 4),
          Text(
            'O\'chirish',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

class _TransactionIcon extends StatefulWidget {
  final bool isIncome;
  final Color color;

  const _TransactionIcon({
    required this.isIncome,
    required this.color,
  });

  @override
  State<_TransactionIcon> createState() => _TransactionIconState();
}

class _TransactionIconState extends State<_TransactionIcon>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.1,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _pulseAnimation.value,
          child: Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: widget.color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(AppConstants.mediumRadius),
              border: Border.all(
                color: widget.color.withOpacity(0.3),
                width: 1.5,
              ),
            ),
            child: Icon(
              widget.isIncome 
                  ? Icons.arrow_downward_rounded 
                  : Icons.arrow_upward_rounded,
              color: widget.color,
              size: 24,
            ),
          ),
        );
      },
    );
  }
}

class _TransactionDetails extends StatelessWidget {
  final Transaction transaction;

  const _TransactionDetails({required this.transaction});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          transaction.note.isEmpty ? 'Amaliyot' : transaction.note,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w700,
            color: Theme.of(context).colorScheme.onSurface,
            height: 1.2,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 6),
        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 6,
                vertical: 2,
              ),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                _formatDate(transaction.date),
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.w600,
                  fontSize: 10,
                ),
              ),
            ),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                _formatTime(transaction.date),
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                  fontWeight: FontWeight.w500,
                  fontSize: 11,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    return DateFormat('MMM dd').format(date);
  }

  String _formatTime(DateTime date) {
    return DateFormat('hh:mm a').format(date);
  }
}

class _TransactionAmount extends StatelessWidget {
  final double amount;
  final bool isIncome;
  final Color color;

  const _TransactionAmount({
    required this.amount,
    required this.isIncome,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: color.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: TweenAnimationBuilder<double>(
        tween: Tween<double>(begin: 0.0, end: amount),
        duration: AppConstants.mediumAnimation,
        curve: Curves.easeOutCubic,
        builder: (context, value, child) {
          return Text(
            '${isIncome ? '+' : '-'}\$${value.toStringAsFixed(2)}',
            key: ValueKey('${amount}_${isIncome}'),
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: color,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.5,
            ),
          );
        },
      ),
    );
  }
}
