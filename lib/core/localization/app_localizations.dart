import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';

class AppLocalizations {
  AppLocalizations(this.locale);

  final Locale locale;

  static const supportedLocales = <Locale>[
    Locale('en'),
    Locale('hi'),
    Locale('en', 'XA'),
  ];

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations) ??
        AppLocalizations(const Locale('en'));
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  static Set<String> get englishKeys => _english.keys.toSet();
  static Set<String> get hindiKeys => _hindi.keys.toSet();

  String text(
    String key, [
    Map<String, Object?> arguments = const <String, Object?>{},
  ]) {
    var value =
        (locale.languageCode == 'hi' ? _hindi[key] : _english[key]) ??
        _english[key] ??
        key;
    for (final entry in arguments.entries) {
      value = value.replaceAll('{${entry.key}}', entry.value.toString());
    }
    if (locale.countryCode == 'XA') value = pseudoLocalize(value);
    return value;
  }

  static String pseudoLocalize(String value) {
    const replacements = <String, String>{
      'a': 'á',
      'e': 'é',
      'i': 'í',
      'o': 'ó',
      'u': 'ú',
      'A': 'Á',
      'E': 'É',
      'I': 'Í',
      'O': 'Ó',
      'U': 'Ú',
    };
    final transformed = value
        .split('')
        .map((character) => replacements[character] ?? character)
        .join();
    return '⟦$transformed ···⟧';
  }

  String plural(String key, int count) {
    final suffix = count == 1 ? 'one' : 'other';
    return text('$key.$suffix', <String, Object?>{
      'count': NumberFormat.decimalPattern(
        locale.toLanguageTag(),
      ).format(count),
    });
  }

  String formatDate(DateTime date) =>
      DateFormat.yMMMd(locale.toLanguageTag()).format(date);

  String formatNumber(num value) =>
      NumberFormat.decimalPattern(locale.toLanguageTag()).format(value);

  static const Map<String, String> _english = <String, String>{
    'app.name': 'PuzzleForge',
    'app.tagline': 'Think deeper. Solve smarter.',
    'app.creator': 'Made by the Sanskar',
    'common.back': 'Back',
    'common.cancel': 'Cancel',
    'common.close': 'Close',
    'common.continue': 'Continue',
    'common.copy': 'Copy',
    'common.delete': 'Delete',
    'common.done': 'Done',
    'common.edit': 'Edit',
    'common.error': 'Something went wrong',
    'common.import': 'Import',
    'common.new': 'New',
    'common.off': 'Off',
    'common.on': 'On',
    'common.preview': 'Preview',
    'common.reset': 'Reset',
    'common.retry': 'Retry',
    'common.save': 'Save',
    'common.share': 'Share',
    'common.validate': 'Validate',
    'common.version': 'Version {version}',
    'home.greeting': 'Ready to forge a solution?',
    'home.dailyTitle': 'Puzzle of the Day',
    'home.dailyBody': 'One deterministic challenge, available offline.',
    'home.playDaily': 'Play daily puzzle',
    'home.continueTitle': 'Continue last puzzle',
    'home.allPuzzles': 'Puzzle collection',
    'home.explore': 'Explore all',
    'home.progress': 'Your progress',
    'home.level': 'Level {level}',
    'home.xp': '{xp} XP',
    'home.streak': '{days}-day streak',
    'home.hints': '{count} hints',
    'home.more': 'More ways to play',
    'catalog.title': 'Puzzle categories',
    'catalog.favorite': 'Add to favorites',
    'catalog.unfavorite': 'Remove from favorites',
    'catalog.chooseDifficulty': 'Choose difficulty',
    'catalog.customSeed': 'Custom seed',
    'catalog.start': 'Start puzzle',
    'difficulty.beginner': 'Beginner',
    'difficulty.easy': 'Easy',
    'difficulty.medium': 'Medium',
    'difficulty.hard': 'Hard',
    'difficulty.expert': 'Expert',
    'difficulty.master': 'Master',
    'mode.daily': 'Daily',
    'mode.endless': 'Endless',
    'mode.campaign': 'Campaign',
    'mode.custom': 'Custom seed',
    'category.spatial': 'Spatial',
    'category.numbers': 'Numbers',
    'category.logic': 'Logic',
    'category.path': 'Paths',
    'category.memory': 'Memory',
    'category.sorting': 'Sorting',
    'category.patterns': 'Patterns',
    'puzzle.sliding.title': 'Sliding Tiles',
    'puzzle.sliding.description':
        'Restore the numbered grid by sliding tiles into the empty space.',
    'puzzle.sliding.rules':
        'Tap a tile next to the empty space. Arrange numbers in order with the empty space last.',
    'puzzle.merge.title': 'Number Merge',
    'puzzle.merge.description':
        'Combine equal numbers and build the target tile.',
    'puzzle.merge.rules':
        'Swipe in a direction. Equal tiles merge once per move. Reach the displayed target.',
    'puzzle.lights.title': 'Light Grid',
    'puzzle.lights.description':
        'Turn every light off by toggling connected cells.',
    'puzzle.lights.rules':
        'Tap a cell to toggle it and its orthogonal neighbors. Finish when every cell is dark.',
    'puzzle.maze.title': 'Maze Trail',
    'puzzle.maze.description':
        'Guide the spark through a procedurally carved maze.',
    'puzzle.maze.rules':
        'Use the direction controls or arrow keys to reach the star without crossing walls.',
    'puzzle.sudoku.title': 'Sudoku',
    'puzzle.sudoku.description': 'Complete the classic 9×9 logic grid.',
    'puzzle.sudoku.rules':
        'Fill each row, column, and 3×3 region with 1 through 9. Given cells cannot change.',
    'puzzle.memory.title': 'Memory Match',
    'puzzle.memory.description':
        'Reveal symbols and remember where each pair is hidden.',
    'puzzle.memory.rules':
        'Reveal two cards. Matching symbols stay visible; unmatched cards hide on your next choice.',
    'puzzle.sort.title': 'Color Sort',
    'puzzle.sort.description': 'Separate patterned pieces into uniform tubes.',
    'puzzle.sort.rules':
        'Select a source and destination. Move one top piece onto an empty tube or the same symbol.',
    'puzzle.sequence.title': 'Number Sequence',
    'puzzle.sequence.description':
        'Find the rule and choose the missing number.',
    'puzzle.sequence.rules':
        'Study the five values, infer the pattern, and select the next value.',
    'game.moves': '{count} moves',
    'game.time': '{time}',
    'game.target': 'Target {target}',
    'game.undo': 'Undo',
    'game.redo': 'Redo',
    'game.hint': 'Hint',
    'game.pause': 'Pause',
    'game.resume': 'Resume',
    'game.restart': 'Restart puzzle',
    'game.quit': 'Save and leave',
    'game.paused': 'Puzzle paused',
    'game.pausedBody': 'Your timer is stopped.',
    'game.noHint': 'No hint is available for this state.',
    'game.noTokens': 'You have no hint tokens left.',
    'game.hintRepeated': 'This hint was already shown; no token was charged.',
    'game.unsolvableMove': 'That move is not available.',
    'result.title': 'Puzzle forged!',
    'result.score': '{score} points',
    'result.moves': 'Moves',
    'result.time': 'Time',
    'result.hints': 'Hints used',
    'result.replay': 'Replay',
    'result.next': 'Choose another puzzle',
    'result.reward': 'Progress was saved locally.',
    'hint.sliding.moveTile': 'Move tile {tile} toward the empty space.',
    'hint.lights.toggle': 'Toggle row {row}, column {column}.',
    'hint.memory.reveal': 'Reveal card {position}.',
    'hint.sequence.arithmetic':
        'Look for a constant difference between neighboring numbers.',
    'hint.sequence.sumPrevious':
        'Each value is built from the two values before it.',
    'hint.sequence.quadratic': 'Compare how the differences themselves change.',
    'hint.maze.direction': 'Move {direction}.',
    'hint.sudoku.value': 'Row {row}, column {column} can be {value}.',
    'hint.merge.direction': 'Try moving {direction}.',
    'hint.sort.pour': 'Move the top piece from tube {from} to tube {to}.',
    'direction.up': 'up',
    'direction.down': 'down',
    'direction.left': 'left',
    'direction.right': 'right',
    'accessibility.sliding.board':
        '{size} by {size} board. Empty position {empty}. {moves} moves.',
    'accessibility.lights.board':
        '{lit} of {total} lights are on. {moves} moves.',
    'accessibility.memory.board':
        '{pairs} of {total} pairs found. {moves} moves.',
    'accessibility.sequence.board': 'Sequence {sequence}. {moves} attempts.',
    'accessibility.maze.board':
        'Player row {row}, column {column}. Exit row {exitRow}, column {exitColumn}. {moves} moves.',
    'accessibility.sudoku.board': '{filled} of 81 cells filled. {moves} moves.',
    'accessibility.merge.board':
        'Largest tile {largest}. Target {target}. {moves} moves.',
    'accessibility.sort.board':
        '{completed} of {total} tubes completed. {moves} moves.',
    'settings.title': 'Settings',
    'settings.general': 'General',
    'settings.appearance': 'Appearance',
    'settings.gameplay': 'Gameplay',
    'settings.controls': 'Controls',
    'settings.sound': 'Sound & haptics',
    'settings.accessibility': 'Accessibility',
    'settings.language': 'Language',
    'settings.notifications': 'Notifications',
    'settings.data': 'Data & storage',
    'settings.privacy': 'Privacy',
    'settings.security': 'Security',
    'settings.performance': 'Performance',
    'settings.support': 'Support the project',
    'settings.about': 'About',
    'settings.legal': 'Legal',
    'settings.developer': 'Developer options',
    'settings.theme': 'App theme',
    'settings.theme.system': 'System',
    'settings.theme.light': 'Light',
    'settings.theme.dark': 'Dark',
    'settings.gameTheme': 'Game theme',
    'settings.reducedMotion': 'Reduced motion',
    'settings.highContrast': 'High contrast',
    'settings.dyslexia': 'Dyslexia-friendly spacing',
    'settings.numericLabels': 'Numeric labels',
    'settings.masterSound': 'Master sound',
    'settings.music': 'Music',
    'settings.effects': 'Sound effects',
    'settings.gameplaySounds': 'Individual gameplay sounds',
    'settings.haptics': 'Haptics',
    'settings.battery': 'Battery saver',
    'settings.confirm': 'Confirm destructive actions',
    'settings.tutorialReset': 'Reset tutorial',
    'settings.restoreDefaults': 'Restore defaults',
    'settings.clearHistory': 'Clear history',
    'settings.deleteAll': 'Delete all local data',
    'settings.export': 'Export backup',
    'settings.import': 'Import backup',
    'settings.english': 'English',
    'settings.hindi': 'हिन्दी',
    'settings.animationSpeed': 'Animation speed',
    'settings.animationQuality': 'Animation quality',
    'settings.quality.low': 'Low',
    'settings.quality.balanced': 'Balanced',
    'settings.quality.high': 'High',
    'settings.performanceMode': 'Performance preference',
    'settings.performance.battery': 'Battery',
    'settings.performance.balanced': 'Balanced',
    'settings.performance.smooth': 'Smooth',
    'settings.clearCache': 'Clear cache',
    'settings.unlockProgress':
        'Tap {remaining} more times to unlock developer options.',
    'settings.unlocked': 'Developer options unlocked.',
    'support.title': 'Support PuzzleForge',
    'support.bmc': 'Support this project — Buy Me a Coffee',
    'support.bmcLabel': 'Support Sanskar on Buy Me a Coffee',
    'support.optional':
        'Optional support. Core puzzles stay fair and accessible.',
    'support.openFailed':
        'Could not open the external app. The link is shown below.',
    'support.contact': 'Contact',
    'about.title': 'About PuzzleForge',
    'about.openSource': 'PuzzleForge is open source under the MIT License.',
    'about.repository': 'View source on GitHub',
    'about.creator': 'Creator GitHub profile',
    'about.credits': 'Original design and development by Sanskar.',
    'legal.privacy': 'Privacy policy',
    'legal.terms': 'Terms & conditions',
    'legal.notices': 'Third-party notices',
    'legal.review':
        'Developer-prepared templates require legal review before commercial publication.',
    'menu.title': 'Explore PuzzleForge',
    'menu.dailyChallenges': 'Daily challenges',
    'menu.campaign': 'Campaign',
    'menu.endless': 'Endless mode',
    'menu.favorites': 'Favorites',
    'menu.recent': 'Recently played',
    'menu.completed': 'Completed puzzles',
    'menu.statistics': 'Statistics',
    'menu.achievements': 'Achievements',
    'menu.streak': 'Streak',
    'menu.themes': 'Themes',
    'menu.tutorial': 'Tutorial',
    'menu.guide': 'Guide',
    'menu.editor': 'Puzzle editor',
    'empty.favorites': 'Favorite a puzzle to find it here.',
    'empty.history': 'Complete a puzzle to begin your history.',
    'campaign.title': 'Forge Trail',
    'campaign.body':
        'Complete puzzles across six difficulty worlds. Stars unlock each milestone.',
    'daily.title': 'Daily Brain Challenge',
    'daily.body':
        'The same versioned offline seeds are used for everyone on this date.',
    'statistics.title': 'Statistics',
    'statistics.completed': 'Completed',
    'statistics.bestScore': 'Best score',
    'statistics.hintFree': 'Hint-free wins',
    'achievements.title': 'Achievements',
    'achievement.hint_free_first': 'Independent thinker',
    'achievement.ten_solutions': 'Ten forged solutions',
    'achievement.master_score': 'Master score',
    'achievement.level_two': 'Rising solver',
    'achievement.seven_day_streak': 'Seven-day flame',
    'streak.title': 'Daily streak',
    'streak.body':
        'Complete one daily puzzle per local calendar date. Duplicate completions never increase the streak.',
    'themes.title': 'Board themes',
    'theme.forge': 'Forge',
    'theme.ocean': 'Ocean',
    'theme.forest': 'Forest',
    'theme.mono': 'Monochrome',
    'tutorial.title': 'How PuzzleForge works',
    'tutorial.body':
        'Choose a module and difficulty, make legal moves, use undo when needed, and request progressive hints only when you want help.',
    'guide.title': 'Player guide',
    'guide.body':
        'Every puzzle has deterministic rules, a local save, accessible labels, and a replayable action history. Open a puzzle detail card to read its exact rules.',
    'developer.title': 'Developer options',
    'developer.warning':
        'Diagnostics are local and never reveal secrets or grant paid entitlements.',
    'developer.overlay': 'Performance overlay',
    'developer.seed': 'Deterministic seed tool',
    'developer.localization': 'Localization inspector',
    'developer.state': 'State inspector',
    'developer.testData': 'Generate test progress',
    'developer.reset': 'Developer reset tools',
    'editor.title': 'Puzzle editor',
    'editor.levelId': 'Level ID',
    'editor.module': 'Puzzle module',
    'editor.seed': 'Seed',
    'editor.tags': 'Tags',
    'editor.position': 'Campaign position',
    'editor.reward': 'Challenge reward',
    'editor.json': 'Level JSON',
    'editor.valid':
        'Level is valid and the generated state passed module verification.',
    'editor.invalid': 'Level is invalid: {error}',
    'editor.duplicate': 'That level ID already exists in this editor session.',
    'editor.difficultyEstimate': 'Estimated difficulty: {difficulty}',
    'data.backupReady': 'Backup JSON is ready below.',
    'data.imported': 'Backup imported successfully.',
    'data.invalid': 'Backup rejected: {error}',
    'data.confirmDelete': 'Delete all PuzzleForge data from this device?',
    'data.deleted': 'Local data was deleted and safe defaults were restored.',
    'data.cacheCleared': 'Temporary cache is clear.',
    'notice.recovered':
        'Some saved data was invalid. Safe defaults were loaded without overwriting the source.',
    'count.puzzles.one': '{count} puzzle',
    'count.puzzles.other': '{count} puzzles',
  };

  static const Map<String, String> _hindi = <String, String>{
    'app.name': 'PuzzleForge',
    'app.tagline': 'गहराई से सोचें। समझदारी से हल करें।',
    'app.creator': 'Made by the Sanskar',
    'common.back': 'वापस',
    'common.cancel': 'रद्द करें',
    'common.close': 'बंद करें',
    'common.continue': 'जारी रखें',
    'common.copy': 'कॉपी करें',
    'common.delete': 'हटाएँ',
    'common.done': 'पूर्ण',
    'common.edit': 'संपादित करें',
    'common.error': 'कुछ गलत हुआ',
    'common.import': 'आयात',
    'common.new': 'नया',
    'common.off': 'बंद',
    'common.on': 'चालू',
    'common.preview': 'पूर्वावलोकन',
    'common.reset': 'रीसेट',
    'common.retry': 'फिर कोशिश करें',
    'common.save': 'सहेजें',
    'common.share': 'साझा करें',
    'common.validate': 'जाँचें',
    'common.version': 'संस्करण {version}',
    'home.greeting': 'समाधान गढ़ने के लिए तैयार?',
    'home.dailyTitle': 'आज की पहेली',
    'home.dailyBody': 'एक निश्चित ऑफलाइन चुनौती।',
    'home.playDaily': 'आज की पहेली खेलें',
    'home.continueTitle': 'पिछली पहेली जारी रखें',
    'home.allPuzzles': 'पहेली संग्रह',
    'home.explore': 'सभी देखें',
    'home.progress': 'आपकी प्रगति',
    'home.level': 'स्तर {level}',
    'home.xp': '{xp} XP',
    'home.streak': '{days} दिन की लड़ी',
    'home.hints': '{count} संकेत',
    'home.more': 'खेलने के और तरीके',
    'catalog.title': 'पहेली श्रेणियाँ',
    'catalog.favorite': 'पसंदीदा में जोड़ें',
    'catalog.unfavorite': 'पसंदीदा से हटाएँ',
    'catalog.chooseDifficulty': 'कठिनाई चुनें',
    'catalog.customSeed': 'कस्टम सीड',
    'catalog.start': 'पहेली शुरू करें',
    'difficulty.beginner': 'शुरुआती',
    'difficulty.easy': 'आसान',
    'difficulty.medium': 'मध्यम',
    'difficulty.hard': 'कठिन',
    'difficulty.expert': 'विशेषज्ञ',
    'difficulty.master': 'मास्टर',
    'mode.daily': 'दैनिक',
    'mode.endless': 'अनंत',
    'mode.campaign': 'अभियान',
    'mode.custom': 'कस्टम सीड',
    'category.spatial': 'स्थानिक',
    'category.numbers': 'संख्याएँ',
    'category.logic': 'तर्क',
    'category.path': 'रास्ते',
    'category.memory': 'स्मृति',
    'category.sorting': 'छँटाई',
    'category.patterns': 'पैटर्न',
    'puzzle.sliding.title': 'स्लाइडिंग टाइल्स',
    'puzzle.sliding.description': 'टाइल खिसकाकर संख्या ग्रिड सही करें।',
    'puzzle.sliding.rules':
        'खाली जगह के पास की टाइल दबाएँ। संख्याएँ क्रम में लगाएँ।',
    'puzzle.merge.title': 'संख्या मर्ज',
    'puzzle.merge.description': 'समान संख्याएँ मिलाकर लक्ष्य बनाएँ।',
    'puzzle.merge.rules': 'दिशा में स्वाइप करें। समान टाइलें एक बार मिलती हैं।',
    'puzzle.lights.title': 'लाइट ग्रिड',
    'puzzle.lights.description': 'जुड़ी कोशिकाएँ बदलकर सभी लाइट बंद करें।',
    'puzzle.lights.rules':
        'एक कोशिका दबाने पर वह और उसके चार पड़ोसी बदलते हैं।',
    'puzzle.maze.title': 'भूलभुलैया पथ',
    'puzzle.maze.description': 'चिंगारी को रास्ते से लक्ष्य तक पहुँचाएँ।',
    'puzzle.maze.rules':
        'दीवार पार किए बिना तारे तक पहुँचने के लिए दिशा बटन प्रयोग करें।',
    'puzzle.sudoku.title': 'सुडोकू',
    'puzzle.sudoku.description': '9×9 तर्क ग्रिड पूरा करें।',
    'puzzle.sudoku.rules': 'हर पंक्ति, स्तंभ और 3×3 खंड में 1 से 9 भरें।',
    'puzzle.memory.title': 'मेमोरी मैच',
    'puzzle.memory.description': 'चिह्न खोलें और जोड़े याद रखें।',
    'puzzle.memory.rules': 'दो कार्ड खोलें। समान चिह्न खुले रहते हैं।',
    'puzzle.sort.title': 'रंग छँटाई',
    'puzzle.sort.description': 'चिह्नित टुकड़ों को एक जैसे ट्यूब में रखें।',
    'puzzle.sort.rules':
        'स्रोत और लक्ष्य चुनें। ऊपर का एक टुकड़ा खाली या समान चिह्न पर रखें।',
    'puzzle.sequence.title': 'संख्या क्रम',
    'puzzle.sequence.description': 'नियम पहचानें और अगली संख्या चुनें।',
    'puzzle.sequence.rules':
        'पाँच संख्याएँ देखकर पैटर्न समझें और अगला मान चुनें।',
    'game.moves': '{count} चाल',
    'game.time': '{time}',
    'game.target': 'लक्ष्य {target}',
    'game.undo': 'वापस',
    'game.redo': 'फिर करें',
    'game.hint': 'संकेत',
    'game.pause': 'रोकें',
    'game.resume': 'जारी रखें',
    'game.restart': 'पहेली फिर शुरू करें',
    'game.quit': 'सहेजकर बाहर जाएँ',
    'game.paused': 'पहेली रुकी है',
    'game.pausedBody': 'टाइमर रुक गया है।',
    'game.noHint': 'इस स्थिति के लिए संकेत उपलब्ध नहीं है।',
    'game.noTokens': 'आपके संकेत टोकन समाप्त हैं।',
    'game.hintRepeated': 'यह संकेत पहले दिखाया गया था; टोकन नहीं कटा।',
    'game.unsolvableMove': 'यह चाल उपलब्ध नहीं है।',
    'result.title': 'पहेली गढ़ ली!',
    'result.score': '{score} अंक',
    'result.moves': 'चालें',
    'result.time': 'समय',
    'result.hints': 'प्रयुक्त संकेत',
    'result.replay': 'फिर खेलें',
    'result.next': 'दूसरी पहेली चुनें',
    'result.reward': 'प्रगति डिवाइस पर सहेजी गई।',
    'hint.sliding.moveTile': 'टाइल {tile} को खाली जगह की ओर खिसकाएँ।',
    'hint.lights.toggle': 'पंक्ति {row}, स्तंभ {column} बदलें।',
    'hint.memory.reveal': 'कार्ड {position} खोलें।',
    'hint.sequence.arithmetic': 'पास की संख्याओं के बीच समान अंतर देखें।',
    'hint.sequence.sumPrevious': 'हर मान पिछली दो संख्याओं से बनता है।',
    'hint.sequence.quadratic': 'देखें कि अंतर किस तरह बदलते हैं।',
    'hint.maze.direction': '{direction} जाएँ।',
    'hint.sudoku.value': 'पंक्ति {row}, स्तंभ {column} में {value} हो सकता है।',
    'hint.merge.direction': '{direction} दिशा आज़माएँ।',
    'hint.sort.pour': 'ट्यूब {from} से ऊपर का टुकड़ा ट्यूब {to} में रखें।',
    'direction.up': 'ऊपर',
    'direction.down': 'नीचे',
    'direction.left': 'बाएँ',
    'direction.right': 'दाएँ',
    'accessibility.sliding.board':
        '{size} गुणा {size} बोर्ड। खाली स्थान {empty}। {moves} चाल।',
    'accessibility.lights.board':
        '{total} में से {lit} लाइट चालू। {moves} चाल।',
    'accessibility.memory.board':
        '{total} में से {pairs} जोड़े मिले। {moves} चाल।',
    'accessibility.sequence.board': 'क्रम {sequence}। {moves} प्रयास।',
    'accessibility.maze.board':
        'खिलाड़ी पंक्ति {row}, स्तंभ {column}। लक्ष्य पंक्ति {exitRow}, स्तंभ {exitColumn}।',
    'accessibility.sudoku.board':
        '81 में से {filled} कोशिकाएँ भरीं। {moves} चाल।',
    'accessibility.merge.board':
        'सबसे बड़ी टाइल {largest}। लक्ष्य {target}। {moves} चाल।',
    'accessibility.sort.board':
        '{total} में से {completed} ट्यूब पूरे। {moves} चाल।',
    'settings.title': 'सेटिंग्स',
    'settings.general': 'सामान्य',
    'settings.appearance': 'रूप',
    'settings.gameplay': 'गेमप्ले',
    'settings.controls': 'नियंत्रण',
    'settings.sound': 'ध्वनि और कंपन',
    'settings.accessibility': 'सुगम्यता',
    'settings.language': 'भाषा',
    'settings.notifications': 'सूचनाएँ',
    'settings.data': 'डेटा और स्टोरेज',
    'settings.privacy': 'गोपनीयता',
    'settings.security': 'सुरक्षा',
    'settings.performance': 'प्रदर्शन',
    'settings.support': 'प्रोजेक्ट का समर्थन',
    'settings.about': 'परिचय',
    'settings.legal': 'कानूनी',
    'settings.developer': 'डेवलपर विकल्प',
    'settings.theme': 'ऐप थीम',
    'settings.theme.system': 'सिस्टम',
    'settings.theme.light': 'हल्की',
    'settings.theme.dark': 'गहरी',
    'settings.gameTheme': 'गेम थीम',
    'settings.reducedMotion': 'कम गति',
    'settings.highContrast': 'अधिक कंट्रास्ट',
    'settings.dyslexia': 'डिस्लेक्सिया-अनुकूल अंतर',
    'settings.numericLabels': 'संख्या लेबल',
    'settings.masterSound': 'मुख्य ध्वनि',
    'settings.music': 'संगीत',
    'settings.effects': 'ध्वनि प्रभाव',
    'settings.gameplaySounds': 'अलग गेमप्ले ध्वनियाँ',
    'settings.haptics': 'कंपन',
    'settings.battery': 'बैटरी सेवर',
    'settings.confirm': 'हटाने से पहले पुष्टि',
    'settings.tutorialReset': 'ट्यूटोरियल रीसेट',
    'settings.restoreDefaults': 'डिफ़ॉल्ट लौटाएँ',
    'settings.clearHistory': 'इतिहास साफ करें',
    'settings.deleteAll': 'सारा स्थानीय डेटा हटाएँ',
    'settings.export': 'बैकअप निर्यात',
    'settings.import': 'बैकअप आयात',
    'settings.english': 'English',
    'settings.hindi': 'हिन्दी',
    'settings.animationSpeed': 'एनीमेशन गति',
    'settings.animationQuality': 'एनीमेशन गुणवत्ता',
    'settings.quality.low': 'कम',
    'settings.quality.balanced': 'संतुलित',
    'settings.quality.high': 'उच्च',
    'settings.performanceMode': 'प्रदर्शन प्राथमिकता',
    'settings.performance.battery': 'बैटरी',
    'settings.performance.balanced': 'संतुलित',
    'settings.performance.smooth': 'स्मूद',
    'settings.clearCache': 'कैश साफ करें',
    'settings.unlockProgress': 'डेवलपर विकल्प के लिए {remaining} बार और दबाएँ।',
    'settings.unlocked': 'डेवलपर विकल्प चालू हुए।',
    'support.title': 'PuzzleForge का समर्थन',
    'support.bmc': 'इस प्रोजेक्ट का समर्थन करें — Buy Me a Coffee',
    'support.bmcLabel': 'Buy Me a Coffee पर Sanskar का समर्थन करें',
    'support.optional':
        'समर्थन वैकल्पिक है। मुख्य पहेलियाँ निष्पक्ष और सुगम रहती हैं।',
    'support.openFailed': 'बाहरी ऐप नहीं खुल सका। लिंक नीचे दिया है।',
    'support.contact': 'संपर्क',
    'about.title': 'PuzzleForge के बारे में',
    'about.openSource': 'PuzzleForge MIT लाइसेंस के अंतर्गत ओपन सोर्स है।',
    'about.repository': 'GitHub पर स्रोत देखें',
    'about.creator': 'निर्माता का GitHub प्रोफ़ाइल',
    'about.credits': 'मूल डिज़ाइन और विकास Sanskar द्वारा।',
    'legal.privacy': 'गोपनीयता नीति',
    'legal.terms': 'नियम और शर्तें',
    'legal.notices': 'तृतीय-पक्ष सूचनाएँ',
    'legal.review':
        'व्यावसायिक प्रकाशन से पहले इन डेवलपर टेम्पलेट की कानूनी समीक्षा आवश्यक है।',
    'menu.title': 'PuzzleForge देखें',
    'menu.dailyChallenges': 'दैनिक चुनौतियाँ',
    'menu.campaign': 'अभियान',
    'menu.endless': 'अनंत मोड',
    'menu.favorites': 'पसंदीदा',
    'menu.recent': 'हाल में खेली',
    'menu.completed': 'पूरी पहेलियाँ',
    'menu.statistics': 'आँकड़े',
    'menu.achievements': 'उपलब्धियाँ',
    'menu.streak': 'लड़ी',
    'menu.themes': 'थीम',
    'menu.tutorial': 'ट्यूटोरियल',
    'menu.guide': 'मार्गदर्शिका',
    'menu.editor': 'पहेली संपादक',
    'empty.favorites': 'पहेली को पसंदीदा बनाकर यहाँ पाएँ।',
    'empty.history': 'इतिहास शुरू करने के लिए पहेली पूरी करें।',
    'campaign.title': 'फोर्ज ट्रेल',
    'campaign.body':
        'छह कठिनाई दुनियाओं में पहेलियाँ पूरी करें। तारे पड़ाव खोलते हैं।',
    'daily.title': 'दैनिक मस्तिष्क चुनौती',
    'daily.body': 'इस तारीख के लिए सभी को समान संस्करणित ऑफलाइन सीड मिलता है।',
    'statistics.title': 'आँकड़े',
    'statistics.completed': 'पूर्ण',
    'statistics.bestScore': 'सर्वश्रेष्ठ अंक',
    'statistics.hintFree': 'बिना संकेत जीत',
    'achievements.title': 'उपलब्धियाँ',
    'achievement.hint_free_first': 'स्वतंत्र विचारक',
    'achievement.ten_solutions': 'दस गढ़े समाधान',
    'achievement.master_score': 'मास्टर स्कोर',
    'achievement.level_two': 'उभरता हलकर्ता',
    'achievement.seven_day_streak': 'सात-दिन ज्वाला',
    'streak.title': 'दैनिक लड़ी',
    'streak.body':
        'हर स्थानीय तारीख पर एक दैनिक पहेली पूरी करें। दोहराव लड़ी नहीं बढ़ाता।',
    'themes.title': 'बोर्ड थीम',
    'theme.forge': 'फोर्ज',
    'theme.ocean': 'महासागर',
    'theme.forest': 'वन',
    'theme.mono': 'एकरंगी',
    'tutorial.title': 'PuzzleForge कैसे चलता है',
    'tutorial.body':
        'मॉड्यूल और कठिनाई चुनें, वैध चाल चलें, जरूरत पर वापस जाएँ और सहायता चाहें तभी संकेत लें।',
    'guide.title': 'खिलाड़ी मार्गदर्शिका',
    'guide.body':
        'हर पहेली के निश्चित नियम, स्थानीय सेव, सुगम लेबल और दोहराने योग्य चाल इतिहास हैं।',
    'developer.title': 'डेवलपर विकल्प',
    'developer.warning':
        'डायग्नोस्टिक स्थानीय हैं और रहस्य या भुगतान अधिकार नहीं दिखाते।',
    'developer.overlay': 'प्रदर्शन ओवरले',
    'developer.seed': 'निश्चित सीड टूल',
    'developer.localization': 'स्थानीयकरण निरीक्षक',
    'developer.state': 'स्थिति निरीक्षक',
    'developer.testData': 'टेस्ट प्रगति बनाएँ',
    'developer.reset': 'डेवलपर रीसेट टूल',
    'editor.title': 'पहेली संपादक',
    'editor.levelId': 'लेवल ID',
    'editor.module': 'पहेली मॉड्यूल',
    'editor.seed': 'सीड',
    'editor.tags': 'टैग',
    'editor.position': 'अभियान स्थान',
    'editor.reward': 'चुनौती पुरस्कार',
    'editor.json': 'लेवल JSON',
    'editor.valid': 'लेवल वैध है और मॉड्यूल जाँच सफल हुई।',
    'editor.invalid': 'लेवल अमान्य: {error}',
    'editor.duplicate': 'यह लेवल ID इस सत्र में पहले से है।',
    'editor.difficultyEstimate': 'अनुमानित कठिनाई: {difficulty}',
    'data.backupReady': 'बैकअप JSON नीचे तैयार है।',
    'data.imported': 'बैकअप सफलतापूर्वक आयात हुआ।',
    'data.invalid': 'बैकअप अस्वीकार: {error}',
    'data.confirmDelete': 'इस डिवाइस का सारा PuzzleForge डेटा हटाएँ?',
    'data.deleted': 'स्थानीय डेटा हटाकर सुरक्षित डिफ़ॉल्ट लागू किए गए।',
    'data.cacheCleared': 'अस्थायी कैश साफ है।',
    'notice.recovered':
        'कुछ सहेजा डेटा अमान्य था। स्रोत बदले बिना सुरक्षित डिफ़ॉल्ट लोड हुए।',
    'count.puzzles.one': '{count} पहेली',
    'count.puzzles.other': '{count} पहेलियाँ',
  };
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) =>
      const <String>{'en', 'hi'}.contains(locale.languageCode);

  @override
  Future<AppLocalizations> load(Locale locale) =>
      SynchronousFuture<AppLocalizations>(AppLocalizations(locale));

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

extension LocalizationBuildContext on BuildContext {
  AppLocalizations get strings => AppLocalizations.of(this);
}
