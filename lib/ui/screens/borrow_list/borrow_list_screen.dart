import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../data/models/borrow_item.dart';
import '../../../providers/borrow_provider.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/utils/date_utils.dart';

class BorrowListScreen extends StatefulWidget {
  const BorrowListScreen({super.key});

  @override
  State<BorrowListScreen> createState() => _BorrowListScreenState();
}

class _BorrowListScreenState extends State<BorrowListScreen> {
  @override
  void initState() {
    super.initState();
    _checkAndResetDaily();
  }

  Future<void> _checkAndResetDaily() async {
    final prefs = await SharedPreferences.getInstance();
    final lastDate = prefs.getString('lastBorrowDate') ?? '';
    final today = DateFormat('yyyy-MM-dd').format(DateTime.now());

    if (lastDate != today) {
      // New day, clear old borrow items
      if (mounted) {
        await context.read<BorrowProvider>().clearAll();
        await prefs.setString('lastBorrowDate', today);
      }
    }
  }

  void _showAddBorrowSheet() {
    final partNameController = TextEditingController();
    final shopNameController = TextEditingController();
    final shopPhoneController = TextEditingController();
    int quantity = 1;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          top: 16,
          left: 16,
          right: 16,
        ),
        child: SingleChildScrollView(
          child: StatefulBuilder(
            builder: (context, setState) => Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Add Borrow Item',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: partNameController,
                  decoration: InputDecoration(
                    labelText: 'Part Name',
                    hintText: 'iPhone 13 Screen',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: shopNameController,
                  decoration: InputDecoration(
                    labelText: 'Shop Name',
                    hintText: 'Ali Electronics',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: shopPhoneController,
                  keyboardType: TextInputType.phone,
                  decoration: InputDecoration(
                    labelText: 'Shop Phone (Optional)',
                    hintText: '03001234567',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Quantity',
                  style: Theme.of(context).textTheme.labelMedium,
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      onPressed: quantity > 1
                          ? () => setState(() => quantity--)
                          : null,
                      icon: const Icon(Icons.remove),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Color(AppConstants.primaryColor),
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        quantity.toString(),
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ),
                    IconButton(
                      onPressed: () => setState(() => quantity++),
                      icon: const Icon(Icons.add),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      if (partNameController.text.isEmpty ||
                          shopNameController.text.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Please fill required fields'),
                          ),
                        );
                        return;
                      }

                      final item = BorrowItem(
                        id: const Uuid().v4(),
                        partName: partNameController.text,
                        shopName: shopNameController.text,
                        shopPhone: shopPhoneController.text.isEmpty
                            ? null
                            : shopPhoneController.text,
                        quantity: quantity,
                        borrowedAt: DateTime.now(),
                        returned: false,
                      );

                      context.read<BorrowProvider>().addItem(item);
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Item added to borrow list'),
                        ),
                      );
                    },
                    child: const Text('Add Item'),
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _confirmResetAll() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset All?'),
        content: const Text(
          'Clear all borrow items? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              await context.read<BorrowProvider>().clearAll();
              if (!context.mounted) return;
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('All items cleared')),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(AppConstants.errorColor),
            ),
            child: const Text('Reset'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Borrow List — Today'),
            Text(
              AppDateUtils.formatDateFull(DateTime.now()),
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(fontSize: 12),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _confirmResetAll,
            tooltip: 'Reset All',
          ),
        ],
      ),
      body: Consumer<BorrowProvider>(
        builder: (context, borrowProvider, _) {
          final items = borrowProvider.items;

          if (items.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.shopping_bag,
                    size: 64,
                    color: Theme.of(context).disabledColor,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No borrowed items today',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: Theme.of(context).disabledColor,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Tap + to add an item',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: items.length,
            itemBuilder: (context, index) {
              final item = items[index];
              return Dismissible(
                key: Key(item.id),
                direction: DismissDirection.startToEnd,
                onDismissed: (_) {
                  borrowProvider.deleteItem(item.id);
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(const SnackBar(content: Text('Item removed')));
                },
                background: Container(
                  decoration: BoxDecoration(
                    color: Color(AppConstants.errorColor),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  alignment: Alignment.centerLeft,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: const Icon(Icons.delete, color: Colors.white),
                ),
                child: Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item.partName,
                                    style: Theme.of(
                                      context,
                                    ).textTheme.titleMedium,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    item.shopName,
                                    style: Theme.of(
                                      context,
                                    ).textTheme.bodySmall,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  if (item.shopPhone != null) ...[
                                    const SizedBox(height: 4),
                                    Text(
                                      item.shopPhone!,
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodySmall
                                          ?.copyWith(
                                            color: Color(
                                              AppConstants.primaryColor,
                                            ),
                                          ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: Color(AppConstants.fillColor),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                'x${item.quantity}',
                                style: Theme.of(context).textTheme.labelMedium,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              DateFormat('hh:mm a').format(item.borrowedAt),
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                            GestureDetector(
                              onTap: () {
                                borrowProvider.toggleReturned(item.id);
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: item.returned
                                      ? Color(
                                          AppConstants.successColor,
                                        ).withValues(alpha: 0.2)
                                      : Color(
                                          AppConstants.warningColor,
                                        ).withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  item.returned ? 'RETURNED' : 'PENDING',
                                  style: Theme.of(context).textTheme.labelSmall
                                      ?.copyWith(
                                        color: item.returned
                                            ? Color(AppConstants.successColor)
                                            : Color(AppConstants.warningColor),
                                      ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        if (item.returned)
                          Padding(
                            padding: const EdgeInsets.only(top: 12),
                            child: Text(
                              item.partName,
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(
                                    decoration: TextDecoration.lineThrough,
                                    color: Theme.of(context).disabledColor,
                                  ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddBorrowSheet,
        child: const Icon(Icons.add),
      ),
    );
  }
}
