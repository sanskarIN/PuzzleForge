enum AppThemePreference { system, light, dark }

enum AnimationQuality { low, balanced, high }

enum PerformancePreference { battery, balanced, smooth }

class AppSettings {
  const AppSettings({
    this.theme = AppThemePreference.system,
    this.localeCode = 'en',
    this.gameTheme = 'forge',
    this.animationQuality = AnimationQuality.balanced,
    this.performance = PerformancePreference.balanced,
    this.animationSpeed = 1,
    this.reducedMotion = false,
    this.highContrast = false,
    this.dyslexiaFriendly = false,
    this.numericLabels = true,
    this.masterSound = true,
    this.music = true,
    this.soundEffects = true,
    this.gameplaySounds = true,
    this.haptics = true,
    this.batterySaver = false,
    this.confirmDestructiveActions = true,
    this.notifications = false,
    this.tutorialCompleted = false,
    this.developerOptionsUnlocked = false,
    this.performanceOverlay = false,
    this.deterministicSeed = '',
  });

  final AppThemePreference theme;
  final String localeCode;
  final String gameTheme;
  final AnimationQuality animationQuality;
  final PerformancePreference performance;
  final double animationSpeed;
  final bool reducedMotion;
  final bool highContrast;
  final bool dyslexiaFriendly;
  final bool numericLabels;
  final bool masterSound;
  final bool music;
  final bool soundEffects;
  final bool gameplaySounds;
  final bool haptics;
  final bool batterySaver;
  final bool confirmDestructiveActions;
  final bool notifications;
  final bool tutorialCompleted;
  final bool developerOptionsUnlocked;
  final bool performanceOverlay;
  final String deterministicSeed;

  AppSettings copyWith({
    AppThemePreference? theme,
    String? localeCode,
    String? gameTheme,
    AnimationQuality? animationQuality,
    PerformancePreference? performance,
    double? animationSpeed,
    bool? reducedMotion,
    bool? highContrast,
    bool? dyslexiaFriendly,
    bool? numericLabels,
    bool? masterSound,
    bool? music,
    bool? soundEffects,
    bool? gameplaySounds,
    bool? haptics,
    bool? batterySaver,
    bool? confirmDestructiveActions,
    bool? notifications,
    bool? tutorialCompleted,
    bool? developerOptionsUnlocked,
    bool? performanceOverlay,
    String? deterministicSeed,
  }) {
    return AppSettings(
      theme: theme ?? this.theme,
      localeCode: localeCode ?? this.localeCode,
      gameTheme: gameTheme ?? this.gameTheme,
      animationQuality: animationQuality ?? this.animationQuality,
      performance: performance ?? this.performance,
      animationSpeed: animationSpeed ?? this.animationSpeed,
      reducedMotion: reducedMotion ?? this.reducedMotion,
      highContrast: highContrast ?? this.highContrast,
      dyslexiaFriendly: dyslexiaFriendly ?? this.dyslexiaFriendly,
      numericLabels: numericLabels ?? this.numericLabels,
      masterSound: masterSound ?? this.masterSound,
      music: music ?? this.music,
      soundEffects: soundEffects ?? this.soundEffects,
      gameplaySounds: gameplaySounds ?? this.gameplaySounds,
      haptics: haptics ?? this.haptics,
      batterySaver: batterySaver ?? this.batterySaver,
      confirmDestructiveActions:
          confirmDestructiveActions ?? this.confirmDestructiveActions,
      notifications: notifications ?? this.notifications,
      tutorialCompleted: tutorialCompleted ?? this.tutorialCompleted,
      developerOptionsUnlocked:
          developerOptionsUnlocked ?? this.developerOptionsUnlocked,
      performanceOverlay: performanceOverlay ?? this.performanceOverlay,
      deterministicSeed: deterministicSeed ?? this.deterministicSeed,
    );
  }

  Map<String, Object?> toJson() => <String, Object?>{
    'schemaVersion': 1,
    'theme': theme.name,
    'localeCode': localeCode,
    'gameTheme': gameTheme,
    'animationQuality': animationQuality.name,
    'performance': performance.name,
    'animationSpeed': animationSpeed,
    'reducedMotion': reducedMotion,
    'highContrast': highContrast,
    'dyslexiaFriendly': dyslexiaFriendly,
    'numericLabels': numericLabels,
    'masterSound': masterSound,
    'music': music,
    'soundEffects': soundEffects,
    'gameplaySounds': gameplaySounds,
    'haptics': haptics,
    'batterySaver': batterySaver,
    'confirmDestructiveActions': confirmDestructiveActions,
    'notifications': notifications,
    'tutorialCompleted': tutorialCompleted,
    'developerOptionsUnlocked': developerOptionsUnlocked,
    'performanceOverlay': performanceOverlay,
    'deterministicSeed': deterministicSeed,
  };

  factory AppSettings.fromJson(Map<String, Object?> json) {
    if (json['schemaVersion'] != 1)
      throw const FormatException('Unsupported settings schema');
    T parseEnum<T extends Enum>(List<T> values, String key) {
      final raw = json[key];
      return values.firstWhere(
        (value) => value.name == raw,
        orElse: () => throw FormatException('Invalid $key'),
      );
    }

    bool flag(String key) {
      final value = json[key];
      if (value is! bool) throw FormatException('Invalid $key');
      return value;
    }

    final locale = json['localeCode'];
    final gameTheme = json['gameTheme'];
    final speed = json['animationSpeed'];
    final seed = json['deterministicSeed'];
    if (locale is! String ||
        !const <String>{'en', 'hi'}.contains(locale) ||
        gameTheme is! String ||
        !const <String>{
          'forge',
          'ocean',
          'forest',
          'mono',
        }.contains(gameTheme) ||
        speed is! num ||
        speed < 0.5 ||
        speed > 2 ||
        seed is! String ||
        seed.length > 80) {
      throw const FormatException('Invalid settings value');
    }
    return AppSettings(
      theme: parseEnum(AppThemePreference.values, 'theme'),
      localeCode: locale,
      gameTheme: gameTheme,
      animationQuality: parseEnum(AnimationQuality.values, 'animationQuality'),
      performance: parseEnum(PerformancePreference.values, 'performance'),
      animationSpeed: speed.toDouble(),
      reducedMotion: flag('reducedMotion'),
      highContrast: flag('highContrast'),
      dyslexiaFriendly: flag('dyslexiaFriendly'),
      numericLabels: flag('numericLabels'),
      masterSound: flag('masterSound'),
      music: flag('music'),
      soundEffects: flag('soundEffects'),
      gameplaySounds: flag('gameplaySounds'),
      haptics: flag('haptics'),
      batterySaver: flag('batterySaver'),
      confirmDestructiveActions: flag('confirmDestructiveActions'),
      notifications: flag('notifications'),
      tutorialCompleted: flag('tutorialCompleted'),
      developerOptionsUnlocked: flag('developerOptionsUnlocked'),
      performanceOverlay: flag('performanceOverlay'),
      deterministicSeed: seed,
    );
  }
}
