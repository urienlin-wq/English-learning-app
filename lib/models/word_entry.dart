class WordEntry {
  final int? id;
  final String english;
  final String chinese;
  final String partOfSpeech; // 词性，如 n. v. adj. adv.
  final DateTime createdAt;

  WordEntry({
    this.id,
    required this.english,
    required this.chinese,
    required this.partOfSpeech,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'english': english,
      'chinese': chinese,
      'partOfSpeech': partOfSpeech,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory WordEntry.fromMap(Map<String, dynamic> map) {
    return WordEntry(
      id: map['id'] as int?,
      english: map['english'] as String,
      chinese: map['chinese'] as String,
      partOfSpeech: map['partOfSpeech'] as String,
      createdAt: DateTime.parse(map['createdAt'] as String),
    );
  }
}
