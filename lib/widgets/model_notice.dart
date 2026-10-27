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
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.fromLTRB(14, 12, 10, 12),
      decoration: BoxDecoration(
        color: AppColors.lilacSoft,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.memory_outlined, size: 18, color: AppColors.lilac),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  ModelService.label,
                  style: theme.textTheme.titleMedium?.copyWith(fontSize: 13.5),
                ),
                const SizedBox(height: 2),
                Text(
                  'Writing works. Reflection is off until a local model is set up.',
                  style: theme.textTheme.bodySmall?.copyWith(fontSize: 12.2),
                ),
              ],
            ),
          ),
          if (onOpenSettings != null)
            TextButton(
              onPressed: onOpenSettings,
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                minimumSize: const Size(0, 30),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: const Text('Details'),
            ),
        ],
      ),
    );
  }
}
