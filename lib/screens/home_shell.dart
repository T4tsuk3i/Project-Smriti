import 'package:flutter/material.dart';

import '../app_theme.dart';
import '../data/journal_repository.dart';
import 'letter_screen.dart';
import 'settings_screen.dart';
import 'timeline_screen.dart';
import 'today_screen.dart';

class HomeShell extends StatefulWidget {
  const HomeShell({super.key, required this.repository});

  final JournalRepository repository;

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _index = 0;

  void _openSettings() {
    setState(() => _index = 3);
  }

  void _openJournal() {
    setState(() => _index = 1);
  }

  Widget _page() {
    switch (_index) {
      case 0:
        return TodayScreen(
          repository: widget.repository,
          onOpenSettings: _openSettings,
          onOpenJournal: _openJournal,
        );
      case 1:
        return TimelineScreen(repository: widget.repository);
      case 2:
        return LetterScreen(repository: widget.repository);
      default:
        return SettingsScreen(repository: widget.repository);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(22, 14, 18, 12),
              child: Row(
                children: [
                  Text(
                    'स्मृति',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      color: AppColors.rust,
                      fontSize: 21,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Smriti',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontSize: 20,
                    ),
                  ),
                  const Spacer(),
                  Tooltip(
                    message: 'Stored on this phone',
                    child: const Icon(
                      Icons.lock_outline,
                      size: 18,
                      color: AppColors.faint,
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            Expanded(child: _page()),
          ],
        ),
      ),
      bottomNavigationBar: DecoratedBox(
        decoration: const BoxDecoration(
          border: Border(top: BorderSide(color: AppColors.line)),
        ),
        child: NavigationBar(
          selectedIndex: _index,
          onDestinationSelected: (index) => setState(() => _index = index),
          labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.edit_note_outlined),
              selectedIcon: Icon(Icons.edit_note),
              label: 'Today',
            ),
            NavigationDestination(
              icon: Icon(Icons.menu_book_outlined),
              selectedIcon: Icon(Icons.menu_book),
              label: 'Journal',
            ),
            NavigationDestination(
              icon: Icon(Icons.mail_outline),
              selectedIcon: Icon(Icons.mail),
              label: 'Weekly',
            ),
            NavigationDestination(
              icon: Icon(Icons.settings_outlined),
              selectedIcon: Icon(Icons.settings),
              label: 'Settings',
            ),
          ],
        ),
      ),
    );
  }
}
