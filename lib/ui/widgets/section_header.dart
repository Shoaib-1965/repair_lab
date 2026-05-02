import 'package:flutter/material.dart';
import '../../core/constants/app_constants.dart';

class SectionHeader extends StatelessWidget {
  final String title;
  final Widget? trailing;

  const SectionHeader({super.key, required this.title, this.trailing});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title.toUpperCase(),
          style: Theme.of(
            context,
          ).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w700,
            letterSpacing: 1.2,
            fontSize: 15,
            color: Color(AppConstants.textPrimary),
          ),
        ),
        ?trailing,
      ],
    );
  }
}
