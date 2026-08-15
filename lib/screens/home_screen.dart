import 'package:flutter/material.dart';

import '../app/controller_scope.dart';
import '../app/app_controller.dart';
import '../core/localization/app_localizations.dart';
import '../puzzles/core/puzzle_models.dart';
import '../puzzles/puzzle_catalog.dart';
import '../widgets/bmc_support_card.dart';
import '../widgets/brand_mark.dart';
import '../widgets/puzzle_card.dart';
import 'catalog_screen.dart';
import 'game_screen.dart';
import 'more_screen.dart';
import 'navigation_helpers.dart';
import 'settings_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final strings = context.strings;
    final controller = ControllerScope.of(context);
    final width = MediaQuery.sizeOf(context).width;
    final contentWidth = width >= 1000 ? 1120.0 : 760.0;
    final dailyEntry = PuzzleCatalog
        .entries[DateTime.now().day % PuzzleCatalog.entries.length];
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            const BrandMark(size: 36),
            const SizedBox(width: 10),
            Text(strings.text('app.name')),
          ],
        ),
        actions: <Widget>[
          IconButton(
            tooltip: strings.text('menu.title'),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute<void>(builder: (_) => const MoreScreen()),
            ),
            icon: const Icon(Icons.apps_rounded),
          ),
          IconButton(
            tooltip: strings.text('settings.title'),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute<void>(builder: (_) => const SettingsScreen()),
            ),
            icon: const Icon(Icons.settings_outlined),
          ),
        ],
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: contentWidth),
            child: CustomScrollView(
              slivers: <Widget>[
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
                  sliver: SliverList.list(
                    children: <Widget>[
                      _HeroPanel(controller: controller),
                      if (controller.noticeKey != null) ...<Widget>[
                        const SizedBox(height: 12),
                        MaterialBanner(
                          content: Text(strings.text(controller.noticeKey!)),
                          actions: <Widget>[
                            TextButton(
                              onPressed: controller.dismissNotice,
                              child: Text(strings.text('common.close')),
                            ),
                          ],
                        ),
                      ],
                      const SizedBox(height: 16),
                      if (controller.hasActiveSession) ...<Widget>[
                        _ContinueCard(controller: controller),
                        const SizedBox(height: 12),
                      ],
                      _DailyCard(
                        entry: dailyEntry,
                        onPlay: () => openPuzzle(
                          context,
                          dailyEntry,
                          mode: PlayMode.daily,
                          fixedDifficulty: PuzzleDifficulty.medium,
                        ),
                      ),
                      const SizedBox(height: 22),
                      _SectionHeader(
                        title: strings.text('home.allPuzzles'),
                        action: strings.text('home.explore'),
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute<void>(
                            builder: (_) => const CatalogScreen(),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
                  sliver: SliverGrid(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: width >= 700 ? 3 : 2,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: width < 380 ? 0.72 : 0.82,
                    ),
                    delegate: SliverChildBuilderDelegate((context, index) {
                      final entry = PuzzleCatalog.entries[index];
                      return PuzzleCard(
                        entry: entry,
                        onTap: () => openPuzzle(context, entry),
                      );
                    }, childCount: width >= 700 ? 6 : 4),
                  ),
                ),
                const SliverPadding(
                  padding: EdgeInsets.fromLTRB(16, 0, 16, 10),
                  sliver: SliverToBoxAdapter(child: BmcSupportCard()),
                ),
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
                  sliver: SliverToBoxAdapter(
                    child: Center(child: Text(strings.text('app.creator'))),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _HeroPanel extends StatelessWidget {
  const _HeroPanel({required this.controller});

  final AppController controller;

  @override
  Widget build(BuildContext context) {
    final strings = context.strings;
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: <Color>[scheme.primaryContainer, scheme.tertiaryContainer],
        ),
        borderRadius: BorderRadius.circular(28),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            strings.text('home.greeting'),
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 6),
          Text(strings.text('app.tagline')),
          const SizedBox(height: 18),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: <Widget>[
              _Metric(
                icon: Icons.auto_awesome_rounded,
                label: strings.text('home.level', <String, Object?>{
                  'level': controller.progress.level,
                }),
              ),
              _Metric(
                icon: Icons.local_fire_department_rounded,
                label: strings.text('home.streak', <String, Object?>{
                  'days': controller.progress.currentStreak,
                }),
              ),
              _Metric(
                icon: Icons.lightbulb_rounded,
                label: strings.text('home.hints', <String, Object?>{
                  'count': controller.progress.hintTokens,
                }),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Metric extends StatelessWidget {
  const _Metric({required this.icon, required this.label});
  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) =>
      Chip(avatar: Icon(icon, size: 18), label: Text(label));
}

class _DailyCard extends StatelessWidget {
  const _DailyCard({required this.entry, required this.onPlay});
  final PuzzleCatalogEntry entry;
  final VoidCallback onPlay;

  @override
  Widget build(BuildContext context) {
    final strings = context.strings;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: <Widget>[
            CircleAvatar(radius: 28, child: const Icon(Icons.today_rounded)),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    strings.text('home.dailyTitle'),
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(strings.text(entry.module.titleKey)),
                ],
              ),
            ),
            FilledButton(
              onPressed: onPlay,
              child: Text(strings.text('home.playDaily')),
            ),
          ],
        ),
      ),
    );
  }
}

class _ContinueCard extends StatelessWidget {
  const _ContinueCard({required this.controller});
  final AppController controller;

  @override
  Widget build(BuildContext context) {
    final session = controller.activeSession!;
    return Card(
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 10,
        ),
        leading: const CircleAvatar(child: Icon(Icons.play_arrow_rounded)),
        title: Text(context.strings.text('home.continueTitle')),
        subtitle: Text(context.strings.text(session.module.titleKey)),
        trailing: const Icon(Icons.arrow_forward_rounded),
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute<void>(builder: (_) => const GameScreen()),
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    required this.title,
    required this.action,
    required this.onTap,
  });
  final String title;
  final String action;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Row(
    children: <Widget>[
      Expanded(
        child: Text(title, style: Theme.of(context).textTheme.headlineSmall),
      ),
      TextButton(onPressed: onTap, child: Text(action)),
    ],
  );
}
