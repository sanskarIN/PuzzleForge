import 'package:flutter/foundation.dart';

import '../../puzzles/core/puzzle_models.dart';
import '../../puzzles/core/puzzle_module.dart';

typedef PuzzleClock = DateTime Function();

enum HintOutcomeStatus { delivered, repeated, unavailable, noTokens }

class HintOutcome {
  const HintOutcome(this.status, {this.hint});

  final HintOutcomeStatus status;
  final PuzzleHint? hint;
}

class PuzzleSessionController extends ChangeNotifier {
  PuzzleSessionController({
    required this.module,
    required this.seed,
    required this.difficulty,
    required this.mode,
    required PuzzleBoardState initialState,
    required int hintTokens,
    PuzzleClock? clock,
    String? sessionId,
  }) : _clock = clock ?? DateTime.now,
       _initialState = initialState,
       _state = initialState,
       _hintTokens = hintTokens,
       sessionId =
           sessionId ??
           '${module.id}:${module.version}:$seed:${difficulty.name}:${mode.name}' {
    final verification = module.verify(initialState);
    if (!verification.isValid) {
      throw ArgumentError.value(
        initialState,
        'initialState',
        verification.message,
      );
    }
    _runningSince = _clock();
  }

  final PuzzleModule module;
  final int seed;
  final PuzzleDifficulty difficulty;
  final PlayMode mode;
  final String sessionId;
  final PuzzleClock _clock;
  final PuzzleBoardState _initialState;
  final List<PuzzleBoardState> _undo = <PuzzleBoardState>[];
  final List<PuzzleBoardState> _redo = <PuzzleBoardState>[];
  final List<PuzzleAction> _redoActions = <PuzzleAction>[];
  final Set<String> _deliveredHintIds = <String>{};
  final List<PuzzleAction> _replayActions = <PuzzleAction>[];

  PuzzleBoardState _state;
  int _hintTokens;
  int _hintsUsed = 0;
  Duration _elapsed = Duration.zero;
  DateTime? _runningSince;
  bool _paused = false;

  PuzzleBoardState get state => _state;
  int get hintTokens => _hintTokens;
  int get hintsUsed => _hintsUsed;
  bool get canUndo => _undo.isNotEmpty;
  bool get canRedo => _redo.isNotEmpty;
  bool get isPaused => _paused;
  List<PuzzleAction> get replayActions =>
      List<PuzzleAction>.unmodifiable(_replayActions);

  Duration get elapsed {
    if (_runningSince == null) return _elapsed;
    return _elapsed + _clock().difference(_runningSince!);
  }

  bool apply(PuzzleAction action) {
    if (_paused || _state.solved || !module.isLegalAction(_state, action))
      return false;
    final next = module.applyAction(_state, action);
    final verification = module.verify(next);
    if (!verification.isValid) {
      throw StateError(
        'Module produced invalid state: ${verification.message}',
      );
    }
    _undo.add(_state);
    _state = next;
    _redo.clear();
    _redoActions.clear();
    _replayActions.add(action);
    if (_state.solved) _stopClock();
    notifyListeners();
    return true;
  }

  bool undo() {
    if (_paused || _undo.isEmpty) return false;
    _redo.add(_state);
    _state = _undo.removeLast();
    if (_replayActions.isNotEmpty)
      _redoActions.add(_replayActions.removeLast());
    if (_runningSince == null && !_state.solved) _runningSince = _clock();
    notifyListeners();
    return true;
  }

  bool redo() {
    if (_paused || _redo.isEmpty) return false;
    _undo.add(_state);
    _state = _redo.removeLast();
    if (_redoActions.isNotEmpty) _replayActions.add(_redoActions.removeLast());
    if (_state.solved) _stopClock();
    notifyListeners();
    return true;
  }

  HintOutcome requestHint() {
    if (_paused || _state.solved)
      return const HintOutcome(HintOutcomeStatus.unavailable);
    final hint = module.hint(_state);
    if (hint == null) return const HintOutcome(HintOutcomeStatus.unavailable);
    if (_deliveredHintIds.contains(hint.id)) {
      return HintOutcome(HintOutcomeStatus.repeated, hint: hint);
    }
    if (_hintTokens <= 0) return const HintOutcome(HintOutcomeStatus.noTokens);
    _deliveredHintIds.add(hint.id);
    _hintTokens--;
    _hintsUsed++;
    notifyListeners();
    return HintOutcome(HintOutcomeStatus.delivered, hint: hint);
  }

