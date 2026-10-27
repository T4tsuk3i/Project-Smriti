import 'package:flutter/material.dart';

import 'app.dart';
import 'data/journal_repository.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(SmritiApp(repository: JournalRepository()));
}
