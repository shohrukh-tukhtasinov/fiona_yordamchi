import 'package:flutter/foundation.dart';
import '../../domain/entities/transaction.dart';
import '../../domain/repositories/transaction_repository.dart';
import '../../core/enums/currency_type.dart';
import '../../data/services/hive_service.dart';

class TransactionViewModel extends ChangeNotifier {
  final TransactionRepository _repository;
  
  List<Transaction> _transactions = [];
  bool _isLoading = false;
  String? _error;
  CurrencyType _displayCurrency = CurrencyType.usd;
  double _usdToUzsRate = 12600.0;

  TransactionViewModel({required TransactionRepository repository}) 
      : _repository = repository {
    _loadTransactions();
  }

  // Getters
  List<Transaction> get transactions => _transactions;
  bool get isLoading => _isLoading;
  String? get error => _error;
  CurrencyType get displayCurrency => _displayCurrency;
  double get usdToUzsRate => _usdToUzsRate;

  // Computed properties
  double get balance {
    double total = 0.0;
    for (final transaction in _transactions) {
      final amount = _convertToDisplayCurrency(
        transaction.amount, 
        transaction.currencyCode
      );
      total += transaction.isIncome ? amount : -amount;
    }
    return total;
  }

  double get totalIncome {
    double total = 0.0;
    for (final transaction in _transactions.where((t) => t.isIncome)) {
      total += _convertToDisplayCurrency(transaction.amount, transaction.currencyCode);
    }
    return total;
  }

  double get totalExpense {
    double total = 0.0;
    for (final transaction in _transactions.where((t) => !t.isIncome)) {
      total += _convertToDisplayCurrency(transaction.amount, transaction.currencyCode);
    }
    return total;
  }

  double _convertToDisplayCurrency(double amount, String currencyCode) {
    if (currencyCode == 'USD' && _displayCurrency == CurrencyType.uzs) {
      return amount * _usdToUzsRate;
    } else if (currencyCode == 'UZS' && _displayCurrency == CurrencyType.usd) {
      return amount / _usdToUzsRate;
    }
    return amount; // Same currency
  }

  Future<void> _loadTransactions() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _transactions = await _repository.getAllTransactions();
      _transactions.sort((a, b) => b.date.compareTo(a.date));
    } catch (e) {
      _error = e.toString();
      debugPrint('Error loading transactions: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> refresh() async {
    await _loadTransactions();
  }

  Future<void> addTransaction(Transaction transaction) async {
    try {
      await _repository.addTransaction(transaction);
      await _loadTransactions();
    } catch (e) {
      _error = e.toString();
      debugPrint('Error adding transaction: $e');
      notifyListeners();
    }
  }

  Future<void> updateTransaction(Transaction transaction) async {
    try {
      await _repository.updateTransaction(transaction);
      await _loadTransactions();
    } catch (e) {
      _error = e.toString();
      debugPrint('Error updating transaction: $e');
      notifyListeners();
    }
  }

  Future<void> deleteTransaction(String id) async {
    try {
      await _repository.deleteTransaction(id);
      await _loadTransactions();
    } catch (e) {
      _error = e.toString();
      debugPrint('Error deleting transaction: $e');
      notifyListeners();
    }
  }

  void setDisplayCurrency(CurrencyType currency) {
    if (_displayCurrency == currency) return;
    _displayCurrency = currency;
    notifyListeners();
  }

  void setExchangeRate(double rate) {
    if (_usdToUzsRate == rate) return;
    _usdToUzsRate = rate;
    notifyListeners();
  }

  String formatAmount(double amount, {String? currencyCode}) {
    final displayAmount = currencyCode != null 
        ? _convertToDisplayCurrency(amount, currencyCode)
        : amount;
    
    switch (_displayCurrency) {
      case CurrencyType.usd:
        return '\$${displayAmount.toStringAsFixed(2)}';
      case CurrencyType.uzs:
        return '${displayAmount.toStringAsFixed(0)} so\'m';
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  Future<void> clearAllData() async {
    try {
      _isLoading = true;
      notifyListeners();
      
      await HiveService.clearAllData();
      
      // Reset local state
      _transactions = [];
      _displayCurrency = CurrencyType.usd;
      _usdToUzsRate = 12600.0;
      _error = null;
      
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = 'Ma\'lumotlarni tozalashda xatolik: $e';
      _isLoading = false;
      notifyListeners();
    }
  }
}
