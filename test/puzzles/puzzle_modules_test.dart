import 'package:flutter_test/flutter_test.dart';
import 'package:puzzle_forge/puzzles/core/puzzle_models.dart';
import 'package:puzzle_forge/puzzles/puzzle_catalog.dart';

void main() {
  group('starter puzzle modules', () {
    for (final entry in PuzzleCatalog.entries) {
      final module = entry.module;

      test(
        '${module.id} has stable identity and valid deterministic boards',
        () {
          expect(module.id, isNotEmpty);
          expect(module.version, greaterThan(0));
          for (final difficulty in PuzzleDifficulty.values) {
            for (final seed in const <int>[1, 42, 987654321]) {
              final first = module.generate(seed: seed, difficulty: difficulty);
              final second = module.generate(
                seed: seed,
                difficulty: difficulty,
              );
              expect(
                first,
                second,
                reason: '${module.id} must be deterministic',
              );
              expect(
                module.verify(first).isValid,
                isTrue,
                reason: module.verify(first).message,
              );
              final restored = module.deserialize(first.toJson());
              expect(restored, first);
              if (!first.solved) {
                final actions = module.legalActions(first);
                expect(actions, isNotEmpty);
                final next = module.applyAction(first, actions.first);
                expect(next.moveCount, first.moveCount + 1);
                expect(
                  module.verify(next).isValid,
                  isTrue,
                  reason: module.verify(next).message,
                );
              }
            }
          }
        },
      );

      test('${module.id} hint is legal and stable', () {
        final state = module.generate(
          seed: 20260814,
          difficulty: PuzzleDifficulty.medium,
        );
        final first = module.hint(state);
        final second = module.hint(state);
        expect(first?.id, second?.id);
        if (first?.suggestedAction != null) {
          expect(module.isLegalAction(state, first!.suggestedAction!), isTrue);
        }
      });
    }
  });

  test('catalog IDs are unique', () {
    final ids = PuzzleCatalog.entries.map((entry) => entry.module.id).toList();
    expect(ids.toSet().length, ids.length);
  });

  test('puzzle actions and board states round-trip through JSON maps', () {
    const action = PuzzleAction('move', <String, Object?>{'index': 3});
    expect(PuzzleAction.fromJson(action.toJson()), action);
    final state = PuzzleBoardState(
      data: <String, Object?>{
        'values': <int>[1, 2, 3],
      },
      moveCount: 4,
      solved: true,
    );
    expect(PuzzleBoardState.fromJson(state.toJson()), state);
  });

  test(
    'verifiers reject structurally valid but impossible imported openings',
    () {
      final sliding = PuzzleCatalog.byId('sliding_tiles').module;
      final slidingState = sliding.generate(
        seed: 1,
        difficulty: PuzzleDifficulty.beginner,
      );
      final slidingBoard = intList(slidingState.data['board']);
      final first = slidingBoard.indexWhere((value) => value != 0);
      final second = slidingBoard.indexWhere((value) => value != 0, first + 1);
      final temporary = slidingBoard[first];
      slidingBoard[first] = slidingBoard[second];
      slidingBoard[second] = temporary;
      expect(
        sliding
            .verify(
              PuzzleBoardState(
                data: <String, Object?>{
                  'size': slidingState.data['size']!,
                  'board': slidingBoard,
                },
              ),
            )
            .isValid,
        isFalse,
      );

      final lights = PuzzleCatalog.byId('light_grid').module;
      final lightState = lights.generate(
        seed: 2,
        difficulty: PuzzleDifficulty.easy,
      );
      expect(
        lights
            .verify(
              PuzzleBoardState(
                data: <String, Object?>{
                  ...lightState.data,
                  'remainingSolution': List<bool>.filled(16, false),
                },
              ),
            )
            .isValid,
        isFalse,
      );

      final sort = PuzzleCatalog.byId('color_sort').module;
      final sortState = sort.generate(
        seed: 3,
        difficulty: PuzzleDifficulty.medium,
      );
      expect(
        sort
            .verify(
              PuzzleBoardState(
                data: <String, Object?>{
                  ...sortState.data,
                  'generatedSolution': <Object?>[],
                },
              ),
            )
            .isValid,
        isFalse,
      );
    },
  );
}
