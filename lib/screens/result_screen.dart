import 'package:flutter/material.dart';

import '../app/controller_scope.dart';
import '../core/localization/app_localizations.dart';
import '../widgets/brand_mark.dart';
import 'catalog_screen.dart';
import 'game_screen.dart';

class ResultScreen extends StatelessWidget {
  const ResultScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = ControllerScope.of(context);
    final session = controller.activeSession;
    final strings = context.strings;
    if (session == null) {
      return Scaffold(body: Center(child: Text(strings.text('common.error'))));
    }
    final elapsed = session.elapsed;
    final time =
        '${elapsed.inMinutes}:${elapsed.inSeconds.remainder(60).toString().padLeft(2, '0')}';
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 560),
              child: Column(
                children: <Widget>[
                  const BrandMark(size: 92),
                  const SizedBox(height: 20),
                  Text(
                    strings.text('result.title'),
                    style: Theme.of(context).textTheme.displaySmall,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    strings.text(session.module.titleKey),
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    strings.text('result.score', <String, Object?>{
                      'score': strings.formatNumber(session.score()),
                    }),
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 22),
                  Row(
                    children: <Widget>[
                      Expanded(
                        child: _ResultMetric(
                          label: strings.text('result.moves'),
                          value: '${session.state.moveCount}',
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _ResultMetric(
                          label: strings.text('result.time'),
                          value: time,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _ResultMetric(
                          label: strings.text('result.hints'),
                          value: '${session.hintsUsed}',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    strings.text('result.reward'),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  FilledButton.icon(
                    onPressed: () {
                      session.restart();
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute<void>(
                          builder: (_) => const GameScreen(),
                        ),
                      );
                    },
                    icon: const Icon(Icons.replay_rounded),
                    label: Text(strings.text('result.replay')),
                  ),
                  const SizedBox(height: 10),
                  OutlinedButton.icon(
                    onPressed: () async {
                      await controller.abandonSession();
                      if (!context.mounted) return;
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute<void>(
                          builder: (_) => const CatalogScreen(),
                        ),
                      );
                    },
                    icon: const Icon(Icons.grid_view_rounded),
                    label: Text(strings.text('result.next')),
                  ),
                  const SizedBox(height: 26),
                  Text(strings.text('app.creator')),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ResultMetric extends StatelessWidget {
  const _ResultMetric({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => Card(
    child: Padding(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
      child: Column(
        children: <Widget>[
          Text(
            value,
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 3),
          Text(
            label,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.labelMedium,
          ),
        ],
      ),
    ),
  );
}
