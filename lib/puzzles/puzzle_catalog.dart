import 'core/puzzle_module.dart';
import 'modules/color_sort_module.dart';
import 'modules/light_grid_module.dart';
import 'modules/maze_module.dart';
import 'modules/memory_match_module.dart';
import 'modules/number_merge_module.dart';
import 'modules/number_sequence_module.dart';
import 'modules/sliding_tiles_module.dart';
import 'modules/sudoku_module.dart';

class PuzzleCatalogEntry {
  const PuzzleCatalogEntry({
    required this.module,
    required this.categoryKey,
    required this.iconName,
    required this.accentValue,
  });

  final PuzzleModule module;
  final String categoryKey;
  final String iconName;
  final int accentValue;
}

class PuzzleCatalog {
  PuzzleCatalog._();

  static const entries = <PuzzleCatalogEntry>[
    PuzzleCatalogEntry(
      module: SlidingTilesModule(),
      categoryKey: 'category.spatial',
      iconName: 'grid_view',
      accentValue: 0xff4f46e5,
    ),
    PuzzleCatalogEntry(
      module: NumberMergeModule(),
      categoryKey: 'category.numbers',
      iconName: 'merge',
      accentValue: 0xffea580c,
    ),
    PuzzleCatalogEntry(
      module: LightGridModule(),
      categoryKey: 'category.logic',
      iconName: 'lightbulb',
      accentValue: 0xffca8a04,
    ),
    PuzzleCatalogEntry(
      module: MazeModule(),
      categoryKey: 'category.path',
      iconName: 'route',
      accentValue: 0xff0f766e,
    ),
    PuzzleCatalogEntry(
      module: SudokuModule(),
      categoryKey: 'category.logic',
      iconName: 'dialpad',
      accentValue: 0xff7c3aed,
    ),
    PuzzleCatalogEntry(
      module: MemoryMatchModule(),
      categoryKey: 'category.memory',
      iconName: 'style',
      accentValue: 0xffdb2777,
    ),
    PuzzleCatalogEntry(
      module: ColorSortModule(),
      categoryKey: 'category.sorting',
      iconName: 'science',
      accentValue: 0xff0284c7,
    ),
    PuzzleCatalogEntry(
      module: NumberSequenceModule(),
      categoryKey: 'category.patterns',
      iconName: 'query_stats',
      accentValue: 0xff16a34a,
    ),
  ];

  static final Map<String, PuzzleCatalogEntry> _byId =
      <String, PuzzleCatalogEntry>{
        for (final entry in entries) entry.module.id: entry,
      };

  static PuzzleCatalogEntry byId(String id) {
    final entry = _byId[id];
    if (entry == null)
      throw ArgumentError.value(id, 'id', 'Unknown puzzle module');
    return entry;
  }
}
