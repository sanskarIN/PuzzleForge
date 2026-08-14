import 'dart:convert';

import 'package:crypto/crypto.dart';

class BackupPayload {
  const BackupPayload({
    required this.settings,
    required this.progress,
    this.activeSession,
  });

  final Map<String, Object?> settings;
  final Map<String, Object?> progress;
  final Map<String, Object?>? activeSession;

  Map<String, Object?> toJson() => <String, Object?>{
    'settings': settings,
    'progress': progress,
    'activeSession': activeSession,
  };
}

class BackupCodec {
  const BackupCodec();

  static const maxBackupBytes = 1024 * 1024;

  String encode(BackupPayload payload, {DateTime? exportedAt}) {
    final payloadJson = jsonEncode(payload.toJson());
    final envelope = <String, Object?>{
      'format': 'puzzleforge-backup',
      'schemaVersion': 1,
      'exportedAt': (exportedAt ?? DateTime.now()).toUtc().toIso8601String(),
      'payload': jsonDecode(payloadJson),
      'sha256': sha256.convert(utf8.encode(payloadJson)).toString(),
    };
    final encoded = const JsonEncoder.withIndent('  ').convert(envelope);
    if (utf8.encode(encoded).length > maxBackupBytes)
      throw const FormatException('Backup is too large');
    return encoded;
  }

  BackupPayload decode(String encoded) {
    if (utf8.encode(encoded).length > maxBackupBytes)
      throw const FormatException('Backup is too large');
    final decoded = jsonDecode(encoded);
    if (decoded is! Map)
      throw const FormatException('Backup must be an object');
    final envelope = Map<String, Object?>.from(decoded);
    if (envelope['format'] != 'puzzleforge-backup' ||
        envelope['schemaVersion'] != 1 ||
        DateTime.tryParse(envelope['exportedAt']?.toString() ?? '') == null) {
      throw const FormatException('Unsupported backup format');
    }
    final payload = envelope['payload'];
    final digest = envelope['sha256'];
    if (payload is! Map || digest is! String)
      throw const FormatException('Invalid backup envelope');
    final payloadMap = Map<String, Object?>.from(payload);
    final payloadJson = jsonEncode(payloadMap);
    final actual = sha256.convert(utf8.encode(payloadJson)).toString();
    if (!_constantTimeEquals(actual, digest))
      throw const FormatException('Backup integrity check failed');
    Map<String, Object?> requiredMap(String key) {
      final value = payloadMap[key];
      if (value is! Map) throw FormatException('Missing backup $key');
      return Map<String, Object?>.from(value);
    }

    final active = payloadMap['activeSession'];
    if (active != null && active is! Map)
      throw const FormatException('Invalid active session backup');
    return BackupPayload(
      settings: requiredMap('settings'),
      progress: requiredMap('progress'),
      activeSession: active == null
          ? null
          : Map<String, Object?>.from(active as Map),
    );
  }

  bool _constantTimeEquals(String first, String second) {
    var difference = first.length ^ second.length;
    final length = first.length < second.length ? first.length : second.length;
    for (var index = 0; index < length; index++) {
      difference |= first.codeUnitAt(index) ^ second.codeUnitAt(index);
    }
    return difference == 0;
  }
}
