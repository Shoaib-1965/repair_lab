import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/models/repair_job.dart';
import '../../core/utils/date_utils.dart';
import '../../core/utils/whatsapp_utils.dart';
import '../../core/constants/app_constants.dart';
import '../../core/widgets/glass_widgets.dart';
import '../../providers/repair_provider.dart';
import 'status_badge.dart';
import 'tag_chip.dart';

class JobCard extends StatelessWidget {
  final RepairJob job;

  const JobCard({super.key, required this.job});

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key(job.id),
      direction: DismissDirection.startToEnd,
      onDismissed: (direction) {
        context.read<RepairProvider>().deleteJob(job.id);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Job deleted'),
            action: SnackBarAction(label: 'Undo', onPressed: () {}),
          ),
        );
      },
      background: Container(
        decoration: BoxDecoration(
          color: Color(AppConstants.errorColor),
          borderRadius: BorderRadius.circular(24),
        ),
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      child: GlassCard(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header: Model name & Status
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        job.mobileModel,
                        style: Theme.of(context).textTheme.titleLarge,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${job.customerName} • ${job.customerPhone}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w600),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                StatusBadge(status: job.status),
              ],
            ),
            const SizedBox(height: 12),

            // Issue Tags
            if (job.issueTags.isNotEmpty)
              SizedBox(
                height: 28,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: job.issueTags.length > 3
                      ? 3
                      : job.issueTags.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 6),
                  itemBuilder: (_, index) {
                    if (index < 2) {
                      return TagChip(tag: job.issueTags[index]);
                    } else {
                      return TagChip(tag: '+${job.issueTags.length - 2}');
                    }
                  },
                ),
              ),
            const SizedBox(height: 12),

            // Price & Time Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'PKR ${job.repairPrice.toStringAsFixed(0)}',
                      style: Theme.of(context).textTheme.titleMedium
                          ?.copyWith(
                            color: Color(AppConstants.primaryColor),
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                    Text(
                      job.estimatedTime,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      AppDateUtils.getTimeAgo(job.receivedAt),
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    if (job.imagePath != null)
                      const Icon(Icons.image, size: 16),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Action Buttons
            Column(
              children: [
                if (job.status == 'pending')
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => _markAsDone(context, job),
                          icon: const Icon(Icons.check, size: 14),
                          label: const Text('Done', style: TextStyle(fontSize: 12)),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Color(AppConstants.successColor),
                            side: BorderSide(color: Color(AppConstants.successColor)),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                            minimumSize: const Size(0, 36),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => _reportIssue(context, job),
                          icon: const Icon(Icons.warning, size: 14),
                          label: const Text('Issue', style: TextStyle(fontSize: 12)),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Color(AppConstants.warningColor),
                            side: BorderSide(color: Color(AppConstants.warningColor)),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                            minimumSize: const Size(0, 36),
                          ),
                        ),
                      ),
                    ],
                  ),
                if (job.status == 'issue_found' || job.status == 'done')
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => _markPending(context, job),
                          icon: const Icon(Icons.pending, size: 14),
                          label: const Text('Pending', style: TextStyle(fontSize: 12)),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Color(AppConstants.warningColor),
                            side: BorderSide(color: Color(AppConstants.warningColor)),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                            minimumSize: const Size(0, 36),
                          ),
                        ),
                      ),
                      if (job.status == 'issue_found') ...[
                        const SizedBox(width: 8),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () => _markAsDone(context, job),
                            icon: const Icon(Icons.check, size: 14),
                            label: const Text('Done', style: TextStyle(fontSize: 12)),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Color(AppConstants.successColor),
                              side: BorderSide(color: Color(AppConstants.successColor)),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                              minimumSize: const Size(0, 36),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                if (job.status == 'pending' || job.status == 'issue_found' || job.status == 'done')
                  const SizedBox(height: 6),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          Navigator.of(context).pushNamed('/print-bill', arguments: job);
                        },
                        icon: const Icon(Icons.print, size: 14),
                        label: const Text('Bill', style: TextStyle(fontSize: 12)),
                        style: OutlinedButton.styleFrom(
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                          minimumSize: const Size(0, 36),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          Navigator.of(context).pushNamed('/job-detail', arguments: job);
                        },
                        icon: const Icon(Icons.visibility, size: 14),
                        label: const Text('View', style: TextStyle(fontSize: 12)),
                        style: OutlinedButton.styleFrom(
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                          minimumSize: const Size(0, 36),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _markPending(BuildContext context, RepairJob job) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Move to Pending?'),
        content: const Text('This will reset the job status to pending.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              context.read<RepairProvider>().markPending(job.id);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(AppConstants.warningColor),
            ),
            child: const Text('Confirm'),
          ),
        ],
      ),
    );
  }

  void _markAsDone(BuildContext context, RepairJob job) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text('Send WhatsApp Message?'),
        content: Text(
          'Send repair completion message to ${job.customerName}?',
        ),
        actions: [
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              // Skip WhatsApp — just mark done
              await context.read<RepairProvider>().markDone(job.id);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Job marked as done!')),
                );
              }
            },
            style: TextButton.styleFrom(
              foregroundColor: Color(AppConstants.textSecondary),
            ),
            child: const Text('Skip'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await context.read<RepairProvider>().markDone(job.id);
              await WhatsAppUtils.sendRepairDoneMessage(
                customerPhone: job.customerPhone,
                customerName: job.customerName,
                deviceModel: job.mobileModel,
                price: job.repairPrice,
              );
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Job marked as done!')),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(AppConstants.successColor),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: const Text('Send'),
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
      backgroundColor: Colors.transparent,
      builder: (context) => GlassBottomSheet(
        child: Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'REPORT ADDITIONAL ISSUE',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    letterSpacing: 1.2,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: issueController,
                  maxLines: 4,
                  decoration: InputDecoration(
                    hintText: 'Describe the additional issue found...',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: GradientButton(
                    label: 'Send via WhatsApp',
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
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Issue reported!')),
                        );
                      }
                    },
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
}
