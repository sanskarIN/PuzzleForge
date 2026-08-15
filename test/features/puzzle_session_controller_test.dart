import 'package:flutter_test/flutter_test.dart';
import 'package:puzzle_forge/features/gameplay/puzzle_session_controller.dart';
import 'package:puzzle_forge/puzzles/core/puzzle_models.dart';
import 'package:puzzle_forge/puzzles/modules/number_sequence_module.dart';

void main() {
  const module = NumberSequenceModule();
  late DateTime now;
  late PuzzleSessionController controller;

  setUp(() {
    now = DateTime.utc(2026, 8, 14, 10);
    controller = PuzzleSessionController(
      module: module,
      seed: 42,
      difficulty: PuzzleDifficulty.medium,
      mode: PlayMode.daily,
      initialState: module.generate(
        seed: 42,
        difficulty: PuzzleDifficulty.medium,
      ),
      hintTokens: 3,
      clock: () => now,
    );
  });

  test('applies legal actions and keeps undo/redo consistent', () {
    final answer = controller.state.data['answer']! as int;
    final choices = intList(controller.state.data['choices']);
    final wrong = choices.firstWhere((choice) => choice != answer);
    expect(
      controller.apply(
        PuzzleAction('choose', <String, Object?>{'value': wrong}),
      ),
      isTrue,
    );
    expect(controller.state.solved, isFalse);
    expect(controller.replayActions, hasLength(1));
    expect(controller.undo(), isTrue);
    expect(controller.replayActions, isEmpty);
    expect(controller.redo(), isTrue);
    expect(controller.replayActions, hasLength(1));
    expect(controller.undo(), isTrue);
    expect(
      controller.apply(
        PuzzleAction('choose', <String, Object?>{'value': answer}),
      ),
      isTrue,
    );
    expect(controller.state.solved, isTrue);
    expect(controller.canRedo, isFalse);
  });

  test('charges a generated hint exactly once', () {
    final first = controller.requestHint();
    expect(first.status, HintOutcomeStatus.delivered);
    expect(controller.hintTokens, 2);
    final repeated = controller.requestHint();
    expect(repeated.status, HintOutcomeStatus.repeated);
    expect(controller.hintTokens, 2);
    expect(repeated.hint?.id, first.hint?.id);
  });

  test('does not charge when no tokens are available', () {
    final empty = PuzzleSessionController(
      module: module,
      seed: 1,
      difficulty: PuzzleDifficulty.easy,
      mode: PlayMode.endless,
      initialState: module.generate(seed: 1, difficulty: PuzzleDifficulty.easy),
      hintTokens: 0,
    );
    expect(empty.requestHint().status, HintOutcomeStatus.noTokens);
    expect(empty.hintsUsed, 0);
  });

  test('timer pauses, resumes, and survives serialization', () {
    now = now.add(const Duration(seconds: 12));
    controller.pause();
    expect(controller.elapsed, const Duration(seconds: 12));
    now = now.add(const Duration(minutes: 5));
    expect(controller.elapsed, const Duration(seconds: 12));
    controller.resume();
    now = now.add(const Duration(seconds: 8));
    final restored = PuzzleSessionController.restore(
      json: controller.toJson(),
      module: module,
      clock: () => now,
    );
    expect(restored.elapsed, const Duration(seconds: 20));
    expect(restored.state, controller.state);
    expect(restored.sessionId, controller.sessionId);
  });
}
