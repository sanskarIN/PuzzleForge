import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import '../core/localization/app_localizations.dart';
import '../core/theme/app_theme.dart';
import '../features/gameplay/puzzle_session_controller.dart';
import '../features/settings/app_settings.dart';
import '../screens/home_screen.dart';
import '../screens/splash_screen.dart';
import 'app_controller.dart';
import 'controller_scope.dart';

class PuzzlePathApp extends StatefulWidget {
  const PuzzlePathApp({required this.controller, super.key});

  final AppController controller;

  @override
  State<PuzzlePathApp> createState() => _PuzzlePathAppState();
}

class _PuzzlePathAppState extends State<PuzzlePathApp>
    with WidgetsBindingObserver {
  PuzzleSessionController? _lifecyclePausedSession;

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
        state == AppLifecycleState.hidden ||
        state == AppLifecycleState.detached) {
      final session = widget.controller.activeSession;
      if (session != null && !session.isPaused && !session.state.solved) {
        _lifecyclePausedSession = session;
        session.pause();
      }
      widget.controller.persistSession();
    } else if (state == AppLifecycleState.resumed) {
      final session = _lifecyclePausedSession;
      _lifecyclePausedSession = null;
      if (identical(session, widget.controller.activeSession)) {
        session?.resume();
      }
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
            title: 'Puzzle Path',
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
