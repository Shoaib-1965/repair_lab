import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import '../../core/utils/date_utils.dart';
import '../data/models/repair_job.dart';

class RepairProvider extends ChangeNotifier {
  final Box<RepairJob> _box = Hive.box<RepairJob>('repair_jobs');

  List<RepairJob> get allJobs {
    final jobs = _box.values.toList();
    jobs.sort((a, b) => b.receivedAt.compareTo(a.receivedAt));
    return jobs;
  }

  List<RepairJob> get pendingJobs =>
      allJobs.where((j) => j.status == 'pending').toList();

  int get totalCount => _box.length;

  int get pendingCount => pendingJobs.length;

  int get doneTodayCount => allJobs
      .where(
        (j) =>
            j.status == 'done' &&
            j.completedAt != null &&
            AppDateUtils.isSameDay(j.completedAt!, DateTime.now()),
      )
      .length;

  Future<void> addJob(RepairJob job) async {
    await _box.put(job.id, job);
    notifyListeners();
  }

  Future<void> markDone(String id) async {
    final job = _box.get(id);
    if (job != null) {
      job.status = 'done';
      job.completedAt = DateTime.now();
      await job.save();
      notifyListeners();
    }
  }

  Future<void> reportIssue(String id, String note) async {
    final job = _box.get(id);
    if (job != null) {
      job.status = 'issue_found';
      job.extraIssueNote = note;
      await job.save();
      notifyListeners();
    }
  }

  Future<void> deleteJob(String id) async {
    await _box.delete(id);
    notifyListeners();
  }

  Future<void> updateJob(RepairJob job) async {
    await job.save();
    notifyListeners();
  }

  RepairJob? getJobById(String id) => _box.get(id);

  List<RepairJob> filterByStatus(String? status) {
    if (status == null || status == 'all') return allJobs;
    return allJobs.where((j) => j.status == status).toList();
  }

  List<RepairJob> searchJobs(String query) {
    if (query.isEmpty) return allJobs;
    final lowerQuery = query.toLowerCase();
    return allJobs.where((job) {
      return job.customerName.toLowerCase().contains(lowerQuery) ||
          job.customerPhone.contains(query) ||
          job.mobileModel.toLowerCase().contains(lowerQuery);
    }).toList();
  }
}
