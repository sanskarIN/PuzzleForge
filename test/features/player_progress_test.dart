import 'package:flutter_test/flutter_test.dart';
import 'package:puzzle_forge/features/progression/player_progress.dart';

CompletionRecord record(String id, DateTime date, {int hints = 0}) =>
    CompletionRecord(
      id: id,
      puzzleId: 'maze',
      difficulty: 'medium',
      completedOn: date,
      score: 2400,
      moves: 20,
      elapsedSeconds: 60,
      hintsUsed: hints,
    );

void main() {
  test('completion awards are idempotent', () {
    final progress = PlayerProgress();
    final completion = record('daily:maze:2026-08-14', DateTime(2026, 8, 14));
    expect(progress.award(completion, isDaily: true), isTrue);
    final xp = progress.xp;
    final stars = progress.stars;
    expect(progress.award(completion, isDaily: true), isFalse);
    expect(progress.xp, xp);
    expect(progress.stars, stars);
    expect(progress.history, hasLength(1));
    expect(progress.currentStreak, 1);
  });

  test(
    'daily streak advances once per consecutive date and resets after a gap',
    () {
      final progress = PlayerProgress();
      progress.award(record('one', DateTime(2026, 8, 10)), isDaily: true);
      progress.award(record('two', DateTime(2026, 8, 11)), isDaily: true);
      progress.award(record('three', DateTime(2026, 8, 11, 20)), isDaily: true);
      expect(progress.currentStreak, 2);
      progress.award(record('four', DateTime(2026, 8, 14)), isDaily: true);
      expect(progress.currentStreak, 1);
      expect(progress.bestStreak, 2);
    },
  );

  test('progress round-trips through validated JSON', () {
    final progress = PlayerProgress()..favorites.add('sudoku');
    progress.award(record('one', DateTime.utc(2026, 8, 14)), isDaily: true);
    final restored = PlayerProgress.fromJson(progress.toJson());
    expect(restored.toJson(), progress.toJson());
  });
}
