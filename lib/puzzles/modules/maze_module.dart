import 'dart:collection';
import 'dart:math';

import '../core/puzzle_models.dart';
import '../core/puzzle_module.dart';

class MazeModule extends PuzzleModule {
  const MazeModule();

  @override
  String get id => 'maze';

  @override
  int get version => 1;

  @override
  String get titleKey => 'puzzle.maze.title';

  @override
  String get descriptionKey => 'puzzle.maze.description';

  @override
  String get rulesKey => 'puzzle.maze.rules';

  @override
  PuzzleBoardState generate({
    required int seed,
    required PuzzleDifficulty difficulty,
  }) {
    final size = <int>[7, 9, 11, 13, 15, 17][difficulty.index];
    final walls = List<bool>.filled(size * size, true);
    final random = Random(seed);
    final stack = <int>[size + 1];
    walls[stack.first] = false;
    while (stack.isNotEmpty) {
      final current = stack.last;
      final row = current ~/ size;
      final column = current % size;
      final candidates = <int>[
        if (row > 2) current - size * 2,
        if (row < size - 3) current + size * 2,
        if (column > 2) current - 2,
        if (column < size - 3) current + 2,
      ].where((target) => walls[target]).toList();
      if (candidates.isEmpty) {
        stack.removeLast();
        continue;
      }
      final target = candidates[random.nextInt(candidates.length)];
      walls[(current + target) ~/ 2] = false;
      walls[target] = false;
      stack.add(target);
    }
    final start = size + 1;
    final exit = size * (size - 2) + size - 2;
    return PuzzleBoardState(
      data: <String, Object?>{
        'size': size,
        'walls': walls,
        'player': start,
        'exit': exit,
      },
    );
  }

  @override
  List<PuzzleAction> legalActions(PuzzleBoardState state) {
    if (state.solved) return const <PuzzleAction>[];
    final size = state.data['size']! as int;
    final walls = boolList(state.data['walls'], length: size * size);
    final player = state.data['player']! as int;
    final actions = <PuzzleAction>[];
    for (final entry in <(String, int)>[
      ('up', player - size),
      ('down', player + size),
      ('left', player - 1),
      ('right', player + 1),
    ]) {
      final target = entry.$2;
      if (target >= 0 && target < walls.length && !walls[target]) {
        actions.add(
          PuzzleAction('move', <String, Object?>{'direction': entry.$1}),
        );
      }
    }
    return actions;
  }

  @override
  PuzzleBoardState applyAction(PuzzleBoardState state, PuzzleAction action) {
    if (!isLegalAction(state, action)) illegalAction('Maze move is blocked');
    final size = state.data['size']! as int;
    final player = state.data['player']! as int;
    final next = switch (action.arguments['direction']) {
      'up' => player - size,
      'down' => player + size,
      'left' => player - 1,
      'right' => player + 1,
      _ => throw StateError('Unknown maze direction'),
    };
    final data = Map<String, Object?>.from(state.data)..['player'] = next;
    return PuzzleBoardState(
      data: data,
      moveCount: state.moveCount + 1,
      solved: next == state.data['exit'],
    );
  }

  @override
  PuzzleHint? hint(PuzzleBoardState state) {
    if (state.solved) return null;
    final size = state.data['size']! as int;
    final walls = boolList(state.data['walls'], length: size * size);
    final player = state.data['player']! as int;
    final exit = state.data['exit']! as int;
    final predecessor = <int, int>{player: -1};
    final queue = Queue<int>()..add(player);
    while (queue.isNotEmpty && !predecessor.containsKey(exit)) {
      final current = queue.removeFirst();
      for (final next in _openNeighbors(current, size, walls)) {
        if (predecessor.containsKey(next)) continue;
        predecessor[next] = current;
        queue.add(next);
      }
    }
    if (!predecessor.containsKey(exit)) return null;
    var step = exit;
    while (predecessor[step] != player) {
      step = predecessor[step]!;
    }
    final direction = step == player - size
        ? 'up'
        : step == player + size
        ? 'down'
        : step == player - 1
        ? 'left'
        : 'right';
    final action = PuzzleAction('move', <String, Object?>{
      'direction': direction,
    });
    return PuzzleHint(
      id: 'maze:$player:$exit:$direction',
      messageKey: 'hint.maze.direction',
      arguments: <String, Object?>{'direction': direction},
      suggestedAction: action,
      focusIndices: <int>[step],
    );
  }

  @override
  VerificationResult verify(PuzzleBoardState state) {
    final size = state.data['size'];
    if (size is! int || size < 7 || size > 17 || size.isEven) {
      return const VerificationResult.invalid('Maze size is invalid');
    }
    try {
      final walls = boolList(state.data['walls'], length: size * size);
      final player = state.data['player'];
      final exit = state.data['exit'];
      if (player is! int ||
          exit is! int ||
          player < 0 ||
          exit < 0 ||
          player >= walls.length ||
          exit >= walls.length ||
          walls[player] ||
          walls[exit]) {
        return const VerificationResult.invalid('Maze endpoints are invalid');
      }
      for (var index = 0; index < walls.length; index++) {
        final row = index ~/ size;
        final column = index % size;
        if ((row == 0 ||
                row == size - 1 ||
                column == 0 ||
                column == size - 1) &&
            !walls[index]) {
          return const VerificationResult.invalid(
            'Maze boundary must remain closed',
          );
        }
      }
      if (!_reachable(player, exit, size, walls)) {
        return const VerificationResult.invalid('Maze exit is unreachable');
      }
      if (state.solved != (player == exit)) {
        return const VerificationResult.invalid(
          'Maze solved flag is inconsistent',
        );
      }
    } on FormatException {
      return const VerificationResult.invalid('Maze cell data is invalid');
    }
    return const VerificationResult.valid();
  }

  @override
  PuzzleDescription accessibilityDescription(PuzzleBoardState state) {
    final size = state.data['size']! as int;
    final player = state.data['player']! as int;
    final exit = state.data['exit']! as int;
    return PuzzleDescription('accessibility.maze.board', <String, Object?>{
      'row': player ~/ size + 1,
      'column': player % size + 1,
      'exitRow': exit ~/ size + 1,
      'exitColumn': exit % size + 1,
      'moves': state.moveCount,
    });
  }

  Iterable<int> _openNeighbors(int index, int size, List<bool> walls) sync* {
    final row = index ~/ size;
    final column = index % size;
    for (final next in <int>[
      if (row > 0) index - size,
      if (row < size - 1) index + size,
      if (column > 0) index - 1,
      if (column < size - 1) index + 1,
    ]) {
      if (!walls[next]) yield next;
    }
  }

  bool _reachable(int start, int exit, int size, List<bool> walls) {
    final seen = <int>{start};
    final queue = Queue<int>()..add(start);
    while (queue.isNotEmpty) {
      final current = queue.removeFirst();
      if (current == exit) return true;
      for (final next in _openNeighbors(current, size, walls)) {
        if (seen.add(next)) queue.add(next);
      }
    }
    return false;
  }
}
