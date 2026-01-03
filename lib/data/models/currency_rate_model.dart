import 'package:hive/hive.dart';
import '../../domain/entities/currency_rate.dart';

part 'currency_rate_model.g.dart';

@HiveType(typeId: 2)
class CurrencyRateModel extends HiveObject {
  @HiveField(0)
  final double usdToUzs;
  
  @HiveField(1)
  final DateTime lastUpdated;

  CurrencyRateModel({
    required this.usdToUzs,
    required this.lastUpdated,
  });

  CurrencyRate toEntity() {
    return CurrencyRate(
      usdToUzs: usdToUzs,
      lastUpdated: lastUpdated,
    );
  }
}
