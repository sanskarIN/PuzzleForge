import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:puzzle_forge/app/app.dart';
import 'package:puzzle_forge/app/app_controller.dart';
import 'package:puzzle_forge/core/services/external_link_service.dart';
import 'package:puzzle_forge/core/storage/app_repository.dart';
import 'package:puzzle_forge/core/storage/key_value_store.dart';
import 'package:puzzle_forge/widgets/bmc_support_card.dart';

void main() {
  testWidgets('home renders brand, daily content, puzzles, and support', (
    tester,
  ) async {
    final controller = AppController(
      repository: AppRepository(MemoryKeyValueStore()),
      externalLinks: FakeExternalLinkService(),
      clock: () => DateTime.utc(2026, 8, 14),
    );
    await tester.pumpWidget(PuzzleForgeApp(controller: controller));
    await tester.pumpAndSettle();
    expect(find.text('PuzzleForge'), findsWidgets);
    expect(find.text('Puzzle of the Day'), findsOneWidget);
    expect(find.text('Sliding Tiles'), findsOneWidget);
    await tester.scrollUntilVisible(
      find.text('Support this project — Buy Me a Coffee'),
      500,
    );
    expect(find.text('Support this project — Buy Me a Coffee'), findsOneWidget);
    expect(tester.takeException(), isNull);
    controller.dispose();
  });

  testWidgets('support card launches the allowlisted BMC destination', (
    tester,
  ) async {
    final links = FakeExternalLinkService();
    final controller = AppController(
      repository: AppRepository(MemoryKeyValueStore()),
      externalLinks: links,
    );
    await tester.pumpWidget(PuzzleForgeApp(controller: controller));
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(find.byType(BmcSupportCard), 500);
    await tester.ensureVisible(find.byType(BmcSupportCard));
    await tester.pumpAndSettle();
    await tester.tap(find.byType(BmcSupportCard));
    await tester.pump();
    expect(
      links.opened.single.toString(),
      'https://buymeacoffee.com/sanskarIN',
    );
    controller.dispose();
  });

  testWidgets('catalog flow starts a playable puzzle', (tester) async {
    final controller = AppController(
      repository: AppRepository(MemoryKeyValueStore()),
      externalLinks: FakeExternalLinkService(),
    );
    await tester.pumpWidget(PuzzleForgeApp(controller: controller));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Sliding Tiles'));
    await tester.pumpAndSettle();
    expect(find.text('Choose difficulty'), findsOneWidget);
    await tester.tap(find.text('Medium'));
    await tester.pumpAndSettle();
    expect(find.text('Sliding Tiles'), findsOneWidget);
    expect(find.text('Hint'), findsWidgets);
    expect(controller.activeSession, isNotNull);
    expect(tester.takeException(), isNull);
    controller.dispose();
  });

  testWidgets('settings changes language without reinstalling', (tester) async {
    final controller = AppController(
      repository: AppRepository(MemoryKeyValueStore()),
      externalLinks: FakeExternalLinkService(),
    );
    await tester.pumpWidget(PuzzleForgeApp(controller: controller));
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.settings_outlined));
    await tester.pumpAndSettle();
    expect(find.text('Settings'), findsOneWidget);
    await controller.updateSettings(
      controller.settings.copyWith(localeCode: 'hi'),
    );
    await tester.pumpAndSettle();
    expect(find.text('सेटिंग्स'), findsOneWidget);
    controller.dispose();
  });
}
