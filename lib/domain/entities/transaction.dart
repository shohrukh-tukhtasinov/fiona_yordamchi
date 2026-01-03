class Transaction {
  final String id;
  final double amount;
  final bool isIncome;
  final String note;
  final DateTime date;
  final String currencyCode;

  const Transaction({
    required this.id,
    required this.amount,
    required this.isIncome,
    required this.note,
    required this.date,
    this.currencyCode = 'USD',
  });

  Transaction copyWith({
    String? id,
    double? amount,
    bool? isIncome,
    String? note,
    DateTime? date,
    String? currencyCode,
  }) {
    return Transaction(
      id: id ?? this.id,
      amount: amount ?? this.amount,
      isIncome: isIncome ?? this.isIncome,
      note: note ?? this.note,
      date: date ?? this.date,
      currencyCode: currencyCode ?? this.currencyCode,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Transaction &&
        other.id == id &&
        other.amount == amount &&
        other.isIncome == isIncome &&
        other.note == note &&
        other.date == date &&
        other.currencyCode == currencyCode;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        amount.hashCode ^
        isIncome.hashCode ^
        note.hashCode ^
        date.hashCode ^
        currencyCode.hashCode;
  }

  @override
  String toString() {
    return 'Transaction(id: $id, amount: $amount, isIncome: $isIncome, note: $note, date: $date, currencyCode: $currencyCode)';
  }
}
