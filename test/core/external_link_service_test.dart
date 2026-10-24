import 'package:flutter_test/flutter_test.dart';
import 'package:puzzle_path/core/constants/app_links.dart';
import 'package:puzzle_path/core/services/external_link_service.dart';

void main() {
  test('opens every registered creator and support destination', () async {
    final opened = <Uri>[];
    final service = SafeExternalLinkService(
      launcher: (uri) async {
        opened.add(uri);
        return true;
      },
    );
    for (final destination in AppLinks.destinations) {
      expect(await service.open(destination), isTrue);
    }
    expect(opened, unorderedEquals(AppLinks.destinations));
  });

  test('rejects modified links before invoking the launcher', () async {
    final opened = <Uri>[];
    final service = SafeExternalLinkService(
      launcher: (uri) async {
        opened.add(uri);
        return true;
      },
    );
    for (final value in <String>[
      'http://buymeacoffee.com/SanskarCodes',
      'https://buymeacoffee.com/someone-else',
      'https://paypal.me/SanskarCodes?amount=1000',
      'https://paypal.me/SanskarCodes#redirect',
      'https://user:password@razorpay.me/@SanskarCodes',
      'https://razorpay.me:8443/@SanskarCodes',
      'https://sanskarin.github.io.evil.example',
      'https://github.com/another-user',
      'mailto:someone-else@example.com',
      'mailto:sanskarcodes@gmail.com?bcc=someone-else@example.com',
      'javascript:alert(1)',
      'file:///private',
    ]) {
      expect(await service.open(Uri.parse(value)), isFalse, reason: value);
    }
    expect(opened, isEmpty);
  });

  test('returns a recoverable failure if no external handler opens', () async {
    final unavailable = SafeExternalLinkService(launcher: (_) async => false);
    final failed = SafeExternalLinkService(
      launcher: (_) async => throw Exception('No external handler'),
    );
    expect(await unavailable.open(AppLinks.website), isFalse);
    expect(await failed.open(AppLinks.mainEmail), isFalse);
  });
}
