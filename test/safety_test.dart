import 'package:flutter_test/flutter_test.dart';
import 'package:smriti/models/journal_entry.dart';
import 'package:smriti/services/safety_service.dart';
import 'package:smriti/services/weekly_summary_service.dart';

void main() {
  group('SafetyService', () {
    test('flags explicit crisis language', () {
      final check = SafetyService.check('I want to die and I cannot go on');
      expect(check.flagged, isTrue);
      expect(check.resources, isNotEmpty);
    });

    test('does not flag ordinary frustration', () {
      final check = SafetyService.check(
        'Work was annoying but I got through it.',
      );
      expect(check.flagged, isFalse);
    });

    test('returns country resources', () {
      final check = SafetyService.check('nothing', country: 'US');
      expect(check.resources.any((r) => r.contact.contains('988')), isTrue);
    });
  });

  group('WeeklySummaryService', () {
    test('summarises counts without a model', () {
      final now = DateTime.now();
      final entries = [
        JournalEntry(
          content:
              'Work was hard. I avoided invoices again and went for a walk.',
          createdAt: now,
        ),
        JournalEntry(
          content: 'Went for a walk. Invoices still waiting.',
          createdAt: now.subtract(const Duration(days: 1)),
        ),
      ];

      final summary = WeeklySummaryService.build(entries);
      expect(summary, contains('2 times'));
      expect(summary, contains('walk'));
      expect(summary, contains('No model read this'));
    });

    test('handles an empty week', () {
      expect(
        WeeklySummaryService.build(const []),
        contains('Nothing to sum up'),
      );
    });
  });
}
