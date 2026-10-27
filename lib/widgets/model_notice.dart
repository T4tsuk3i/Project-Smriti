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
      margin: const EdgeInsets.only(bottom: 22),
      padding: const EdgeInsets.only(left: 12),
      decoration: const BoxDecoration(
        border: Border(left: BorderSide(color: AppColors.olive, width: 2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            ModelService.label,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            'You can write now. Reflection stays off until a model is set up.',
            style: theme.textTheme.bodySmall,
          ),
          if (onOpenSettings != null)
            Padding(
              padding: const EdgeInsets.only(top: 2),
              child: TextButton(
                onPressed: onOpenSettings,
                style: TextButton.styleFrom(
                  padding: EdgeInsets.zero,
                  minimumSize: const Size(0, 30),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: const Text('Details'),
              ),
            ),
        ],
      ),
    );
  }
}
