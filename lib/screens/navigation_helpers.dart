import 'package:flutter/material.dart';

import '../app/controller_scope.dart';
import '../core/localization/app_localizations.dart';
import '../puzzles/core/puzzle_models.dart';
import '../puzzles/puzzle_catalog.dart';
import 'game_screen.dart';

Future<void> openPuzzle(
  BuildContext context,
  PuzzleCatalogEntry entry, {
  PlayMode mode = PlayMode.endless,
  PuzzleDifficulty? fixedDifficulty,
}) async {
  final difficulty =
      fixedDifficulty ?? await showDifficultySheet(context, entry);
  if (difficulty == null || !context.mounted) return;
  await ControllerScope.read(
    context,
  ).startPuzzle(moduleId: entry.module.id, difficulty: difficulty, mode: mode);
  if (!context.mounted) return;
  await Navigator.of(
    context,
  ).push(MaterialPageRoute<void>(builder: (_) => const GameScreen()));
}

Future<PuzzleDifficulty?> showDifficultySheet(
  BuildContext context,
  PuzzleCatalogEntry entry,
) {
  final strings = context.strings;
  return showModalBottomSheet<PuzzleDifficulty>(
    context: context,
    showDragHandle: true,
    isScrollControlled: true,
    builder: (context) => SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Text(
              strings.text('catalog.chooseDifficulty'),
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 6),
            Text(strings.text(entry.module.rulesKey)),
            const SizedBox(height: 16),
            for (final difficulty in PuzzleDifficulty.values)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  tileColor: Theme.of(context).colorScheme.surfaceContainer,
                  leading: CircleAvatar(child: Text('${difficulty.rank}')),
                  title: Text(strings.text(difficulty.localizationKey)),
                  trailing: const Icon(Icons.arrow_forward_rounded),
                  onTap: () => Navigator.pop(context, difficulty),
                ),
              ),
          ],
        ),
      ),
    ),
  );
}
