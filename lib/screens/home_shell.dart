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

  Widget _page() {
    switch (_index) {
      case 0:
        return TodayScreen(
          repository: widget.repository,
          onOpenSettings: _openSettings,
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
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Row(
                children: [
                  Text(
                    'स्मृति',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      color: AppColors.mint,
                      fontSize: 24,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Smriti',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontSize: 22,
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.mint.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(
                        color: AppColors.mint.withValues(alpha: 0.2),
                      ),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.lock_outline,
                          size: 13,
                          color: AppColors.mint,
                        ),
                        SizedBox(width: 5),
                        Text(
                          'Local',
                          style: TextStyle(
                            color: AppColors.mint,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Expanded(child: _page()),
          ],
        ),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (index) => setState(() => _index = index),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.edit_note_outlined),
            selectedIcon: Icon(Icons.edit_note),
            label: 'Today',
          ),
          NavigationDestination(
            icon: Icon(Icons.timeline_outlined),
            selectedIcon: Icon(Icons.timeline),
            label: 'Timeline',
          ),
          NavigationDestination(
            icon: Icon(Icons.mail_outline),
            selectedIcon: Icon(Icons.mail),
            label: 'Letter',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings_outlined),
            selectedIcon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}
