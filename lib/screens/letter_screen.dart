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
  WeekStats? _stats;
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
    final start = DateTime(
      end.year,
      end.month,
      end.day,
    ).subtract(const Duration(days: 6));
    final letter = await widget.repository.latestLetter();
    final entries = await widget.repository.entriesBetween(start, end);
    if (!mounted) return;
    setState(() {
      _letter = letter;
      _recentCount = entries.length;
      _stats = WeeklySummaryService.stats(entries);
      _loading = false;
    });
  }

  Future<void> _writeSummary() async {
    if (_generating) return;
    setState(() => _generating = true);

    try {
      final end = DateTime.now();
      final start = DateTime(
        end.year,
        end.month,
        end.day,
      ).subtract(const Duration(days: 6));
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
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 96),
      children: [
        const PageHeader(
          title: 'This week',
          subtitle: 'A plain look at what you wrote. No model involved.',
        ),
        if (_loading)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 20),
            child: LinearProgressIndicator(minHeight: 2),
          )
        else ...[
          if (_stats != null) _StatsCard(stats: _stats!),
          const SizedBox(height: 14),
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
          const SizedBox(height: 22),
          if (_letter != null)
            Container(
              padding: const EdgeInsets.all(20),
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
                      fontSize: 16.5,
                      height: 1.8,
                    ),
                  ),
                ],
              ),
            )
          else
            const EmptyState(
              title: 'Nothing written up yet.',
              body: 'A few check-ins are enough. Write it up when you want.',
              icon: Icons.article_outlined,
              color: AppColors.yellowSoft,
            ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.lilacSoft,
              borderRadius: BorderRadius.circular(18),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.auto_awesome_outlined,
                  size: 18,
                  color: AppColors.lilac,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Reflection is off',
                        style: theme.textTheme.titleMedium,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'When there is a model on your phone, this page gets a '
                        'real letter. For now it is just a count.',
                        style: theme.textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}

class _StatsCard extends StatelessWidget {
  const _StatsCard({required this.stats});

  final WeekStats stats;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final maxWords = stats.bars.fold<int>(
      1,
      (max, day) => day.words > max ? day.words : max,
    );

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
          const SizedBox(height: 18),
          Text(
            'Words by day',
            style: theme.textTheme.bodySmall?.copyWith(
              color: AppColors.faint,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: 86,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                for (final day in stats.bars)
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Container(
                          width: 18,
                          height: 6 + (day.words / maxWords) * 54,
                          decoration: BoxDecoration(
                            color: day.words > 0
                                ? AppColors.rust
                                : AppColors.paperDeep,
                            borderRadius: BorderRadius.circular(6),
                          ),
                        ),
                        const SizedBox(height: 6),
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
