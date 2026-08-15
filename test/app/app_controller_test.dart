import 'package:flutter_test/flutter_test.dart';
import 'package:puzzle_forge/app/app_controller.dart';
import 'package:puzzle_forge/core/services/external_link_service.dart';
import 'package:puzzle_forge/core/storage/app_repository.dart';
import 'package:puzzle_forge/core/storage/key_value_store.dart';
import 'package:puzzle_forge/puzzles/core/puzzle_models.dart';

void main() {
  test('app controller persists and restores an active session', () async {
    final store = MemoryKeyValueStore();
    final first = AppController(
      repository: AppRepository(store),
      externalLinks: FakeExternalLinkService(),
      clock: () => DateTime.utc(2026, 8, 14),
    );
    await first.initialize();
    await first.startPuzzle(
      moduleId: 'maze',
      difficulty: PuzzleDifficulty.easy,
      mode: PlayMode.daily,
    );
    final action = first.activeSession!.module
        .legalActions(first.activeSession!.state)
        .first;
    first.activeSession!.apply(action);
    await first.persistSession();

    final second = AppController(
      repository: AppRepository(store),
      externalLinks: FakeExternalLinkService(),
      clock: () => DateTime.utc(2026, 8, 14),
    );
    await second.initialize();
    expect(second.activeSession, isNotNull);
    expect(second.activeSession!.state, first.activeSession!.state);
    expect(second.activeSession!.seed, first.activeSession!.seed);
    first.dispose();
    second.dispose();
  });

  test(
    'solved completion is awarded once and clears the saved session',
    () async {
      final store = MemoryKeyValueStore();
      final controller = AppController(
        repository: AppRepository(store),
        externalLinks: FakeExternalLinkService(),
        clock: () => DateTime.utc(2026, 8, 14),
      );
      await controller.initialize();
      await controller.startPuzzle(
        moduleId: 'number_sequence',
        difficulty: PuzzleDifficulty.beginner,
        mode: PlayMode.daily,
      );
      final hint = controller.activeSession!.requestHint().hint!;
      controller.activeSession!.apply(hint.suggestedAction!);
      await Future<void>.delayed(Duration.zero);
      await Future<void>.delayed(Duration.zero);
      expect(controller.progress.history, hasLength(1));
      final xp = controller.progress.xp;
      expect(
        controller.progress.award(
          controller.progress.history.single,
          isDaily: true,
        ),
        isFalse,
      );
      expect(controller.progress.xp, xp);
      expect(
        await AppRepository(store).loadSession(),
        isA<LoadResult<Map<String, Object?>?>>(),
      );
      expect((await AppRepository(store).loadSession()).value, isNull);
      controller.dispose();
    },
  );
}
