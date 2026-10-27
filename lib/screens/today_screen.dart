import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../app_theme.dart';
import '../data/journal_repository.dart';
import '../models/journal_entry.dart';
import '../models/mood.dart';
import '../models/safety_check.dart';
import '../services/safety_service.dart';
import '../widgets/empty_state.dart';
import '../widgets/entry_card.dart';
import '../widgets/model_notice.dart';
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
  Mood? _mood;
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

  String get _greeting {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning.';
    if (hour < 17) return 'Good afternoon.';
    if (hour < 22) return 'Good evening.';
    return 'Still up?';
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
      await widget.repository.addEntry(
        content,
        safetyFlag: check.flagged,
        mood: _mood?.id,
      );
      _controller.clear();
      _mood = null;
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
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 96),
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        Text(_greeting, style: theme.textTheme.displaySmall),
        const SizedBox(height: 2),
        Text(
          today,
          style: theme.textTheme.bodySmall?.copyWith(color: AppColors.faint),
        ),
        const SizedBox(height: 18),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: _cardDecoration(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'How are you arriving?',
                style: theme.textTheme.headlineSmall,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  for (final mood in moods)
                    Expanded(
                      child: _MoodButton(
                        mood: mood,
                        selected: _mood?.id == mood.id,
                        onTap: () => setState(() {
                          _mood = _mood?.id == mood.id ? null : mood;
                        }),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        Container(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 14),
          decoration: _cardDecoration(),
          child: Column(
            children: [
              TextField(
                controller: _controller,
                minLines: 5,
                maxLines: 10,
                maxLength: 12000,
                textCapitalization: TextCapitalization.sentences,
                onChanged: (_) => setState(() {}),
                decoration: const InputDecoration(
                  hintText: "What's on your mind?",
                  counterText: '',
                  border: InputBorder.none,
                  filled: false,
                  contentPadding: EdgeInsets.zero,
                ),
                style: theme.textTheme.bodyMedium?.copyWith(
                  height: 1.65,
                  fontSize: 16,
                  fontFamily: 'serif',
                ),
              ),
              const SizedBox(height: 8),
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
            ],
          ),
        ),
        if (_safety != null) SafetyNotice(check: _safety!),
        const SizedBox(height: 12),
        ModelNotice(onOpenSettings: widget.onOpenSettings),
        const SizedBox(height: 6),
        Row(
          children: [
            Text('Lately', style: theme.textTheme.headlineMedium),
            const Spacer(),
            if (_entries.isNotEmpty && widget.onOpenJournal != null)
              TextButton(
                onPressed: widget.onOpenJournal,
                child: const Text('See all'),
              ),
          ],
        ),
        const SizedBox(height: 8),
        if (_loading)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 20),
            child: LinearProgressIndicator(minHeight: 2),
          )
        else if (_entries.isEmpty)
          const EmptyState(
            title: 'Blank page.',
            body: 'Write one line. That counts.',
          )
        else
          for (final entry in _entries) EntryCard(entry: entry),
      ],
    );
  }

  BoxDecoration _cardDecoration() {
    return BoxDecoration(
      color: AppColors.paperRaised,
      borderRadius: BorderRadius.circular(20),
      boxShadow: [
        BoxShadow(
          color: AppColors.ink.withValues(alpha: 0.05),
          blurRadius: 20,
          offset: const Offset(0, 7),
        ),
      ],
    );
  }
}

class _MoodButton extends StatelessWidget {
  const _MoodButton({
    required this.mood,
    required this.selected,
    required this.onTap,
  });

  final Mood mood;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        margin: const EdgeInsets.symmetric(horizontal: 2),
        padding: const EdgeInsets.symmetric(vertical: 9),
        decoration: BoxDecoration(
          color: selected
              ? mood.soft
              : AppColors.paperDeep.withValues(alpha: 0.55),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: selected ? mood.color : Colors.transparent,
            width: 1.2,
          ),
        ),
        child: Column(
          children: [
            Text(mood.emoji, style: const TextStyle(fontSize: 20)),
            const SizedBox(height: 3),
            Text(
              mood.label,
              style: TextStyle(
                fontSize: 10.5,
                fontWeight: FontWeight.w600,
                color: selected ? mood.color : AppColors.muted,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
