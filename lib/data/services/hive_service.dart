import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/transaction_model.dart';
import '../models/currency_rate_model.dart';

class HiveService {
  static const String _transactionsBoxName = 'transactions';
  static const String _currencyRateBoxName = 'currency_rate';
  static const String _settingsBoxName = 'settings';

  static Future<void> init() async {
    await Hive.initFlutter();
    
    // Register adapters
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(TransactionModelAdapter());
    }
    if (!Hive.isAdapterRegistered(1)) {
      Hive.registerAdapter(CurrencyRateModelAdapter());
    }
    
    // Clear old data to avoid migration issues
    await _clearOldData();
    
    // Open boxes
    await openBox();
    await Hive.openBox<CurrencyRateModel>(_currencyRateBoxName);
    await Hive.openBox(_settingsBoxName);
    
    // Initialize default data
    await _initializeDefaultData();
  }

  static Future<void> _clearOldData() async {
    try {
      // Clear old boxes if they exist
      final appDir = await getApplicationDocumentsDirectory();
      final hiveDir = Directory('${appDir.path}/hive');
      
      if (await hiveDir.exists()) {
        await hiveDir.delete(recursive: true);
      }
    } catch (e) {
      // Ignore errors during cleanup
      print('Error clearing old data: $e');
    }
  }

  static Future<void> _initializeDefaultData() async {
    // Save default currency rate if none exists
    if (getCurrencyRate() == null) {
      await saveDefaultCurrencyRate();
    }
  }

  // Transactions
  static Box<TransactionModel> get transactionsBox => 
      Hive.box<TransactionModel>(_transactionsBoxName);

  // Currency Rate
  static Box<CurrencyRateModel> get currencyRateBox => 
      Hive.box<CurrencyRateModel>(_currencyRateBoxName);

  // Settings
  static Box get settingsBox => Hive.box(_settingsBoxName);

  // Currency rate methods
  static Future<void> saveCurrencyRate(CurrencyRateModel rate) async {
    await currencyRateBox.clear();
    await currencyRateBox.add(rate);
  }

  static CurrencyRateModel? getCurrencyRate() {
    final rates = currencyRateBox.values.toList();
    return rates.isNotEmpty ? rates.first : null;
  }

  // Settings methods
  static Future<void> saveSelectedCurrency(String currencyCode) async {
    await settingsBox.put('selected_currency', currencyCode);
  }

  static String getSelectedCurrency() {
    return settingsBox.get('selected_currency', defaultValue: 'USD');
  }

  static Future<void> saveDefaultCurrencyRate() async {
    final defaultRate = CurrencyRateModel(
      usdToUzs: 12600.0, // Default exchange rate
      lastUpdated: DateTime.now(),
    );
    await saveCurrencyRate(defaultRate);
  }

  static Future<Box<TransactionModel>> openBox() async {
    return await Hive.openBox<TransactionModel>(_transactionsBoxName);
  }

  static Box<TransactionModel> getTransactionBox() {
    return Hive.box<TransactionModel>(_transactionsBoxName);
  }
  
  static Future<void> closeBox() async {
    await getTransactionBox().close();
  }
  
  static Future<void> clearAllData() async {
    try {
      // Clear all boxes
      await getTransactionBox().clear();
      await Hive.openBox<CurrencyRateModel>(_currencyRateBoxName).then((box) => box.clear());
      await Hive.openBox(_settingsBoxName).then((box) => box.clear());
      
      // Reset default settings
      await saveDefaultCurrencyRate();
      await saveSelectedCurrency('USD');
    } catch (e) {
      print('Error clearing data: $e');
    }
  }
}
