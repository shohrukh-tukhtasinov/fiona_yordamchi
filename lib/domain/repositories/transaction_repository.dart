import '../entities/transaction.dart';

abstract class TransactionRepository {
  Future<List<Transaction>> getAllTransactions();
  Future<Transaction?> getTransactionById(String id);
  Future<void> addTransaction(Transaction transaction);
  Future<void> updateTransaction(Transaction transaction);
  Future<void> deleteTransaction(String id);
  Future<double> getTotalIncome();
  Future<double> getTotalExpense();
  Future<double> getBalance();
}
