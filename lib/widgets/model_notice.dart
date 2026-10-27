import 'package:flutter/material.dart';

import '../app_theme.dart';
import '../services/model_service.dart';

class ModelNotice extends StatelessWidget {
  const ModelNotice({super.key, this.onOpenSettings});

  final VoidCallback? onOpenSettings;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 18),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.warning.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.warning.withValues(alpha: 0.25)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 2),
            child: Icon(
              Icons.memory_outlined,
              size: 20,
              color: AppColors.warning,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  ModelService.label,
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: AppColors.warning,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Journaling works now. AI reflection stays off until a local '
                  'model is configured.',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: AppColors.muted,
                    height: 1.45,
                  ),
                ),
                if (onOpenSettings != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: TextButton(
                      onPressed: onOpenSettings,
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.zero,
                        minimumSize: const Size(0, 32),
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: const Text('Settings →'),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
