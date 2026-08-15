import 'dart:convert';

import '../../features/progression/player_progress.dart';
import '../../features/settings/app_settings.dart';
import 'key_value_store.dart';

class LoadResult<T> {
  const LoadResult(
    this.value, {
    this.recoveredFromCorruption = false,
    this.error,
  });

  final T value;
  final bool recoveredFromCorruption;
  final Object? error;
}

class AppRepository {
  AppRepository(this._store);

  static const _settingsKey = 'settings';
  static const _progressKey = 'progress';
  static const _sessionKey = 'activeSession';
  static const maxRecordCharacters = 1024 * 1024;

  final KeyValueStore _store;

  Future<LoadResult<AppSettings>> loadSettings() async {
    return _load(
      _settingsKey,
      fallback: const AppSettings(),
      decode: AppSettings.fromJson,
    );
  }

  Future<void> saveSettings(AppSettings settings) =>
      _save(_settingsKey, settings.toJson());

  Future<LoadResult<PlayerProgress>> loadProgress() async {
    return _load(
      _progressKey,
      fallback: PlayerProgress(),
      decode: PlayerProgress.fromJson,
    );
  }

  Future<void> saveProgress(PlayerProgress progress) =>
      _save(_progressKey, progress.toJson());

  Future<LoadResult<Map<String, Object?>?>> loadSession() async {
    return _load<Map<String, Object?>?>(
      _sessionKey,
      fallback: null,
      decode: (json) => json,
    );
  }

  Future<void> saveSession(Map<String, Object?> session) =>
      _save(_sessionKey, session);

  Future<void> deleteSession() => _store.remove(_sessionKey);

  Future<void> deleteAllData() => _store.clearPuzzleForgeData();

  Future<LoadResult<T>> _load<T>(
    String key, {
    required T fallback,
    required T Function(Map<String, Object?> json) decode,
  }) async {
    final raw = await _store.read(key);
    if (raw == null) return LoadResult<T>(fallback);
    if (raw.length > maxRecordCharacters) {
      return LoadResult<T>(
        fallback,
        recoveredFromCorruption: true,
        error: const FormatException('Record too large'),
      );
    }
    try {
      final value = jsonDecode(raw);
      if (value is! Map) throw const FormatException('Expected a JSON object');
      return LoadResult<T>(decode(Map<String, Object?>.from(value)));
    } catch (error) {
      return LoadResult<T>(
        fallback,
        recoveredFromCorruption: true,
        error: error,
      );
    }
  }

  Future<void> _save(String key, Map<String, Object?> value) async {
    final encoded = jsonEncode(value);
    if (encoded.length > maxRecordCharacters)
      throw const FormatException('Record too large');
    await _store.write(key, encoded);
  }
}
