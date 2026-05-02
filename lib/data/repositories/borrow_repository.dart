import 'package:hive/hive.dart';
import '../models/borrow_item.dart';

/// Repository layer for BorrowItem Hive operations.
/// Provides a clean data-access API that providers can consume.
class BorrowRepository {
  static const String _boxName = 'borrow_items';

  Box<BorrowItem> get _box => Hive.box<BorrowItem>(_boxName);

  /// Get all borrow items, sorted newest first
  List<BorrowItem> getAll() {
    final items = _box.values.toList();
    items.sort((a, b) => b.borrowedAt.compareTo(a.borrowedAt));
    return items;
  }

  /// Get a single item by ID
  BorrowItem? getById(String id) => _box.get(id);

  /// Add or update a borrow item
  Future<void> save(BorrowItem item) async {
    await _box.put(item.id, item);
  }

  /// Delete a borrow item by ID
  Future<void> delete(String id) async {
    await _box.delete(id);
  }

  /// Clear all borrow items (daily reset)
  Future<void> clearAll() async {
    await _box.clear();
  }

  /// Get count of all items
  int get count => _box.length;

  /// Get count of returned items
  int get returnedCount =>
      getAll().where((item) => item.returned).length;

  /// Get count of pending (not returned) items
  int get pendingCount =>
      getAll().where((item) => !item.returned).length;
}
