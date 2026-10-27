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
      margin: const EdgeInsets.only(top: 16),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.danger.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.danger.withValues(alpha: 0.35)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'This sounds like a lot to carry alone.',
            style: theme.textTheme.titleMedium?.copyWith(
              color: AppColors.danger,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Smriti is not a crisis service. If you might be in danger, please '
            'contact a local helpline or emergency services. A real person can help.',
            style: theme.textTheme.bodySmall?.copyWith(
              color: AppColors.text,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 12),
          for (final resource in check.resources)
            Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Text(
                '• ${resource.label} — ${resource.contact}',
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
