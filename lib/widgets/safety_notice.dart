import 'package:flutter/material.dart';

import '../app_theme.dart';
import '../models/safety_check.dart';

class SafetyNotice extends StatelessWidget {
  const SafetyNotice({super.key, required this.check});

  final SafetyCheck check;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: 18),
      padding: const EdgeInsets.only(left: 12),
      decoration: const BoxDecoration(
        border: Border(left: BorderSide(color: AppColors.danger, width: 2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'That sounds heavy.',
            style: theme.textTheme.titleMedium?.copyWith(
              color: AppColors.danger,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'If you might be in danger, please call a local helpline or emergency '
            'services. Smriti cannot monitor you or call anyone for you.',
            style: theme.textTheme.bodySmall?.copyWith(
              color: AppColors.ink,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 10),
          for (final resource in check.resources)
            Padding(
              padding: const EdgeInsets.only(bottom: 3),
              child: Text(
                '${resource.label} — ${resource.contact}',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: AppColors.muted,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
