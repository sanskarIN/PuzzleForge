import 'dart:math';

import '../core/puzzle_models.dart';
import '../core/puzzle_module.dart';

class ColorSortModule extends PuzzleModule {
  const ColorSortModule();

  static const capacity = 4;

  @override
  String get id => 'color_sort';

  @override
  int get version => 1;

  @override
  String get titleKey => 'puzzle.sort.title';

  @override
  String get descriptionKey => 'puzzle.sort.description';

  @override
  String get rulesKey => 'puzzle.sort.rules';

  @override
  PuzzleBoardState generate({
    required int seed,
    required PuzzleDifficulty difficulty,
  }) {
    final colors = <int>[3, 3, 4, 4, 5, 5][difficulty.index];
    final random = Random(seed);
    final solved = <List<int>>[
      for (var color = 1; color <= colors; color++)
        List<int>.filled(capacity, color),
      <int>[],
      <int>[],
    ];
    for (var attempt = 0; attempt < 60; attempt++) {
      final tubes = <List<int>>[
        for (final tube in solved) List<int>.from(tube),
      ];
      final reverse = <(int, int)>[];
      final steps = 12 + difficulty.rank * 5;
      for (var step = 0; step < steps; step++) {
        final sources = <int>[
          for (var index = 0; index < tubes.length; index++)
            if (tubes[index].isNotEmpty &&
                (tubes[index].length == 1 ||
                    tubes[index][tubes[index].length - 2] == tubes[index].last))
              index,
        ];
        if (sources.isEmpty) break;
        final from = sources[random.nextInt(sources.length)];
        final destinations = <int>[
          for (var index = 0; index < tubes.length; index++)
            if (index != from &&
                tubes[index].length < capacity &&
                (tubes[index].isEmpty || tubes[index].last != tubes[from].last))
              index,
        ];
        if (destinations.isEmpty) continue;
        final to = destinations[random.nextInt(destinations.length)];
        tubes[to].add(tubes[from].removeLast());
        reverse.insert(0, (to, from));
      }
      if (_isSolved(tubes)) continue;
      var replay = <List<int>>[for (final tube in tubes) List<int>.from(tube)];
      var valid = true;
      for (final move in reverse) {
        final next = _pour(replay, move.$1, move.$2);
        if (next == null) {
          valid = false;
          break;
        }
        replay = next;
      }
      if (valid && _isSolved(replay)) {
        return PuzzleBoardState(
          data: <String, Object?>{
            'capacity': capacity,
            'tubes': tubes,
            'colors': colors,
            'generatedSolution': <Object?>[
              for (final move in reverse)
                <String, Object?>{'from': move.$1, 'to': move.$2},
            ],
          },
        );
      }
    }
    throw StateError('Unable to generate a verified color sort board');
  }

  @override
  List<PuzzleAction> legalActions(PuzzleBoardState state) {
    if (state.solved) return const <PuzzleAction>[];
    final tubes = _tubes(state.data['tubes']);
    return <PuzzleAction>[
      for (var from = 0; from < tubes.length; from++)
        for (var to = 0; to < tubes.length; to++)
          if (_pour(tubes, from, to) != null)
            PuzzleAction('pour', <String, Object?>{'from': from, 'to': to}),
    ];
  }

  @override
  PuzzleBoardState applyAction(PuzzleBoardState state, PuzzleAction action) {
    if (!isLegalAction(state, action))
      illegalAction('Color sort pour is invalid');
    final tubes = _tubes(state.data['tubes']);
    final next = _pour(
      tubes,
      action.arguments['from']! as int,
      action.arguments['to']! as int,
    )!;
    final data = Map<String, Object?>.from(state.data)
      ..['tubes'] = next
      ..['generatedSolution'] = <Object?>[];
    return PuzzleBoardState(
      data: data,
      moveCount: state.moveCount + 1,
      solved: _isSolved(next),
    );
  }

