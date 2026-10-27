import 'package:flutter/material.dart';

import '../app_theme.dart';
import '../data/journal_repository.dart';
import '../models/journal_entry.dart';
import '../models/safety_check.dart';
import '../services/safety_service.dart';
import '../widgets/empty_state.dart';
import '../widgets/entry_card.dart';
import '../widgets/model_notice.dart';
import '../widgets/page_header.dart';
import '../widgets/safety_notice.dart';

class TodayScreen extends StatefulWidget {
  const TodayScreen({super.key, required this.repository, this.onOpenSettings});

  final JournalRepository repository;
  final VoidCallback? onOpenSettings;

  @override
  State<TodayScreen> createState() => _TodayScreenState();
}

class _TodayScreenState extends State<TodayScreen> {
  final _controller = TextEditingController();

  List<JournalEntry> _entries = const [];
  SafetyCheck? _safety;
  bool _loading = true;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final entries = await widget.repository.recentEntries(limit: 5);
    if (!mounted) return;
    setState(() {
      _entries = entries;
      _loading = false;
    });
  }

  Future<void> _save() async {
    final content = _controller.text.trim();
    if (content.isEmpty || _saving) return;

    setState(() {
      _saving = true;
      _safety = null;
    });

    try {
      final country = await widget.repository.getSetting(
        'safety_country',
        fallback: 'IN',
      );
      final check = SafetyService.check(content, country: country);
      await widget.repository.addEntry(content, safetyFlag: check.flagged);
      _controller.clear();
      await _load();
      if (!mounted) return;
      setState(() {
        _safety = check.flagged ? check : null;
      });
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Saved locally.')));
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Could not save: $error')));
    } finally {
      if (mounted) {
        setState(() => _saving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasText = _controller.text.trim().isNotEmpty;

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 40),
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        PageHeader(
          eyebrow: 'A quiet place that remembers',
          title: 'How did today actually go?',
          subtitle:
              'A short check-in, no audience. Smriti keeps it on this phone.',
        ),
        ModelNotice(onOpenSettings: widget.onOpenSettings),
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("TODAY'S CHECK-IN", style: theme.textTheme.labelSmall),
              const SizedBox(height: 10),
              TextField(
                controller: _controller,
                minLines: 7,
                maxLines: 12,
                maxLength: 12000,
                textCapitalization: TextCapitalization.sentences,
                onChanged: (_) => setState(() {}),
                decoration: const InputDecoration(
                  hintText: 'What happened? What did you avoid? What did you get through?\n\nNo performance needed.',
                  counterText: '',
                  border: InputBorder.none,
                  filled: false,
                  contentPadding: EdgeInsets.zero,
                ),
                style: theme.textTheme.bodyMedium?.copyWith(
                  height: 1.65,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      '${_controller.text.length} / 12000 · local only',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: AppColors.faint,
                        fontSize: 11.5,
                      ),
                    ),
                  ),
                  FilledButton(
                    onPressed: hasText && !_saving ? _save : null,
                    child: Text(_saving ? 'Saving…' : 'Save check-in'),
                  ),
                ],
              ),
            ],
          ),
        ),
        if (_safety != null) SafetyNotice(check: _safety!),
        const SizedBox(height: 28),
        Row(
          children: [
            Text('Recent', style: theme.textTheme.headlineSmall),
            const Spacer(),
            if (_entries.isNotEmpty)
              Text(
                '${_entries.length}',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: AppColors.faint,
                ),
              ),
          ],
        ),
        const SizedBox(height: 12),
        if (_loading)
          const Center(
            child: Padding(
              padding: EdgeInsets.all(24),
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          )
        else if (_entries.isEmpty)
          const EmptyState(
            title: 'Nothing here yet.',
            body: 'Write the first check-in. It does not have to be good.',
            icon: Icons.edit_note,
          )
        else
          for (final entry in _entries) EntryCard(entry: entry),
      ],
    );
  }
}
