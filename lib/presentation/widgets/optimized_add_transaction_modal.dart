import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:uuid/uuid.dart';
import '../../domain/entities/transaction.dart';
import '../../core/constants/app_constants.dart';
import '../../core/themes/app_theme.dart';

class OptimizedAddTransactionModal extends StatefulWidget {
  const OptimizedAddTransactionModal({super.key});

  @override
  State<OptimizedAddTransactionModal> createState() => _OptimizedAddTransactionModalState();
}

class _OptimizedAddTransactionModalState extends State<OptimizedAddTransactionModal>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  final _amountController = TextEditingController();
  final _noteController = TextEditingController();
  bool _isIncome = true;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: AppConstants.mediumAnimation,
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return SlideTransition(
          position: _slideAnimation,
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: DraggableScrollableSheet(
              initialChildSize: 0.75,
              maxChildSize: 0.95,
              minChildSize: 0.5,
              expand: false,
              builder: (context, scrollController) {
                return Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(AppConstants.extraLargeRadius),
                      topRight: Radius.circular(AppConstants.extraLargeRadius),
                    ),
                  ),
                  child: SingleChildScrollView(
                    controller: scrollController,
                    padding: EdgeInsets.only(
                      left: AppConstants.largePadding,
                      right: AppConstants.largePadding,
                      top: AppConstants.largePadding,
                      bottom: MediaQuery.of(context).viewInsets.bottom + AppConstants.largePadding,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildHeader(),
                        const SizedBox(height: AppConstants.largePadding),
                        _buildTransactionTypeToggle(),
                        const SizedBox(height: AppConstants.largePadding),
                        _buildAmountInput(),
                        const SizedBox(height: AppConstants.largePadding),
                        _buildNoteInput(),
                        const SizedBox(height: AppConstants.largePadding),
                        _buildSaveButton(),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Container(
          width: 4,
          height: 24,
          decoration: BoxDecoration(
            color: _isIncome ? AppTheme.incomeColor : AppTheme.expenseColor,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: AppConstants.mediumPadding),
        Expanded(
          child: Text(
            'Tranzaksiya Qo\'shish',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.close),
          style: IconButton.styleFrom(
            backgroundColor: Theme.of(context).colorScheme.surfaceVariant,
          ),
        ),
      ],
    );
  }

  Widget _buildTransactionTypeToggle() {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceVariant,
        borderRadius: BorderRadius.circular(AppConstants.largeRadius),
      ),
      child: Row(
        children: [
          Expanded(
            child: _ToggleButton(
              isSelected: _isIncome,
              text: 'Daromad',
              onTap: () => setState(() => _isIncome = true),
              color: AppTheme.incomeColor,
            ),
          ),
          Expanded(
            child: _ToggleButton(
              isSelected: !_isIncome,
              text: 'Xarajat',
              onTap: () => setState(() => _isIncome = false),
              color: AppTheme.expenseColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAmountInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Summa',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: AppConstants.smallPadding),
        TextField(
          controller: _amountController,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
          ],
          style: Theme.of(context).textTheme.headlineLarge?.copyWith(
            fontWeight: FontWeight.w700,
            color: _isIncome ? AppTheme.incomeColor : AppTheme.expenseColor,
          ),
          decoration: InputDecoration(
            prefixText: '\$',
            prefixStyle: Theme.of(context).textTheme.headlineLarge?.copyWith(
              fontWeight: FontWeight.w700,
              color: _isIncome ? AppTheme.incomeColor : AppTheme.expenseColor,
            ),
            hintText: '0.00',
            hintStyle: Theme.of(context).textTheme.headlineLarge?.copyWith(
              fontWeight: FontWeight.w700,
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.3),
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppConstants.mediumRadius),
              borderSide: BorderSide.none,
            ),
            filled: true,
            fillColor: Theme.of(context).colorScheme.surfaceVariant,
          ),
        ),
      ],
    );
  }

  Widget _buildNoteInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Izoh (Ixtiyoriy)',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: AppConstants.smallPadding),
        TextField(
          controller: _noteController,
          maxLines: 3,
          decoration: InputDecoration(
            hintText: 'Ushbu tranzaksiya uchun izoh qo\'shing...',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppConstants.mediumRadius),
              borderSide: BorderSide.none,
            ),
            filled: true,
            fillColor: Theme.of(context).colorScheme.surfaceVariant,
          ),
        ),
      ],
    );
  }

  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: AnimatedSwitcher(
        duration: AppConstants.shortAnimation,
        child: _isLoading
            ? const Center(
                key: ValueKey('loading'),
                child: CircularProgressIndicator(),
              )
            : ElevatedButton(
                key: const ValueKey('button'),
                onPressed: _saveTransaction,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _isIncome ? AppTheme.incomeColor : AppTheme.expenseColor,
                  foregroundColor: Colors.white,
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppConstants.mediumRadius),
                  ),
                ),
                child: const Text(
                  'Tranzaksiyani Saqlash',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
      ),
    );
  }

  Future<void> _saveTransaction() async {
    final amountText = _amountController.text.trim();
    if (amountText.isEmpty) {
      _showError('Please enter an amount');
      return;
    }

    final amount = double.tryParse(amountText);
    if (amount == null || amount <= 0) {
      _showError('Please enter a valid amount');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final transaction = Transaction(
        id: const Uuid().v4(),
        amount: amount,
        isIncome: _isIncome,
        note: _noteController.text.trim(),
        date: DateTime.now(),
      );

      // Get the view model and add transaction
      if (context.mounted) {
        Navigator.of(context).pop(transaction);
      }
    } catch (e) {
      _showError('Failed to save transaction');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Theme.of(context).colorScheme.error,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}

class _ToggleButton extends StatelessWidget {
  final bool isSelected;
  final String text;
  final VoidCallback onTap;
  final Color color;

  const _ToggleButton({
    required this.isSelected,
    required this.text,
    required this.onTap,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: AppConstants.shortAnimation,
        margin: const EdgeInsets.all(4),
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? color : Colors.transparent,
          borderRadius: BorderRadius.circular(AppConstants.mediumRadius),
        ),
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            color: isSelected
                ? Colors.white
                : Theme.of(context).colorScheme.onSurfaceVariant,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
