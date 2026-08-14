import 'dart:math';

import '../core/puzzle_models.dart';
import '../core/puzzle_module.dart';

class SudokuModule extends PuzzleModule {
  const SudokuModule();

  @override
  String get id => 'sudoku';

  @override
  int get version => 1;

  @override
  String get titleKey => 'puzzle.sudoku.title';

  @override
  String get descriptionKey => 'puzzle.sudoku.description';

  @override
  String get rulesKey => 'puzzle.sudoku.rules';

  @override
  PuzzleBoardState generate({
    required int seed,
    required PuzzleDifficulty difficulty,
  }) {
    final random = Random(seed);
    final digits = List<int>.generate(9, (index) => index + 1)..shuffle(random);
    final rowBands = <int>[0, 1, 2]..shuffle(random);
    final columnBands = <int>[0, 1, 2]..shuffle(random);
    final rows = <int>[
      for (final band in rowBands)
        ...(<int>[0, 1, 2]..shuffle(random)).map((row) => band * 3 + row),
    ];
    final columns = <int>[
      for (final band in columnBands)
        ...(<int>[0, 1, 2]..shuffle(random)).map((column) => band * 3 + column),
    ];
    final solution = <int>[
      for (final row in rows)
        for (final column in columns) digits[(row * 3 + row ~/ 3 + column) % 9],
    ];
    final clueCount = <int>[50, 44, 38, 32, 27, 23][difficulty.index];
    final order = List<int>.generate(81, (index) => index)..shuffle(random);
    final givens = List<bool>.filled(81, true);
    for (final index in order.take(81 - clueCount)) givens[index] = false;
    final cells = <int>[
      for (var index = 0; index < 81; index++)
        if (givens[index]) solution[index] else 0,
    ];
    return PuzzleBoardState(
      data: <String, Object?>{
        'cells': cells,
        'givens': givens,
        'solution': solution,
      },
    );
  }

  @override
  List<PuzzleAction> legalActions(PuzzleBoardState state) {
    if (state.solved) return const <PuzzleAction>[];
    final givens = boolList(state.data['givens'], length: 81);
    return <PuzzleAction>[
      for (var index = 0; index < 81; index++)
        if (!givens[index])
          for (var value = 0; value <= 9; value++)
            PuzzleAction('set', <String, Object?>{
              'index': index,
              'value': value,
            }),
    ];
  }

  @override
  PuzzleBoardState applyAction(PuzzleBoardState state, PuzzleAction action) {
    if (!isLegalAction(state, action))
      illegalAction('Sudoku cell is fixed or value is invalid');
    final cells = intList(state.data['cells'], length: 81);
    final solution = intList(state.data['solution'], length: 81);
    cells[action.arguments['index']! as int] =
        action.arguments['value']! as int;
    final data = Map<String, Object?>.from(state.data)..['cells'] = cells;
    return PuzzleBoardState(
      data: data,
      moveCount: state.moveCount + 1,
      solved: _same(cells, solution),
    );
  }

  @override
  PuzzleHint? hint(PuzzleBoardState state) {
    if (state.solved) return null;
    final cells = intList(state.data['cells'], length: 81);
    final solution = intList(state.data['solution'], length: 81);
    final givens = boolList(state.data['givens'], length: 81);
    final index = List<int>.generate(
      81,
      (value) => value,
    ).firstWhere((value) => !givens[value] && cells[value] != solution[value]);
    final action = PuzzleAction('set', <String, Object?>{
      'index': index,
      'value': solution[index],
    });
    return PuzzleHint(
      id: 'sudoku:${canonicalJson(cells)}:$index',
      messageKey: 'hint.sudoku.value',
      arguments: <String, Object?>{
        'row': index ~/ 9 + 1,
        'column': index % 9 + 1,
        'value': solution[index],
      },
      suggestedAction: action,
      focusIndices: <int>[index],
    );
  }

  @override
  VerificationResult verify(PuzzleBoardState state) {
    try {
      final cells = intList(state.data['cells'], length: 81);
      final givens = boolList(state.data['givens'], length: 81);
      final solution = intList(state.data['solution'], length: 81);
      if (!_validSolution(solution)) {
        return const VerificationResult.invalid('Sudoku solution is invalid');
      }
      for (var index = 0; index < 81; index++) {
        if (cells[index] < 0 ||
            cells[index] > 9 ||
            (givens[index] && cells[index] != solution[index])) {
          return const VerificationResult.invalid(
            'Sudoku cell values are invalid',
          );
        }
      }
      if (state.solved != _same(cells, solution)) {
        return const VerificationResult.invalid(
          'Sudoku solved flag is inconsistent',
        );
      }
    } on FormatException {
      return const VerificationResult.invalid('Sudoku state data is invalid');
    }
    return const VerificationResult.valid();
  }

  @override
  PuzzleDescription accessibilityDescription(PuzzleBoardState state) {
    final cells = intList(state.data['cells'], length: 81);
    return PuzzleDescription('accessibility.sudoku.board', <String, Object?>{
      'filled': cells.where((value) => value != 0).length,
      'moves': state.moveCount,
    });
  }

  bool _same(List<int> first, List<int> second) {
    for (var index = 0; index < first.length; index++) {
      if (first[index] != second[index]) return false;
    }
    return true;
  }

  bool _validSolution(List<int> values) {
    final expected = <int>{1, 2, 3, 4, 5, 6, 7, 8, 9};
    for (var index = 0; index < 9; index++) {
      if (values.sublist(index * 9, index * 9 + 9).toSet().length !=
          expected.length)
        return false;
      if (<int>{
            for (var row = 0; row < 9; row++) values[row * 9 + index],
          }.length !=
          expected.length) {
        return false;
      }
    }
    for (var blockRow = 0; blockRow < 3; blockRow++) {
      for (var blockColumn = 0; blockColumn < 3; blockColumn++) {
        final block = <int>{
          for (var row = 0; row < 3; row++)
            for (var column = 0; column < 3; column++)
              values[(blockRow * 3 + row) * 9 + blockColumn * 3 + column],
        };
        if (block.length != expected.length) return false;
      }
    }
    return true;
  }
}
