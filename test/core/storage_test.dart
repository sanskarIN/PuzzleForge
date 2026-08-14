import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:puzzle_forge/core/storage/app_repository.dart';
import 'package:puzzle_forge/core/storage/backup_codec.dart';
import 'package:puzzle_forge/core/storage/key_value_store.dart';
import 'package:puzzle_forge/features/progression/player_progress.dart';
import 'package:puzzle_forge/features/settings/app_settings.dart';

void main() {
  test('repository saves and loads settings and progress', () async {
    final repository = AppRepository(MemoryKeyValueStore());
    const settings = AppSettings(localeCode: 'hi', highContrast: true);
    final progress = PlayerProgress(xp: 1500)..favorites.add('maze');
    await repository.saveSettings(settings);
    await repository.saveProgress(progress);
    expect((await repository.loadSettings()).value.toJson(), settings.toJson());
    expect((await repository.loadProgress()).value.toJson(), progress.toJson());
  });

  test('repository recovers safely from malformed data', () async {
    final store = MemoryKeyValueStore()..values['settings'] = '{broken';
    final result = await AppRepository(store).loadSettings();
    expect(result.recoveredFromCorruption, isTrue);
    expect(result.value.toJson(), const AppSettings().toJson());
    expect(
      store.values['settings'],
      '{broken',
      reason: 'corrupt source must not be silently overwritten',
    );
  });

  test('backup validates integrity before returning data', () {
    const codec = BackupCodec();
    final payload = BackupPayload(
      settings: const AppSettings().toJson(),
      progress: PlayerProgress().toJson(),
    );
    final encoded = codec.encode(
      payload,
      exportedAt: DateTime.utc(2026, 8, 14),
    );
    final restored = codec.decode(encoded);
    expect(restored.settings, payload.settings);
    final tampered = jsonDecode(encoded) as Map<String, Object?>;
    (tampered['payload']! as Map<String, Object?>)['settings'] =
        <String, Object?>{};
    expect(() => codec.decode(jsonEncode(tampered)), throwsFormatException);
  });
}
