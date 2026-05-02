import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import '../core/services/notification_service.dart';
import '../data/models/borrow_item.dart';

class BorrowProvider extends ChangeNotifier {
  final Box<BorrowItem> _box = Hive.box<BorrowItem>('borrow_items');

  List<BorrowItem> get items {
    final items = _box.values.toList();
    items.sort((a, b) => b.borrowedAt.compareTo(a.borrowedAt));
    return items;
  }

  int get totalItems => _box.length;

  int get returnedCount => items.where((item) => item.returned).length;

  int get pendingCount => items.where((item) => !item.returned).length;

  Future<void> addItem(BorrowItem item) async {
    await _box.put(item.id, item);
    // Show notification for borrowed part
    await NotificationService()
        .showBorrowItemNotification(item.partName, item.shopName);
    notifyListeners();
  }

  Future<void> toggleReturned(String id) async {
    final item = _box.get(id);
    if (item != null) {
      item.returned = !item.returned;
      await item.save();
      notifyListeners();
    }
  }

  Future<void> deleteItem(String id) async {
    await _box.delete(id);
    notifyListeners();
  }

  Future<void> clearAll() async {
    await _box.clear();
    notifyListeners();
  }

  BorrowItem? getItemById(String id) => _box.get(id);
}
