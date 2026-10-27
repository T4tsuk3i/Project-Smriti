import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../app_theme.dart';
import '../models/journal_entry.dart';

class EntryCard extends StatelessWidget {
  const EntryCard({super.key, required this.entry, this.onDelete});

  final JournalEntry entry;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final date = DateFormat('MMM d, h:mm a').format(entry.createdAt);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.fromLTRB(18, 14, 12, 18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  date,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: AppColors.faint,
                    fontSize: 12,
                  ),
                ),
              ),
              if (entry.safetyFlag)
                const Padding(
                  padding: EdgeInsets.only(right: 6),
                  child: Icon(
                    Icons.favorite_outline,
                    size: 16,
                    color: AppColors.warning,
                  ),
                ),
              if (onDelete != null)
                IconButton(
                  onPressed: onDelete,
                  tooltip: 'Delete entry',
                  visualDensity: VisualDensity.compact,
                  icon: const Icon(
                    Icons.delete_outline,
                    size: 19,
                    color: AppColors.faint,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            entry.content,
            style: theme.textTheme.bodyMedium?.copyWith(height: 1.6),
          ),
        ],
      ),
    );
  }
}
