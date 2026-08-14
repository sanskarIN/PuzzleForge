import 'dart:math';

import '../core/puzzle_models.dart';
import '../core/puzzle_module.dart';

class NumberSequenceModule extends PuzzleModule {
  const NumberSequenceModule();

  @override
  String get id => 'number_sequence';

  @override
  int get version => 1;

  @override
  String get titleKey => 'puzzle.sequence.title';

  @override
  String get descriptionKey => 'puzzle.sequence.description';

  @override
  String get rulesKey => 'puzzle.sequence.rules';

  @override
  PuzzleBoardState generate({
    required int seed,
    required PuzzleDifficulty difficulty,
  }) {
    final random = Random(seed);
    final values = <int>[];
    late final String pattern;
    switch (difficulty) {
      case PuzzleDifficulty.beginner:
      case PuzzleDifficulty.easy:
        final start = random.nextInt(8) + 1;
        final step = random.nextInt(5) + difficulty.rank;
        values.addAll(List<int>.generate(6, (index) => start + index * step));
        pattern = 'arithmetic';
      case PuzzleDifficulty.medium:
      case PuzzleDifficulty.hard:
        var first = random.nextInt(5) + 1;
        var second = random.nextInt(5) + 2;
        values.addAll(<int>[first, second]);
        while (values.length < 6) {
          final next = first + second;
          values.add(next);
          first = second;
          second = next;
        }
        pattern = 'sumPrevious';
      case PuzzleDifficulty.expert:
      case PuzzleDifficulty.master:
        final base = random.nextInt(3) + 2;
        final offset = random.nextInt(4) + 1;
        values.addAll(
          List<int>.generate(6, (index) => base * index * index + offset),
        );
        pattern = 'quadratic';
    }
    final answer = values.removeLast();
    final choices = <int>{answer};
    while (choices.length < 4) {
      final delta = random.nextInt(max(4, answer ~/ 4)) + 1;
      choices.add(max(0, answer + (random.nextBool() ? delta : -delta)));
    }
    final shuffled = choices.toList()..shuffle(random);
    return PuzzleBoardState(
      data: <String, Object?>{
        'sequence': values,
        'answer': answer,
        'choices': shuffled,
        'selected': null,
        'pattern': pattern,
      },
    );
  }

  @override
  List<PuzzleAction> legalActions(PuzzleBoardState state) {
    if (state.solved) return const <PuzzleAction>[];
    final choices = intList(state.data['choices'], length: 4);
    return choices
        .map(
          (choice) =>
              PuzzleAction('choose', <String, Object?>{'value': choice}),
        )
        .toList(growable: false);
  }

  @override
  PuzzleBoardState applyAction(PuzzleBoardState state, PuzzleAction action) {
    if (!isLegalAction(state, action))
      illegalAction('Sequence answer is invalid');
    final value = action.arguments['value']! as int;
    final answer = state.data['answer']! as int;
    final data = Map<String, Object?>.from(state.data)..['selected'] = value;
    return PuzzleBoardState(
      data: data,
      moveCount: state.moveCount + 1,
      solved: value == answer,
    );
  }

  @override
  PuzzleHint? hint(PuzzleBoardState state) {
    if (state.solved) return null;
    final pattern = state.data['pattern']! as String;
    final answer = state.data['answer']! as int;
    return PuzzleHint(
      id: 'sequence:${canonicalJson(state.data)}',
      messageKey: 'hint.sequence.$pattern',
      suggestedAction: PuzzleAction('choose', <String, Object?>{
        'value': answer,
      }),
    );
  }

  @override
  VerificationResult verify(PuzzleBoardState state) {
    try {
      final sequence = intList(state.data['sequence'], length: 5);
      final choices = intList(state.data['choices'], length: 4);
      final answer = state.data['answer'];
      final selected = state.data['selected'];
      final pattern = state.data['pattern'];
      if (answer is! int ||
          !choices.contains(answer) ||
          sequence.any((value) => value < 0)) {
        return const VerificationResult.invalid(
          'Sequence answer data is invalid',
        );
      }
      if (selected != null &&
          (selected is! int || !choices.contains(selected))) {
        return const VerificationResult.invalid(
          'Sequence selection is invalid',
        );
      }
      if (!const <String>{
        'arithmetic',
        'sumPrevious',
        'quadratic',
      }.contains(pattern)) {
        return const VerificationResult.invalid('Sequence pattern is invalid');
      }
      if (state.solved != (selected == answer)) {
        return const VerificationResult.invalid(
          'Sequence solved flag is inconsistent',
        );
      }
    } on FormatException {
      return const VerificationResult.invalid(
        'Sequence state values are invalid',
      );
    }
    return const VerificationResult.valid();
  }

  @override
  PuzzleDescription accessibilityDescription(PuzzleBoardState state) {
    return PuzzleDescription('accessibility.sequence.board', <String, Object?>{
      'sequence': intList(state.data['sequence']).join(', '),
      'moves': state.moveCount,
    });
  }
}