  @override
  PuzzleHint? hint(PuzzleBoardState state) {
    if (state.solved) return null;
    final generated = state.data['generatedSolution'];
    if (state.moveCount == 0 &&
        generated is List &&
        generated.isNotEmpty &&
        generated.first is Map) {
      final move = Map<String, Object?>.from(generated.first as Map);
      final action = PuzzleAction('pour', move);
      if (isLegalAction(state, action)) return _hintFor(state, action);
    }
    final tubes = _tubes(state.data['tubes']);
    final actions = legalActions(state);
    PuzzleAction? best;
    var bestScore = -1 << 30;
    for (final action in actions) {
      final next = _pour(
        tubes,
        action.arguments['from']! as int,
        action.arguments['to']! as int,
      )!;
      final score = _quality(next);
      if (score > bestScore) {
        bestScore = score;
        best = action;
      }
    }
    return best == null ? null : _hintFor(state, best);
  }

  PuzzleHint _hintFor(PuzzleBoardState state, PuzzleAction action) {
    final from = action.arguments['from']! as int;
    final to = action.arguments['to']! as int;
    return PuzzleHint(
      id: 'sort:${canonicalJson(state.data['tubes'])}:$from:$to',
      messageKey: 'hint.sort.pour',
      arguments: <String, Object?>{'from': from + 1, 'to': to + 1},
      suggestedAction: action,
      focusIndices: <int>[from, to],
    );
  }

  @override
  VerificationResult verify(PuzzleBoardState state) {
    try {
      final tubes = _tubes(state.data['tubes']);
      final colors = state.data['colors'];
      final storedCapacity = state.data['capacity'];
      if (colors is! int ||
          colors < 3 ||
          colors > 5 ||
          storedCapacity != capacity ||
          tubes.length != colors + 2 ||
          tubes.any((tube) => tube.length > capacity)) {
        return const VerificationResult.invalid(
          'Color sort dimensions are invalid',
        );
      }
      final counts = <int, int>{};
      for (final tube in tubes) {
        for (final color in tube) counts[color] = (counts[color] ?? 0) + 1;
      }
      if (counts.length != colors ||
          counts.keys.any((color) => color < 1 || color > colors) ||
          counts.values.any((count) => count != capacity)) {
        return const VerificationResult.invalid(
          'Color sort token counts are invalid',
        );
      }
      if (state.solved != _isSolved(tubes)) {
        return const VerificationResult.invalid(
          'Color sort solved flag is inconsistent',
        );
      }
    } on FormatException {
      return const VerificationResult.invalid(
        'Color sort state data is invalid',
      );
    }
    return const VerificationResult.valid();
  }

  @override
  PuzzleDescription accessibilityDescription(PuzzleBoardState state) {
    final tubes = _tubes(state.data['tubes']);
    return PuzzleDescription('accessibility.sort.board', <String, Object?>{
      'completed': tubes.where(_isCompleteTube).length,
      'total': state.data['colors']!,
      'moves': state.moveCount,
    });
  }

  List<List<int>> _tubes(Object? value) {
    if (value is! List) throw const FormatException('Expected tube list');
    return <List<int>>[for (final tube in value) intList(tube)];
  }

  List<List<int>>? _pour(List<List<int>> input, int from, int to) {
    if (from == to ||
        from < 0 ||
        to < 0 ||
        from >= input.length ||
        to >= input.length ||
        input[from].isEmpty ||
        input[to].length >= capacity) {
      return null;
    }
    final color = input[from].last;
    if (input[to].isNotEmpty && input[to].last != color) return null;
    final tubes = <List<int>>[for (final tube in input) List<int>.from(tube)];
    tubes[to].add(tubes[from].removeLast());
    return tubes;
  }

  bool _isCompleteTube(List<int> tube) =>
      tube.length == capacity && tube.every((color) => color == tube.first);

  bool _isSolved(List<List<int>> tubes) =>
      tubes.every((tube) => tube.isEmpty || _isCompleteTube(tube));

  int _quality(List<List<int>> tubes) {
    var value = tubes.where(_isCompleteTube).length * 100;
    value += tubes.where((tube) => tube.isEmpty).length * 8;
    for (final tube in tubes) {
      for (var index = 1; index < tube.length; index++) {
        if (tube[index] == tube[index - 1]) value += 2;
      }
    }
    return value;
  }
}
