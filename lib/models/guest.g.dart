// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'guest.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class GuestAdapter extends TypeAdapter<Guest> {
  @override
  final int typeId = 1;

  @override
  Guest read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Guest(
      localId: fields[0] as int,
      backendId: fields[1] as int,
      weddingId: fields[2] as int,
      nameEn: fields[3] as String,
      nameHi: fields[4] as String,
      addressEn: fields[5] as String,
      addressHi: fields[6] as String,
      giftEn: fields[7] as String,
      giftHi: fields[8] as String,
      given: fields[9] as double,
      taken: (fields[12] as num?)?.toDouble() ?? 0,
      type: fields[10] as String,
      date: fields[11] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, Guest obj) {
    writer
      ..writeByte(12)
      ..writeByte(13)
      ..writeByte(0)
      ..write(obj.localId)
      ..writeByte(1)
      ..write(obj.backendId)
      ..writeByte(2)
      ..write(obj.weddingId)
      ..writeByte(3)
      ..write(obj.nameEn)
      ..writeByte(4)
      ..write(obj.nameHi)
      ..writeByte(5)
      ..write(obj.addressEn)
      ..writeByte(6)
      ..write(obj.addressHi)
      ..writeByte(7)
      ..write(obj.giftEn)
      ..writeByte(8)
      ..write(obj.giftHi)
      ..writeByte(9)
      ..write(obj.given)
      ..writeByte(10)
      ..write(obj.type)
      ..writeByte(11)
      ..write(obj.date);
      ..writeByte(12)
      ..write(obj.taken);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GuestAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
