class WeeklyLetter {
  const WeeklyLetter({
    this.id,
    required this.content,
    required this.periodStart,
    required this.periodEnd,
    required this.createdAt,
    this.kind = 'local',
  });

  final int? id;
  final String content;
  final DateTime periodStart;
  final DateTime periodEnd;
  final DateTime createdAt;

  /// `local` for the deterministic summary, `ai` for a future on-device letter.
  final String kind;

  factory WeeklyLetter.fromMap(Map<String, Object?> map) {
    return WeeklyLetter(
      id: map['id'] as int?,
      content: map['content'] as String,
      periodStart: DateTime.parse(map['period_start'] as String).toLocal(),
      periodEnd: DateTime.parse(map['period_end'] as String).toLocal(),
      createdAt: DateTime.parse(map['created_at'] as String).toLocal(),
      kind: map['kind'] as String? ?? 'local',
    );
  }
}
