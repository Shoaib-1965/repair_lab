// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'borrow_item.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class BorrowItemAdapter extends TypeAdapter<BorrowItem> {
  @override
  final int typeId = 1;

  @override
  BorrowItem read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return BorrowItem(
      id: fields[0] as String,
      partName: fields[1] as String,
      shopName: fields[2] as String,
      shopPhone: fields[3] as String?,
      quantity: fields[4] as int,
      borrowedAt: fields[5] as DateTime,
      returned: fields[6] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, BorrowItem obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.partName)
      ..writeByte(2)
      ..write(obj.shopName)
      ..writeByte(3)
      ..write(obj.shopPhone)
      ..writeByte(4)
      ..write(obj.quantity)
      ..writeByte(5)
      ..write(obj.borrowedAt)
      ..writeByte(6)
      ..write(obj.returned);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BorrowItemAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
