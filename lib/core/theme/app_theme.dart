import 'package:flutter/material.dart';

import '../../features/settings/app_settings.dart';

class AppTheme {
  const AppTheme._();

  static ThemeData light(AppSettings settings) =>
      _build(Brightness.light, settings);

  static ThemeData dark(AppSettings settings) =>
      _build(Brightness.dark, settings);

  static ThemeData _build(Brightness brightness, AppSettings settings) {
    final seed = switch (settings.gameTheme) {
      'ocean' => const Color(0xff0369a1),
      'forest' => const Color(0xff15803d),
      'mono' => const Color(0xff475569),
      _ => const Color(0xff4f46e5),
    };
    var scheme = ColorScheme.fromSeed(seedColor: seed, brightness: brightness);
    if (settings.highContrast) {
      scheme = scheme.copyWith(
        surface: brightness == Brightness.light ? Colors.white : Colors.black,
        onSurface: brightness == Brightness.light ? Colors.black : Colors.white,
        outline: brightness == Brightness.light ? Colors.black : Colors.white,
      );
    }
    final base = ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      brightness: brightness,
    );
    final textTheme = settings.dyslexiaFriendly
        ? base.textTheme
              .apply(fontSizeFactor: 1.04)
              .copyWith(
                bodyLarge: base.textTheme.bodyLarge?.copyWith(
                  height: 1.55,
                  letterSpacing: 0.35,
                ),
                bodyMedium: base.textTheme.bodyMedium?.copyWith(
                  height: 1.55,
                  letterSpacing: 0.35,
                ),
              )
        : base.textTheme;
    return base.copyWith(
      textTheme: textTheme,
      scaffoldBackgroundColor: scheme.surface,
      cardTheme: CardThemeData(
        elevation: settings.highContrast ? 0 : 1,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(
            color: scheme.outlineVariant,
            width: settings.highContrast ? 2 : 1,
          ),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size(48, 48),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(48, 48),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
      iconButtonTheme: const IconButtonThemeData(
        style: ButtonStyle(
          minimumSize: WidgetStatePropertyAll<Size>(Size(48, 48)),
        ),
      ),
      pageTransitionsTheme: settings.reducedMotion
          ? const PageTransitionsTheme(
              builders: <TargetPlatform, PageTransitionsBuilder>{
                TargetPlatform.android: _NoMotionPageTransitionsBuilder(),
              },
            )
          : const PageTransitionsTheme(),
    );
  }
}

class _NoMotionPageTransitionsBuilder extends PageTransitionsBuilder {
  const _NoMotionPageTransitionsBuilder();

  @override
  Widget buildTransitions<T>(
    PageRoute<T> route,
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) => child;
}
