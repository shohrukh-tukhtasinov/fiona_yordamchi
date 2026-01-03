import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../state/transaction_view_model.dart';
import '../widgets/currency_balance_card.dart';
import '../widgets/currency_transaction_item.dart';
import '../widgets/currency_add_transaction_modal.dart';
import '../widgets/empty_state.dart';
import '../../domain/entities/transaction.dart';
import '../../core/constants/app_constants.dart';
import '../../core/themes/app_theme.dart';
import '../../core/enums/currency_type.dart';
import 'info_page.dart';

class OptimizedHomePage extends StatelessWidget {
  const OptimizedHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      extendBodyBehindAppBar: false,
      appBar: _AppBar(),
      body: _Body(),
    );
  }
}

class _AppBar extends StatelessWidget implements PreferredSizeWidget {
  const _AppBar();

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: const Text('Fiona Yordamchi (Beta)'),
      centerTitle: true,
      backgroundColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
      systemOverlayStyle: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Theme.of(context).brightness == Brightness.dark
            ? Brightness.light
            : Brightness.dark,
      ),
      actions: [
        _InfoButton(),
        _CurrencyToggle(),
        const SizedBox(width: 8),
        _AddTransactionButton(),
        const SizedBox(width: 16),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class _Body extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: context.watch<TransactionViewModel>(),
      builder: (context, child) {
        final viewModel = context.read<TransactionViewModel>();
        
        if (viewModel.isLoading) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        if (viewModel.error != null) {
          return _ErrorView(
            error: viewModel.error!,
            onRetry: viewModel.refresh,
          );
        }

        return RefreshIndicator(
          onRefresh: viewModel.refresh,
          child: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: _AppHeader(),
              ),
              SliverToBoxAdapter(
                child: CurrencyBalanceCard(),
              ),
              SliverToBoxAdapter(
                child: _QuickActions(),
              ),
              if (viewModel.transactions.isEmpty)
                const SliverFillRemaining(
                  child: EmptyState(),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.only(
                    left: AppConstants.mediumPadding,
                    right: AppConstants.mediumPadding,
                    bottom: AppConstants.extraLargePadding,
                  ),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final transaction = viewModel.transactions[index];
                        return AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeOut,
                          child: CurrencyTransactionItem(
                            key: ValueKey(transaction.id),
                            transaction: transaction,
                            onDelete: () => _showDeleteConfirmation(context, transaction),
                            animation: AlwaysStoppedAnimation(1.0),
                          ),
                        );
                      },
                      childCount: viewModel.transactions.length,
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  void _showDeleteConfirmation(BuildContext context, transaction) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Amaliyotni O\'chirish'),
        content: Text(
          'Ushbu amaliyotni o\'chirmoqchimisiz?\n\n${transaction.note}',
          style: Theme.of(context).textTheme.bodyMedium,
          textAlign: TextAlign.center,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Bekor qilish'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              context.read<TransactionViewModel>().deleteTransaction(transaction.id);
            },
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('O\'chirish'),
          ),
        ],
      ),
    );
  }
}

class _AppHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(
        left: AppConstants.mediumPadding,
        right: AppConstants.mediumPadding,
        top: AppConstants.mediumPadding,
        bottom: AppConstants.smallPadding,
      ),
      padding: const EdgeInsets.all(AppConstants.mediumPadding),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Theme.of(context).colorScheme.primary.withOpacity(0.1),
            Theme.of(context).colorScheme.secondary.withOpacity(0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(AppConstants.mediumRadius),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withOpacity(0.1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(AppConstants.smallRadius),
                ),
                child: Icon(
                  Icons.account_balance_wallet_outlined,
                  color: Theme.of(context).colorScheme.primary,
                  size: 24,
                ),
              ),
              const SizedBox(width: AppConstants.mediumPadding),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Fiona Yordamchi',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                    Text(
                      '(Beta)',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context).colorScheme.primary.withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppConstants.smallPadding),
          Consumer<TransactionViewModel>(
            builder: (context, viewModel, child) {
              return Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    size: 14,
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'Amaliyotlar: ${viewModel.transactions.length} ta',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                    ),
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 4),
          _AuthorInfo(),
        ],
      ),
    );
  }
}

