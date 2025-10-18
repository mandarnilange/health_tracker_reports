// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'vital_measurement_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class VitalMeasurementModelAdapter extends TypeAdapter<VitalMeasurementModel> {
  @override
  final int typeId = 12;

  @override
  VitalMeasurementModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return VitalMeasurementModel(
      id: fields[0] as String,
      vitalTypeIndex: fields[1] as int,
      value: fields[2] as double,
      unit: fields[3] as String,
      statusIndex: fields[4] as int,
      referenceRange: fields[5] as ReferenceRangeModel?,
    );
  }

  @override
  void write(BinaryWriter writer, VitalMeasurementModel obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.vitalTypeIndex)
      ..writeByte(2)
      ..write(obj.value)
      ..writeByte(3)
      ..write(obj.unit)
      ..writeByte(4)
      ..write(obj.statusIndex)
      ..writeByte(5)
      ..write(obj.referenceRange);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is VitalMeasurementModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
