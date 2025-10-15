// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'biomarker_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class BiomarkerModelAdapter extends TypeAdapter<BiomarkerModel> {
  @override
  final int typeId = 1;

  @override
  BiomarkerModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return BiomarkerModel(
      id: fields[0] as String,
      name: fields[1] as String,
      value: fields[2] as double,
      unit: fields[3] as String,
      referenceRange: fields[4] as ReferenceRangeModel,
      measuredAt: fields[5] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, BiomarkerModel obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.value)
      ..writeByte(3)
      ..write(obj.unit)
      ..writeByte(4)
      ..write(obj.referenceRange)
      ..writeByte(5)
      ..write(obj.measuredAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BiomarkerModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
