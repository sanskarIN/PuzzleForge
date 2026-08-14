import 'dart:math';

import '../core/puzzle_models.dart';
import '../core/puzzle_module.dart';

class MemoryMatchModule extends PuzzleModule {
  const MemoryMatchModule();

  @override
  String get id => 'memory_match';

  @override
  int get version => 1;

  @override
  String get titleKey => 'puzzle.memory.title';

  @override
  String get descriptionKey => 'puzzle.memory.description';

  @override
  String get rulesKey => 'puzzle.memory.rules';

  @override
  PuzzleBoardState generate({
    required int seed,
    required PuzzleDifficulty difficulty,
  }) {
    final pairs = <int>[3, 4, 6, 8, 10, 12][difficulty.index];
    final cards = <int>[
      for (var value = 1; value <= pairs; value++) ...<int>[value, value],
    ];
    cards.shuffle(Random(seed));
    return PuzzleBoardState(
      data: <String, Object?>{
        'cards': cards,
        'revealed': List<bool>.filled(cards.length, false),
        'matched': List<bool>.filled(cards.length, false),
        'selection': <int>[],
      },
    );
  }

  @override
  List<PuzzleAction> legalActions(PuzzleBoardState state) {
    if (state.solved) return const <PuzzleAction>[];
    final cards = intList(state.data['cards']);
    final revealed = boolList(state.data['revealed'], length: cards.length);
    final matched = boolList(state.data['matched'], length: cards.length);
    final selection = intList(state.data['selection']);
    final blocked = selection.length == 2 ? selection.toSet() : const <int>{};
    return <PuzzleAction>[
      for (var index = 0; index < cards.length; index++)
        if (!matched[index] && !revealed[index] && !blocked.contains(index))
          PuzzleAction('flip', <String, Object?>{'index': index}),
    ];
  }

  @override
  PuzzleBoardState applyAction(PuzzleBoardState state, PuzzleAction action) {
    if (!isLegalAction(state, action))
      illegalAction('Memory card cannot be flipped');
    final cards = intList(state.data['cards']);
    final revealed = boolList(state.data['revealed'], length: cards.length);
    final matched = boolList(state.data['matched'], length: cards.length);
    var selection = intList(state.data['selection']);
    if (selection.length == 2) {
      for (final index in selection) {
        if (!matched[index]) revealed[index] = false;
      }
      selection = <int>[];
    }
    final index = action.arguments['index']! as int;
    revealed[index] = true;
    selection.add(index);
    if (selection.length == 2 && cards[selection[0]] == cards[selection[1]]) {
      matched[selection[0]] = true;
      matched[selection[1]] = true;
      selection = <int>[];
    }
    final solved = matched.every((value) => value);
    return PuzzleBoardState(
      data: <String, Object?>{
        'cards': cards,
        'revealed': revealed,
        'matched': matched,
        'selection': selection,
      },
      moveCount: state.moveCount + 1,
      solved: solved,
    );
  }

  @override
  PuzzleHint? hint(PuzzleBoardState state) {
    if (state.solved) return null;
    final cards = intList(state.data['cards']);
    final matched = boolList(state.data['matched'], length: cards.length);
    final selection = intList(state.data['selection']);
    var index = -1;
    if (selection.length == 1) {
      index = List<int>.generate(cards.length, (value) => value).firstWhere(
        (candidate) =>
            candidate != selection.first &&
            !matched[candidate] &&
            cards[candidate] == cards[selection.first],
      );
    } else {
      index = matched.indexOf(false);
    }
    final action = PuzzleAction('flip', <String, Object?>{'index': index});
    return PuzzleHint(
      id: 'memory:${state.moveCount}:${canonicalJson(state.data)}:$index',
      messageKey: 'hint.memory.reveal',
      arguments: <String, Object?>{'position': index + 1},
      suggestedAction: action,
      focusIndices: <int>[index],
    );
  }

  @override
  VerificationResult verify(PuzzleBoardState state) {
    List<int> cards;
    try {
      cards = intList(state.data['cards']);
      final revealed = boolList(state.data['revealed'], length: cards.length);
      final matched = boolList(state.data['matched'], length: cards.length);
      final selection = intList(state.data['selection']);
      if (cards.length < 6 || cards.length > 24 || cards.length.isOdd) {
        return const VerificationResult.invalid('Memory card count is invalid');
      }
      if (selection.length > 2 ||
          selection.any((index) => index < 0 || index >= cards.length)) {
        return const VerificationResult.invalid('Memory selection is invalid');
      }
      final counts = <int, int>{};
      for (final card in cards) counts[card] = (counts[card] ?? 0) + 1;
      if (counts.values.any((count) => count != 2)) {
        return const VerificationResult.invalid('Memory cards must form pairs');
      }
      for (var index = 0; index < cards.length; index++) {
        if (matched[index] && !revealed[index]) {
          return const VerificationResult.invalid(
            'Matched cards must remain revealed',
          );
        }
      }
      if (state.solved != matched.every((value) => value)) {
        return const VerificationResult.invalid(
          'Memory solved flag is inconsistent',
        );
      }
    } on FormatException {
      return const VerificationResult.invalid(
        'Memory state values are invalid',
      );
    }
    return const VerificationResult.valid();
  }

  @override
  PuzzleDescription accessibilityDescription(PuzzleBoardState state) {
    final matched = boolList(state.data['matched']);
    return PuzzleDescription('accessibility.memory.board', <String, Object?>{
      'pairs': matched.where((value) => value).length ~/ 2,
      'total': matched.length ~/ 2,
      'moves': state.moveCount,
    });
  }
}
