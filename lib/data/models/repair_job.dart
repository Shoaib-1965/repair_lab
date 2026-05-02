import 'package:hive/hive.dart';

part 'repair_job.g.dart';

@HiveType(typeId: 0)
class RepairJob extends HiveObject {
  @HiveField(0)
  late String id; // UUID v4

  @HiveField(1)
  late String customerName;

  @HiveField(2)
  late String customerPhone; // e.g. 03001234567

  @HiveField(3)
  late String? customerCNIC; // e.g. 35201-1234567-1

  @HiveField(4)
  late String mobileModel; // Device brand/model

  @HiveField(5)
  late String issueDescription; // Free text + selected tags

  @HiveField(6)
  late double repairPrice;

  @HiveField(7)
  late String estimatedTime; // e.g. "2 Hours", "Tomorrow 5pm"

  @HiveField(8)
  late String? imagePath; // Local file path to device photo

  @HiveField(9)
  late DateTime receivedAt;

  @HiveField(10)
  late DateTime? completedAt;

  @HiveField(11)
  late String status; // "pending" | "done" | "issue_found"

  @HiveField(12)
  late String? extraIssueNote; // If technician finds more problems

  @HiveField(13)
  late List<String> issueTags; // Quick-select tags used

  RepairJob({
    required this.id,
    required this.customerName,
    required this.customerPhone,
    this.customerCNIC,
    required this.mobileModel,
    required this.issueDescription,
    required this.repairPrice,
    required this.estimatedTime,
    this.imagePath,
    required this.receivedAt,
    this.completedAt,
    required this.status,
    this.extraIssueNote,
    required this.issueTags,
  });
}
