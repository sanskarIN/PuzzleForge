import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/widgets.dart';
import 'package:puzzle_forge/core/localization/app_localizations.dart';

void main() {
  test('English and Hindi catalogs have identical keys', () {
    expect(
      AppLocalizations.hindiKeys.difference(AppLocalizations.englishKeys),
      isEmpty,
    );
    expect(
      AppLocalizations.englishKeys.difference(AppLocalizations.hindiKeys),
      isEmpty,
    );
    expect(AppLocalizations.englishKeys.length, greaterThan(180));
  });

  test('missing keys fall back to the key without throwing', () {
    expect(
      AppLocalizations(const Locale('hi')).text('missing.example'),
      'missing.example',
    );
  });

  test('arguments and plurals are substituted', () {
    final strings = AppLocalizations(const Locale('en'));
    expect(
      strings.text('home.level', <String, Object?>{'level': 3}),
      'Level 3',
    );
    expect(strings.plural('count.puzzles', 1), '1 puzzle');
    expect(strings.plural('count.puzzles', 4), '4 puzzles');
  });

  test('pseudolocalization expands and marks translated text', () {
    final strings = AppLocalizations(const Locale('en', 'XA'));
    final value = strings.text('home.level', <String, Object?>{'level': 12});
    expect(value, startsWith('⟦'));
    expect(value, endsWith('···⟧'));
    expect(value, contains('12'));
    expect(value, isNot('Level 12'));
  });
}
