import 'package:flutter/material.dart';

import '../app/controller_scope.dart';
import '../core/localization/app_localizations.dart';
import '../puzzles/core/puzzle_models.dart';
import '../puzzles/puzzle_catalog.dart';
import '../widgets/puzzle_card.dart';
import 'navigation_helpers.dart';
import 'puzzle_editor_screen.dart';

class MoreScreen extends StatelessWidget {
  const MoreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final items = <(String, IconData, Widget)>[
      (
        'menu.dailyChallenges',
        Icons.today_rounded,
        const DailyChallengesScreen(),
      ),
      ('menu.campaign', Icons.map_outlined, const CampaignScreen()),
      ('menu.endless', Icons.all_inclusive_rounded, const EndlessScreen()),
      (
        'menu.favorites',
        Icons.favorite_outline_rounded,
        const FavoritesScreen(),
      ),
      ('menu.recent', Icons.history_rounded, const HistoryScreen()),
      ('menu.completed', Icons.task_alt_rounded, const HistoryScreen()),
      ('menu.statistics', Icons.query_stats_rounded, const StatisticsScreen()),
      (
        'menu.achievements',
        Icons.emoji_events_outlined,
        const AchievementsScreen(),
      ),
      (
        'menu.streak',
        Icons.local_fire_department_outlined,
        const StreakScreen(),
      ),
      ('menu.themes', Icons.palette_outlined, const ThemesScreen()),
      ('menu.tutorial', Icons.school_outlined, const TutorialScreen()),
      ('menu.guide', Icons.menu_book_outlined, const GuideScreen()),
      ('menu.editor', Icons.construction_rounded, const PuzzleEditorScreen()),
    ];
    return Scaffold(
      appBar: AppBar(title: Text(context.strings.text('menu.title'))),
      body: GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
          maxCrossAxisExtent: 290,
          mainAxisExtent: 104,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
        ),
        itemCount: items.length,
        itemBuilder: (context, index) {
          final item = items[index];
          return Card(
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute<void>(builder: (_) => item.$3),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: <Widget>[
                    CircleAvatar(child: Icon(item.$2)),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Text(
                        context.strings.text(item.$1),
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class DailyChallengesScreen extends StatelessWidget {
  const DailyChallengesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final entries = PuzzleCatalog.entries.take(3).toList();
    return Scaffold(
      appBar: AppBar(title: Text(context.strings.text('daily.title'))),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: <Widget>[
          Text(
            context.strings.text('daily.body'),
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: 16),
          for (var index = 0; index < entries.length; index++)
            Card(
              child: ListTile(
                leading: CircleAvatar(child: Text('${index + 1}')),
                title: Text(
                  context.strings.text(entries[index].module.titleKey),
                ),
                subtitle: Text(
                  context.strings.text(
                    PuzzleDifficulty.values[index + 1].localizationKey,
                  ),
                ),
                trailing: const Icon(Icons.play_arrow_rounded),
                onTap: () => openPuzzle(
                  context,
                  entries[index],
                  mode: PlayMode.daily,
                  fixedDifficulty: PuzzleDifficulty.values[index + 1],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class CampaignScreen extends StatelessWidget {
  const CampaignScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = ControllerScope.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(context.strings.text('campaign.title'))),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: <Widget>[
          Text(
            context.strings.text('campaign.body'),
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: 18),
          for (final difficulty in PuzzleDifficulty.values)
            Card(
              child: ListTile(
                leading: CircleAvatar(child: Text('${difficulty.rank}')),
                title: Text(context.strings.text(difficulty.localizationKey)),
                subtitle: Text('${controller.progress.stars} ★'),
                trailing: const Icon(Icons.arrow_forward_rounded),
                onTap: () => openPuzzle(
                  context,
                  PuzzleCatalog.entries[difficulty.index %
                      PuzzleCatalog.entries.length],
                  mode: PlayMode.campaign,
                  fixedDifficulty: difficulty,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class EndlessScreen extends StatelessWidget {
  const EndlessScreen({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: Text(context.strings.text('menu.endless'))),
    body: GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 320,
        mainAxisExtent: 300,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: PuzzleCatalog.entries.length,
      itemBuilder: (context, index) {
        final entry = PuzzleCatalog.entries[index];
        return PuzzleCard(
          entry: entry,
          onTap: () => openPuzzle(context, entry),
        );
      },
    ),
  );
}

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final favorites = ControllerScope.of(context).progress.favorites;
    final entries = PuzzleCatalog.entries
        .where((entry) => favorites.contains(entry.module.id))
        .toList();
    return Scaffold(
      appBar: AppBar(title: Text(context.strings.text('menu.favorites'))),
      body: entries.isEmpty
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  context.strings.text('empty.favorites'),
                  textAlign: TextAlign.center,
                ),
              ),
            )
          : GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 320,
                mainAxisExtent: 300,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              itemCount: entries.length,
              itemBuilder: (context, index) => PuzzleCard(
                entry: entries[index],
                onTap: () => openPuzzle(context, entries[index]),
              ),
            ),
    );
  }
}

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final history = ControllerScope.of(context).progress.history;
    return Scaffold(
      appBar: AppBar(title: Text(context.strings.text('menu.recent'))),
      body: history.isEmpty
          ? Center(child: Text(context.strings.text('empty.history')))
          : ListView.builder(
              itemCount: history.length,
              itemBuilder: (context, index) {
                final record = history[index];
                return ListTile(
                  leading: const CircleAvatar(child: Icon(Icons.check_rounded)),
                  title: Text(
                    context.strings.text(
                      PuzzleCatalog.byId(record.puzzleId).module.titleKey,
                    ),
                  ),
                  subtitle: Text(
                    '${context.strings.formatDate(record.completedOn)} · ${record.moves} · ${record.elapsedSeconds}s',
                  ),
                  trailing: Text(context.strings.formatNumber(record.score)),
                );
              },
            ),
    );
  }
}

class StatisticsScreen extends StatelessWidget {
  const StatisticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final progress = ControllerScope.of(context).progress;
    final best = progress.history.isEmpty
        ? 0
        : progress.history
              .map((record) => record.score)
              .reduce((a, b) => a > b ? a : b);
    final hintFree = progress.history
        .where((record) => record.hintsUsed == 0)
        .length;
    return _MetricPage(
      titleKey: 'statistics.title',
      metrics: <(String, String, IconData)>[
        (
          'statistics.completed',
          '${progress.history.length}',
          Icons.task_alt_rounded,
        ),
        ('statistics.bestScore', '$best', Icons.emoji_events_rounded),
        ('statistics.hintFree', '$hintFree', Icons.psychology_alt_rounded),
      ],
    );
  }
}

class AchievementsScreen extends StatelessWidget {
  const AchievementsScreen({super.key});

  static const all = <String>[
    'hint_free_first',
    'ten_solutions',
    'master_score',
    'level_two',
    'seven_day_streak',
  ];

  @override
  Widget build(BuildContext context) {
    final unlocked = ControllerScope.of(context).progress.achievements;
    return Scaffold(
      appBar: AppBar(title: Text(context.strings.text('achievements.title'))),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: <Widget>[
          for (final id in all)
            Card(
              child: ListTile(
                leading: CircleAvatar(
                  child: Icon(
                    unlocked.contains(id)
                        ? Icons.emoji_events_rounded
                        : Icons.lock_outline_rounded,
                  ),
                ),
                title: Text(context.strings.text('achievement.$id')),
                enabled: unlocked.contains(id),
              ),
            ),
        ],
      ),
    );
  }
}

class StreakScreen extends StatelessWidget {
  const StreakScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final progress = ControllerScope.of(context).progress;
    return _MetricPage(
      titleKey: 'streak.title',
      bodyKey: 'streak.body',
      metrics: <(String, String, IconData)>[
        (
          'home.streak',
          '${progress.currentStreak}',
          Icons.local_fire_department_rounded,
        ),
        (
          'statistics.bestScore',
          '${progress.bestStreak}',
          Icons.workspace_premium_rounded,
        ),
      ],
    );
  }
}

class ThemesScreen extends StatelessWidget {
  const ThemesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = ControllerScope.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(context.strings.text('themes.title'))),
      body: RadioGroup<String>(
        groupValue: controller.settings.gameTheme,
        onChanged: (value) {
          if (value != null) {
            controller.updateSettings(
              controller.settings.copyWith(gameTheme: value),
            );
          }
        },
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: <Widget>[
            for (final theme in const <String>[
              'forge',
              'ocean',
              'forest',
              'mono',
            ])
              RadioListTile<String>(
                value: theme,
                title: Text(context.strings.text('theme.$theme')),
                secondary: Icon(
                  Icons.palette_rounded,
                  color: _themeColor(theme),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Color _themeColor(String theme) => switch (theme) {
    'ocean' => const Color(0xff0369a1),
    'forest' => const Color(0xff15803d),
    'mono' => const Color(0xff475569),
    _ => const Color(0xff4f46e5),
  };
}

class TutorialScreen extends StatelessWidget {
  const TutorialScreen({super.key});
  @override
  Widget build(BuildContext context) => const _TextPage(
    titleKey: 'tutorial.title',
    bodyKey: 'tutorial.body',
    icon: Icons.school_rounded,
  );
}

class GuideScreen extends StatelessWidget {
  const GuideScreen({super.key});
  @override
  Widget build(BuildContext context) => const _TextPage(
    titleKey: 'guide.title',
    bodyKey: 'guide.body',
    icon: Icons.menu_book_rounded,
  );
}

class _TextPage extends StatelessWidget {
  const _TextPage({
    required this.titleKey,
    required this.bodyKey,
    required this.icon,
  });
  final String titleKey;
  final String bodyKey;
  final IconData icon;

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: Text(context.strings.text(titleKey))),
    body: Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 680),
          child: Column(
            children: <Widget>[
              Icon(icon, size: 80),
              const SizedBox(height: 20),
              Text(
                context.strings.text(bodyKey),
                style: Theme.of(context).textTheme.bodyLarge,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

class _MetricPage extends StatelessWidget {
  const _MetricPage({
    required this.titleKey,
    required this.metrics,
    this.bodyKey,
  });
  final String titleKey;
  final String? bodyKey;
  final List<(String, String, IconData)> metrics;

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: Text(context.strings.text(titleKey))),
    body: ListView(
      padding: const EdgeInsets.all(20),
      children: <Widget>[
        if (bodyKey != null) ...<Widget>[
          Text(
            context.strings.text(bodyKey!),
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: 18),
        ],
        for (final metric in metrics)
          Card(
            child: ListTile(
              leading: CircleAvatar(child: Icon(metric.$3)),
              title: Text(context.strings.text(metric.$1)),
              trailing: Text(
                metric.$2,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
            ),
          ),
      ],
    ),
  );
}
