import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/transaction_bloc.dart';
import '../bloc/transaction_event.dart';
import '../bloc/transaction_state.dart';
import '../widgets/balance_card.dart';
import '../widgets/transaction_item.dart';
import '../widgets/empty_state.dart';
import '../widgets/add_transaction_modal.dart';
import '../../core/constants/app_constants.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: const Text('Expense Tracker'),
        centerTitle: true,
      ),
      body: BlocBuilder<TransactionBloc, TransactionState>(
        builder: (context, state) {
          if (state is TransactionLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (state is TransactionError) {
            return Center(
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
                    'Something went wrong',
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const SizedBox(height: AppConstants.smallPadding),
                  Text(
                    state.message,
                    style: Theme.of(context).textTheme.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppConstants.largePadding),
                  ElevatedButton(
                    onPressed: () {
                      context.read<TransactionBloc>().add(LoadTransactions());
                    },
                    child: const Text('Try Again'),
                  ),
                ],
              ),
            );
          }

          if (state is TransactionLoaded) {
            return RefreshIndicator(
              onRefresh: () async {
                context.read<TransactionBloc>().add(LoadTransactions());
              },
              child: CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(
                    child: BalanceCard(
                      balance: state.balance,
                      totalIncome: state.totalIncome,
                      totalExpense: state.totalExpense,
                    ),
                  ),
                  if (state.transactions.isEmpty)
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
                            final transaction = state.transactions[index];
                            return TransactionItem(
                              transaction: transaction,
                              onSwipe: () {
                                _showDeleteConfirmation(context, transaction);
                              },
                            );
                          },
                          childCount: state.transactions.length,
                        ),
                      ),
                    ),
                ],
              ),
            );
          }

          return const SizedBox.shrink();
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          _showAddTransactionModal(context);
        },
        icon: const Icon(Icons.add),
        label: const Text('Add Transaction'),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  void _showAddTransactionModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const AddTransactionModal(),
    );
  }

  void _showDeleteConfirmation(BuildContext context, transaction) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Amaliyotni o'chirish"),
        content: Text("Ushbu amaloyotni o'chirmoqchimisiz?\n\n${transaction.note}"),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Bekor qilish'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              context.read<TransactionBloc>().add(DeleteTransaction(transaction.id));
            },
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text("O'chirih"),
          ),
        ],
      ),
    );
  }
}
