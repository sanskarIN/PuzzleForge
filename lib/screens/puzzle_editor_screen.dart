import 'dart:convert';

import 'package:flutter/material.dart';

import '../core/localization/app_localizations.dart';
import '../puzzles/core/puzzle_models.dart';
import '../puzzles/puzzle_catalog.dart';

class PuzzleEditorScreen extends StatefulWidget {
  const PuzzleEditorScreen({super.key});

  @override
  State<PuzzleEditorScreen> createState() => _PuzzleEditorScreenState();
}

class _PuzzleEditorScreenState extends State<PuzzleEditorScreen> {
  final _formKey = GlobalKey<FormState>();
  final _levelId = TextEditingController(text: 'community_level_001');
  final _seed = TextEditingController(text: '20260814');
  final _tags = TextEditingController(text: 'community, logic');
  final _position = TextEditingController(text: '1');
  final _reward = TextEditingController(text: '100');
  final _json = TextEditingController();
  final Set<String> _knownIds = <String>{};
  String _moduleId = PuzzleCatalog.entries.first.module.id;
  PuzzleDifficulty _difficulty = PuzzleDifficulty.medium;
  String? _statusKey;
  Map<String, Object?> _statusArguments = const <String, Object?>{};
  Map<String, Object?>? _level;

  @override
  void dispose() {
    _levelId.dispose();
    _seed.dispose();
    _tags.dispose();
    _position.dispose();
    _reward.dispose();
    _json.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final strings = context.strings;
    return Scaffold(
      appBar: AppBar(
        title: Text(strings.text('editor.title')),
        actions: <Widget>[
          IconButton(
            tooltip: strings.text('common.new'),
            onPressed: _newLevel,
            icon: const Icon(Icons.add_rounded),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: <Widget>[
            TextFormField(
              controller: _levelId,
              maxLength: 80,
              decoration: InputDecoration(
                labelText: strings.text('editor.levelId'),
                border: const OutlineInputBorder(),
              ),
              validator: (value) =>
                  value == null ||
                      !RegExp(r'^[a-z0-9_\-]{3,80}$').hasMatch(value)
                  ? strings.text('editor.invalid', <String, Object?>{
                      'error': strings.text('editor.levelId'),
                    })
                  : null,
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              initialValue: _moduleId,
              decoration: InputDecoration(
                labelText: strings.text('editor.module'),
                border: const OutlineInputBorder(),
              ),
              items: <DropdownMenuItem<String>>[
                for (final entry in PuzzleCatalog.entries)
                  DropdownMenuItem(
                    value: entry.module.id,
                    child: Text(strings.text(entry.module.titleKey)),
                  ),
              ],
              onChanged: (value) {
                if (value != null) setState(() => _moduleId = value);
              },
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<PuzzleDifficulty>(
              initialValue: _difficulty,
              decoration: InputDecoration(
                labelText: strings.text('catalog.chooseDifficulty'),
                border: const OutlineInputBorder(),
              ),
              items: <DropdownMenuItem<PuzzleDifficulty>>[
                for (final value in PuzzleDifficulty.values)
                  DropdownMenuItem(
                    value: value,
                    child: Text(strings.text(value.localizationKey)),
                  ),
              ],
              onChanged: (value) {
                if (value != null) setState(() => _difficulty = value);
              },
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _seed,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: strings.text('editor.seed'),
                border: const OutlineInputBorder(),
              ),
              validator: (value) => int.tryParse(value ?? '') == null
                  ? strings.text('editor.invalid', <String, Object?>{
                      'error': strings.text('editor.seed'),
                    })
                  : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _tags,
              maxLength: 160,
              decoration: InputDecoration(
                labelText: strings.text('editor.tags'),
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: <Widget>[
                Expanded(
                  child: TextFormField(
                    controller: _position,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: strings.text('editor.position'),
                      border: const OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: _reward,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: strings.text('editor.reward'),
                      border: const OutlineInputBorder(),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: <Widget>[
                FilledButton.icon(
                  onPressed: _generateAndValidate,
                  icon: const Icon(Icons.verified_outlined),
                  label: Text(strings.text('common.validate')),
                ),
                OutlinedButton.icon(
                  onPressed: _level == null ? null : _preview,
                  icon: const Icon(Icons.visibility_outlined),
                  label: Text(strings.text('common.preview')),
                ),
                OutlinedButton.icon(
                  onPressed: _import,
                  icon: const Icon(Icons.download_rounded),
                  label: Text(strings.text('common.import')),
                ),
                OutlinedButton.icon(
                  onPressed: _level == null ? null : _export,
                  icon: const Icon(Icons.upload_rounded),
                  label: Text(strings.text('common.save')),
                ),
              ],
            ),
            if (_statusKey != null) ...<Widget>[
              const SizedBox(height: 16),
              Card(
                color: _statusKey == 'editor.valid'
                    ? Theme.of(context).colorScheme.primaryContainer
                    : Theme.of(context).colorScheme.errorContainer,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(strings.text(_statusKey!, _statusArguments)),
                ),
              ),
            ],
            const SizedBox(height: 16),
            TextField(
              controller: _json,
              minLines: 10,
              maxLines: 24,
              decoration: InputDecoration(
                labelText: strings.text('editor.json'),
                border: const OutlineInputBorder(),
                alignLabelWithHint: true,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _generateAndValidate() {
    if (!_formKey.currentState!.validate()) return;
    if (_knownIds.contains(_levelId.text)) {
      setState(() => _statusKey = 'editor.duplicate');
      return;
    }
    try {
      final entry = PuzzleCatalog.byId(_moduleId);
      final seed = int.parse(_seed.text);
      final state = entry.module.generate(seed: seed, difficulty: _difficulty);
      final verification = entry.module.verify(state);
      if (!verification.isValid)
        throw FormatException(verification.message ?? 'verification');
      final level = <String, Object?>{
        'schemaVersion': 1,
        'id': _levelId.text,
        'moduleId': _moduleId,
        'moduleVersion': entry.module.version,
        'difficulty': _difficulty.name,
        'seed': seed,
        'localization': <String, Object?>{
          'titleKey': 'level.${_levelId.text}.title',
          'reviewedLocales': <String>[],
        },
        'tags': _tags.text
            .split(',')
            .map((tag) => tag.trim())
            .where((tag) => tag.isNotEmpty)
            .toList(),
        'campaignPosition': int.tryParse(_position.text) ?? 0,
        'challengeReward': int.tryParse(_reward.text) ?? 0,
        'state': state.toJson(),
      };
      _knownIds.add(_levelId.text);
      _level = level;
      _json.text = const JsonEncoder.withIndent('  ').convert(level);
      setState(() {
        _statusKey = 'editor.valid';
        _statusArguments = const <String, Object?>{};
      });
    } catch (error) {
      setState(() {
        _statusKey = 'editor.invalid';
        _statusArguments = <String, Object?>{'error': error};
      });
    }
  }

  void _import() {
    try {
      final decoded = jsonDecode(_json.text);
      if (decoded is! Map) throw const FormatException('object');
      final level = Map<String, Object?>.from(decoded);
      if (level['schemaVersion'] != 1 ||
          level['id'] is! String ||
          level['moduleId'] is! String ||
          level['difficulty'] is! String ||
          level['seed'] is! int ||
          level['state'] is! Map) {
        throw const FormatException('schema');
      }
      final id = level['id']! as String;
      if (_knownIds.contains(id)) {
        setState(() => _statusKey = 'editor.duplicate');
        return;
      }
      final entry = PuzzleCatalog.byId(level['moduleId']! as String);
      if (level['moduleVersion'] != entry.module.version)
        throw const FormatException('module version');
      entry.module.deserialize(
        Map<String, Object?>.from(level['state']! as Map),
      );
      _knownIds.add(id);
      _level = level;
      _levelId.text = id;
      _moduleId = entry.module.id;
      _difficulty = PuzzleDifficultyX.parse(level['difficulty']);
      _seed.text = '${level['seed']}';
      setState(() => _statusKey = 'editor.valid');
    } catch (error) {
      setState(() {
        _statusKey = 'editor.invalid';
        _statusArguments = <String, Object?>{'error': error};
      });
    }
  }

  void _export() {
    if (_level == null) return;
    _json.text = const JsonEncoder.withIndent('  ').convert(_level);
    setState(() => _statusKey = 'editor.valid');
  }

  Future<void> _preview() async {
    final level = _level;
    if (level == null) return;
    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(context.strings.text('common.preview')),
        content: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 560),
          child: SingleChildScrollView(
            child: SelectableText(
              const JsonEncoder.withIndent('  ').convert(level),
            ),
          ),
        ),
        actions: <Widget>[
          FilledButton(
            onPressed: () => Navigator.pop(context),
            child: Text(context.strings.text('common.done')),
          ),
        ],
      ),
    );
  }

  void _newLevel() {
    _level = null;
    _statusKey = null;
    _json.clear();
    _levelId.text =
        'community_level_${(_knownIds.length + 1).toString().padLeft(3, '0')}';
    setState(() {});
  }
}
