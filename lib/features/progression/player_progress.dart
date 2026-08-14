class CompletionRecord {
  const CompletionRecord({
    required this.id,
    required this.puzzleId,
    required this.difficulty,
    required this.completedOn,
    required this.score,
    required this.moves,
    required this.elapsedSeconds,
    required this.hintsUsed,
  });

  final String id;
  final String puzzleId;
  final String difficulty;
  final DateTime completedOn;
  final int score;
  final int moves;
  final int elapsedSeconds;
  final int hintsUsed;

  Map<String, Object?> toJson() => <String, Object?>{
    'id': id,
    'puzzleId': puzzleId,
    'difficulty': difficulty,
    'completedOn': completedOn.toUtc().toIso8601String(),
    'score': score,
    'moves': moves,
    'elapsedSeconds': elapsedSeconds,
    'hintsUsed': hintsUsed,
  };

  factory CompletionRecord.fromJson(Map<String, Object?> json) {
    final id = json['id'];
    final puzzleId = json['puzzleId'];
    final difficulty = json['difficulty'];
    final completedOn = DateTime.tryParse(
      json['completedOn']?.toString() ?? '',
    );
    final score = json['score'];
    final moves = json['moves'];
    final elapsedSeconds = json['elapsedSeconds'];
    final hintsUsed = json['hintsUsed'];
    if (id is! String ||
        id.isEmpty ||
        puzzleId is! String ||
        difficulty is! String ||
        completedOn == null ||
        score is! int ||
        score < 0 ||
        moves is! int ||
        moves < 0 ||
        elapsedSeconds is! int ||
        elapsedSeconds < 0 ||
        hintsUsed is! int ||
        hintsUsed < 0) {
      throw const FormatException('Invalid completion record');
    }
    return CompletionRecord(
      id: id,
      puzzleId: puzzleId,
      difficulty: difficulty,
      completedOn: completedOn,
      score: score,
      moves: moves,
      elapsedSeconds: elapsedSeconds,
      hintsUsed: hintsUsed,
    );
  }
}

class PlayerProgress {
  PlayerProgress({
    this.xp = 0,
    this.stars = 0,
    this.hintTokens = 5,
    this.currentStreak = 0,
    this.bestStreak = 0,
    this.lastDailyDate,
    Set<String>? awardedCompletionIds,
    List<CompletionRecord>? history,
    Set<String>? favorites,
    Set<String>? achievements,
  }) : awardedCompletionIds = awardedCompletionIds ?? <String>{},
       history = history ?? <CompletionRecord>[],
       favorites = favorites ?? <String>{},
       achievements = achievements ?? <String>{};

  int xp;
  int stars;
  int hintTokens;
  int currentStreak;
  int bestStreak;
  DateTime? lastDailyDate;
  final Set<String> awardedCompletionIds;
  final List<CompletionRecord> history;
  final Set<String> favorites;
  final Set<String> achievements;

  int get level => xp ~/ 1000 + 1;

  bool award(CompletionRecord record, {required bool isDaily}) {
    if (!awardedCompletionIds.add(record.id)) return false;
    xp += 100 + record.score ~/ 20;
    stars += record.hintsUsed == 0
        ? 3
        : record.hintsUsed == 1
        ? 2
        : 1;
    history.insert(0, record);
    if (history.length > 250) history.removeRange(250, history.length);
    if (record.hintsUsed == 0) achievements.add('hint_free_first');
    if (history.length >= 10) achievements.add('ten_solutions');
    if (record.score >= 3000) achievements.add('master_score');
    if (isDaily) _advanceStreak(record.completedOn);
    if (xp >= 1000) achievements.add('level_two');
    return true;
  }

  void _advanceStreak(DateTime completedAt) {
    final date = DateTime(completedAt.year, completedAt.month, completedAt.day);
    final previous = lastDailyDate;
    if (previous != null) {
      final priorDate = DateTime(previous.year, previous.month, previous.day);
      final difference = date.difference(priorDate).inDays;
      if (difference == 0) return;
      currentStreak = difference == 1 ? currentStreak + 1 : 1;
    } else {
      currentStreak = 1;
    }
    lastDailyDate = date;
    if (currentStreak > bestStreak) bestStreak = currentStreak;
    if (currentStreak >= 7) achievements.add('seven_day_streak');
  }

  Map<String, Object?> toJson() => <String, Object?>{
    'schemaVersion': 1,
    'xp': xp,
    'stars': stars,
    'hintTokens': hintTokens,
    'currentStreak': currentStreak,
    'bestStreak': bestStreak,
    'lastDailyDate': lastDailyDate?.toIso8601String(),
    'awardedCompletionIds': awardedCompletionIds.toList()..sort(),
    'history': history.map((record) => record.toJson()).toList(growable: false),
    'favorites': favorites.toList()..sort(),
    'achievements': achievements.toList()..sort(),
  };

  factory PlayerProgress.fromJson(Map<String, Object?> json) {
    if (json['schemaVersion'] != 1)
      throw const FormatException('Unsupported progress schema');
    int nonNegative(String key) {
      final value = json[key];
      if (value is! int || value < 0) throw FormatException('Invalid $key');
      return value;
    }

    Set<String> strings(String key) {
      final value = json[key];
      if (value is! List || value.any((item) => item is! String)) {
        throw FormatException('Invalid $key');
      }
      return value.cast<String>().toSet();
    }

    final rawHistory = json['history'];
    if (rawHistory is! List || rawHistory.length > 250) {
      throw const FormatException('Invalid progress history');
    }
    final lastDaily = json['lastDailyDate'];
    final parsedDate = lastDaily == null
        ? null
        : DateTime.tryParse(lastDaily.toString());
    if (lastDaily != null && parsedDate == null)
      throw const FormatException('Invalid daily date');
    return PlayerProgress(
      xp: nonNegative('xp'),
      stars: nonNegative('stars'),
      hintTokens: nonNegative('hintTokens'),
      currentStreak: nonNegative('currentStreak'),
      bestStreak: nonNegative('bestStreak'),
      lastDailyDate: parsedDate,
      awardedCompletionIds: strings('awardedCompletionIds'),
      history: rawHistory.map((item) {
        if (item is! Map)
          throw const FormatException('Invalid completion item');
        return CompletionRecord.fromJson(Map<String, Object?>.from(item));
      }).toList(),
      favorites: strings('favorites'),
      achievements: strings('achievements'),
    );
  }
}
