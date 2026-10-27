import 'package:flutter/material.dart';

import 'app_theme.dart';
import 'data/journal_repository.dart';
import 'screens/home_shell.dart';

class SmritiApp extends StatelessWidget {
  const SmritiApp({super.key, required this.repository});

  final JournalRepository repository;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Smriti',
      debugShowCheckedModeBanner: false,
      theme: buildAppTheme(),
      themeMode: ThemeMode.light,
      home: HomeShell(repository: repository),
    );
  }
}
