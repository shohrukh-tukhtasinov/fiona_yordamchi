class CurrencyRate {
  final double usdToUzs;
  final DateTime lastUpdated;

  const CurrencyRate({
    required this.usdToUzs,
    required this.lastUpdated,
  });

  CurrencyRate copyWith({
    double? usdToUzs,
    DateTime? lastUpdated,
  }) {
    return CurrencyRate(
      usdToUzs: usdToUzs ?? this.usdToUzs,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CurrencyRate &&
        other.usdToUzs == usdToUzs &&
        other.lastUpdated == lastUpdated;
  }

  @override
  int get hashCode {
    return usdToUzs.hashCode ^ lastUpdated.hashCode;
  }

  @override
  String toString() {
    return 'CurrencyRate(usdToUzs: $usdToUzs, lastUpdated: $lastUpdated)';
  }
}
