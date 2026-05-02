import 'package:flutter/material.dart';
import '../../core/constants/app_constants.dart';

class StatusBadge extends StatelessWidget {
  final String status;

  const StatusBadge({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    final statusConfig = _getStatusConfig();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: statusConfig['color'] as Color,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        statusConfig['label'] as String,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Map<String, dynamic> _getStatusConfig() {
    switch (status) {
      case 'pending':
        return {'label': 'PENDING', 'color': Color(AppConstants.warningColor)};
      case 'done':
        return {'label': 'DONE', 'color': Color(AppConstants.successColor)};
      case 'issue_found':
        return {
          'label': 'ISSUE FOUND',
          'color': Color(AppConstants.errorColor),
        };
      default:
        return {'label': 'UNKNOWN', 'color': Color(AppConstants.textSecondary)};
    }
  }
}
