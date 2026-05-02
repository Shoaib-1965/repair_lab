import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../data/models/repair_job.dart';
import '../../../providers/repair_provider.dart';
import '../../../core/utils/date_utils.dart';
import '../../../core/utils/whatsapp_utils.dart';
import '../../../core/constants/app_constants.dart';
import '../../widgets/tag_chip.dart';
import '../../widgets/status_badge.dart';
import 'dart:io';

class JobDetailScreen extends StatelessWidget {
  const JobDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final job = ModalRoute.of(context)?.settings.arguments as RepairJob?;

    if (job == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Job Details')),
        body: const Center(child: Text('No job selected')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Job Details'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () {
              _confirmDelete(context, job);
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Device Photo
            if (job.imagePath != null && File(job.imagePath!).existsSync())
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.file(
                  File(job.imagePath!),
                  width: double.infinity,
                  height: 200,
                  fit: BoxFit.cover,
                ),
              )
            else
              Container(
                width: double.infinity,
                height: 200,
                decoration: BoxDecoration(
                  color: Color(AppConstants.fillColor),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Center(
                  child: Icon(
                    Icons.image_not_supported,
                    size: 48,
                    color: Theme.of(context).disabledColor,
                  ),
                ),
              ),
            const SizedBox(height: 20),

            // Customer Information Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Customer Information',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 12),
                    _buildDetailRow(
                      context,
                      'Name',
                      job.customerName,
                      Icons.person,
                    ),
                    const SizedBox(height: 12),
                    _buildDetailRow(
                      context,
                      'Phone',
                      job.customerPhone,
                      Icons.phone,
                      onTap: () {
                        // Call phone
                        _callPhone(context, job.customerPhone);
                      },
                    ),
                    if (job.customerCNIC != null) ...[
                      const SizedBox(height: 12),
                      _buildDetailRow(
                        context,
                        'CNIC',
                        job.customerCNIC!,
                        Icons.credit_card,
                      ),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Device Information Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Device Information',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 12),
                    _buildDetailRow(
                      context,
                      'Model',
                      job.mobileModel,
                      Icons.smartphone,
                    ),
                    const SizedBox(height: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Issue Tags',
                          style: Theme.of(context).textTheme.labelSmall,
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 6,
                          runSpacing: 6,
                          children: job.issueTags.map((tag) {
                            return TagChip(tag: tag);
                          }).toList(),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Full Issue Description',
                          style: Theme.of(context).textTheme.labelSmall,
                        ),
                        const SizedBox(height: 6),
                        Text(
                          job.issueDescription,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Repair Information Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Repair Information',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 12),
                    _buildDetailRow(
                      context,
                      'Estimated Price',
                      'Rs. ${job.repairPrice.toStringAsFixed(0)}',
                      Icons.currency_rupee,
                    ),
                    const SizedBox(height: 12),
                    _buildDetailRow(
                      context,
                      'Estimated Time',
                      job.estimatedTime,
                      Icons.schedule,
                    ),
                    const SizedBox(height: 12),
                    _buildDetailRow(
                      context,
                      'Status',
                      job.status.replaceAll('_', ' ').toUpperCase(),
                      Icons.info,
                      widget: StatusBadge(status: job.status),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Timeline Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Timeline',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 12),
                    _buildTimelineItem(
                      context,
                      'Received',
                      AppDateUtils.formatDateTimeShort(job.receivedAt),
                    ),
                    if (job.completedAt != null) ...[
                      const SizedBox(height: 12),
                      _buildTimelineItem(
                        context,
                        'Completed',
                        AppDateUtils.formatDateTimeShort(job.completedAt!),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Additional Issue Note (if exists)
            if (job.extraIssueNote != null)
              Card(
                color: Color(AppConstants.errorColor).withValues(alpha: 0.1),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.warning_rounded,
                            color: Color(AppConstants.errorColor),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Additional Issue Found',
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(
                                  color: Color(AppConstants.errorColor),
                                ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        job.extraIssueNote!,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
              ),
            const SizedBox(height: 24),

            // Action Buttons
            if (job.status == 'pending')
              SizedBox(
                width: double.infinity,
                child: Column(
                  children: [
                    ElevatedButton.icon(
                      onPressed: () => _markAsDone(context, job),
                      icon: const Icon(Icons.check_circle),
                      label: const Text('Mark as Done'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(AppConstants.successColor),
                      ),
                    ),
                    const SizedBox(height: 12),
                    OutlinedButton.icon(
                      onPressed: () => _reportIssue(context, job),
                      icon: const Icon(Icons.warning),
                      label: const Text('Report Issue'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Color(AppConstants.warningColor),
                        side: BorderSide(
                          color: Color(AppConstants.warningColor),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            if (job.status != 'pending')
              SizedBox(
                width: double.infinity,
                child: Column(
                  children: [
                    OutlinedButton.icon(
                      onPressed: () {
                        Navigator.of(
                          context,
                        ).pushNamed('/print-bill', arguments: job);
                      },
                      icon: const Icon(Icons.print),
                      label: const Text('Print Bill'),
                    ),
                    const SizedBox(height: 12),
                    OutlinedButton.icon(
                      onPressed: () async {
                        await WhatsAppUtils.sendRepairDoneMessage(
                          customerPhone: job.customerPhone,
                          customerName: job.customerName,
                          deviceModel: job.mobileModel,
                        );
                      },
                      icon: const Icon(Icons.chat),
                      label: const Text('Send WhatsApp'),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(
    BuildContext context,
    String label,
    String value,
    IconData icon, {
    VoidCallback? onTap,
    Widget? widget,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
        children: [
          Icon(icon, size: 20, color: Color(AppConstants.primaryColor)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: Theme.of(context).textTheme.labelSmall),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: Theme.of(context).textTheme.bodyMedium,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          ?widget,
        ],
      ),
    );
  }

  Widget _buildTimelineItem(BuildContext context, String label, String value) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: Color(AppConstants.primaryColor),
            borderRadius: BorderRadius.circular(6),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: Theme.of(context).textTheme.labelSmall),
              const SizedBox(height: 4),
              Text(value, style: Theme.of(context).textTheme.bodyMedium),
            ],
          ),
        ),
      ],
    );
  }

  void _markAsDone(BuildContext context, RepairJob job) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Mark as Done?'),
        content: const Text('Send completion notification via WhatsApp?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await context.read<RepairProvider>().markDone(job.id);
              await WhatsAppUtils.sendRepairDoneMessage(
                customerPhone: job.customerPhone,
                customerName: job.customerName,
                deviceModel: job.mobileModel,
              );
              if (context.mounted) {
                Navigator.pop(context);
              }
            },
            child: const Text('Yes, Mark Done'),
          ),
        ],
      ),
    );
  }

  void _reportIssue(BuildContext context, RepairJob job) {
    final issueController = TextEditingController();
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
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Report Additional Issue',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: issueController,
                maxLines: 4,
                decoration: InputDecoration(
                  hintText: 'Describe the additional issue found...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    if (issueController.text.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Please enter issue note'),
                        ),
                      );
                      return;
                    }
                    Navigator.pop(context);
                    await context.read<RepairProvider>().reportIssue(
                      job.id,
                      issueController.text,
                    );
                    await WhatsAppUtils.sendIssueFoundMessage(
                      customerPhone: job.customerPhone,
                      customerName: job.customerName,
                      deviceModel: job.mobileModel,
                      issueNote: issueController.text,
                    );
                    if (context.mounted) {
                      Navigator.pop(context);
                    }
                  },
                  child: const Text('Send via WhatsApp'),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context, RepairJob job) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Job?'),
        content: const Text('This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              await context.read<RepairProvider>().deleteJob(job.id);
              if (context.mounted) {
                Navigator.pop(context); // Close dialog
                Navigator.pop(context); // Go back to dashboard
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(AppConstants.errorColor),
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _callPhone(BuildContext context, String phone) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Call Customer'),
        content: Text('Call $phone?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              // Would implement phone calling here
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Phone feature coming soon')),
              );
            },
            child: const Text('Call'),
          ),
        ],
      ),
    );
  }
}
