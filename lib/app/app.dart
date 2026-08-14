import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import '../core/localization/app_localizations.dart';
import '../core/theme/app_theme.dart';
import '../features/settings/app_settings.dart';
import '../screens/home_screen.dart';
import '../screens/splash_screen.dart';
import 'app_controller.dart';
import 'controller_scope.dart';

class PuzzleForgeApp extends StatefulWidget {
  const PuzzleForgeApp({required this.controller, super.key});

  final AppController controller;

  @override
  State<PuzzleForgeApp> createState() => _PuzzleForgeAppState();
}

class _PuzzleForgeAppState extends State<PuzzleForgeApp>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    widget.controller.initialize();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.inactive ||
        state == AppLifecycleState.paused ||
        state == AppLifecycleState.detached) {
      widget.controller.activeSession?.pause();
      widget.controller.persistSession();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ControllerScope(
      controller: widget.controller,
      child: ListenableBuilder(
        listenable: widget.controller,
        builder: (context, _) {
          final settings = widget.controller.settings;
          return MaterialApp(
            title: 'PuzzleForge',
            debugShowCheckedModeBanner: false,
            locale: Locale(settings.localeCode),
            supportedLocales: AppLocalizations.supportedLocales,
            localizationsDelegates: const <LocalizationsDelegate<dynamic>>[
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            theme: AppTheme.light(settings),
            darkTheme: AppTheme.dark(settings),
            themeMode: switch (settings.theme) {
              AppThemePreference.system => ThemeMode.system,
              AppThemePreference.light => ThemeMode.light,
              AppThemePreference.dark => ThemeMode.dark,
            },
            showPerformanceOverlay:
                settings.developerOptionsUnlocked &&
                settings.performanceOverlay,
            home: widget.controller.initialized
                ? const HomeScreen()
                : const SplashScreen(),
          );
        },
      ),
    );
  }
}
