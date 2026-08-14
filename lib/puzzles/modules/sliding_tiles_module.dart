import 'dart:math';

import '../core/puzzle_models.dart';
import '../core/puzzle_module.dart';

class SlidingTilesModule extends PuzzleModule {
  const SlidingTilesModule();

  @override
  String get id => 'sliding_tiles';

  @override
  int get version => 1;

  @override
  String get titleKey => 'puzzle.sliding.title';

  @override
  String get descriptionKey => 'puzzle.sliding.description';

  @override
  String get rulesKey => 'puzzle.sliding.rules';

  @override
  PuzzleBoardState generate({
    required int seed,
    required PuzzleDifficulty difficulty,
  }) {
    final size = switch (difficulty) {
      PuzzleDifficulty.beginner || PuzzleDifficulty.easy => 3,
      PuzzleDifficulty.medium || PuzzleDifficulty.hard => 4,
      PuzzleDifficulty.expert || PuzzleDifficulty.master => 5,
    };
    final board = List<int>.generate(
      size * size,
      (index) => (index + 1) % (size * size),
    );
    final random = Random(seed);
    var blank = board.length - 1;
    var previousBlank = -1;
    final scrambleCount = 14 + difficulty.rank * 14;
    for (var move = 0; move < scrambleCount; move++) {
      final candidates = _neighbors(
        blank,
        size,
      ).where((index) => index != previousBlank).toList();
      final target = candidates[random.nextInt(candidates.length)];
      board[blank] = board[target];
      board[target] = 0;
      previousBlank = blank;
      blank = target;
    }
    if (_isSolved(board)) {
      final target = _neighbors(blank, size).first;
      board[blank] = board[target];
      board[target] = 0;
    }
    return PuzzleBoardState(
      data: <String, Object?>{'size': size, 'board': board},
    );
  }

  @override
  List<PuzzleAction> legalActions(PuzzleBoardState state) {
    if (state.solved) return const <PuzzleAction>[];
    final size = state.data['size'] as int;
    final board = intList(state.data['board'], length: size * size);
    final blank = board.indexOf(0);
    return _neighbors(blank, size)
        .map(
          (index) => PuzzleAction('slide', <String, Object?>{'index': index}),
        )
        .toList(growable: false);
  }

  @override
  PuzzleBoardState applyAction(PuzzleBoardState state, PuzzleAction action) {
    if (!isLegalAction(state, action))
      illegalAction('Tile is not adjacent to the empty space');
    final size = state.data['size'] as int;
    final board = intList(state.data['board'], length: size * size);
    final target = action.arguments['index']! as int;
    final blank = board.indexOf(0);
    board[blank] = board[target];
    board[target] = 0;
    return PuzzleBoardState(
      data: <String, Object?>{'size': size, 'board': board},
      moveCount: state.moveCount + 1,
      solved: _isSolved(board),
    );
  }

  @override
  PuzzleHint? hint(PuzzleBoardState state) {
    if (state.solved) return null;
    final size = state.data['size'] as int;
    final board = intList(state.data['board'], length: size * size);
    final actions = legalActions(state);
    PuzzleAction best = actions.first;
    var bestDistance = 1 << 30;
    for (final action in actions) {
      final candidate = List<int>.from(board);
      final blank = candidate.indexOf(0);
      final target = action.arguments['index']! as int;
      candidate[blank] = candidate[target];
      candidate[target] = 0;
      final distance = _manhattan(candidate, size);
      if (distance < bestDistance) {
        bestDistance = distance;
        best = action;
      }
    }
    final index = best.arguments['index']! as int;
    return PuzzleHint(
      id: 'sliding:${state.moveCount}:${canonicalJson(state.data)}:$index',
      messageKey: 'hint.sliding.moveTile',
      arguments: <String, Object?>{'tile': board[index]},
      suggestedAction: best,
      focusIndices: <int>[index],
    );
  }

  @override
  VerificationResult verify(PuzzleBoardState state) {
    final size = state.data['size'];
    if (size is! int || size < 3 || size > 5) {
      return const VerificationResult.invalid(
        'Sliding board size is out of range',
      );
    }
    List<int> board;
    try {
      board = intList(state.data['board'], length: size * size);
    } on FormatException {
      return const VerificationResult.invalid(
        'Sliding board cells are invalid',
      );
    }
    final expected = List<int>.generate(size * size, (index) => index)..sort();
    final actual = List<int>.from(board)..sort();
    if (canonicalJson(expected) != canonicalJson(actual)) {
      return const VerificationResult.invalid(
        'Sliding board is not a permutation',
      );
    }
    if (!_isSolvable(board, size)) {
      return const VerificationResult.invalid('Sliding board is not solvable');
    }
    if (state.solved != _isSolved(board)) {
      return const VerificationResult.invalid(
        'Sliding solved flag is inconsistent',
      );
    }
    return const VerificationResult.valid();
  }

  @override
  PuzzleDescription accessibilityDescription(PuzzleBoardState state) {
    final size = state.data['size']! as int;
    final board = intList(state.data['board'], length: size * size);
    return PuzzleDescription('accessibility.sliding.board', <String, Object?>{
      'size': size,
      'empty': board.indexOf(0) + 1,
      'moves': state.moveCount,
    });
  }

  List<int> _neighbors(int index, int size) {
    final row = index ~/ size;
    final column = index % size;
    return <int>[
      if (row > 0) index - size,
      if (row < size - 1) index + size,
      if (column > 0) index - 1,
      if (column < size - 1) index + 1,
    ];
  }

  bool _isSolved(List<int> board) {
    for (var index = 0; index < board.length - 1; index++) {
      if (board[index] != index + 1) return false;
    }
    return board.last == 0;
  }

  int _manhattan(List<int> board, int size) {
    var distance = 0;
    for (var index = 0; index < board.length; index++) {
      final tile = board[index];
      if (tile == 0) continue;
      final goal = tile - 1;
      distance += (index ~/ size - goal ~/ size).abs();
      distance += (index % size - goal % size).abs();
    }
    return distance;
  }

  bool _isSolvable(List<int> board, int size) {
    var inversions = 0;
    for (var first = 0; first < board.length; first++) {
      if (board[first] == 0) continue;
      for (var second = first + 1; second < board.length; second++) {
        if (board[second] != 0 && board[first] > board[second]) inversions++;
      }
    }
    if (size.isOdd) return inversions.isEven;
    final blankRowFromBottom = size - board.indexOf(0) ~/ size;
    return blankRowFromBottom.isEven ? inversions.isOdd : inversions.isEven;
  }
}
