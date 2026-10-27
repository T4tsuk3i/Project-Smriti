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
      const SnackBar(content: Text('Copied. Paste it somewhere safe.')),
    );
  }

  Future<void> _clearJournal() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.paperRaised,
        title: const Text('Delete everything?'),
        content: const Text(
          'Every entry and summary on this phone will be gone. '
          'Settings stay. This cannot be undone.',
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
          .showSnackBar(const SnackBar(content: Text('Deleted.')));
    } finally {
      if (mounted) setState(() => _clearing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 96),
      children: [
        const PageHeader(
          title: 'Settings',
          subtitle: 'Small app. Local by default.',
        ),
        _SettingsCard(
          color: AppColors.lilacSoft,
          icon: Icons.memory_outlined,
          iconColor: AppColors.lilac,
          title: 'Model',
          children: [
            Row(
              children: [
                Text(ModelService.label, style: theme.textTheme.titleMedium),
                const SizedBox(width: 10),
                Text(
                  ModelService.shortStatus,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: AppColors.lilac,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 5),
            Text(ModelService.explanation, style: theme.textTheme.bodySmall),
            const SizedBox(height: 4),
            Text(
              ModelService.roadmapNote,
              style: theme.textTheme.bodySmall?.copyWith(
                color: AppColors.faint,
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        _SettingsCard(
          color: AppColors.sageSoft,
          icon: Icons.favorite_outline,
          iconColor: AppColors.sage,
          title: 'Support',
          children: [
            Text(
              'Used only to show the right helplines if something you write '
              'looks like a crisis. Smriti cannot call anyone for you.',
              style: theme.textTheme.bodySmall,
            ),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: AppColors.paperRaised,
                borderRadius: BorderRadius.circular(12),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  isExpanded: true,
                  value: _country,
                  dropdownColor: AppColors.paperRaised,
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
        const SizedBox(height: 14),
        _SettingsCard(
          color: AppColors.orangeSoft,
          icon: Icons.folder_outlined,
          iconColor: AppColors.orange,
          title: 'Data',
          children: [
            Text(
              _loading
                  ? 'Loading…'
                  : '$_entryCount ${_entryCount == 1 ? 'entry' : 'entries'} on this phone.',
              style: theme.textTheme.bodySmall,
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 10,
              runSpacing: 8,
              children: [
                OutlinedButton(
                  onPressed: _loading ? null : _copyExport,
                  style: OutlinedButton.styleFrom(
                    backgroundColor: AppColors.paperRaised,
                    foregroundColor: AppColors.ink,
                    side: BorderSide.none,
                  ),
                  child: const Text('Copy export'),
                ),
                OutlinedButton(
                  onPressed: _clearing ? null : _clearJournal,
                  style: OutlinedButton.styleFrom(
                    backgroundColor: AppColors.paperRaised,
                    foregroundColor: AppColors.danger,
                    side: BorderSide.none,
                  ),
                  child: Text(_clearing ? 'Deleting…' : 'Delete everything'),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 14),
        _SettingsCard(
          color: AppColors.yellowSoft,
          icon: Icons.info_outline,
          iconColor: AppColors.yellow,
          title: 'About',
          children: [
            Text('Smriti 0.1.0 · MIT', style: theme.textTheme.bodySmall),
            const SizedBox(height: 4),
            Text(
              'Built by one person. Android first; iOS when it is ready.',
              style: theme.textTheme.bodySmall,
            ),
            const SizedBox(height: 4),
            Text(
              'Next: a local model, then a home-screen widget for quick check-ins.',
              style: theme.textTheme.bodySmall?.copyWith(
                color: AppColors.faint,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'No account. No server. No analytics.',
              style: theme.textTheme.bodySmall?.copyWith(
                color: AppColors.muted,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _SettingsCard extends StatelessWidget {
  const _SettingsCard({
    required this.color,
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.children,
  });

  final Color color;
  final IconData icon;
  final Color iconColor;
  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: AppColors.paperRaised,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: iconColor, size: 20),
              ),
              const SizedBox(width: 10),
              Text(title, style: theme.textTheme.headlineSmall),
            ],
          ),
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }
}
