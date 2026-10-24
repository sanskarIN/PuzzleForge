import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../app/controller_scope.dart';
import '../core/localization/app_localizations.dart';

Future<void> openExternalLink(BuildContext context, Uri uri) async {
  final opened = await ControllerScope.read(context).openExternal(uri);
  if (!context.mounted || opened) return;
  final strings = context.strings;
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text('${strings.text('support.openFailed')}\n$uri'),
      action: SnackBarAction(
        label: strings.text('common.copy'),
        onPressed: () => Clipboard.setData(ClipboardData(text: uri.toString())),
      ),
    ),
  );
}

class ExternalLinkTile extends StatelessWidget {
  const ExternalLinkTile({
    required this.icon,
    required this.label,
    required this.uri,
    super.key,
  });

  final IconData icon;
  final String label;
  final Uri uri;

  @override
  Widget build(BuildContext context) => Card(
    child: ListTile(
      leading: Icon(icon),
      title: Text(label),
      subtitle: Text(uri.scheme == 'mailto' ? uri.path : uri.toString()),
      trailing: const Icon(Icons.open_in_new_rounded),
      onTap: () => openExternalLink(context, uri),
    ),
  );
}
