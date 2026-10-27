import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

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
  const TodayScreen({
    super.key,
    required this.repository,
    this.onOpenSettings,
    this.onOpenJournal,
  });

  final JournalRepository repository;
  final VoidCallback? onOpenSettings;
  final VoidCallback? onOpenJournal;

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
    final entries = await widget.repository.recentEntries(limit: 4);
    if (!mounted) return;
    setState(() {
      _entries = entries;
      _loading = false;
    });
  }

  int get _wordCount {
    final text = _controller.text.trim();
    if (text.isEmpty) return 0;
    return text.split(RegExp(r'\s+')).where((word) => word.isNotEmpty).length;
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
          .showSnackBar(const SnackBar(content: Text('Saved.')));
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Could not save. $error')));
    } finally {
      if (mounted) {
        setState(() => _saving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final today = DateFormat('EEEE, d MMMM').format(DateTime.now());
    final hasText = _controller.text.trim().isNotEmpty;

    return ListView(
      padding: const EdgeInsets.fromLTRB(22, 18, 22, 36),
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        PageHeader(
          eyebrow: today,
          title: 'What happened today?',
          subtitle:
              'A few lines is enough. It does not have to make sense yet.',
        ),
        ModelNotice(onOpenSettings: widget.onOpenSettings),
        Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: const BoxDecoration(
            border: Border(
              top: BorderSide(color: AppColors.line),
              bottom: BorderSide(color: AppColors.line),
            ),
          ),
          child: TextField(
            controller: _controller,
            minLines: 8,
            maxLines: 14,
            maxLength: 12000,
            textCapitalization: TextCapitalization.sentences,
            onChanged: (_) => setState(() {}),
            decoration: const InputDecoration(
              hintText: 'Start anywhere.',
              counterText: '',
              border: InputBorder.none,
              filled: false,
              contentPadding: EdgeInsets.zero,
            ),
            style: theme.textTheme.bodyMedium?.copyWith(
              height: 1.7,
              fontSize: 16,
              color: AppColors.ink,
            ),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Text(
              '$_wordCount ${_wordCount == 1 ? 'word' : 'words'}',
              style: theme.textTheme.bodySmall?.copyWith(
                color: AppColors.faint,
                fontSize: 12,
              ),
            ),
            const Spacer(),
            FilledButton(
              onPressed: hasText && !_saving ? _save : null,
              child: Text(_saving ? 'Saving…' : 'Save'),
            ),
          ],
        ),
        if (_safety != null) SafetyNotice(check: _safety!),
        const SizedBox(height: 30),
        Row(
          children: [
            Text('Earlier', style: theme.textTheme.headlineSmall),
            const Spacer(),
            if (_entries.isNotEmpty && widget.onOpenJournal != null)
              TextButton(
                onPressed: widget.onOpenJournal,
                child: const Text('All entries'),
              ),
          ],
        ),
        const SizedBox(height: 4),
        if (_loading)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 24),
            child: LinearProgressIndicator(minHeight: 1),
          )
        else if (_entries.isEmpty)
          const EmptyState(
            title: 'Nothing yet.',
            body: 'Write the first one. One line counts.',
          )
        else
          for (final entry in _entries) EntryCard(entry: entry),
      ],
    );
  }
}
