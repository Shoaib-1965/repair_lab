import 'package:hive/hive.dart';

part 'borrow_item.g.dart';

@HiveType(typeId: 1)
class BorrowItem extends HiveObject {
  @HiveField(0)
  late String id; // UUID v4

  @HiveField(1)
  late String partName; // e.g. "iPhone 13 Screen"

  @HiveField(2)
  late String shopName; // Where borrowed from

  @HiveField(3)
  late String? shopPhone;

  @HiveField(4)
  late int quantity;

  @HiveField(5)
  late DateTime borrowedAt;

  @HiveField(6)
  late bool returned; // For manual mark-returned

  BorrowItem({
    required this.id,
    required this.partName,
    required this.shopName,
    this.shopPhone,
    required this.quantity,
    required this.borrowedAt,
    required this.returned,
  });
}
