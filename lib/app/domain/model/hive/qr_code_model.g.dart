// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'qr_code_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class QrCodeModelAdapter extends TypeAdapter<QrCodeModel> {
  @override
  final int typeId = 0;

  @override
  QrCodeModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return QrCodeModel(
      id: fields[0] as String,
      type: fields[1] as String,
      data: fields[2] as String,
      displayTitle: fields[3] as String,
      createdAt: fields[4] as DateTime,
      isFavorite: fields[5] as bool,
      isScanned: fields[6] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, QrCodeModel obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.type)
      ..writeByte(2)
      ..write(obj.data)
      ..writeByte(3)
      ..write(obj.displayTitle)
      ..writeByte(4)
      ..write(obj.createdAt)
      ..writeByte(5)
      ..write(obj.isFavorite)
      ..writeByte(6)
      ..write(obj.isScanned);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is QrCodeModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
