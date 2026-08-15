import 'package:flutter/material.dart';

import '../app/controller_scope.dart';
import '../core/localization/app_localizations.dart';
import '../puzzles/puzzle_catalog.dart';
import 'puzzle_icon.dart';

class PuzzleCard extends StatelessWidget {
  const PuzzleCard({required this.entry, required this.onTap, super.key});

  final PuzzleCatalogEntry entry;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final strings = context.strings;
    final controller = ControllerScope.of(context);
    final favorite = controller.progress.favorites.contains(entry.module.id);
    final accent = Color(entry.accentValue);
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                children: <Widget>[
                  PuzzleIcon(name: entry.iconName, color: accent),
                  const Spacer(),
                  IconButton(
                    tooltip: strings.text(
                      favorite ? 'catalog.unfavorite' : 'catalog.favorite',
                    ),
                    onPressed: () => controller.toggleFavorite(entry.module.id),
                    icon: Icon(
                      favorite
                          ? Icons.favorite_rounded
                          : Icons.favorite_border_rounded,
                    ),
                    color: favorite
                        ? Theme.of(context).colorScheme.error
                        : null,
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                strings.text(entry.module.titleKey),
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 5),
              Text(
                strings.text(entry.module.descriptionKey),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
              const Spacer(),
              const SizedBox(height: 12),
              Chip(
                avatar: const Icon(Icons.category_outlined, size: 17),
                label: Text(strings.text(entry.categoryKey)),
                visualDensity: VisualDensity.compact,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
