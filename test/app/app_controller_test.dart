import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:puzzle_path/app/app_controller.dart';
import 'package:puzzle_path/core/services/external_link_service.dart';
import 'package:puzzle_path/core/storage/app_repository.dart';
import 'package:puzzle_path/core/storage/key_value_store.dart';
import 'package:puzzle_path/puzzles/core/puzzle_models.dart';

class GatedStore extends MemoryKeyValueStore {
  String? blockedKey;
  final started = Completer<void>();
  final released = Completer<void>();
  final finished = Completer<void>();

  @override
  Future<void> write(String key, String value) async {
    if (key == blockedKey) {
      blockedKey = null;
      started.complete();
      await released.future;
      await super.write(key, value);
      finished.complete();
      return;
    }
    await super.write(key, value);
  }
}

void main() {
  test(
    'deletion waits for pending moves and cannot resurrect a save',
    () async {
      final store = GatedStore();
      final controller = AppController(
        repository: AppRepository(store),
        externalLinks: FakeExternalLinkService(),
      );
      await controller.initialize();
      await controller.startPuzzle(
        moduleId: 'number_sequence',
        difficulty: PuzzleDifficulty.easy,
        mode: PlayMode.endless,
      );
      store.blockedKey = 'activeSession';
      final session = controller.activeSession!;
      final answer = session.state.data['answer'];
      final wrong = intList(
        session.state.data['choices'],
      ).firstWhere((choice) => choice != answer);
      session.apply(PuzzleAction('choose', <String, Object?>{'value': wrong}));
      await store.started.future;
      final deletion = controller.deleteAllData();
      store.released.complete();
      await deletion;
      await store.finished.future;
      await controller.persistSession();
      expect(store.values, isEmpty);
      expect(controller.activeSession, isNull);
      controller.dispose();
    },
  );

  test(
    'rapid settings changes persist in the order they were requested',
    () async {
      final store = GatedStore()..blockedKey = 'settings';
      final repository = AppRepository(store);
      final controller = AppController(
        repository: repository,
        externalLinks: FakeExternalLinkService(),
      );
      await controller.initialize();
      final first = controller.updateSettings(
        controller.settings.copyWith(localeCode: 'hi'),
      );
      await store.started.future;
      final second = controller.updateSettings(
        controller.settings.copyWith(localeCode: 'en'),
      );
      store.released.complete();
      await Future.wait(<Future<void>>[first, second]);
      expect((await repository.loadSettings()).value.localeCode, 'en');
      controller.dispose();
    },
  );

  test('a replay cannot change the completion already being saved', () async {
    final controller = AppController(
      repository: AppRepository(MemoryKeyValueStore()),
      externalLinks: FakeExternalLinkService(),
    );
    await controller.initialize();
    await controller.startPuzzle(
      moduleId: 'number_sequence',
      difficulty: PuzzleDifficulty.easy,
      mode: PlayMode.daily,
    );
    final session = controller.activeSession!;
    session.apply(
      PuzzleAction('choose', <String, Object?>{
        'value': session.state.data['answer'],
      }),
    );
    session.restart();
    await controller.persistSession();
    expect(controller.progress.history.single.moves, 1);
    expect(controller.progress.history.single.hintsUsed, 0);
    controller.dispose();
  });

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
    expect(second.activeSession!.isPaused, isTrue);
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
