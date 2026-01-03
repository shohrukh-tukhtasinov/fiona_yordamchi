import '../../domain/entities/transaction.dart';
import '../../domain/repositories/transaction_repository.dart';
import '../models/transaction_model.dart';
import '../services/hive_service.dart';

class TransactionRepositoryImpl implements TransactionRepository {
  @override
  Future<List<Transaction>> getAllTransactions() async {
    final box = HiveService.getTransactionBox();
    final transactions = box.values.map((model) => model.toEntity()).toList();
    
    // Sort by date (newest first)
    transactions.sort((a, b) => b.date.compareTo(a.date));
    
    return transactions;
  }

  @override
  Future<Transaction?> getTransactionById(String id) async {
    final box = HiveService.getTransactionBox();
    final model = box.get(id);
    return model?.toEntity();
  }

  @override
  Future<void> addTransaction(Transaction transaction) async {
    final model = TransactionModel(
      id: transaction.id,
      amount: transaction.amount,
      isIncome: transaction.isIncome,
      note: transaction.note,
      date: transaction.date,
      currencyCode: transaction.currencyCode,
    );
    
    await HiveService.transactionsBox.add(model);
  }

  @override
  Future<void> updateTransaction(Transaction transaction) async {
    final model = TransactionModel(
      id: transaction.id,
      amount: transaction.amount,
      isIncome: transaction.isIncome,
      note: transaction.note,
      date: transaction.date,
      currencyCode: transaction.currencyCode,
    );
    
    await model.save();
  }

  @override
  Future<void> deleteTransaction(String id) async {
    final box = HiveService.getTransactionBox();
    await box.delete(id);
  }

  @override
  Future<double> getTotalIncome() async {
    final box = HiveService.getTransactionBox();
    final transactions = box.values.where((model) => model.isIncome);
    double total = 0.0;
    for (final model in transactions) {
      total += model.amount;
    }
    return total;
  }

  @override
  Future<double> getTotalExpense() async {
    final box = HiveService.getTransactionBox();
    final transactions = box.values.where((model) => !model.isIncome);
    double total = 0.0;
    for (final model in transactions) {
      total += model.amount;
    }
    return total;
  }

  @override
  Future<double> getBalance() async {
    final income = await getTotalIncome();
    final expense = await getTotalExpense();
    return income - expense;
  }
}
