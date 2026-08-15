import 'dart:convert';

enum PuzzleDifficulty { beginner, easy, medium, hard, expert, master }

extension PuzzleDifficultyX on PuzzleDifficulty {
  int get rank => index + 1;

  String get localizationKey => 'difficulty.$name';

  static PuzzleDifficulty parse(Object? value) {
    return PuzzleDifficulty.values.firstWhere(
      (difficulty) => difficulty.name == value,
      orElse: () => throw const FormatException('Unknown puzzle difficulty'),
    );
  }
}

enum PlayMode { daily, endless, campaign, custom }

extension PlayModeX on PlayMode {
  static PlayMode parse(Object? value) {
    return PlayMode.values.firstWhere(
      (mode) => mode.name == value,
      orElse: () => throw const FormatException('Unknown play mode'),
    );
  }
}

class PuzzleAction {
  const PuzzleAction(this.type, [this.arguments = const <String, Object?>{}]);

  final String type;
  final Map<String, Object?> arguments;

  Map<String, Object?> toJson() => <String, Object?>{
    'type': type,
    'arguments': arguments,
  };

  factory PuzzleAction.fromJson(Map<String, Object?> json) {
    final type = json['type'];
    final arguments = json['arguments'];
    if (type is! String || arguments is! Map) {
      throw const FormatException('Invalid puzzle action');
    }
    return PuzzleAction(type, Map<String, Object?>.from(arguments));
  }

  @override
  bool operator ==(Object other) =>
      other is PuzzleAction &&
      other.type == type &&
      canonicalJson(other.arguments) == canonicalJson(arguments);

  @override
  int get hashCode => Object.hash(type, canonicalJson(arguments));
}

class PuzzleBoardState {
  PuzzleBoardState({
    required Map<String, Object?> data,
    this.moveCount = 0,
    this.solved = false,
  }) : data = deepJsonMap(data);

  final Map<String, Object?> data;
  final int moveCount;
  final bool solved;

  PuzzleBoardState copyWith({
    Map<String, Object?>? data,
    int? moveCount,
    bool? solved,
  }) {
    return PuzzleBoardState(
      data: data ?? this.data,
      moveCount: moveCount ?? this.moveCount,
      solved: solved ?? this.solved,
    );
  }

  Map<String, Object?> toJson() => <String, Object?>{
    'data': data,
    'moveCount': moveCount,
    'solved': solved,
  };

  factory PuzzleBoardState.fromJson(Map<String, Object?> json) {
    final data = json['data'];
    final moveCount = json['moveCount'];
    final solved = json['solved'];
    if (data is! Map || moveCount is! int || moveCount < 0 || solved is! bool) {
      throw const FormatException('Invalid puzzle board state');
    }
    return PuzzleBoardState(
      data: Map<String, Object?>.from(data),
      moveCount: moveCount,
      solved: solved,
    );
  }

  @override
  bool operator ==(Object other) =>
      other is PuzzleBoardState &&
      canonicalJson(toJson()) == canonicalJson(other.toJson());

  @override
  int get hashCode => canonicalJson(toJson()).hashCode;
}

class PuzzleHint {
  const PuzzleHint({
    required this.id,
    required this.messageKey,
    this.arguments = const <String, Object?>{},
    this.suggestedAction,
    this.focusIndices = const <int>[],
  });

  final String id;
  final String messageKey;
  final Map<String, Object?> arguments;
  final PuzzleAction? suggestedAction;
  final List<int> focusIndices;
}

class PuzzleDescription {
  const PuzzleDescription(
    this.messageKey, [
    this.arguments = const <String, Object?>{},
  ]);

  final String messageKey;
  final Map<String, Object?> arguments;
}

class VerificationResult {
  const VerificationResult._(this.isValid, this.message);

  const VerificationResult.valid() : this._(true, null);

  const VerificationResult.invalid(String message) : this._(false, message);

  final bool isValid;
  final String? message;
}

Map<String, Object?> deepJsonMap(Map<String, Object?> value) {
  final decoded = jsonDecode(jsonEncode(value));
  if (decoded is! Map) {
    throw const FormatException('Expected a JSON object');
  }
  return Map<String, Object?>.from(decoded);
}

String canonicalJson(Object? value) {
  Object? normalize(Object? current) {
    if (current is Map) {
      final keys = current.keys.map((key) => key.toString()).toList()..sort();
      return <String, Object?>{
        for (final key in keys) key: normalize(current[key]),
      };
    }
    if (current is List) {
      return current.map(normalize).toList(growable: false);
    }
    return current;
  }

  return jsonEncode(normalize(value));
}

List<int> intList(Object? value, {int? length}) {
  if (value is! List || value.any((item) => item is! int)) {
    throw const FormatException('Expected an integer list');
  }
  final result = List<int>.from(value);
  if (length != null && result.length != length) {
    throw const FormatException('Unexpected integer list length');
  }
  return result;
}

List<bool> boolList(Object? value, {int? length}) {
  if (value is! List || value.any((item) => item is! bool)) {
    throw const FormatException('Expected a boolean list');
  }
  final result = List<bool>.from(value);
  if (length != null && result.length != length) {
    throw const FormatException('Unexpected boolean list length');
  }
  return result;
}
