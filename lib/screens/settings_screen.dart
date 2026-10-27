import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../app_theme.dart';
import '../data/journal_repository.dart';
import '../services/model_service.dart';
import '../widgets/page_header.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key, required this.repository});

  final JournalRepository repository;

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  String _country = 'IN';
  int _entryCount = 0;
  bool _loading = true;
  bool _clearing = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final country = await widget.repository.getSetting(
      'safety_country',
      fallback: 'IN',
    );
    final count = await widget.repository.countEntries();
    if (!mounted) return;
    setState(() {
      _country = country;
      _entryCount = count;
      _loading = false;
    });
  }

  Future<void> _setCountry(String? value) async {
    if (value == null) return;
    setState(() => _country = value);
    await widget.repository.setSetting('safety_country', value);
  }

  Future<void> _copyExport() async {
    final data = await widget.repository.exportData();
    final text = const JsonEncoder.withIndent('  ').convert(data);
    await Clipboard.setData(ClipboardData(text: text));
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Export JSON copied to clipboard.')),
    );
  }

  Future<void> _clearJournal() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surfaceHigh,
        title: const Text('Delete all journal data?'),
        content: const Text(
          'Every entry and letter on this phone will be removed. '
          'This cannot be undone. Settings are kept.',
        ),
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

    if (confirmed != true) return;
    setState(() => _clearing = true);
    try {
      await widget.repository.clearJournal();
      await _load();
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Journal data deleted.')));
    } finally {
      if (mounted) setState(() => _clearing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 40),
      children: [
        const PageHeader(
          eyebrow: 'Your phone, your data',
          title: 'Settings',
          subtitle:
              'No account. No Smriti server. No telemetry. Entries live in a local '
              'SQLite file on this device.',
        ),
        _SettingsCard(
          children: [
            Row(
              children: [
                const Icon(
                  Icons.memory_outlined,
                  color: AppColors.faint,
                  size: 22,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'On-device model',
                    style: theme.textTheme.headlineSmall,
                  ),
                ),
                _StatusChip(label: ModelService.shortStatus),
              ],
            ),
            const SizedBox(height: 10),
            Text(ModelService.explanation, style: theme.textTheme.bodySmall),
            const SizedBox(height: 10),
            Text(
              ModelService.roadmapNote,
              style: theme.textTheme.bodySmall?.copyWith(
                color: AppColors.faint,
              ),
            ),
            const SizedBox(height: 14),
            FilledButton.tonal(
              onPressed: null,
              child: const Text('Choose model (coming soon)'),
            ),
          ],
        ),
        const SizedBox(height: 16),
        _SettingsCard(
          children: [
            Text('You', style: theme.textTheme.headlineSmall),
            const SizedBox(height: 6),
            Text(
              'Used only to show relevant support resources. Smriti is not a crisis service.',
              style: theme.textTheme.bodySmall,
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                color: AppColors.surfaceHigh,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.border),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  isExpanded: true,
                  value: _country,
                  dropdownColor: AppColors.surfaceHigh,
                  icon: const Icon(Icons.expand_more, color: AppColors.muted),
                  style: theme.textTheme.bodyMedium,
                  items: const [
                    DropdownMenuItem(value: 'IN', child: Text('India')),
                    DropdownMenuItem(value: 'US', child: Text('United States')),
                    DropdownMenuItem(
                      value: 'GB',
                      child: Text('United Kingdom'),
                    ),
                    DropdownMenuItem(value: 'CA', child: Text('Canada')),
                    DropdownMenuItem(value: 'AU', child: Text('Australia')),
                    DropdownMenuItem(
                      value: 'OTHER',
                      child: Text('Other / international'),
                    ),
                  ],
                  onChanged: _setCountry,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        _SettingsCard(
          children: [
            Text('Data', style: theme.textTheme.headlineSmall),
            const SizedBox(height: 6),
            Text(
              '$_entryCount ${_entryCount == 1 ? 'entry' : 'entries'} stored on this phone.',
              style: theme.textTheme.bodySmall,
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _loading ? null : _copyExport,
                    icon: const Icon(Icons.copy_all_outlined, size: 18),
                    label: const Text('Copy export'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _clearing ? null : _clearJournal,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.danger,
                      side: BorderSide(
                        color: AppColors.danger.withValues(alpha: 0.35),
                      ),
                    ),
                    icon: const Icon(Icons.delete_outline, size: 18),
                    label: Text(_clearing ? 'Deleting…' : 'Delete data'),
                  ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 16),
        _SettingsCard(
          children: [
            Text('Privacy', style: theme.textTheme.headlineSmall),
            const SizedBox(height: 6),
            Text(
              'Smriti has no server and no telemetry. There is no account to log '
              'into. The app does not bundle or download a model right now, and it '
              'does not call a cloud model.',
              style: theme.textTheme.bodySmall,
            ),
          ],
        ),
        const SizedBox(height: 16),
        _SettingsCard(
          children: [
            Text('About', style: theme.textTheme.headlineSmall),
            const SizedBox(height: 6),
            Text('Smriti v0.1.0 · MIT', style: theme.textTheme.bodySmall),
            const SizedBox(height: 4),
            Text(
              'Android-first. iOS welcome when the free local build path is ready.',
              style: theme.textTheme.bodySmall,
            ),
            const SizedBox(height: 4),
            Text(
              'Roadmap: Rust FFI core, encrypted storage, on-device GGUF, '
              'home-screen / linking widget.',
              style: theme.textTheme.bodySmall?.copyWith(
                color: AppColors.faint,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _SettingsCard extends StatelessWidget {
  const _SettingsCard({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: AppColors.warning.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: AppColors.warning.withValues(alpha: 0.28)),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: AppColors.warning,
          fontSize: 11,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
