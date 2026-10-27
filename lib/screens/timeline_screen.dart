import 'package:flutter/material.dart';

import '../app_theme.dart';
import '../data/journal_repository.dart';
import '../models/journal_entry.dart';
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
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final entries = await widget.repository.recentEntries(limit: 300);
    if (!mounted) return;
    setState(() {
      _entries = entries;
      _loading = false;
    });
  }

  Future<void> _delete(JournalEntry entry) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surfaceHigh,
        title: const Text('Delete this entry?'),
        content: const Text('This cannot be undone.'),
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
        .showSnackBar(const SnackBar(content: Text('Entry deleted.')));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 40),
      children: [
        PageHeader(
          eyebrow: 'Everything you wrote',
          title: 'Timeline',
          subtitle: _loading
              ? 'Loading your entries…'
              : '${_entries.length} ${_entries.length == 1 ? 'entry' : 'entries'} on this phone. No feed, no audience.',
        ),
        if (_loading)
          const Center(
            child: Padding(
              padding: EdgeInsets.all(24),
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          )
        else if (_entries.isEmpty)
          const EmptyState(
            title: 'No entries yet.',
            body: 'Start with today. Write a check-in, then come back.',
            icon: Icons.timeline,
          )
        else ...[
          Text(
            'Newest first',
            style: theme.textTheme.bodySmall?.copyWith(color: AppColors.faint),
          ),
          const SizedBox(height: 10),
          for (final entry in _entries)
            EntryCard(entry: entry, onDelete: () => _delete(entry)),
        ],
      ],
    );
  }
}
