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
      return 'Nothing to sum up yet.';
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

    final buffer = StringBuffer()..writeln('This week');

    if (entries.length == 1) {
      buffer.writeln();
      buffer.writeln('You wrote once.');
    } else {
      buffer.writeln();
      buffer.writeln(
        'You wrote ${entries.length} times, on ${days.length} '
        '${days.length == 1 ? 'day' : 'different days'}.',
      );
    }

    if (words.isNotEmpty) {
      buffer.writeln();
      buffer.writeln('Words you came back to: ${words.join(', ')}.');
    }

    buffer
      ..writeln()
      ..writeln(
        'Your longest entry was ${longest.content.trim().length} characters.',
      );

    if (busiestDay.value > 1) {
      buffer.writeln('Most of your writing happened on ${busiestDay.key}.');
    }

    buffer
      ..writeln()
      ..writeln(
        'That is it. No model read this — it is just a count of what you wrote.',
      );

    return buffer.toString().trim();
  }
}
