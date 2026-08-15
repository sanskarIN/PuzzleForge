import 'package:flutter/material.dart';

import '../core/localization/app_localizations.dart';
import '../puzzles/puzzle_catalog.dart';
import '../widgets/puzzle_card.dart';
import 'navigation_helpers.dart';

class CatalogScreen extends StatelessWidget {
  const CatalogScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final strings = context.strings;
    return Scaffold(
      appBar: AppBar(title: Text(strings.text('catalog.title'))),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final columns = constraints.maxWidth >= 1000
              ? 4
              : constraints.maxWidth >= 650
              ? 3
              : 2;
          return GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: columns,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: constraints.maxWidth < 380 ? 0.72 : 0.82,
            ),
            itemCount: PuzzleCatalog.entries.length,
            itemBuilder: (context, index) {
              final entry = PuzzleCatalog.entries[index];
              return PuzzleCard(
                entry: entry,
                onTap: () => openPuzzle(context, entry),
              );
            },
          );
        },
      ),
    );
  }
}
