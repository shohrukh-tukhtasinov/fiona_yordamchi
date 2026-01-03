import 'package:flutter/foundation.dart';
import '../../data/services/hive_service.dart';
import '../../core/enums/currency_type.dart';

class CurrencyViewModel extends ChangeNotifier {
  CurrencyType _selectedCurrency = CurrencyType.usd;
  double _usdToUzsRate = 12600.0;
  bool _isLoading = false;

  CurrencyType get selectedCurrency => _selectedCurrency;
  double get usdToUzsRate => _usdToUzsRate;
  bool get isLoading => _isLoading;

  CurrencyViewModel() {
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    _isLoading = true;
    notifyListeners();

    try {
      // Load selected currency
      final savedCurrency = HiveService.getSelectedCurrency();
      _selectedCurrency = CurrencyType.values.firstWhere(
        (currency) => currency.code == savedCurrency,
        orElse: () => CurrencyType.usd,
      );

      // Load currency rate
      final rateModel = HiveService.getCurrencyRate();
      if (rateModel != null) {
        _usdToUzsRate = rateModel.usdToUzs;
      } else {
        // Save default rate if none exists
        await HiveService.saveDefaultCurrencyRate();
        _usdToUzsRate = 12600.0;
      }
    } catch (e) {
      debugPrint('Error loading currency settings: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> setSelectedCurrency(CurrencyType currency) async {
    if (_selectedCurrency == currency) return;

    _selectedCurrency = currency;
    await HiveService.saveSelectedCurrency(currency.code);
    notifyListeners();
  }

  Future<void> updateExchangeRate(double newRate) async {
    if (_usdToUzsRate == newRate) return;

    _usdToUzsRate = newRate;
    
    final rateModel = HiveService.getCurrencyRate();
    if (rateModel != null) {
      final updatedRate = rateModel.copyWith(usdToUzs: newRate);
      await HiveService.saveCurrencyRate(updatedRate);
    } else {
      await HiveService.saveDefaultCurrencyRate();
    }
    
    notifyListeners();
  }

  double convertAmount(double amount, {CurrencyType? fromCurrency, CurrencyType? toCurrency}) {
    fromCurrency = fromCurrency ?? _selectedCurrency;
    toCurrency = toCurrency ?? _selectedCurrency;

    if (fromCurrency == toCurrency) return amount;

    // Convert to USD first, then to target currency
    double amountInUsd = amount;
    if (fromCurrency == CurrencyType.uzs) {
      amountInUsd = amount / _usdToUzsRate;
    }

    // Convert from USD to target currency
    if (toCurrency == CurrencyType.uzs) {
      return amountInUsd * _usdToUzsRate;
    }

    return amountInUsd; // USD
  }

  String formatAmount(double amount, {CurrencyType? currency}) {
    currency = currency ?? _selectedCurrency;
    
    switch (currency) {
      case CurrencyType.usd:
        return '\$${amount.toStringAsFixed(2)}';
      case CurrencyType.uzs:
        return '${amount.toStringAsFixed(0)} ${currency.symbol}';
    }
  }

  String getCurrencySymbol({CurrencyType? currency}) {
    currency = currency ?? _selectedCurrency;
    return currency.symbol;
  }
}
