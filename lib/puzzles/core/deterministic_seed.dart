import 'dart:convert';
import 'package:crypto/crypto.dart';

class DeterministicSeed {
  const DeterministicSeed._();

  static int fromText(String value) {
    final digest = sha256.convert(utf8.encode(value)).bytes;
    var result = 0;
    for (var index = 0; index < 8; index++) {
      result = ((result << 8) | digest[index]) & 0x7fffffffffffffff;
    }
    return result;
  }

  static int daily({
    required DateTime date,
    required String puzzleId,
    required int generatorVersion,
  }) {
    final utc = DateTime.utc(date.year, date.month, date.day);
    final stamp =
        '${utc.year.toString().padLeft(4, '0')}-'
        '${utc.month.toString().padLeft(2, '0')}-'
        '${utc.day.toString().padLeft(2, '0')}';
    return fromText('puzzleforge:daily:v$generatorVersion:$puzzleId:$stamp');
  }

  static int weekly({
    required DateTime date,
    required String puzzleId,
    required int generatorVersion,
  }) {
    final normalized = DateTime.utc(date.year, date.month, date.day);
    final monday = normalized.subtract(Duration(days: normalized.weekday - 1));
    return fromText(
      'puzzleforge:weekly:v$generatorVersion:$puzzleId:${monday.toIso8601String().substring(0, 10)}',
    );
  }
}
