import 'dart:ui' show SemanticsAction;

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:puzzle_forge/app/app_controller.dart';
import 'package:puzzle_forge/app/controller_scope.dart';
import 'package:puzzle_forge/core/localization/app_localizations.dart';
import 'package:puzzle_forge/core/services/external_link_service.dart';
import 'package:puzzle_forge/core/storage/app_repository.dart';
import 'package:puzzle_forge/core/storage/key_value_store.dart';
import 'package:puzzle_forge/widgets/bmc_support_card.dart';

void main() {
  testWidgets(
    'BMC component has accessible link semantics and a large tap target',
    (tester) async {
      final controller = AppController(
        repository: AppRepository(MemoryKeyValueStore()),
        externalLinks: FakeExternalLinkService(),
      );
      await controller.initialize();
      await tester.pumpWidget(
        ControllerScope(
          controller: controller,
          child: const MaterialApp(
            locale: Locale('en'),
            localizationsDelegates: <LocalizationsDelegate<dynamic>>[
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: AppLocalizations.supportedLocales,
            home: Scaffold(body: BmcSupportCard()),
          ),
        ),
      );
      final semantics = tester.getSemantics(find.byType(BmcSupportCard));
      expect(semantics.label, contains('Support Sanskar on Buy Me a Coffee'));
      expect(
        semantics.getSemanticsData().hasAction(SemanticsAction.tap),
        isTrue,
      );
      expect(
        tester.getSize(find.byType(BmcSupportCard)).height,
        greaterThanOrEqualTo(48),
      );
      controller.dispose();
    },
  );
}
