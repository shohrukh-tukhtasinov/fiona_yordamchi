import 'package:equatable/equatable.dart';
import '../../domain/entities/transaction.dart';

abstract class TransactionState extends Equatable {
  const TransactionState();

  @override
  List<Object?> get props => [];
}

class TransactionInitial extends TransactionState {}

class TransactionLoading extends TransactionState {}

class TransactionLoaded extends TransactionState {
  final List<Transaction> transactions;
  final double totalIncome;
  final double totalExpense;
  final double balance;

  const TransactionLoaded({
    required this.transactions,
    required this.totalIncome,
    required this.totalExpense,
    required this.balance,
  });

  @override
  List<Object?> get props => [transactions, totalIncome, totalExpense, balance];

  TransactionLoaded copyWith({
    List<Transaction>? transactions,
    double? totalIncome,
    double? totalExpense,
    double? balance,
  }) {
    return TransactionLoaded(
      transactions: transactions ?? this.transactions,
      totalIncome: totalIncome ?? this.totalIncome,
      totalExpense: totalExpense ?? this.totalExpense,
      balance: balance ?? this.balance,
    );
  }
}

class TransactionError extends TransactionState {
  final String message;

  const TransactionError(this.message);

  @override
  List<Object?> get props => [message];
}
