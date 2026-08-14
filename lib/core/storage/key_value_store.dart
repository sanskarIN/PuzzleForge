import 'package:shared_preferences/shared_preferences.dart';

abstract interface class KeyValueStore {
  Future<String?> read(String key);
  Future<void> write(String key, String value);
  Future<void> remove(String key);
  Future<void> clearPuzzleForgeData();
}

class SharedPreferencesKeyValueStore implements KeyValueStore {
  SharedPreferencesKeyValueStore(this._preferences);

  static const prefix = 'puzzleforge.';
  final SharedPreferences _preferences;

  static Future<SharedPreferencesKeyValueStore> create() async {
    return SharedPreferencesKeyValueStore(
      await SharedPreferences.getInstance(),
    );
  }

  @override
  Future<String?> read(String key) async =>
      _preferences.getString('$prefix$key');

  @override
  Future<void> write(String key, String value) async {
    final written = await _preferences.setString('$prefix$key', value);
    if (!written) throw StateError('Unable to persist $key');
  }

  @override
  Future<void> remove(String key) async {
    final removed = await _preferences.remove('$prefix$key');
    if (!removed && _preferences.containsKey('$prefix$key')) {
      throw StateError('Unable to remove $key');
    }
  }

  @override
  Future<void> clearPuzzleForgeData() async {
    final keys = _preferences
        .getKeys()
        .where((key) => key.startsWith(prefix))
        .toList();
    for (final key in keys) {
      if (!await _preferences.remove(key))
        throw StateError('Unable to remove $key');
    }
  }
}

class MemoryKeyValueStore implements KeyValueStore {
  final Map<String, String> values = <String, String>{};

  @override
  Future<void> clearPuzzleForgeData() async => values.clear();

  @override
  Future<String?> read(String key) async => values[key];

  @override
  Future<void> remove(String key) async => values.remove(key);

  @override
  Future<void> write(String key, String value) async => values[key] = value;
}
