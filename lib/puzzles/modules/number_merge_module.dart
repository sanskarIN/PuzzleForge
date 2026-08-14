import 'dart:math';

import '../core/puzzle_models.dart';
import '../core/puzzle_module.dart';

class NumberMergeModule extends PuzzleModule {
  const NumberMergeModule();

  @override
  String get id => 'number_merge';

  @override
  int get version => 1;

  @override
  String get titleKey => 'puzzle.merge.title';

  @override
  String get descriptionKey => 'puzzle.merge.description';

  @override
  String get rulesKey => 'puzzle.merge.rules';

  @override
  PuzzleBoardState generate({
    required int seed,
    required PuzzleDifficulty difficulty,
  }) {
    var rngState = seed & 0x7fffffff;
    var board = List<int>.filled(16, 0);
    final first = _spawn(board, rngState);
    board = first.$1;
    rngState = first.$2;
    final second = _spawn(board, rngState);
    board = second.$1;
    rngState = second.$2;
    return PuzzleBoardState(
      data: <String, Object?>{
        'board': board,
        'rngState': rngState,
        'target': <int>[128, 256, 512, 1024, 2048, 4096][difficulty.index],
        'mergeScore': 0,
      },
    );
  }

  @override
  List<PuzzleAction> legalActions(PuzzleBoardState state) {
    if (state.solved) return const <PuzzleAction>[];
    final board = intList(state.data['board'], length: 16);
    return <PuzzleAction>[
      for (final direction in const <String>['up', 'down', 'left', 'right'])
        if (_move(board, direction).$1 != null)
          PuzzleAction('swipe', <String, Object?>{'direction': direction}),
    ];
  }

  @override
  PuzzleBoardState applyAction(PuzzleBoardState state, PuzzleAction action) {
    if (!isLegalAction(state, action))
      illegalAction('Number merge direction has no effect');
    final board = intList(state.data['board'], length: 16);
    final moved = _move(board, action.arguments['direction']! as String);
    final spawned = _spawn(moved.$1!, state.data['rngState']! as int);
    final target = state.data['target']! as int;
    final mergeScore = state.data['mergeScore']! as int;
    return PuzzleBoardState(
      data: <String, Object?>{
        'board': spawned.$1,
        'rngState': spawned.$2,
        'target': target,
        'mergeScore': mergeScore + moved.$2,
      },
      moveCount: state.moveCount + 1,
      solved: spawned.$1.any((value) => value >= target),
    );
  }

  @override
  PuzzleHint? hint(PuzzleBoardState state) {
    if (state.solved) return null;
    final board = intList(state.data['board'], length: 16);
    PuzzleAction? best;
    var bestValue = -1;
    for (final action in legalActions(state)) {
      final result = _move(board, action.arguments['direction']! as String);
      final empties = result.$1!.where((value) => value == 0).length;
      final value = result.$2 * 10 + empties;
      if (value > bestValue) {
        bestValue = value;
        best = action;
      }
    }
    if (best == null) return null;
    final direction = best.arguments['direction']! as String;
    return PuzzleHint(
      id: 'merge:${canonicalJson(board)}:$direction',
      messageKey: 'hint.merge.direction',
      arguments: <String, Object?>{'direction': direction},
      suggestedAction: best,
    );
  }

  @override
  VerificationResult verify(PuzzleBoardState state) {
    try {
      final board = intList(state.data['board'], length: 16);
      final rngState = state.data['rngState'];
      final target = state.data['target'];
      final mergeScore = state.data['mergeScore'];
      if (rngState is! int ||
          rngState < 0 ||
          target is! int ||
          !const <int>{128, 256, 512, 1024, 2048, 4096}.contains(target) ||
          mergeScore is! int ||
          mergeScore < 0) {
        return const VerificationResult.invalid(
          'Number merge metadata is invalid',
        );
      }
      if (board.any(
        (value) => value < 0 || (value != 0 && !_isPowerOfTwo(value)),
      )) {
        return const VerificationResult.invalid(
          'Number merge board contains an invalid tile',
        );
      }
      if (state.solved != board.any((value) => value >= target)) {
        return const VerificationResult.invalid(
          'Number merge solved flag is inconsistent',
        );
      }
    } on FormatException {
      return const VerificationResult.invalid(
        'Number merge state data is invalid',
      );
    }
    return const VerificationResult.valid();
  }

  @override
  PuzzleDescription accessibilityDescription(PuzzleBoardState state) {
    final board = intList(state.data['board'], length: 16);
    return PuzzleDescription('accessibility.merge.board', <String, Object?>{
      'largest': board.reduce(max),
      'target': state.data['target']!,
      'moves': state.moveCount,
    });
  }

  (List<int>, int) _spawn(List<int> input, int state) {
    final board = List<int>.from(input);
    final empty = <int>[
      for (var index = 0; index < board.length; index++)
        if (board[index] == 0) index,
    ];
    if (empty.isEmpty) return (board, state);
    var next = _nextState(state);
    final index = empty[next % empty.length];
    next = _nextState(next);
    board[index] = next % 10 == 0 ? 4 : 2;
    return (board, next);
  }

  int _nextState(int state) => (1103515245 * state + 12345) & 0x7fffffff;

  (List<int>?, int) _move(List<int> board, String direction) {
    final output = List<int>.filled(16, 0);
    var gained = 0;
    for (var line = 0; line < 4; line++) {
      final indices = switch (direction) {
        'left' => <int>[
          for (var column = 0; column < 4; column++) line * 4 + column,
        ],
        'right' => <int>[
          for (var column = 3; column >= 0; column--) line * 4 + column,
        ],
        'up' => <int>[for (var row = 0; row < 4; row++) row * 4 + line],
        'down' => <int>[for (var row = 3; row >= 0; row--) row * 4 + line],
        _ => throw ArgumentError.value(direction, 'direction'),
      };
      final values = <int>[
        for (final index in indices)
          if (board[index] != 0) board[index],
      ];
      final merged = <int>[];
      for (var index = 0; index < values.length; index++) {
        if (index + 1 < values.length && values[index] == values[index + 1]) {
          final value = values[index] * 2;
          merged.add(value);
          gained += value;
          index++;
        } else {
          merged.add(values[index]);
        }
      }
      for (var index = 0; index < indices.length; index++) {
        output[indices[index]] = index < merged.length ? merged[index] : 0;
      }
    }
    for (var index = 0; index < 16; index++) {
      if (output[index] != board[index]) return (output, gained);
    }
    return (null, 0);
  }

  bool _isPowerOfTwo(int value) => value > 0 && (value & (value - 1)) == 0;
}