class _AuthorInfo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPress: () {
        _showAuthorDialog(context);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.5),
          borderRadius: BorderRadius.circular(AppConstants.smallRadius),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.code,
              size: 12,
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.4),
            ),
            const SizedBox(width: 4),
            Text(
              'v1.0.0 Shohrux Tuxtasinov',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.4),
                fontSize: 10,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAuthorDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(
              Icons.info,
              color: Theme.of(context).colorScheme.primary,
              size: 24,
            ),
            const SizedBox(width: 12),
            const Text('Ilova Haqida'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Fiona Yordamchi (Beta)',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Moliyaviy boshqaruvchi ilovasi',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Icon(
                  Icons.person,
                  size: 16,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  'Muallif: Tuxtasinov Shohrux',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(
                  Icons.build,
                  size: 16,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  'Versiya: 1.0.0 (Beta)',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Yopish'),
          ),
          Consumer<TransactionViewModel>(
            builder: (context, viewModel, child) {
              return TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  _showClearDataConfirmation(context, viewModel);
                },
                style: TextButton.styleFrom(
                  foregroundColor: Theme.of(context).colorScheme.error,
                ),
                child: const Text('Ma\'lumotlarni Tozalash'),
              );
            },
          ),
        ],
      ),
    );
  }

  void _showClearDataConfirmation(BuildContext context, TransactionViewModel viewModel) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(
              Icons.warning,
              color: Theme.of(context).colorScheme.error,
              size: 24,
            ),
            const SizedBox(width: 12),
            const Text('Diqqat!'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Barcha ma\'lumotlarni tozalashni istaysizmi?',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Bu amal barcha amaliyotlarni, valyuta kurslarini va sozlamalarni o\'chirib tashlaydi. Bu amalni qaytarib bo\'lmaydi!',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.error.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: Theme.of(context).colorScheme.error.withOpacity(0.3),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    size: 16,
                    color: Theme.of(context).colorScheme.error,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Joriy amaliyotlar: ${viewModel.transactions.length} ta',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.error,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Bekor qilish'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop();
              await viewModel.clearAllData();
              _showClearSuccessSnackBar(context);
            },
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.error,
              backgroundColor: Theme.of(context).colorScheme.error.withOpacity(0.1),
            ),
            child: const Text('Tozalash'),
          ),
        ],
      ),
    );
  }

  void _showClearSuccessSnackBar(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: 8),
            Text(
              'Barcha ma\'lumotlar muvaffaqiyatli tozalandi',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        backgroundColor: AppTheme.expenseColor,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
      ),
    );
  }
}

class _InfoButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      child: IconButton(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => const InfoPage(),
            ),
          );
        },
        icon: const Icon(Icons.info_outline),
        tooltip: 'Ilova haqida',
      ),
    );
  }
}

class _QuickActions extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<TransactionViewModel>(
      builder: (context, viewModel, child) {
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: AppConstants.mediumPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Tezkor Amallar',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.8),
                ),
              ),
              const SizedBox(height: AppConstants.smallPadding),
              Row(
                children: [
                  Expanded(
                    child: _QuickActionCard(
                      icon: Icons.trending_up,
                      label: 'Daromad',
                      amount: viewModel.totalIncome,
                      color: AppTheme.incomeColor,
                      onTap: () => _showAddTransactionModal(context, true),
                    ),
                  ),
                  const SizedBox(width: AppConstants.mediumPadding),
                  Expanded(
                    child: _QuickActionCard(
                      icon: Icons.trending_down,
                      label: 'Xarajat',
                      amount: viewModel.totalExpense,
                      color: AppTheme.expenseColor,
                      onTap: () => _showAddTransactionModal(context, false),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      }
    );
  }

  void _showAddTransactionModal(BuildContext context, bool isIncome) {
    showModalBottomSheet<Transaction>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => CurrencyAddTransactionModal(
        initialIsIncome: isIncome,
      ),
    ).then((transaction) {
      if (transaction != null) {
        context.read<TransactionViewModel>().addTransaction(transaction);
        _showSuccessSnackBar(context);
      }
    });
  }

  void _showSuccessSnackBar(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: 8),
            Text(
              'Amaliyot muvaffaqiyatli qo\'shildi',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        backgroundColor: AppTheme.incomeColor,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }
}

