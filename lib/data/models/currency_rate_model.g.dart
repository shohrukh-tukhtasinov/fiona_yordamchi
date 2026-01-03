// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'currency_rate_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class CurrencyRateModelAdapter extends TypeAdapter<CurrencyRateModel> {
  @override
  final int typeId = 2;

  @override
  CurrencyRateModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return CurrencyRateModel(
      usdToUzs: fields[0] as double,
      lastUpdated: fields[1] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, CurrencyRateModel obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.usdToUzs)
      ..writeByte(1)
      ..write(obj.lastUpdated);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CurrencyRateModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
