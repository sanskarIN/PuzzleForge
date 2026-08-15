import 'package:flutter/material.dart';

import '../app/controller_scope.dart';
import '../core/localization/app_localizations.dart';
import '../features/settings/app_settings.dart';
import 'developer_options_screen.dart';
import 'support_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  int _versionTaps = 0;

  @override
  Widget build(BuildContext context) {
    final controller = ControllerScope.of(context);
    final settings = controller.settings;
    final strings = context.strings;
    return Scaffold(
      appBar: AppBar(title: Text(strings.text('settings.title'))),
      body: ListView(
        padding: const EdgeInsets.only(bottom: 32),
        children: <Widget>[
          _Header(strings.text('settings.appearance')),
          ListTile(
            leading: const Icon(Icons.brightness_6_outlined),
            title: Text(strings.text('settings.theme')),
            trailing: DropdownButton<AppThemePreference>(
              value: settings.theme,
              onChanged: (value) {
                if (value != null)
                  controller.updateSettings(settings.copyWith(theme: value));
              },
              items: <DropdownMenuItem<AppThemePreference>>[
                for (final value in AppThemePreference.values)
                  DropdownMenuItem(
                    value: value,
                    child: Text(strings.text('settings.theme.${value.name}')),
                  ),
              ],
            ),
          ),
          ListTile(
            leading: const Icon(Icons.palette_outlined),
            title: Text(strings.text('settings.gameTheme')),
            trailing: DropdownButton<String>(
              value: settings.gameTheme,
              onChanged: (value) {
                if (value != null)
                  controller.updateSettings(
                    settings.copyWith(gameTheme: value),
                  );
              },
              items: <DropdownMenuItem<String>>[
                for (final value in const <String>[
                  'forge',
                  'ocean',
                  'forest',
                  'mono',
                ])
                  DropdownMenuItem(
                    value: value,
                    child: Text(strings.text('theme.$value')),
                  ),
              ],
            ),
          ),
          SwitchListTile(
            secondary: const Icon(Icons.motion_photos_off_outlined),
            title: Text(strings.text('settings.reducedMotion')),
            value: settings.reducedMotion,
            onChanged: (value) => controller.updateSettings(
              settings.copyWith(reducedMotion: value),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.speed_rounded),
            title: Text(strings.text('settings.animationSpeed')),
            subtitle: Slider(
              value: settings.animationSpeed,
              min: 0.5,
              max: 2,
              divisions: 6,
              label: '${settings.animationSpeed}×',
              onChanged: settings.reducedMotion
                  ? null
                  : (value) => controller.updateSettings(
                      settings.copyWith(animationSpeed: value),
                    ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.animation_rounded),
            title: Text(strings.text('settings.animationQuality')),
            trailing: DropdownButton<AnimationQuality>(
              value: settings.animationQuality,
              onChanged: (value) {
                if (value != null) {
                  controller.updateSettings(
                    settings.copyWith(animationQuality: value),
                  );
                }
              },
              items: <DropdownMenuItem<AnimationQuality>>[
                for (final value in AnimationQuality.values)
                  DropdownMenuItem(
                    value: value,
                    child: Text(strings.text('settings.quality.${value.name}')),
                  ),
              ],
            ),
          ),
          _Header(strings.text('settings.accessibility')),
          _toggle(
            Icons.contrast_rounded,
            'settings.highContrast',
            settings.highContrast,
            (value) => controller.updateSettings(
              settings.copyWith(highContrast: value),
            ),
          ),
          _toggle(
            Icons.text_fields_rounded,
            'settings.dyslexia',
            settings.dyslexiaFriendly,
            (value) => controller.updateSettings(
              settings.copyWith(dyslexiaFriendly: value),
            ),
          ),
          _toggle(
            Icons.pin_outlined,
            'settings.numericLabels',
            settings.numericLabels,
            (value) => controller.updateSettings(
              settings.copyWith(numericLabels: value),
            ),
          ),
          _Header(strings.text('settings.language')),
          ListTile(
            leading: const Icon(Icons.language_rounded),
            title: Text(strings.text('settings.language')),
            trailing: DropdownButton<String>(
              value: settings.localeCode,
              onChanged: (value) {
                if (value != null)
                  controller.updateSettings(
                    settings.copyWith(localeCode: value),
                  );
              },
              items: <DropdownMenuItem<String>>[
                DropdownMenuItem(
                  value: 'en',
                  child: Text(strings.text('settings.english')),
                ),
                DropdownMenuItem(
                  value: 'hi',
                  child: Text(strings.text('settings.hindi')),
                ),
              ],
            ),
          ),
          _Header(strings.text('settings.sound')),
          _toggle(
            Icons.volume_up_outlined,
            'settings.masterSound',
            settings.masterSound,
            (value) => controller.updateSettings(
              settings.copyWith(masterSound: value),
            ),
          ),
          _toggle(
            Icons.music_note_outlined,
            'settings.music',
            settings.music,
            settings.masterSound
                ? (value) =>
                      controller.updateSettings(settings.copyWith(music: value))
                : null,
          ),
          _toggle(
            Icons.graphic_eq_rounded,
            'settings.effects',
            settings.soundEffects,
            settings.masterSound
                ? (value) => controller.updateSettings(
                    settings.copyWith(soundEffects: value),
                  )
                : null,
          ),
          _toggle(
            Icons.sports_esports_outlined,
            'settings.gameplaySounds',
            settings.gameplaySounds,
            settings.masterSound
                ? (value) => controller.updateSettings(
                    settings.copyWith(gameplaySounds: value),
                  )
                : null,
          ),
          _toggle(
            Icons.vibration_rounded,
            'settings.haptics',
            settings.haptics,
            (value) =>
                controller.updateSettings(settings.copyWith(haptics: value)),
          ),
          _Header(strings.text('settings.performance')),
          _toggle(
            Icons.battery_saver_outlined,
            'settings.battery',
            settings.batterySaver,
            (value) => controller.updateSettings(
              settings.copyWith(batterySaver: value),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.tune_rounded),
            title: Text(strings.text('settings.performanceMode')),
            trailing: DropdownButton<PerformancePreference>(
              value: settings.performance,
              onChanged: (value) {
                if (value != null) {
                  controller.updateSettings(
                    settings.copyWith(performance: value),
                  );
                }
              },
              items: <DropdownMenuItem<PerformancePreference>>[
                for (final value in PerformancePreference.values)
                  DropdownMenuItem(
                    value: value,
                    child: Text(
                      strings.text('settings.performance.${value.name}'),
                    ),
                  ),
              ],
            ),
          ),
          _Header(strings.text('settings.general')),
          _toggle(
            Icons.warning_amber_rounded,
            'settings.confirm',
            settings.confirmDestructiveActions,
            (value) => controller.updateSettings(
              settings.copyWith(confirmDestructiveActions: value),
            ),
          ),
          _toggle(
            Icons.notifications_none_rounded,
            'settings.notifications',
            settings.notifications,
            (value) => controller.updateSettings(
              settings.copyWith(notifications: value),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.school_outlined),
            title: Text(strings.text('settings.tutorialReset')),
            onTap: () => controller.updateSettings(
              settings.copyWith(tutorialCompleted: false),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.restore_rounded),
            title: Text(strings.text('settings.restoreDefaults')),
            onTap: () => controller.updateSettings(
              AppSettings(
                developerOptionsUnlocked: settings.developerOptionsUnlocked,
              ),
            ),
          ),
          _Header(strings.text('settings.data')),
          ListTile(
            leading: const Icon(Icons.upload_file_rounded),
            title: Text(strings.text('settings.export')),
            onTap: _exportBackup,
          ),
          ListTile(
            leading: const Icon(Icons.download_rounded),
            title: Text(strings.text('settings.import')),
            onTap: _importBackup,
          ),
          ListTile(
            leading: const Icon(Icons.history_toggle_off_rounded),
            title: Text(strings.text('settings.clearHistory')),
            onTap: _clearHistory,
          ),
          ListTile(
            leading: const Icon(Icons.cleaning_services_outlined),
            title: Text(strings.text('settings.clearCache')),
            onTap: () => ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(strings.text('data.cacheCleared'))),
            ),
          ),
          ListTile(
            leading: Icon(
              Icons.delete_forever_rounded,
              color: Theme.of(context).colorScheme.error,
            ),
            title: Text(strings.text('settings.deleteAll')),
            onTap: _deleteAll,
          ),
          _Header(strings.text('settings.support')),
          ListTile(
            leading: const Icon(Icons.coffee_rounded),
            title: Text(strings.text('support.bmc')),
            trailing: const Icon(Icons.arrow_forward_rounded),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute<void>(builder: (_) => const SupportScreen()),
            ),
          ),
          _Header(strings.text('settings.about')),
          ListTile(
            leading: const Icon(Icons.info_outline_rounded),
            title: Text(strings.text('about.title')),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute<void>(builder: (_) => const AboutScreen()),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.privacy_tip_outlined),
            title: Text(strings.text('legal.privacy')),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute<void>(
                builder: (_) => const LegalScreen(
                  titleKey: 'legal.privacy',
                  bodyKey: 'about.openSource',
                ),
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.gavel_outlined),
            title: Text(strings.text('legal.terms')),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute<void>(
                builder: (_) => const LegalScreen(
                  titleKey: 'legal.terms',
                  bodyKey: 'legal.review',
                ),
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.receipt_long_outlined),
            title: Text(strings.text('legal.notices')),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute<void>(
                builder: (_) => const LegalScreen(
                  titleKey: 'legal.notices',
                  bodyKey: 'about.openSource',
                ),
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.tag_rounded),
            title: Text(
              strings.text('common.version', <String, Object?>{
                'version': '0.1.0+1',
              }),
            ),
            subtitle: Text(strings.text('app.creator')),
            onTap: _handleVersionTap,
          ),
          if (settings.developerOptionsUnlocked)
            ListTile(
              leading: const Icon(Icons.developer_mode_rounded),
              title: Text(strings.text('settings.developer')),
              trailing: const Icon(Icons.arrow_forward_rounded),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute<void>(
                  builder: (_) => const DeveloperOptionsScreen(),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _toggle(
    IconData icon,
    String key,
    bool value,
    ValueChanged<bool>? onChanged,
  ) {
    return SwitchListTile(
      secondary: Icon(icon),
      title: Text(context.strings.text(key)),
      value: value,
      onChanged: onChanged,
    );
  }

  Future<void> _exportBackup() async {
    final text = ControllerScope.read(context).exportBackup();
    await _jsonDialog(
      titleKey: 'settings.export',
      initial: text,
      readOnly: true,
    );
  }

  Future<void> _importBackup() async {
    final text = await _jsonDialog(
      titleKey: 'settings.import',
      initial: '',
      readOnly: false,
    );
    if (text == null || text.trim().isEmpty || !mounted) return;
    try {
      await ControllerScope.read(context).importBackup(text);
      if (mounted)
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(context.strings.text('data.imported'))),
        );
    } catch (error) {
      if (mounted)
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              context.strings.text('data.invalid', <String, Object?>{
                'error': error,
              }),
            ),
          ),
        );
    }
  }

  Future<String?> _jsonDialog({
    required String titleKey,
    required String initial,
    required bool readOnly,
  }) async {
    final textController = TextEditingController(text: initial);
    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(context.strings.text(titleKey)),
        content: SizedBox(
          width: 640,
          child: TextField(
            controller: textController,
            readOnly: readOnly,
            minLines: 8,
            maxLines: 16,
            decoration: InputDecoration(
              border: const OutlineInputBorder(),
              labelText: context.strings.text('editor.json'),
            ),
          ),
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(context.strings.text('common.cancel')),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, textController.text),
            child: Text(
              context.strings.text(readOnly ? 'common.done' : 'common.import'),
            ),
          ),
        ],
      ),
    );
    textController.dispose();
    return result;
  }

  Future<void> _clearHistory() async {
    await ControllerScope.read(context).clearHistory();
  }

  Future<void> _deleteAll() async {
    final strings = context.strings;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(strings.text('settings.deleteAll')),
        content: Text(strings.text('data.confirmDelete')),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(strings.text('common.cancel')),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(strings.text('common.delete')),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    await ControllerScope.read(context).deleteAllData();
    if (mounted)
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.strings.text('data.deleted'))),
      );
  }

  void _handleVersionTap() {
    final controller = ControllerScope.read(context);
    if (controller.settings.developerOptionsUnlocked) return;
    _versionTaps++;
    final remaining = 7 - _versionTaps;
    if (remaining <= 0) {
      controller.updateSettings(
        controller.settings.copyWith(developerOptionsUnlocked: true),
      );
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.strings.text('settings.unlocked'))),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            context.strings.text('settings.unlockProgress', <String, Object?>{
              'remaining': remaining,
            }),
          ),
          duration: const Duration(milliseconds: 700),
        ),
      );
    }
  }
}

class _Header extends StatelessWidget {
  const _Header(this.label);
  final String label;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(20, 26, 20, 8),
    child: Text(
      label,
      style: Theme.of(context).textTheme.titleSmall?.copyWith(
        color: Theme.of(context).colorScheme.primary,
        fontWeight: FontWeight.w900,
      ),
    ),
  );
}
