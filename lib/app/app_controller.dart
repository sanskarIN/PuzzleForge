import 'dart:async';

import 'package:flutter/foundation.dart';

import '../core/services/external_link_service.dart';
import '../core/storage/app_repository.dart';
import '../core/storage/backup_codec.dart';
import '../features/gameplay/puzzle_session_controller.dart';
import '../features/progression/player_progress.dart';
import '../features/settings/app_settings.dart';
import '../puzzles/core/deterministic_seed.dart';
import '../puzzles/core/puzzle_models.dart';
import '../puzzles/puzzle_catalog.dart';

class AppController extends ChangeNotifier {
  AppController({
    required AppRepository repository,
    required this.externalLinks,
    DateTime Function()? clock,
  }) : _repository = repository,
       _clock = clock ?? DateTime.now;

  final AppRepository _repository;
  final DateTime Function() _clock;
  final ExternalLinkService externalLinks;
  final BackupCodec _backupCodec = const BackupCodec();

  AppSettings settings = const AppSettings();
  PlayerProgress progress = PlayerProgress();
  PuzzleSessionController? activeSession;
  bool initialized = false;
  bool busy = false;
  String? noticeKey;
  Object? lastError;
  Future<void> _writeQueue = Future<void>.value();
  bool _completionHandled = false;

  bool get hasActiveSession =>
      activeSession != null && !activeSession!.state.solved;

  Future<void> initialize() async {
    if (initialized) return;
    busy = true;
    notifyListeners();
    try {
      final results = await Future.wait<Object>(<Future<Object>>[
        _repository.loadSettings(),
        _repository.loadProgress(),
        _repository.loadSession(),
      ]);
      final settingsResult = results[0] as LoadResult<AppSettings>;
      final progressResult = results[1] as LoadResult<PlayerProgress>;
      final sessionResult = results[2] as LoadResult<Map<String, Object?>?>;
      settings = settingsResult.value;
      progress = progressResult.value;
      if (settingsResult.recoveredFromCorruption ||
          progressResult.recoveredFromCorruption ||
          sessionResult.recoveredFromCorruption) {
        noticeKey = 'notice.recovered';
      }
      final savedSession = sessionResult.value;
      if (savedSession != null) {
        try {
          final moduleId = savedSession['moduleId'];
          if (moduleId is! String)
            throw const FormatException('Missing session module');
          final module = PuzzleCatalog.byId(moduleId).module;
          _attachSession(
            PuzzleSessionController.restore(json: savedSession, module: module),
          );
        } catch (error) {
          lastError = error;
          noticeKey = 'notice.recovered';
        }
      }
    } catch (error) {
      lastError = error;
      noticeKey = 'notice.recovered';
    } finally {
      busy = false;
      initialized = true;
      notifyListeners();
    }
  }

  Future<void> startPuzzle({
    required String moduleId,
    required PuzzleDifficulty difficulty,
    required PlayMode mode,
    int? customSeed,
  }) async {
    final entry = PuzzleCatalog.byId(moduleId);
    final now = _clock();
    final seed = switch (mode) {
      PlayMode.daily => DeterministicSeed.daily(
        date: now,
        puzzleId: moduleId,
        generatorVersion: entry.module.version,
      ),
      PlayMode.campaign => DeterministicSeed.fromText(
        'campaign:$moduleId:${difficulty.name}:${progress.stars ~/ 10}',
      ),
      PlayMode.custom =>
        customSeed ??
            DeterministicSeed.fromText(
              settings.deterministicSeed.isEmpty
                  ? 'PuzzleForge'
                  : settings.deterministicSeed,
            ),
      PlayMode.endless => DeterministicSeed.fromText(
        'endless:$moduleId:${now.microsecondsSinceEpoch}',
      ),
    };
    final initial = entry.module.generate(seed: seed, difficulty: difficulty);
    final verification = entry.module.verify(initial);
    if (!verification.isValid) {
      throw StateError(
        'Generated puzzle failed verification: ${verification.message}',
      );
    }
    activeSession?.removeListener(_onSessionChanged);
    activeSession?.dispose();
    _attachSession(
      PuzzleSessionController(
        module: entry.module,
        seed: seed,
        difficulty: difficulty,
        mode: mode,
        initialState: initial,
        hintTokens: progress.hintTokens,
      ),
    );
    await _persistActive();
    notifyListeners();
  }

