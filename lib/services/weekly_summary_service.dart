import 'package:intl/intl.dart';

import '../models/journal_entry.dart';

class WeeklySummaryService {
  WeeklySummaryService._();

  static const Set<String> _stopWords = {
    'about',
    'after',
    'again',
    'also',
    'and',
    'another',
    'anything',
    'because',
    'been',
    'before',
    'being',
    'between',
    'could',
    'didn',
    'does',
    'doing',
    'don',
    'down',
    'during',
    'each',
    'even',
    'ever',
    'every',
    'feel',
    'felt',
    'from',
    'have',
    'having',
    'here',
    'into',
    'just',
    'like',
    'little',
    'made',
    'make',
    'many',
    'more',
    'most',
    'much',
    'myself',
    'never',
    'only',
    'other',
    'over',
    'really',
    'should',
    'some',
    'something',
    'still',
    'such',
    'than',
    'that',
    'their',
    'them',
    'then',
    'there',
    'these',
    'they',
    'thing',
    'think',
    'this',
    'through',
    'today',
    'very',
    'want',
    'was',
    'were',
    'what',
    'when',
    'where',
    'which',
    'while',
    'with',
    'would',
    'your',
    'youre',
  };

  static String build(List<JournalEntry> entries) {
    if (entries.isEmpty) {
      return 'No check-ins in the last seven days.';
    }

    final days = entries
        .map((entry) => DateFormat('yyyy-MM-dd').format(entry.createdAt))
        .toSet();

    final counts = <String, int>{};
    for (final entry in entries) {
      final matches = RegExp(r"[A-Za-z']+")
          .allMatches(entry.content.toLowerCase());
      for (final match in matches) {
        final word = match.group(0)!.replaceAll(RegExp(r"^'+|'+$"), '');
        if (word.length < 4 || _stopWords.contains(word)) continue;
        counts[word] = (counts[word] ?? 0) + 1;
      }
    }

    final topWords = counts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final words = topWords
        .where((entry) => entry.value > 1)
        .take(6)
        .map((entry) => entry.key)
        .toList();

    final longest = entries.reduce(
      (a, b) => a.content.length >= b.content.length ? a : b,
    );

    final dayCounts = <String, int>{};
    for (final entry in entries) {
      final day = DateFormat('EEEE').format(entry.createdAt);
      dayCounts[day] = (dayCounts[day] ?? 0) + 1;
    }
    final busiestDay = dayCounts.entries.reduce(
      (a, b) => a.value >= b.value ? a : b,
    );

    final buffer = StringBuffer()
      ..writeln('This week')
      ..writeln()
      ..writeln(
        'You checked in ${entries.length} ${entries.length == 1 ? 'time' : 'times'} '
        'across ${days.length} ${days.length == 1 ? 'day' : 'days'}.',
      );

    if (words.isNotEmpty) {
      buffer.writeln();
      buffer.writeln('The words that came up most: ${words.join(', ')}.');
    }

    buffer
      ..writeln()
      ..writeln(
        'Your longest check-in was ${longest.content.trim().length} characters.',
      );

    if (busiestDay.value > 1) {
      buffer.writeln('Most of your check-ins happened on ${busiestDay.key}.');
    }

    buffer
      ..writeln()
      ..writeln(
        'This is a local summary. Smriti has no on-device model configured yet, '
        'so it is not interpreting the entries or making claims about you.',
      );

    return buffer.toString().trim();
  }
}
