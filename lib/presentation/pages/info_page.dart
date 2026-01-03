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
import 'optimized_home_page.dart';

class InfoPage extends StatelessWidget {
  const InfoPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: const Text('Ilova Haqida'),
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
          Container(
            margin: const EdgeInsets.only(right: 16),
            child: ElevatedButton.icon(
              onPressed: () {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(
                    builder: (context) => const OptimizedHomePage(),
                  ),
                );
              },
              icon: const Icon(Icons.home_outlined),
              label: const Text('Bosh Sahifa'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppConstants.largePadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildAppInfo(context),
            const SizedBox(height: AppConstants.largePadding),
            _buildFeatures(context),
            const SizedBox(height: AppConstants.largePadding),
            _buildInstructions(context),
            const SizedBox(height: AppConstants.largePadding),
            _buildTechnicalInfo(context),
          ],
        ),
      ),
    );
  }

  Widget _buildAppInfo(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppConstants.mediumPadding),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceVariant,
        borderRadius: BorderRadius.circular(AppConstants.mediumRadius),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.incomeColor.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(AppConstants.smallRadius),
                ),
                child: Icon(
                  Icons.account_balance_wallet_outlined,
                  color: AppTheme.incomeColor,
                  size: 24,
                ),
              ),
              const SizedBox(width: AppConstants.mediumPadding),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Fiona Yordamchi (Beta)',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Moliyaviy boshqaruvchi',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppConstants.mediumPadding),
          Text(
            'Fiona Yordamchi - bu sizning moliyaviy holatingizni kuzatish va boshqarish uchun yaratilgan zamonaviy ilova. Ilova ikkita valyutada (USD va UZS) ishlashi, oflayn ma\'lumotlar bazasiga ega ekanligi bilan qulaylik taklom etadi.',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              height: 1.5,
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.8),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatures(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppConstants.mediumPadding),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceVariant,
        borderRadius: BorderRadius.circular(AppConstants.mediumRadius),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Asosiy Imkoniyatlar',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w700,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          const SizedBox(height: AppConstants.mediumPadding),
          _FeatureItem(
            icon: Icons.currency_exchange,
            title: 'Ikki Valyuta',
            description: 'USD va UZS valyutalarida amaliyotlarni kuzatish',
          ),
          _FeatureItem(
            icon: Icons.offline_bolt,
            title: 'Oflayn Ishlash',
            description: 'Internet aloqasisiz ishlashi',
          ),
          _FeatureItem(
            icon: Icons.analytics,
            title: 'Hisobotlar',
            description: 'Daromad va xarajatlarning tahlili',
          ),
          _FeatureItem(
            icon: Icons.speed,
            title: 'Tezkor Interfeys',
            description: 'Silliq va intuitiv dizayn',
          ),
        ],
      ),
    );
  }

  Widget _buildInstructions(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppConstants.mediumPadding),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceVariant,
        borderRadius: BorderRadius.circular(AppConstants.mediumRadius),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Ilovani Ishlatish',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w700,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          const SizedBox(height: AppConstants.mediumPadding),
          _InstructionStep(
            stepNumber: 1,
            title: 'Amaliyot Qo\'shish',
            description: 'Asosiy ekranning yuqorisidagi + tugmasini bosing yoki AppBar dagi qo\'shish tugmasidan foydalaning.',
          ),
          _InstructionStep(
            stepNumber: 2,
            title: 'Valyutani Tanlang',
            description: 'Balans kartkasida yoki AppBar dagi USD/UZS tugmalaridan birini tanlang.',
          ),
          _InstructionStep(
            stepNumber: 3,
            title: 'Tezkor Amallar',
            description: '"Tezkor Amallar" bo\'limidan to\'g\'ri daromad yoki xarajat qo\'shing.',
          ),
          _InstructionStep(
            stepNumber: 4,
            title: 'Amaliyotlarni Boshqarish',
            description: 'Amaliyotga chap tomonga surib o\'chirish tugmasini bosing.',
          ),
        ],
      ),
    );
  }

  Widget _buildTechnicalInfo(BuildContext context) {
    return Consumer<TransactionViewModel>(
      builder: (context, viewModel, child) {
        return Container(
          padding: const EdgeInsets.all(AppConstants.mediumPadding),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceVariant,
            borderRadius: BorderRadius.circular(AppConstants.mediumRadius),
            border: Border.all(
              color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Texnik Ma\'lumot',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              const SizedBox(height: AppConstants.mediumPadding),
              _InfoRow(
                label: 'Joriy Valyuta',
                value: viewModel.displayCurrency.displayName,
              ),
              _InfoRow(
                label: 'USD kursi',
                value: '1 USD = ${viewModel.usdToUzsRate.toStringAsFixed(0)} UZS',
              ),
              _InfoRow(
                label: 'Amaliyotlar soni',
                value: '${viewModel.transactions.length} ta',
              ),
              _InfoRow(
                label: 'Versiya',
                value: '1.0.0 (Beta)',
              ),
            ],
          ),
        );
      }
    );
  }
}

class _FeatureItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;

  const _FeatureItem({
    required this.icon,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppConstants.mediumPadding),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(AppConstants.smallRadius),
            ),
            child: Icon(
              icon,
              color: Theme.of(context).colorScheme.primary,
              size: 20,
            ),
          ),
          const SizedBox(width: AppConstants.mediumPadding),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _InstructionStep extends StatelessWidget {
  final int stepNumber;
  final String title;
  final String description;

  const _InstructionStep({
    required this.stepNumber,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppConstants.mediumPadding),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary,
              borderRadius: BorderRadius.circular(AppConstants.smallRadius),
            ),
            child: Center(
              child: Text(
                '$stepNumber',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
          const SizedBox(width: AppConstants.mediumPadding),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppConstants.smallPadding),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
            ),
          ),
          Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
        ],
      ),
    );
  }
}
