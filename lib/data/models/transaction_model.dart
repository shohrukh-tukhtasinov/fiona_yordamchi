import 'package:hive/hive.dart';
import '../../domain/entities/transaction.dart';

part 'transaction_model.g.dart';

@HiveType(typeId: 0)
class TransactionModel extends HiveObject {
  @HiveField(0)
  final String id;
  
  @HiveField(1)
  final double amount;
  
  @HiveField(2)
  final bool isIncome;
  
  @HiveField(3)
  final String note;
  
  @HiveField(4)
  final DateTime date;
  
  @HiveField(5)
  final String currencyCode;

  TransactionModel({
    required this.id,
    required this.amount,
    required this.isIncome,
    required this.note,
    required this.date,
    this.currencyCode = 'USD',
  });

  TransactionModel fromEntity(Transaction entity) {
    return TransactionModel(
      id: entity.id,
      amount: entity.amount,
      isIncome: entity.isIncome,
      note: entity.note,
      date: entity.date,
      currencyCode: entity.currencyCode,
    );
  }

  Transaction toEntity() {
    return Transaction(
      id: id,
      amount: amount,
      isIncome: isIncome,
      note: note,
      date: date,
      currencyCode: currencyCode,
    );
  }
}
