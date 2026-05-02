import 'package:hive/hive.dart';
import '../models/repair_job.dart';

/// Repository layer for RepairJob Hive operations.
/// Provides a clean data-access API that providers can consume.
class RepairRepository {
  static const String _boxName = 'repair_jobs';

  Box<RepairJob> get _box => Hive.box<RepairJob>(_boxName);

  /// Get all repair jobs, sorted newest first
  List<RepairJob> getAll() {
    final jobs = _box.values.toList();
    jobs.sort((a, b) => b.receivedAt.compareTo(a.receivedAt));
    return jobs;
  }

  /// Get a single job by ID
  RepairJob? getById(String id) => _box.get(id);

  /// Add or update a repair job
  Future<void> save(RepairJob job) async {
    await _box.put(job.id, job);
  }

  /// Delete a repair job by ID
  Future<void> delete(String id) async {
    await _box.delete(id);
  }

  /// Get count of all jobs
  int get count => _box.length;

  /// Get jobs filtered by status
  List<RepairJob> getByStatus(String status) {
    return getAll().where((j) => j.status == status).toList();
  }

  /// Search jobs by customer name, phone, or device model
  List<RepairJob> search(String query) {
    if (query.isEmpty) return getAll();
    final lowerQuery = query.toLowerCase();
    return getAll().where((job) {
      return job.customerName.toLowerCase().contains(lowerQuery) ||
          job.customerPhone.contains(query) ||
          job.mobileModel.toLowerCase().contains(lowerQuery);
    }).toList();
  }
}
