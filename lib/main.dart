import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'data/models/repair_job.dart';
import 'data/models/borrow_item.dart';
import 'core/services/notification_service.dart';
import 'app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Hive
  await Hive.initFlutter();
  
  // Register adapters
  Hive.registerAdapter(RepairJobAdapter());
  Hive.registerAdapter(BorrowItemAdapter());
  
  // Open boxes
  await Hive.openBox<RepairJob>('repair_jobs');
  await Hive.openBox<BorrowItem>('borrow_items');
  
  // Initialize Notifications
  await NotificationService().initialize();
  
  runApp(const JTCApp());
}
