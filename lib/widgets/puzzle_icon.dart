import 'package:flutter/material.dart';

class PuzzleIcon extends StatelessWidget {
  const PuzzleIcon({required this.name, this.color, this.size = 48, super.key});

  final String name;
  final Color? color;
  final double size;

  @override
  Widget build(BuildContext context) {
    final icon = switch (name) {
      'grid_view' => Icons.grid_view_rounded,
      'merge' => Icons.merge_rounded,
      'lightbulb' => Icons.lightbulb_outline_rounded,
      'route' => Icons.route_rounded,
      'dialpad' => Icons.dialpad_rounded,
      'style' => Icons.style_rounded,
      'science' => Icons.science_outlined,
      'query_stats' => Icons.query_stats_rounded,
      _ => Icons.extension_rounded,
    };
    final resolved = color ?? Theme.of(context).colorScheme.primary;
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: resolved.withValues(alpha: 0.13),
        borderRadius: BorderRadius.circular(size * 0.3),
      ),
      child: Icon(icon, color: resolved, size: size * 0.58),
    );
  }
}