class _QuickActionCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final double amount;
  final Color color;
  final VoidCallback onTap;

  const _QuickActionCard({
    required this.icon,
    required this.label,
    required this.amount,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<TransactionViewModel>(
      builder: (context, viewModel, child) {
        return GestureDetector(
          onTap: onTap,
          child: AnimatedContainer(
            duration: AppConstants.shortAnimation,
            padding: const EdgeInsets.all(AppConstants.mediumPadding),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(AppConstants.mediumRadius),
              border: Border.all(
                color: color.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(AppConstants.smallRadius),
                      ),
                      child: Icon(
                        icon,
                        color: color,
                        size: 16,
                      ),
                    ),
                    const Spacer(),
                    Icon(
                      Icons.add_circle_outline,
                      color: color,
                      size: 16,
                    ),
                  ],
                ),
                const SizedBox(height: AppConstants.smallPadding),
                Text(
                  label,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    viewModel.formatAmount(amount),
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: color,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      }
    );
  }
}

class _CurrencyToggle extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<TransactionViewModel>(
      builder: (context, viewModel, child) {
        return Container(
          margin: const EdgeInsets.only(right: 8),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceVariant,
            borderRadius: BorderRadius.circular(AppConstants.mediumRadius),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              GestureDetector(
                onTap: () => viewModel.setDisplayCurrency(CurrencyType.usd),
                child: AnimatedContainer(
                  duration: AppConstants.shortAnimation,
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: viewModel.displayCurrency == CurrencyType.usd
                        ? Theme.of(context).colorScheme.primary
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(AppConstants.smallRadius),
                  ),
                  child: Text(
                    'USD',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: viewModel.displayCurrency == CurrencyType.usd
                          ? Theme.of(context).colorScheme.onPrimary
                          : Theme.of(context).colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 4),
              GestureDetector(
                onTap: () => viewModel.setDisplayCurrency(CurrencyType.uzs),
                child: AnimatedContainer(
                  duration: AppConstants.shortAnimation,
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: viewModel.displayCurrency == CurrencyType.uzs
                        ? Theme.of(context).colorScheme.primary
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(AppConstants.smallRadius),
                  ),
                  child: Text(
                    'UZS',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: viewModel.displayCurrency == CurrencyType.uzs
                          ? Theme.of(context).colorScheme.onPrimary
                          : Theme.of(context).colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      }
    );
  }
}

class _AddTransactionButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary,
        borderRadius: BorderRadius.circular(AppConstants.mediumRadius),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: IconButton(
        onPressed: () => _showAddTransactionModal(context),
        icon: const Icon(Icons.add, color: Colors.white),
        tooltip: 'Amaliyot Qo\'shish',
      ),
    );
  }

  void _showAddTransactionModal(BuildContext context) {
    showModalBottomSheet<Transaction>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const CurrencyAddTransactionModal(),
    ).then((transaction) {
      if (transaction != null) {
        context.read<TransactionViewModel>().addTransaction(transaction);
        _showSuccessSnackBar(context);
      }
    });
  }

  void _showSuccessSnackBar(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: 8),
            Text(
              'Amaliyot muvaffaqiyatli qo\'shildi',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        backgroundColor: AppTheme.incomeColor,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  final String error;
  final VoidCallback onRetry;

  const _ErrorView({
    required this.error,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.largePadding),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(height: AppConstants.mediumPadding),
            Text(
              'Nimadir xato ketdi',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: AppConstants.smallPadding),
            Text(
              error,
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppConstants.largePadding),
            ElevatedButton(
              onPressed: onRetry,
              child: const Text('Qayta urinish'),
            ),
          ],
        ),
      ),
    );
  }
}
