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
    return ListView(
      padding: const EdgeInsets.fromLTRB(22, 18, 22, 36),
      children: [
        PageHeader(
          title: 'Journal',
          subtitle: _loading
              ? 'Loading…'
              : '${_entries.length} ${_entries.length == 1 ? 'entry' : 'entries'}, newest first.',
        ),
        if (_loading)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 24),
            child: LinearProgressIndicator(minHeight: 1),
          )
        else if (_entries.isEmpty)
          const EmptyState(
            title: 'Nothing yet.',
            body: 'Write a check-in first. One line is enough.',
          )
        else
          for (final entry in _entries)
            EntryCard(entry: entry, onDelete: () => _delete(entry)),
      ],
    );
  }
}
