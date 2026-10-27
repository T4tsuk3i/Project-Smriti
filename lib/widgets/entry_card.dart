import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../app_theme.dart';
import '../models/journal_entry.dart';
import '../models/mood.dart';

class EntryCard extends StatelessWidget {
  const EntryCard({super.key, required this.entry, this.onDelete});

  final JournalEntry entry;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final date = DateFormat('d MMM · h:mm a').format(entry.createdAt);
    final mood = moodById(entry.mood);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.fromLTRB(16, 14, 12, 16),
      decoration: BoxDecoration(
        color: AppColors.paperRaised,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: AppColors.ink.withValues(alpha: 0.05),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (mood != null) ...[
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: mood.soft,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    '${mood.emoji}  ${mood.label}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: mood.color,
                      fontSize: 11.5,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
              ],
              Expanded(
                child: Text(
                  date,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: AppColors.faint,
                    fontSize: 11.5,
                  ),
                ),
              ),
              if (onDelete != null)
                IconButton(
                  onPressed: onDelete,
                  tooltip: 'Delete entry',
                  visualDensity: VisualDensity.compact,
                  icon: const Icon(
                    Icons.delete_outline,
                    size: 18,
                    color: AppColors.faint,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            entry.content,
            style: theme.textTheme.bodyMedium?.copyWith(
              height: 1.65,
              fontFamily: 'serif',
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }
}
