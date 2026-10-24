import 'package:url_launcher/url_launcher.dart';

import '../constants/app_links.dart';

abstract interface class ExternalLinkService {
  Future<bool> open(Uri uri);
}

class SafeExternalLinkService implements ExternalLinkService {
  SafeExternalLinkService({Future<bool> Function(Uri)? launcher})
    : _launcher = launcher ?? _launch;

  final Future<bool> Function(Uri) _launcher;

  static Future<bool> _launch(Uri uri) =>
      launchUrl(uri, mode: LaunchMode.externalApplication);

  @override
  Future<bool> open(Uri uri) async {
    if (!AppLinks.destinations.contains(uri)) return false;
    try {
      return await _launcher(uri);
    } on Exception {
      return false;
    }
  }
}

class FakeExternalLinkService implements ExternalLinkService {
  FakeExternalLinkService({this.shouldSucceed = true});

  final bool shouldSucceed;
  final List<Uri> opened = <Uri>[];

  @override
  Future<bool> open(Uri uri) async {
    opened.add(uri);
    return shouldSucceed;
  }
}
