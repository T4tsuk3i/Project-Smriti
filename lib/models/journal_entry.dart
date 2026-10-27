class JournalEntry {
  const JournalEntry({
    this.id,
    required this.content,
    required this.createdAt,
    this.safetyFlag = false,
  });

  final int? id;
  final String content;
  final DateTime createdAt;
  final bool safetyFlag;

  factory JournalEntry.fromMap(Map<String, Object?> map) {
    return JournalEntry(
      id: map['id'] as int?,
      content: map['content'] as String,
      createdAt: DateTime.parse(map['created_at'] as String).toLocal(),
      safetyFlag: (map['safety_flag'] as int? ?? 0) == 1,
    );
  }

  Map<String, Object?> toMap() {
    return {
      if (id != null) 'id': id,
      'content': content,
      'created_at': createdAt.toUtc().toIso8601String(),
      'safety_flag': safetyFlag ? 1 : 0,
    };
  }
}
