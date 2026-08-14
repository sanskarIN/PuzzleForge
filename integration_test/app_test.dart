import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:puzzle_forge/app/app.dart';
import 'package:puzzle_forge/app/app_controller.dart';
import 'package:puzzle_forge/core/services/external_link_service.dart';
import 'package:puzzle_forge/core/storage/app_repository.dart';
import 'package:puzzle_forge/core/storage/key_value_store.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('offline startup and puzzle selection journey', (tester) async {
    final controller = AppController(
      repository: AppRepository(MemoryKeyValueStore()),
      externalLinks: FakeExternalLinkService(),
      clock: () => DateTime.utc(2026, 8, 14),
    );
    await tester.pumpWidget(PuzzleForgeApp(controller: controller));
    await tester.pumpAndSettle();
    expect(find.text('PuzzleForge'), findsWidgets);
    await tester.tap(find.text('Sliding Tiles'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Beginner'));
    await tester.pumpAndSettle();
    expect(find.text('Hint'), findsWidgets);
    expect(controller.activeSession?.module.id, 'sliding_tiles');
    controller.activeSession!.pause();
    await controller.persistSession();
    controller.dispose();
  });
}
