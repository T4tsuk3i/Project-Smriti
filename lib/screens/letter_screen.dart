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
          const SnackBar(
            content: Text(
              'Write at least one check-in in the last seven days.',
            ),
          ),
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
          .showSnackBar(const SnackBar(content: Text('Local summary saved.')));
    } finally {
      if (mounted) setState(() => _generating = false);
    }
  }

  String _period(DateTime start, DateTime end) {
    final format = DateFormat('MMM d');
    return '${format.format(start)} – ${format.format(end)}';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 40),
      children: [
        PageHeader(
          eyebrow: 'Once a week, something gets clearer',
          title: 'The weekly letter',
          subtitle:
              'Right now this is a local summary, not an AI reflection. It counts '
              'what you wrote and shows the words you kept returning to.',
        ),
        if (_loading)
          const Center(
            child: Padding(
              padding: EdgeInsets.all(24),
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          )
        else ...[
          Row(
            children: [
              Expanded(
                child: Text(
                  '$_recentCount ${_recentCount == 1 ? 'entry' : 'entries'} in the last seven days',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: AppColors.muted,
                  ),
                ),
              ),
              FilledButton(
                onPressed: _recentCount == 0 || _generating
                    ? null
                    : _writeSummary,
                child: Text(_generating ? 'Writing…' : 'Write summary'),
              ),
            ],
          ),
          if (_recentCount == 0)
            const Padding(
              padding: EdgeInsets.only(top: 14),
              child: _InfoCard(
                icon: Icons.edit_note,
                title: 'Nothing to summarise yet',
                body: 'Write at least one check-in in the last seven days.',
              ),
            ),
          const SizedBox(height: 20),
          if (_letter != null)
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: AppColors.peach.withValues(alpha: 0.28),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _period(_letter!.periodStart, _letter!.periodEnd),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: AppColors.peach,
                    ),
                  ),
                  const SizedBox(height: 14),
                  SelectableText(
                    _letter!.content,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontFamily: 'serif',
                      fontSize: 16.5,
                      height: 1.75,
                    ),
                  ),
                ],
              ),
            )
          else
            const EmptyState(
              title: 'No letter yet.',
              body: 'A few check-ins are enough. Write a summary when you are ready.',
              icon: Icons.mail_outline,
            ),
          const SizedBox(height: 20),
          const _InfoCard(
            icon: Icons.memory_outlined,
            title: 'AI reflection is off',
            body:
                'No on-device model is configured. The summary above is generated '
                'locally without a model. When local inference lands, this is where '
                'the real weekly letter will appear.',
          ),
        ],
      ],
    );
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({
    required this.icon,
    required this.title,
    required this.body,
  });

  final IconData icon;
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppColors.faint, size: 21),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: theme.textTheme.titleMedium),
                const SizedBox(height: 4),
                Text(body, style: theme.textTheme.bodySmall),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
