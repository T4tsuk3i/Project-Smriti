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

  void _openSettings() => setState(() => _index = 3);

  void _openJournal() => setState(() => _index = 1);

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
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFFFE7D2), AppColors.paper, AppColors.paper],
            stops: [0, 0.38, 1],
          ),
        ),
        child: SafeArea(
          bottom: false,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 4),
                child: Row(
                  children: [
                    Text(
                      'स्मृति',
                      style: theme.textTheme.headlineSmall?.copyWith(
                        color: AppColors.rust,
                        fontSize: 20,
                      ),
                    ),
                    const SizedBox(width: 7),
                    Text(
                      'Smriti',
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontSize: 19,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      width: 5,
                      height: 5,
                      decoration: const BoxDecoration(
                        color: AppColors.rust,
                        shape: BoxShape.circle,
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
              Expanded(child: _page()),
            ],
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        minimum: const EdgeInsets.fromLTRB(16, 0, 16, 10),
        child: Container(
          height: 64,
          padding: const EdgeInsets.symmetric(horizontal: 5),
          decoration: BoxDecoration(
            color: AppColors.paperRaised,
            borderRadius: BorderRadius.circular(22),
            boxShadow: [
              BoxShadow(
                color: AppColors.ink.withValues(alpha: 0.1),
                blurRadius: 24,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            children: [
              _NavItem(
                icon: Icons.edit_note_outlined,
                selectedIcon: Icons.edit_note,
                label: 'Today',
                selected: _index == 0,
                onTap: () => setState(() => _index = 0),
              ),
              _NavItem(
                icon: Icons.menu_book_outlined,
                selectedIcon: Icons.menu_book,
                label: 'Journal',
                selected: _index == 1,
                onTap: () => setState(() => _index = 1),
              ),
              _NavItem(
                icon: Icons.auto_awesome_outlined,
                selectedIcon: Icons.auto_awesome,
                label: 'Weekly',
                selected: _index == 2,
                onTap: () => setState(() => _index = 2),
              ),
              _NavItem(
                icon: Icons.settings_outlined,
                selectedIcon: Icons.settings,
                label: 'Settings',
                selected: _index == 3,
                onTap: () => setState(() => _index = 3),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.icon,
    required this.selectedIcon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final IconData selectedIcon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 3),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            margin: const EdgeInsets.symmetric(vertical: 7),
            decoration: BoxDecoration(
              color: selected ? AppColors.rust : Colors.transparent,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  selected ? selectedIcon : icon,
                  size: 20,
                  color: selected ? Colors.white : AppColors.muted,
                ),
                const SizedBox(height: 2),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 10.5,
                    fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                    color: selected ? Colors.white : AppColors.muted,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
