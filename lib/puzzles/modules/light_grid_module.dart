import 'dart:math';

import '../core/puzzle_models.dart';
import '../core/puzzle_module.dart';

class LightGridModule extends PuzzleModule {
  const LightGridModule();

  @override
  String get id => 'light_grid';

  @override
  int get version => 1;

  @override
  String get titleKey => 'puzzle.lights.title';

  @override
  String get descriptionKey => 'puzzle.lights.description';

  @override
  String get rulesKey => 'puzzle.lights.rules';

  @override
  PuzzleBoardState generate({
    required int seed,
    required PuzzleDifficulty difficulty,
  }) {
    final size = switch (difficulty) {
      PuzzleDifficulty.beginner => 3,
      PuzzleDifficulty.easy => 4,
      PuzzleDifficulty.medium => 5,
      PuzzleDifficulty.hard => 5,
      PuzzleDifficulty.expert => 6,
      PuzzleDifficulty.master => 7,
    };
    final lights = List<bool>.filled(size * size, false);
    final solution = List<bool>.filled(size * size, false);
    final random = Random(seed);
    final presses = size + difficulty.rank * 2;
    for (var index = 0; index < presses; index++) {
      final cell = random.nextInt(lights.length);
      solution[cell] = !solution[cell];
      _toggle(lights, cell, size);
    }
    if (lights.every((light) => !light)) {
      solution[0] = !solution[0];
      _toggle(lights, 0, size);
    }
    return PuzzleBoardState(
      data: <String, Object?>{
        'size': size,
        'lights': lights,
        'remainingSolution': solution,
      },
    );
  }

  @override
  List<PuzzleAction> legalActions(PuzzleBoardState state) {
    if (state.solved) return const <PuzzleAction>[];
    final size = state.data['size']! as int;
    return List<PuzzleAction>.generate(
      size * size,
      (index) => PuzzleAction('toggle', <String, Object?>{'index': index}),
      growable: false,
    );
  }

  @override
  PuzzleBoardState applyAction(PuzzleBoardState state, PuzzleAction action) {
    if (!isLegalAction(state, action)) illegalAction('Light cell is invalid');
    final size = state.data['size']! as int;
    final lights = boolList(state.data['lights'], length: size * size);
    final remaining = boolList(
      state.data['remainingSolution'],
      length: size * size,
    );
    final index = action.arguments['index']! as int;
    _toggle(lights, index, size);
    remaining[index] = !remaining[index];
    final solved = lights.every((light) => !light);
    return PuzzleBoardState(
      data: <String, Object?>{
        'size': size,
        'lights': lights,
        'remainingSolution': remaining,
      },
      moveCount: state.moveCount + 1,
      solved: solved,
    );
  }

  @override
  PuzzleHint? hint(PuzzleBoardState state) {
    if (state.solved) return null;
    final size = state.data['size']! as int;
    final remaining = boolList(
      state.data['remainingSolution'],
      length: size * size,
    );
    final index = remaining.indexOf(true);
    final fallback = index >= 0 ? index : 0;
    final action = PuzzleAction('toggle', <String, Object?>{'index': fallback});
    return PuzzleHint(
      id: 'lights:${state.moveCount}:${canonicalJson(state.data)}:$fallback',
      messageKey: 'hint.lights.toggle',
      arguments: <String, Object?>{
        'row': fallback ~/ size + 1,
        'column': fallback % size + 1,
      },
      suggestedAction: action,
      focusIndices: <int>[fallback],
    );
  }

  @override
  VerificationResult verify(PuzzleBoardState state) {
    final size = state.data['size'];
    if (size is! int || size < 3 || size > 7) {
      return const VerificationResult.invalid(
        'Light grid size is out of range',
      );
    }
    try {
      final lights = boolList(state.data['lights'], length: size * size);
      final remaining = boolList(
        state.data['remainingSolution'],
        length: size * size,
      );
      final solvedByVector = List<bool>.from(lights);
      for (var index = 0; index < remaining.length; index++) {
        if (remaining[index]) _toggle(solvedByVector, index, size);
      }
      if (solvedByVector.any((light) => light)) {
        return const VerificationResult.invalid(
          'Light solution vector does not solve the board',
        );
      }
      if (state.solved != lights.every((light) => !light)) {
        return const VerificationResult.invalid(
          'Light solved flag is inconsistent',
        );
      }
    } on FormatException {
      return const VerificationResult.invalid('Light grid values are invalid');
    }
    return const VerificationResult.valid();
  }

  @override
  PuzzleDescription accessibilityDescription(PuzzleBoardState state) {
    final lights = boolList(state.data['lights']);
    return PuzzleDescription('accessibility.lights.board', <String, Object?>{
      'lit': lights.where((light) => light).length,
      'total': lights.length,
      'moves': state.moveCount,
    });
  }

  void _toggle(List<bool> lights, int index, int size) {
    final row = index ~/ size;
    final column = index % size;
    for (final target in <int>[
      index,
      if (row > 0) index - size,
      if (row < size - 1) index + size,
      if (column > 0) index - 1,
      if (column < size - 1) index + 1,
    ]) {
      lights[target] = !lights[target];
    }
  }
}
