import 'package:flutter/material.dart';

import '../app_theme.dart';

class PageHeader extends StatelessWidget {
  const PageHeader({
    super.key,
    this.eyebrow,
    required this.title,
    this.subtitle,
  });

  final String? eyebrow;
  final String title;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (eyebrow != null) ...[
          Text(eyebrow!.toUpperCase(), style: theme.textTheme.labelSmall),
          const SizedBox(height: 8),
        ],
        Text(title, style: theme.textTheme.displaySmall),
        if (subtitle != null) ...[
          const SizedBox(height: 10),
          Text(
            subtitle!,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: AppColors.muted,
              height: 1.55,
            ),
          ),
        ],
        const SizedBox(height: 22),
      ],
    );
  }
}
