import 'package:url_launcher/url_launcher.dart';

abstract interface class ExternalLinkService {
  Future<bool> open(Uri uri);
}

class SafeExternalLinkService implements ExternalLinkService {
  static const allowedHttpsHosts = <String>{
    'github.com',
    'www.github.com',
    'buymeacoffee.com',
  };
  static const allowedEmails = <String>{
    'supportramsandesh@gmail.com',
    'sanskarin@outlook.in',
    'sanskarin.business@gmail.com',
  };

  @override
  Future<bool> open(Uri uri) async {
    if (!_isAllowed(uri)) return false;
    try {
      if (!await canLaunchUrl(uri)) return false;
      return await launchUrl(uri, mode: LaunchMode.externalApplication);
    } on Exception {
      return false;
    }
  }

  bool _isAllowed(Uri uri) {
    if (uri.scheme == 'https')
      return allowedHttpsHosts.contains(uri.host.toLowerCase());
    if (uri.scheme == 'mailto') {
      final address = uri.path.toLowerCase();
      return allowedEmails.contains(address) && uri.host.isEmpty;
    }
    return false;
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
