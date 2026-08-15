import 'puzzle_models.dart';

abstract class PuzzleModule {
  const PuzzleModule();

  String get id;
  int get version;
  String get titleKey;
  String get descriptionKey;
  String get rulesKey;

  PuzzleBoardState generate({
    required int seed,
    required PuzzleDifficulty difficulty,
  });

  PuzzleBoardState deserialize(Map<String, Object?> json) {
    final state = PuzzleBoardState.fromJson(json);
    final verification = verify(state);
    if (!verification.isValid) {
      throw FormatException(verification.message ?? 'Invalid puzzle state');
    }
    return state;
  }

  List<PuzzleAction> legalActions(PuzzleBoardState state);

  PuzzleBoardState applyAction(PuzzleBoardState state, PuzzleAction action);

  PuzzleHint? hint(PuzzleBoardState state);

  VerificationResult verify(PuzzleBoardState state);

  PuzzleDescription accessibilityDescription(PuzzleBoardState state);

  int score(
    PuzzleBoardState state,
    PuzzleDifficulty difficulty,
    Duration elapsed,
  ) {
    if (!state.solved) return 0;
    final base = 1000 * difficulty.rank;
    final movePenalty = state.moveCount * (8 - difficulty.rank).clamp(2, 7);
    final timePenalty = elapsed.inSeconds.clamp(0, base ~/ 2);
    return (base - movePenalty - timePenalty).clamp(100, base);
  }

  bool isLegalAction(PuzzleBoardState state, PuzzleAction action) {
    return legalActions(state).contains(action);
  }
}

Never illegalAction(String message) => throw StateError(message);
