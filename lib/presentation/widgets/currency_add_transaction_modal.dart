import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../../domain/entities/transaction.dart';
import '../../core/constants/app_constants.dart';
import '../../core/themes/app_theme.dart';
import '../../core/enums/currency_type.dart';
import '../state/transaction_view_model.dart';

class CurrencyAddTransactionModal extends StatefulWidget {
  final bool initialIsIncome;
  
  const CurrencyAddTransactionModal({super.key, this.initialIsIncome = true});

  @override
  State<CurrencyAddTransactionModal> createState() => _CurrencyAddTransactionModalState();
}

class _CurrencyAddTransactionModalState extends State<CurrencyAddTransactionModal>
    with TickerProviderStateMixin {
  late AnimationController _slideController;
  late AnimationController _successController;
  late AnimationController _buttonController;
  late Animation<double> _slideAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<double> _successScaleAnimation;
  late Animation<double> _buttonScaleAnimation;

  final _amountController = TextEditingController();
  final _noteController = TextEditingController();
  bool _isIncome = true;
  bool _isLoading = false;
  bool _showSuccess = false;
  CurrencyType _selectedCurrency = CurrencyType.usd;

  @override
  void initState() {
    super.initState();
    _isIncome = widget.initialIsIncome;
    
    _slideController = AnimationController(
      duration: AppConstants.mediumAnimation,
      vsync: this,
    );

    _successController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _buttonController = AnimationController(
      duration: AppConstants.shortAnimation,
      vsync: this,
    );

    _slideAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
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

    _successScaleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _successController,
      curve: Curves.elasticOut,
    ));

    _buttonScaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _buttonController,
      curve: Curves.easeInOut,
    ));

    _slideController.forward();
  }

  @override
  void dispose() {
    _slideController.dispose();
    _successController.dispose();
    _buttonController.dispose();
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _slideController,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, (1 - _slideAnimation.value) * 100),
          child: Opacity(
            opacity: _fadeAnimation.value,
            child: _showSuccess ? _SuccessAnimation() : _MainContent(),
          ),
        );
      },
    );
  }

  Widget _MainContent() {
    return DraggableScrollableSheet(
      initialChildSize: 0.85,
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
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 20,
                offset: const Offset(0, -10),
              ),
            ],
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
                _buildCurrencySelector(),
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
    );
  }

  Widget _SuccessAnimation() {
    return Container(
      height: 200,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(AppConstants.extraLargeRadius),
          topRight: Radius.circular(AppConstants.extraLargeRadius),
        ),
      ),
      child: Center(
        child: AnimatedBuilder(
          animation: _successController,
          builder: (context, child) {
            return Transform.scale(
              scale: _successScaleAnimation.value,
              child: Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: AppTheme.incomeColor,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.incomeColor.withOpacity(0.4),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.check_rounded,
                  color: Colors.white,
                  size: 40,
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        AnimatedContainer(
          duration: AppConstants.shortAnimation,
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
            'Amaliyot Qo\'shish',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        _CloseButton(),
      ],
    );
  }

  Widget _CloseButton() {
    return GestureDetector(
      onTap: _handleClose,
      child: AnimatedContainer(
        duration: AppConstants.shortAnimation,
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceVariant,
          borderRadius: BorderRadius.circular(AppConstants.mediumRadius),
        ),
        child: const Icon(Icons.close, size: 20),
      ),
    );
  }

  Widget _buildCurrencySelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Valyuta',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: AppConstants.smallPadding),
        Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceVariant,
            borderRadius: BorderRadius.circular(AppConstants.largeRadius),
          ),
          child: Row(
            children: [
              Expanded(
                child: _CurrencyButton(
                  isSelected: _selectedCurrency == CurrencyType.usd,
                  text: 'USD',
                  subtitle: 'AQSH dollari',
                  onTap: () => setState(() => _selectedCurrency = CurrencyType.usd),
                ),
              ),
              Expanded(
                child: _CurrencyButton(
                  isSelected: _selectedCurrency == CurrencyType.uzs,
                  text: 'UZS',
                  subtitle: "O'zbek so'mi",
                  onTap: () => setState(() => _selectedCurrency = CurrencyType.uzs),
                ),
              ),
            ],
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
              onTap: () => _toggleTransactionType(true),
              color: AppTheme.incomeColor,
            ),
          ),
          Expanded(
            child: _ToggleButton(
              isSelected: !_isIncome,
              text: 'Xarajat',
              onTap: () => _toggleTransactionType(false),
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
            fontWeight: FontWeight.w700,
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
            fontWeight: FontWeight.w800,
            color: _isIncome ? AppTheme.incomeColor : AppTheme.expenseColor,
            height: 1.2,
          ),
          decoration: InputDecoration(
            prefixText: _selectedCurrency == CurrencyType.usd ? '\$' : '',
            prefixStyle: Theme.of(context).textTheme.headlineLarge?.copyWith(
              fontWeight: FontWeight.w800,
              color: _isIncome ? AppTheme.incomeColor : AppTheme.expenseColor,
            ),
            suffixText: _selectedCurrency == CurrencyType.uzs ? ' so\'m' : '',
            suffixStyle: Theme.of(context).textTheme.headlineLarge?.copyWith(
              fontWeight: FontWeight.w800,
              color: _isIncome ? AppTheme.incomeColor : AppTheme.expenseColor,
            ),
            hintText: _selectedCurrency == CurrencyType.usd ? '0.00' : '0',
            hintStyle: Theme.of(context).textTheme.headlineLarge?.copyWith(
              fontWeight: FontWeight.w800,
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.3),
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppConstants.mediumRadius),
              borderSide: BorderSide.none,
            ),
            filled: true,
            fillColor: Theme.of(context).colorScheme.surfaceVariant,
            contentPadding: const EdgeInsets.all(AppConstants.mediumPadding),
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
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: AppConstants.smallPadding),
        TextField(
          controller: _noteController,
          maxLines: 3,
          decoration: InputDecoration(
            hintText: 'Ushbu amaliyot uchun izoh qo\'shing...',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppConstants.mediumRadius),
              borderSide: BorderSide.none,
            ),
            filled: true,
            fillColor: Theme.of(context).colorScheme.surfaceVariant,
            contentPadding: const EdgeInsets.all(AppConstants.mediumPadding),
          ),
        ),
      ],
    );
  }

  Widget _buildSaveButton() {
    return AnimatedBuilder(
      animation: _buttonController,
      builder: (context, child) {
        return Transform.scale(
          scale: _buttonScaleAnimation.value,
          child: SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _saveTransaction,
              style: ElevatedButton.styleFrom(
                backgroundColor: _isIncome ? AppTheme.incomeColor : AppTheme.expenseColor,
                foregroundColor: Colors.white,
                elevation: 4,
                shadowColor: (_isIncome ? AppTheme.incomeColor : AppTheme.expenseColor).withOpacity(0.4),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppConstants.mediumRadius),
                ),
              ),
              child: _isLoading
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : Text(
                      'Amaliyotni Saqlash',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.5,
                      ),
                    ),
            ),
          ),
        );
      },
    );
  }

  Widget _CurrencyButton({
    required bool isSelected,
    required String text,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: () {
        _buttonController.forward().then((_) => _buttonController.reverse());
        onTap();
      },
      child: AnimatedContainer(
        duration: AppConstants.shortAnimation,
        margin: const EdgeInsets.all(4),
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: isSelected ? Theme.of(context).colorScheme.primary.withOpacity(0.2) : Colors.transparent,
          borderRadius: BorderRadius.circular(AppConstants.mediumRadius),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Column(
          children: [
            Text(
              text,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: isSelected
                    ? Theme.of(context).colorScheme.primary
                    : Theme.of(context).colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: isSelected
                    ? Theme.of(context).colorScheme.primary
                    : Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.7),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _ToggleButton({
    required bool isSelected,
    required String text,
    required VoidCallback onTap,
    required Color color,
  }) {
    return GestureDetector(
      onTap: () {
        _buttonController.forward().then((_) => _buttonController.reverse());
        onTap();
      },
      child: AnimatedContainer(
        duration: AppConstants.shortAnimation,
        margin: const EdgeInsets.all(4),
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: isSelected ? color : Colors.transparent,
          borderRadius: BorderRadius.circular(AppConstants.mediumRadius),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: color.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Center(
          child: Text(
            text,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: isSelected
                  ? Colors.white
                  : Theme.of(context).colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }

  void _toggleTransactionType(bool isIncome) {
    setState(() => _isIncome = isIncome);
  }

  Future<void> _saveTransaction() async {
    final amountText = _amountController.text.trim();
    if (amountText.isEmpty) {
      _showError('Iltimos, summani kiriting');
      return;
    }

    final amount = double.tryParse(amountText);
    if (amount == null || amount <= 0) {
      _showError('Iltimos, to\'g\'ri summani kiriting');
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
        currencyCode: _selectedCurrency.code,
      );

      // Simulate network delay for better UX
      await Future.delayed(const Duration(milliseconds: 800));

      if (mounted) {
        setState(() {
          _isLoading = false;
          _showSuccess = true;
        });

        _successController.forward().then((_) {
          if (mounted) {
            Navigator.of(context).pop(transaction);
          }
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        _showError('Amaliyotni saqlashda xatolik yuz berdi');
      }
    }
  }

  void _handleClose() {
    if (_isLoading) return;
    Navigator.of(context).pop();
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.error_outline, color: Colors.white, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: AppTheme.expenseColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.mediumRadius),
        ),
        duration: const Duration(seconds: 3),
      ),
    );
  }
}
