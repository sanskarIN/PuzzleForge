import 'package:flutter/material.dart';

import '../app/controller_scope.dart';
import '../core/localization/app_localizations.dart';
import '../features/settings/app_settings.dart';

class DeveloperOptionsScreen extends StatelessWidget {
  const DeveloperOptionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = ControllerScope.of(context);
    final settings = controller.settings;
    return Scaffold(
      appBar: AppBar(title: Text(context.strings.text('developer.title'))),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: <Widget>[
          Card(
            color: Theme.of(context).colorScheme.tertiaryContainer,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Text(context.strings.text('developer.warning')),
            ),
          ),
          SwitchListTile(
            secondary: const Icon(Icons.monitor_heart_outlined),
            title: Text(context.strings.text('developer.overlay')),
            value: settings.performanceOverlay,
            onChanged: (value) => controller.updateSettings(
              settings.copyWith(performanceOverlay: value),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.casino_outlined),
            title: Text(context.strings.text('developer.seed')),
            subtitle: TextFormField(
              initialValue: settings.deterministicSeed,
              maxLength: 80,
              onFieldSubmitted: (value) => controller.updateSettings(
                settings.copyWith(deterministicSeed: value.trim()),
              ),
              decoration: const InputDecoration(border: OutlineInputBorder()),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.translate_rounded),
            title: Text(context.strings.text('developer.localization')),
            subtitle: Text(
              '${context.strings.locale.toLanguageTag()} · ${context.strings.formatDate(DateTime.now())}',
            ),
          ),
          ListTile(
            leading: const Icon(Icons.data_object_rounded),
            title: Text(context.strings.text('developer.state')),
            subtitle: SelectableText(
              controller.activeSession?.toJson().toString() ?? '—',
            ),
          ),
          ListTile(
            leading: const Icon(Icons.science_outlined),
            title: Text(context.strings.text('developer.testData')),
            subtitle: Text(context.strings.text('developer.warning')),
          ),
          ListTile(
            leading: const Icon(Icons.restart_alt_rounded),
            title: Text(context.strings.text('developer.reset')),
            subtitle: Text(context.strings.text('settings.restoreDefaults')),
            onTap: () => controller.updateSettings(
              const AppSettings(developerOptionsUnlocked: true),
            ),
          ),
        ],
      ),
    );
  }
}
