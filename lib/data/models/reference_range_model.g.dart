// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'reference_range_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ReferenceRangeModelAdapter extends TypeAdapter<ReferenceRangeModel> {
  @override
  final int typeId = 2;

  @override
  ReferenceRangeModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ReferenceRangeModel(
      min: fields[0] as double,
      max: fields[1] as double,
    );
  }

  @override
  void write(BinaryWriter writer, ReferenceRangeModel obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.min)
      ..writeByte(1)
      ..write(obj.max);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ReferenceRangeModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
