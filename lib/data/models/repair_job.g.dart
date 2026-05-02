// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'repair_job.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class RepairJobAdapter extends TypeAdapter<RepairJob> {
  @override
  final int typeId = 0;

  @override
  RepairJob read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return RepairJob(
      id: fields[0] as String,
      customerName: fields[1] as String,
      customerPhone: fields[2] as String,
      customerCNIC: fields[3] as String?,
      mobileModel: fields[4] as String,
      issueDescription: fields[5] as String,
      repairPrice: fields[6] as double,
      estimatedTime: fields[7] as String,
      imagePath: fields[8] as String?,
      receivedAt: fields[9] as DateTime,
      completedAt: fields[10] as DateTime?,
      status: fields[11] as String,
      extraIssueNote: fields[12] as String?,
      issueTags: (fields[13] as List).cast<String>(),
    );
  }

  @override
  void write(BinaryWriter writer, RepairJob obj) {
    writer
      ..writeByte(14)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.customerName)
      ..writeByte(2)
      ..write(obj.customerPhone)
      ..writeByte(3)
      ..write(obj.customerCNIC)
      ..writeByte(4)
      ..write(obj.mobileModel)
      ..writeByte(5)
      ..write(obj.issueDescription)
      ..writeByte(6)
      ..write(obj.repairPrice)
      ..writeByte(7)
      ..write(obj.estimatedTime)
      ..writeByte(8)
      ..write(obj.imagePath)
      ..writeByte(9)
      ..write(obj.receivedAt)
      ..writeByte(10)
      ..write(obj.completedAt)
      ..writeByte(11)
      ..write(obj.status)
      ..writeByte(12)
      ..write(obj.extraIssueNote)
      ..writeByte(13)
      ..write(obj.issueTags);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RepairJobAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