  void pause() {
    if (_paused || _state.solved) return;
    _paused = true;
    _stopClock();
    notifyListeners();
  }

  void resume() {
    if (!_paused || _state.solved) return;
    _paused = false;
    _runningSince = _clock();
    notifyListeners();
  }

  void restart() {
    _state = _initialState;
    _undo.clear();
    _redo.clear();
    _redoActions.clear();
    _replayActions.clear();
    _deliveredHintIds.clear();
    _hintsUsed = 0;
    _elapsed = Duration.zero;
    _paused = false;
    _runningSince = _clock();
    notifyListeners();
  }

  int score() => module.score(_state, difficulty, elapsed) - _hintsUsed * 25;

  Map<String, Object?> toJson() => <String, Object?>{
    'schemaVersion': 1,
    'sessionId': sessionId,
    'moduleId': module.id,
    'moduleVersion': module.version,
    'seed': seed,
    'difficulty': difficulty.name,
    'mode': mode.name,
    'initialState': _initialState.toJson(),
    'state': _state.toJson(),
    'undo': _undo.map((item) => item.toJson()).toList(growable: false),
    'redo': _redo.map((item) => item.toJson()).toList(growable: false),
    'redoActions': _redoActions
        .map((action) => action.toJson())
        .toList(growable: false),
    'hintTokens': _hintTokens,
    'hintsUsed': _hintsUsed,
    'deliveredHintIds': _deliveredHintIds.toList()..sort(),
    'replayActions': _replayActions
        .map((action) => action.toJson())
        .toList(growable: false),
    'elapsedMilliseconds': elapsed.inMilliseconds,
    'paused': _paused,
  };

  static PuzzleSessionController restore({
    required Map<String, Object?> json,
    required PuzzleModule module,
    PuzzleClock? clock,
  }) {
    if (json['schemaVersion'] != 1 ||
        json['moduleId'] != module.id ||
        json['moduleVersion'] != module.version) {
      throw const FormatException('Unsupported puzzle session');
    }
    final seed = json['seed'];
    final sessionId = json['sessionId'];
    final hintTokens = json['hintTokens'];
    final hintsUsed = json['hintsUsed'];
    final elapsed = json['elapsedMilliseconds'];
    if (seed is! int ||
        sessionId is! String ||
        hintTokens is! int ||
        hintTokens < 0 ||
        hintsUsed is! int ||
        hintsUsed < 0 ||
        elapsed is! int ||
        elapsed < 0) {
      throw const FormatException('Invalid puzzle session metadata');
    }
    Map<String, Object?> map(Object? value) {
      if (value is! Map)
        throw const FormatException('Expected session state object');
      return Map<String, Object?>.from(value);
    }

    List<PuzzleBoardState> states(Object? value) {
      if (value is! List || value.length > 500)
        throw const FormatException('Invalid session history');
      return value
          .map((item) => module.deserialize(map(item)))
          .toList(growable: false);
    }

    final controller = PuzzleSessionController(
      module: module,
      seed: seed,
      difficulty: PuzzleDifficultyX.parse(json['difficulty']),
      mode: PlayModeX.parse(json['mode']),
      initialState: module.deserialize(map(json['initialState'])),
      hintTokens: hintTokens,
      clock: clock,
      sessionId: sessionId,
    );
    controller._state = module.deserialize(map(json['state']));
    controller._undo.addAll(states(json['undo']));
    controller._redo.addAll(states(json['redo']));
    final ids = json['deliveredHintIds'];
    final actions = json['replayActions'];
    final redoActions = json['redoActions'];
    if (ids is! List ||
        ids.any((id) => id is! String) ||
        actions is! List ||
        redoActions is! List ||
        actions.length > 10000 ||
        redoActions.length > 10000) {
      throw const FormatException('Invalid puzzle session events');
    }
    controller._deliveredHintIds.addAll(ids.cast<String>());
    controller._replayActions.addAll(
      actions.map((action) => PuzzleAction.fromJson(map(action))),
    );
    controller._redoActions.addAll(
      redoActions.map((action) => PuzzleAction.fromJson(map(action))),
    );
    controller._hintsUsed = hintsUsed;
    controller._elapsed = Duration(milliseconds: elapsed);
    controller._paused = json['paused'] == true;
    controller._runningSince = controller._paused || controller._state.solved
        ? null
        : controller._clock();
    return controller;
  }

  void _stopClock() {
    if (_runningSince == null) return;
    _elapsed += _clock().difference(_runningSince!);
    _runningSince = null;
  }
}
