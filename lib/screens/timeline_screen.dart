import 'package:flutter/material.dart';

import '../app_theme.dart';
import '../data/journal_repository.dart';
import '../models/journal_entry.dart';
import '../services/weekly_summary_service.dart';
import '../widgets/empty_state.dart';
import '../widgets/entry_card.dart';
import '../widgets/page_header.dart';

class TimelineScreen extends StatefulWidget {
  const TimelineScreen({super.key, required this.repository});

  final JournalRepository repository;

  @override
  State<TimelineScreen> createState() => _TimelineScreenState();
}

class _TimelineScreenState extends State<TimelineScreen> {
  List<JournalEntry> _entries = const [];
  WeekStats? _stats;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final entries = await widget.repository.recentEntries(limit: 300);
    final end = DateTime.now();
    final start = DateTime(
      end.year,
      end.month,
      end.day,
    ).subtract(const Duration(days: 6));
    final weekEntries = entries
        .where((entry) => !entry.createdAt.toLocal().isBefore(start))
        .toList();

    if (!mounted) return;
    setState(() {
      _entries = entries;
      _stats = WeeklySummaryService.stats(weekEntries);
      _loading = false;
    });
  }

  Future<void> _delete(JournalEntry entry) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.paperRaised,
        title: const Text('Delete this entry?'),
        content: const Text('It will not come back.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Keep'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: AppColors.danger),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed != true || entry.id == null) return;
    await widget.repository.deleteEntry(entry.id!);
    await _load();
    if (!mounted) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text('Deleted.')));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 96),
      children: [
        PageHeader(
          title: 'Journal',
          subtitle: _loading
              ? 'Loading…'
              : '${_entries.length} ${_entries.length == 1 ? 'entry' : 'entries'}, newest first.',
        ),
        if (_loading)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 20),
            child: LinearProgressIndicator(minHeight: 2),
          )
        else ...[
          _WeekCard(stats: _stats!),
          const SizedBox(height: 22),
          Text('All entries', style: theme.textTheme.headlineSmall),
          const SizedBox(height: 10),
          if (_entries.isEmpty)
            const EmptyState(
              title: 'Blank page.',
              body: 'Write a check-in first. One line is enough.',
            )
          else
            for (final entry in _entries)
              EntryCard(entry: entry, onDelete: () => _delete(entry)),
        ],
      ],
    );
  }
}

class _WeekCard extends StatelessWidget {
  const _WeekCard({required this.stats});

  final WeekStats stats;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.paperRaised,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.ink.withValues(alpha: 0.05),
            blurRadius: 20,
            offset: const Offset(0, 7),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'This week',
            style: theme.textTheme.bodySmall?.copyWith(
              color: AppColors.faint,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _Stat(
                value: '${stats.entries}',
                label: 'entries',
                color: AppColors.rust,
              ),
              _Stat(
                value: '${stats.words}',
                label: 'words',
                color: AppColors.lilac,
              ),
              _Stat(
                value: '${stats.days}',
                label: 'days',
                color: AppColors.sage,
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              for (final day in stats.bars)
                Expanded(
                  child: Column(
                    children: [
                      Container(
                        width: 26,
                        height: 26,
                        decoration: BoxDecoration(
                          color: day.wrote
                              ? AppColors.rustSoft
                              : AppColors.paperDeep,
                          shape: BoxShape.circle,
                        ),
                        child: day.wrote
                            ? const Icon(
                                Icons.check,
                                size: 14,
                                color: AppColors.rust,
                              )
                            : null,
                      ),
                      const SizedBox(height: 5),
                      Text(
                        day.label.substring(0, 1),
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: day.wrote ? AppColors.ink : AppColors.faint,
                          fontSize: 10.5,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.value, required this.label, required this.color});

  final String value;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            value,
            style: theme.textTheme.headlineMedium?.copyWith(
              color: color,
              fontSize: 28,
              fontWeight: FontWeight.w800,
            ),
          ),
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: AppColors.muted,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}
