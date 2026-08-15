import 'package:flutter_test/flutter_test.dart';
import 'package:puzzle_forge/puzzles/core/deterministic_seed.dart';

void main() {
  test('daily seed is stable within a calendar date', () {
    final morning = DeterministicSeed.daily(
      date: DateTime(2026, 8, 14, 1),
      puzzleId: 'maze',
      generatorVersion: 1,
    );
    final evening = DeterministicSeed.daily(
      date: DateTime(2026, 8, 14, 23),
      puzzleId: 'maze',
      generatorVersion: 1,
    );
    expect(morning, evening);
  });

  test('daily seed changes by date, module, and version', () {
    int seed(String puzzle, int version, int day) => DeterministicSeed.daily(
      date: DateTime.utc(2026, 8, day),
      puzzleId: puzzle,
      generatorVersion: version,
    );
    expect(
      <int>{
        seed('maze', 1, 14),
        seed('maze', 1, 15),
        seed('maze', 2, 14),
        seed('sudoku', 1, 14),
      }.length,
      4,
    );
  });

  test('weekly seed uses Monday as the boundary', () {
    final monday = DeterministicSeed.weekly(
      date: DateTime.utc(2026, 8, 10),
      puzzleId: 'sliding_tiles',
      generatorVersion: 1,
    );
    final sunday = DeterministicSeed.weekly(
      date: DateTime.utc(2026, 8, 16),
      puzzleId: 'sliding_tiles',
      generatorVersion: 1,
    );
    expect(monday, sunday);
  });
}