  Future<void> updateSettings(AppSettings value) async {
    settings = value;
    notifyListeners();
    await _repository.saveSettings(settings);
  }

  Future<void> toggleFavorite(String moduleId) async {
    if (!progress.favorites.add(moduleId)) progress.favorites.remove(moduleId);
    notifyListeners();
    await _repository.saveProgress(progress);
  }

  Future<void> clearHistory() async {
    progress.history.clear();
    notifyListeners();
    await _repository.saveProgress(progress);
  }

  Future<void> deleteAllData() async {
    activeSession?.removeListener(_onSessionChanged);
    activeSession?.dispose();
    activeSession = null;
    settings = const AppSettings();
    progress = PlayerProgress();
    noticeKey = null;
    lastError = null;
    _completionHandled = false;
    await _repository.deleteAllData();
    notifyListeners();
  }

  Future<void> abandonSession() async {
    activeSession?.removeListener(_onSessionChanged);
    activeSession?.dispose();
    activeSession = null;
    _completionHandled = false;
    await _repository.deleteSession();
    notifyListeners();
  }

  Future<void> persistSession() => _persistActive();

  String exportBackup() {
    return _backupCodec.encode(
      BackupPayload(
        settings: settings.toJson(),
        progress: progress.toJson(),
        activeSession: activeSession?.toJson(),
      ),
    );
  }

  Future<void> importBackup(String encoded) async {
    final payload = _backupCodec.decode(encoded);
    final importedSettings = AppSettings.fromJson(payload.settings);
    final importedProgress = PlayerProgress.fromJson(payload.progress);
    PuzzleSessionController? importedSession;
    if (payload.activeSession != null) {
      final moduleId = payload.activeSession!['moduleId'];
      if (moduleId is! String)
        throw const FormatException('Missing imported module');
      importedSession = PuzzleSessionController.restore(
        json: payload.activeSession!,
        module: PuzzleCatalog.byId(moduleId).module,
      );
    }
    await _repository.saveSettings(importedSettings);
    await _repository.saveProgress(importedProgress);
    if (importedSession == null) {
      await _repository.deleteSession();
    } else {
      await _repository.saveSession(importedSession.toJson());
    }
    activeSession?.removeListener(_onSessionChanged);
    activeSession?.dispose();
    settings = importedSettings;
    progress = importedProgress;
    activeSession = null;
    if (importedSession != null) _attachSession(importedSession);
    notifyListeners();
  }

  Future<bool> openExternal(Uri uri) => externalLinks.open(uri);

  void dismissNotice() {
    noticeKey = null;
    notifyListeners();
  }

  void _attachSession(PuzzleSessionController session) {
    activeSession = session;
    _completionHandled = session.state.solved;
    session.addListener(_onSessionChanged);
  }

  void _onSessionChanged() {
    final session = activeSession;
    if (session == null) return;
    progress.hintTokens = session.hintTokens;
    final solved = session.state.solved;
    final shouldRecordCompletion = solved && !_completionHandled;
    if (shouldRecordCompletion) _completionHandled = true;
    final sessionSnapshot = session.toJson();
    _writeQueue = _writeQueue
        .then((_) async {
          await _repository.saveProgress(progress);
          if (shouldRecordCompletion) {
            await _recordCompletion(session);
          } else if (!solved) {
            await _repository.saveSession(sessionSnapshot);
          }
        })
        .catchError((Object error) {
          lastError = error;
          notifyListeners();
        });
    notifyListeners();
  }

  Future<void> _recordCompletion(PuzzleSessionController session) async {
    final today = _clock();
    final record = CompletionRecord(
      id: session.sessionId,
      puzzleId: session.module.id,
      difficulty: session.difficulty.name,
      completedOn: today,
      score: session.score().clamp(0, 1 << 31),
      moves: session.state.moveCount,
      elapsedSeconds: session.elapsed.inSeconds,
      hintsUsed: session.hintsUsed,
    );
    progress.award(record, isDaily: session.mode == PlayMode.daily);
    await _repository.saveProgress(progress);
    await _repository.deleteSession();
    notifyListeners();
  }

  Future<void> _persistActive() async {
    final session = activeSession;
    if (session == null || session.state.solved) return;
    progress.hintTokens = session.hintTokens;
    await _repository.saveProgress(progress);
    await _repository.saveSession(session.toJson());
  }

  @override
  void dispose() {
    activeSession?.removeListener(_onSessionChanged);
    activeSession?.dispose();
    super.dispose();
  }
}
