import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:puzzle_path/app/app.dart';
import 'package:puzzle_path/app/app_controller.dart';
import 'package:puzzle_path/core/services/external_link_service.dart';
import 'package:puzzle_path/core/storage/app_repository.dart';
import 'package:puzzle_path/core/storage/key_value_store.dart';
import 'package:puzzle_path/puzzles/core/puzzle_models.dart';

void main() {
  testWidgets('Continue resumes a restored paused puzzle', (tester) async {
    final store = MemoryKeyValueStore();
    AppController createController() => AppController(
      repository: AppRepository(store),
      externalLinks: FakeExternalLinkService(),
    );
    final first = createController();
    await first.initialize();
    await first.startPuzzle(
      moduleId: 'number_sequence',
      difficulty: PuzzleDifficulty.easy,
      mode: PlayMode.daily,
    );
    first.activeSession!.pause();
    await first.persistSession();
    first.dispose();

    final restored = createController();
    await tester.pumpWidget(PuzzlePathApp(controller: restored));
    await tester.pumpAndSettle();
    expect(restored.activeSession!.isPaused, isTrue);
    await tester.tap(find.text('Continue last puzzle'));
    await tester.pumpAndSettle();
    final session = restored.activeSession!;
    expect(session.isPaused, isFalse);
    expect(
      session.apply(
        PuzzleAction('choose', <String, Object?>{
          'value': session.state.data['answer'],
        }),
      ),
      isTrue,
    );
    await restored.persistSession();
    await tester.pumpAndSettle();
    expect(find.text('Puzzle solved!'), findsOneWidget);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox());
    restored.dispose();
  });

  testWidgets('background pauses the timer and foreground restores play', (
    tester,
  ) async {
    var now = DateTime(2026, 10, 24, 10);
    final controller = AppController(
      repository: AppRepository(MemoryKeyValueStore()),
      externalLinks: FakeExternalLinkService(),
      clock: () => now,
    );
    await tester.pumpWidget(PuzzlePathApp(controller: controller));
    await tester.pumpAndSettle();
    await controller.startPuzzle(
      moduleId: 'maze',
      difficulty: PuzzleDifficulty.easy,
      mode: PlayMode.daily,
    );
    final session = controller.activeSession!;
    now = now.add(const Duration(seconds: 12));
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.hidden);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
    now = now.add(const Duration(minutes: 5));
    expect(session.isPaused, isTrue);
    expect(session.elapsed, const Duration(seconds: 12));
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    expect(session.isPaused, isFalse);
    now = now.add(const Duration(seconds: 8));
    expect(session.elapsed, const Duration(seconds: 20));

    session.pause();
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    expect(session.isPaused, isTrue, reason: 'A manual pause stays paused');
    await controller.persistSession();
    await tester.pumpWidget(const SizedBox());
    controller.dispose();
  });
}
