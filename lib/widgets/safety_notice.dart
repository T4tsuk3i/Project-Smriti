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
      margin: const EdgeInsets.only(top: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.rustSoft,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.favorite_outline,
                size: 18,
                color: AppColors.danger,
              ),
              const SizedBox(width: 8),
              Text(
                'That sounds heavy.',
                style: theme.textTheme.titleMedium?.copyWith(
                  color: AppColors.danger,
                ),
              ),
            ],
          ),
          const SizedBox(height: 5),
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
