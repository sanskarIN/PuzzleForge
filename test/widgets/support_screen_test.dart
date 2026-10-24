import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:puzzle_path/app/app_controller.dart';
import 'package:puzzle_path/app/controller_scope.dart';
import 'package:puzzle_path/core/constants/app_links.dart';
import 'package:puzzle_path/core/localization/app_localizations.dart';
import 'package:puzzle_path/core/services/external_link_service.dart';
import 'package:puzzle_path/core/storage/app_repository.dart';
import 'package:puzzle_path/core/storage/key_value_store.dart';
import 'package:puzzle_path/screens/support_screen.dart';
import 'package:puzzle_path/widgets/bmc_support_card.dart';
import 'package:puzzle_path/widgets/external_link_tile.dart';

Future<AppController> showSupport(
  WidgetTester tester,
  FakeExternalLinkService links, {
  Locale locale = const Locale('en'),
  double textScale = 1,
}) async {
  final controller = AppController(
    repository: AppRepository(MemoryKeyValueStore()),
    externalLinks: links,
  );
  await controller.initialize();
  await tester.pumpWidget(
    ControllerScope(
      controller: controller,
      child: MaterialApp(
        locale: locale,
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: const <LocalizationsDelegate<dynamic>>[
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(
            context,
          ).copyWith(textScaler: TextScaler.linear(textScale)),
          child: child!,
        ),
        home: const SupportScreen(),
      ),
    ),
  );
  await tester.pumpAndSettle();
  return controller;
}

void main() {
  testWidgets('support actions launch the requested destinations', (
    tester,
  ) async {
    final links = FakeExternalLinkService();
    final controller = await showSupport(tester, links);
    await tester.tap(find.byType(BmcSupportCard));
    for (final uri in <Uri>[
      AppLinks.razorpay,
      AppLinks.paypal,
      AppLinks.website,
      AppLinks.mainEmail,
      AppLinks.businessEmail,
    ]) {
      final tile = find.byWidgetPredicate(
        (widget) => widget is ExternalLinkTile && widget.uri == uri,
      );
      await tester.scrollUntilVisible(
        tile,
        200,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.ensureVisible(tile);
      await tester.pumpAndSettle();
      await tester.tap(tile);
      await tester.pump();
    }
    expect(links.opened, <Uri>[
      AppLinks.buyMeACoffee,
      AppLinks.razorpay,
      AppLinks.paypal,
      AppLinks.website,
      AppLinks.mainEmail,
      AppLinks.businessEmail,
    ]);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox());
    controller.dispose();
  });

  testWidgets('failed launch offers the exact destination for copying', (
    tester,
  ) async {
    String? copied;
    tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
      SystemChannels.platform,
      (call) async {
        if (call.method == 'Clipboard.setData') {
          copied = (call.arguments as Map)['text'] as String;
        }
        return null;
      },
    );
    addTearDown(
      () => tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
        SystemChannels.platform,
        null,
      ),
    );
    final controller = await showSupport(
      tester,
      FakeExternalLinkService(shouldSucceed: false),
    );
    await tester.tap(find.byType(BmcSupportCard));
    await tester.pumpAndSettle();
    expect(find.byType(SnackBar), findsOneWidget);
    await tester.tap(find.text('Copy'));
    await tester.pump();
    expect(copied, AppLinks.buyMeACoffee.toString());
    await tester.pumpWidget(const SizedBox());
    controller.dispose();
  });

  testWidgets('Hindi support remains usable on a narrow screen at large text', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final controller = await showSupport(
      tester,
      FakeExternalLinkService(),
      locale: const Locale('hi'),
      textScale: 2,
    );
    await tester.scrollUntilVisible(find.text('व्यावसायिक पूछताछ'), 250);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox());
    controller.dispose();
  });
}
