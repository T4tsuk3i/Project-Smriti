import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../app_theme.dart';
import '../data/journal_repository.dart';
import '../models/weekly_letter.dart';
import '../services/weekly_summary_service.dart';
import '../widgets/empty_state.dart';
import '../widgets/page_header.dart';

class LetterScreen extends StatefulWidget {
  const LetterScreen({super.key, required this.repository});

  final JournalRepository repository;

  @override
  State<LetterScreen> createState() => _LetterScreenState();
}

class _LetterScreenState extends State<LetterScreen> {
  WeeklyLetter? _letter;
  int _recentCount = 0;
  bool _loading = true;
  bool _generating = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final end = DateTime.now();
    final start = end.subtract(const Duration(days: 7));
    final letter = await widget.repository.latestLetter();
    final entries = await widget.repository.entriesBetween(start, end);
    if (!mounted) return;
    setState(() {
      _letter = letter;
      _recentCount = entries.length;
      _loading = false;
    });
  }

  Future<void> _writeSummary() async {
    if (_generating) return;
    setState(() => _generating = true);

    try {
      final end = DateTime.now();
      final start = end.subtract(const Duration(days: 7));
      final entries = await widget.repository.entriesBetween(start, end);
      if (entries.isEmpty) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Write a check-in first.')),
        );
        return;
      }

      final content = WeeklySummaryService.build(entries);
      await widget.repository.saveLetter(
        content: content,
        periodStart: start,
        periodEnd: end,
      );
      await _load();
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Saved.')));
    } finally {
      if (mounted) setState(() => _generating = false);
    }
  }

  String _period(DateTime start, DateTime end) {
    final format = DateFormat('d MMM');
    return '${format.format(start)} – ${format.format(end)}';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ListView(
      padding: const EdgeInsets.fromLTRB(22, 18, 22, 36),
      children: [
        const PageHeader(
          title: 'This week',
          subtitle: 'A plain summary of what you wrote. No model involved.',
        ),
        if (_loading)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 24),
            child: LinearProgressIndicator(minHeight: 1),
          )
        else ...[
          Row(
            children: [
              Expanded(
                child: Text(
                  '$_recentCount ${_recentCount == 1 ? 'entry' : 'entries'} in the last seven days',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: AppColors.faint,
                  ),
                ),
              ),
              FilledButton(
                onPressed: _recentCount == 0 || _generating
                    ? null
                    : _writeSummary,
                child: Text(_generating ? 'Writing…' : 'Write it up'),
              ),
            ],
          ),
          if (_recentCount == 0)
            const Padding(
              padding: EdgeInsets.only(top: 12),
              child: EmptyState(
                title: 'Nothing to sum up yet.',
                body: 'Write a check-in first.',
                icon: Icons.edit_note,
              ),
            ),
          const SizedBox(height: 24),
          if (_letter != null)
            Container(
              padding: const EdgeInsets.symmetric(vertical: 20),
              decoration: const BoxDecoration(
                border: Border(
                  top: BorderSide(color: AppColors.line),
                  bottom: BorderSide(color: AppColors.line),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _period(_letter!.periodStart, _letter!.periodEnd),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: AppColors.faint,
                    ),
                  ),
                  const SizedBox(height: 12),
                  SelectableText(
                    _letter!.content,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontFamily: 'serif',
                      fontSize: 17,
                      height: 1.8,
                    ),
                  ),
                ],
              ),
            )
          else
            const EmptyState(
              title: 'No summary yet.',
              body: 'A few check-ins are enough. Write it up when you want.',
              icon: Icons.article_outlined,
            ),
          const SizedBox(height: 22),
          Container(
            padding: const EdgeInsets.only(left: 12),
            decoration: const BoxDecoration(
              border: Border(
                left: BorderSide(color: AppColors.olive, width: 2),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Reflection is off', style: theme.textTheme.titleMedium),
                const SizedBox(height: 3),
                Text(
                  'When there is a model on your phone, this page gets a real '
                  'letter. For now it is just a count.',
                  style: theme.textTheme.bodySmall,
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}
