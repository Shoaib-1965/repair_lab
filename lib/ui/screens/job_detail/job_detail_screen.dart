import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../data/models/repair_job.dart';
import '../../../providers/repair_provider.dart';
import '../../../core/utils/date_utils.dart';
import '../../../core/utils/whatsapp_utils.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/widgets/glass_widgets.dart';
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
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.white.withValues(alpha: 0.4),
        elevation: 0,
        title: const Text('Job Details'),
        actions: [
          IconButton(icon: const Icon(Icons.delete), onPressed: () => _confirmDelete(context, job)),
        ],
      ),
      body: GradientBlobBackground(
        child: SingleChildScrollView(
          padding: EdgeInsets.only(
            top: MediaQuery.of(context).padding.top + kToolbarHeight + 16,
            left: 16, right: 16, bottom: 16,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildDevicePhoto(context, job),
              const SizedBox(height: 20),
              _buildCustomerCard(context, job),
              const SizedBox(height: 16),
              _buildDeviceCard(context, job),
              const SizedBox(height: 16),
              _buildRepairCard(context, job),
              const SizedBox(height: 16),
              _buildTimelineCard(context, job),
              const SizedBox(height: 16),
              if (job.extraIssueNote != null) _buildIssueCard(context, job),
              const SizedBox(height: 24),
              _buildActionButtons(context, job),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDevicePhoto(BuildContext context, RepairJob job) {
    if (job.imagePath != null && File(job.imagePath!).existsSync()) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Image.file(File(job.imagePath!), width: double.infinity, height: 200, fit: BoxFit.cover),
      );
    }
    return GlassCard(
      padding: EdgeInsets.zero,
      child: SizedBox(
        width: double.infinity, height: 200,
        child: Center(child: Icon(Icons.image_not_supported, size: 48, color: Color(AppConstants.primaryColor).withValues(alpha: 0.4))),
      ),
    );
  }

  Widget _buildCustomerCard(BuildContext context, RepairJob job) {
    return GlassCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text('CUSTOMER INFORMATION', style: Theme.of(context).textTheme.titleLarge?.copyWith(letterSpacing: 1.2, fontSize: 14)),
      const SizedBox(height: 12),
      _buildDetailRow(context, 'Name', job.customerName, Icons.person),
      const SizedBox(height: 12),
      _buildDetailRow(context, 'Phone', job.customerPhone, Icons.phone, onTap: () => _callPhone(context, job.customerPhone)),
      if (job.customerCNIC != null) ...[const SizedBox(height: 12), _buildDetailRow(context, 'CNIC', job.customerCNIC!, Icons.credit_card)],
    ]));
  }

  Widget _buildDeviceCard(BuildContext context, RepairJob job) {
    return GlassCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text('DEVICE INFORMATION', style: Theme.of(context).textTheme.titleLarge?.copyWith(letterSpacing: 1.2, fontSize: 14)),
      const SizedBox(height: 12),
      _buildDetailRow(context, 'Model', job.mobileModel, Icons.smartphone),
      const SizedBox(height: 12),
      Text('Issue Tags', style: Theme.of(context).textTheme.labelSmall),
      const SizedBox(height: 8),
      Wrap(spacing: 6, runSpacing: 6, children: job.issueTags.map((tag) => TagChip(tag: tag)).toList()),
      const SizedBox(height: 12),
      Text('Full Issue Description', style: Theme.of(context).textTheme.labelSmall),
      const SizedBox(height: 6),
      Text(job.issueDescription, style: Theme.of(context).textTheme.bodyMedium),
    ]));
  }

  Widget _buildRepairCard(BuildContext context, RepairJob job) {
    return GlassCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text('REPAIR INFORMATION', style: Theme.of(context).textTheme.titleLarge?.copyWith(letterSpacing: 1.2, fontSize: 14)),
      const SizedBox(height: 12),
      _buildDetailRow(context, 'Estimated Price', 'Rs. ${job.repairPrice.toStringAsFixed(0)}', Icons.currency_rupee),
      const SizedBox(height: 12),
      _buildDetailRow(context, 'Estimated Time', job.estimatedTime, Icons.schedule),
      const SizedBox(height: 12),
      _buildDetailRow(context, 'Status', job.status.replaceAll('_', ' ').toUpperCase(), Icons.info, widget: StatusBadge(status: job.status)),
    ]));
  }

  Widget _buildTimelineCard(BuildContext context, RepairJob job) {
    return GlassCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text('TIMELINE', style: Theme.of(context).textTheme.titleLarge?.copyWith(letterSpacing: 1.2, fontSize: 14)),
      const SizedBox(height: 12),
      _buildTimelineItem(context, 'Received', AppDateUtils.formatDateTimeShort(job.receivedAt)),
      if (job.completedAt != null) ...[const SizedBox(height: 12), _buildTimelineItem(context, 'Completed', AppDateUtils.formatDateTimeShort(job.completedAt!))],
    ]));
  }

  Widget _buildIssueCard(BuildContext context, RepairJob job) {
    return GlassCard(
      glassColor: Color(AppConstants.errorColor).withValues(alpha: 0.15),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Icon(Icons.warning_rounded, color: Color(AppConstants.errorColor)),
          const SizedBox(width: 8),
          Text('Additional Issue Found', style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Color(AppConstants.errorColor))),
        ]),
        const SizedBox(height: 12),
        Text(job.extraIssueNote!, style: Theme.of(context).textTheme.bodyMedium),
      ]),
    );
  }

  Widget _buildActionButtons(BuildContext context, RepairJob job) {
    if (job.status == 'pending') {
      return Column(children: [
        GradientButton(label: 'Mark as Done ✅', onPressed: () => _markAsDone(context, job)),
        const SizedBox(height: 12),
        GlassButton(label: 'Report Issue ⚠️', onPressed: () => _reportIssue(context, job)),
      ]);
    }
    return Column(children: [
      GradientButton(label: 'Print Bill 🖨️', onPressed: () => Navigator.of(context).pushNamed('/print-bill', arguments: job)),
      const SizedBox(height: 12),
      GlassButton(label: 'Send WhatsApp 💬', onPressed: () async {
        await WhatsAppUtils.sendRepairDoneMessage(customerPhone: job.customerPhone, customerName: job.customerName, deviceModel: job.mobileModel, price: job.repairPrice);
      }),
    ]);
  }

  Widget _buildDetailRow(BuildContext context, String label, String value, IconData icon, {VoidCallback? onTap, Widget? widget}) {
    return GestureDetector(
      onTap: onTap,
      child: Row(children: [
        Icon(icon, size: 20, color: Color(AppConstants.primaryColor)),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(label, style: Theme.of(context).textTheme.labelSmall),
          const SizedBox(height: 4),
          Text(value, style: Theme.of(context).textTheme.bodyMedium, maxLines: 2, overflow: TextOverflow.ellipsis),
        ])),
        if (widget != null) widget,
      ]),
    );
  }

  Widget _buildTimelineItem(BuildContext context, String label, String value) {
    return Row(children: [
      Container(width: 12, height: 12, decoration: BoxDecoration(gradient: const LinearGradient(colors: [Color(0xFF1A73E8), Color(0xFF0D47A1)]), borderRadius: BorderRadius.circular(6))),
      const SizedBox(width: 12),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label, style: Theme.of(context).textTheme.labelSmall),
        const SizedBox(height: 4),
        Text(value, style: Theme.of(context).textTheme.bodyMedium),
      ])),
    ]);
  }

  void _markAsDone(BuildContext context, RepairJob job) {
    showDialog(context: context, builder: (context) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      title: const Text('Send WhatsApp Message?'),
      content: Text('Send repair completion message to ${job.customerName}?'),
      actions: [
        TextButton(
          onPressed: () async { Navigator.pop(context); await context.read<RepairProvider>().markDone(job.id); if (context.mounted) Navigator.pop(context); },
          style: TextButton.styleFrom(foregroundColor: Color(AppConstants.textSecondary)),
          child: const Text('Skip'),
        ),
        ElevatedButton(
          onPressed: () async {
            Navigator.pop(context);
            await context.read<RepairProvider>().markDone(job.id);
            await WhatsAppUtils.sendRepairDoneMessage(customerPhone: job.customerPhone, customerName: job.customerName, deviceModel: job.mobileModel, price: job.repairPrice);
            if (context.mounted) Navigator.pop(context);
          },
          style: ElevatedButton.styleFrom(backgroundColor: Color(AppConstants.successColor), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
          child: const Text('Send'),
        ),
      ],
    ));
  }

  void _reportIssue(BuildContext context, RepairJob job) {
    final c = TextEditingController();
    showModalBottomSheet(context: context, isScrollControlled: true, backgroundColor: Colors.transparent, builder: (context) => GlassBottomSheet(
      child: Padding(padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom), child: SingleChildScrollView(child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('REPORT ADDITIONAL ISSUE', style: Theme.of(context).textTheme.headlineSmall?.copyWith(letterSpacing: 1.2, fontWeight: FontWeight.w700)),
        const SizedBox(height: 16),
        TextField(controller: c, maxLines: 4, decoration: InputDecoration(hintText: 'Describe the additional issue found...', border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)))),
        const SizedBox(height: 16),
        SizedBox(width: double.infinity, child: GradientButton(label: 'Send via WhatsApp', onPressed: () async {
          if (c.text.isEmpty) { ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please enter issue note'))); return; }
          Navigator.pop(context);
          await context.read<RepairProvider>().reportIssue(job.id, c.text);
          await WhatsAppUtils.sendIssueFoundMessage(customerPhone: job.customerPhone, customerName: job.customerName, deviceModel: job.mobileModel, issueNote: c.text);
          if (context.mounted) Navigator.pop(context);
        })),
        const SizedBox(height: 16),
      ]))),
    ));
  }

  void _confirmDelete(BuildContext context, RepairJob job) {
    showDialog(context: context, builder: (context) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      title: const Text('Delete Job?'), content: const Text('This action cannot be undone.'),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
        ElevatedButton(
          onPressed: () async { await context.read<RepairProvider>().deleteJob(job.id); if (context.mounted) { Navigator.pop(context); Navigator.pop(context); } },
          style: ElevatedButton.styleFrom(backgroundColor: Color(AppConstants.errorColor), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
          child: const Text('Delete'),
        ),
      ],
    ));
  }

  void _callPhone(BuildContext context, String phone) {
    showDialog(context: context, builder: (context) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      title: const Text('Call Customer'), content: Text('Call $phone?'),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
        ElevatedButton(
          onPressed: () { Navigator.pop(context); ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Phone feature coming soon'))); },
          child: const Text('Call'),
        ),
      ],
    ));
  }
}
