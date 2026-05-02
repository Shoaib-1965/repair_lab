import 'package:flutter/material.dart';
import '../../core/constants/app_constants.dart';

class TagChip extends StatelessWidget {
  final String tag;
  final VoidCallback? onDeleted;

  const TagChip({super.key, required this.tag, this.onDeleted});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: Color(AppConstants.primaryColor).withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Color(AppConstants.primaryColor).withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            tag,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: Color(AppConstants.primaryColor),
              fontWeight: FontWeight.w600,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          if (onDeleted != null)
            GestureDetector(
              onTap: onDeleted,
              child: const Padding(
                padding: EdgeInsets.only(left: 4),
                child: Icon(Icons.close, size: 14),
              ),
            ),
        ],
      ),
    );
  }
}
