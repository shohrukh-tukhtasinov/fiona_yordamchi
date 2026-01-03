enum CurrencyType {
  usd('USD', '\$'),
  uzs('UZS', 'so\'m');

  const CurrencyType(this.code, this.symbol);
  
  final String code;
  final String symbol;

  String get displayName {
    switch (this) {
      case CurrencyType.usd:
        return 'AQSH dollari';
      case CurrencyType.uzs:
        return "O'zbek so'mi";
    }
  }
}
