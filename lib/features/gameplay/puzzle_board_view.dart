import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/localization/app_localizations.dart';
import '../../puzzles/core/puzzle_models.dart';
import 'puzzle_session_controller.dart';

class PuzzleBoardView extends StatefulWidget {
  const PuzzleBoardView({required this.controller, super.key});

  final PuzzleSessionController controller;

  @override
  State<PuzzleBoardView> createState() => _PuzzleBoardViewState();
}

class _PuzzleBoardViewState extends State<PuzzleBoardView> {
  int? _selectedSudokuCell;
  int? _selectedTube;
  final FocusNode _keyboardFocus = FocusNode(
    debugLabel: 'Puzzle board controls',
  );

  @override
  void dispose() {
    _keyboardFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = widget.controller;
    final description = controller.module.accessibilityDescription(
      controller.state,
    );
    final label = context.strings.text(
      description.messageKey,
      description.arguments,
    );
    return Semantics(
      container: true,
      label: label,
      child: KeyboardListener(
        focusNode: _keyboardFocus,
        autofocus: true,
        onKeyEvent: (event) {
          if (event is! KeyDownEvent) return;
          final direction = switch (event.logicalKey) {
            LogicalKeyboardKey.arrowUp => 'up',
            LogicalKeyboardKey.arrowDown => 'down',
            LogicalKeyboardKey.arrowLeft => 'left',
            LogicalKeyboardKey.arrowRight => 'right',
            _ => null,
          };
          if (direction == null) return;
          final type = controller.module.id == 'number_merge'
              ? 'swipe'
              : 'move';
          controller.apply(
            PuzzleAction(type, <String, Object?>{'direction': direction}),
          );
        },
        child: switch (controller.module.id) {
          'sliding_tiles' => _sliding(context),
          'number_merge' => _merge(context),
          'light_grid' => _lights(context),
          'maze' => _maze(context),
          'sudoku' => _sudoku(context),
          'memory_match' => _memory(context),
          'color_sort' => _sort(context),
          'number_sequence' => _sequence(context),
          _ => const SizedBox.shrink(),
        },
      ),
    );
  }

  Widget _sliding(BuildContext context) {
    final state = widget.controller.state;
    final size = state.data['size']! as int;
    final board = intList(state.data['board'], length: size * size);
    final legal = widget.controller.module
        .legalActions(state)
        .map((action) => action.arguments['index']! as int)
        .toSet();
    return _SquareBoard(
      child: GridView.builder(
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: size,
        ),
        itemCount: board.length,
        itemBuilder: (context, index) {
          final tile = board[index];
          if (tile == 0) return const SizedBox.shrink();
          return Padding(
            padding: const EdgeInsets.all(3),
            child: Semantics(
              button: legal.contains(index),
              label: '${context.strings.text('puzzle.sliding.title')} $tile',
              child: FilledButton(
                onPressed: legal.contains(index)
                    ? () => widget.controller.apply(
                        PuzzleAction('slide', <String, Object?>{
                          'index': index,
                        }),
                      )
                    : null,
                style: FilledButton.styleFrom(
                  padding: EdgeInsets.zero,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: FittedBox(
                  child: Text(
                    '$tile',
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _lights(BuildContext context) {
    final state = widget.controller.state;
    final size = state.data['size']! as int;
    final lights = boolList(state.data['lights'], length: size * size);
    final scheme = Theme.of(context).colorScheme;
    return _SquareBoard(
      child: GridView.builder(
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: size,
        ),
        itemCount: lights.length,
        itemBuilder: (context, index) {
          final active = lights[index];
          return Padding(
            padding: const EdgeInsets.all(3),
            child: Semantics(
              button: true,
              toggled: active,
              label: '${index ~/ size + 1}, ${index % size + 1}',
              child: InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: () => widget.controller.apply(
                  PuzzleAction('toggle', <String, Object?>{'index': index}),
                ),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  decoration: BoxDecoration(
                    color: active
                        ? const Color(0xffffc107)
                        : scheme.surfaceContainerHighest,
                    border: Border.all(
                      color: active ? const Color(0xff7c5800) : scheme.outline,
                      width: 2,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    active
                        ? Icons.light_mode_rounded
                        : Icons.dark_mode_outlined,
                    color: active ? Colors.black : scheme.onSurfaceVariant,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _memory(BuildContext context) {
    final state = widget.controller.state;
    final cards = intList(state.data['cards']);
    final revealed = boolList(state.data['revealed'], length: cards.length);
    final matched = boolList(state.data['matched'], length: cards.length);
    final columns = cards.length <= 8
        ? 4
        : cards.length <= 16
        ? 4
        : 6;
    final symbols = <IconData>[
      Icons.star_rounded,
      Icons.favorite_rounded,
      Icons.bolt_rounded,
      Icons.eco_rounded,
      Icons.water_drop_rounded,
      Icons.hexagon_rounded,
      Icons.circle,
      Icons.change_history_rounded,
      Icons.diamond_rounded,
      Icons.pentagon_rounded,
      Icons.wb_sunny_rounded,
      Icons.nights_stay_rounded,
    ];
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 560, maxHeight: 600),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: columns,
          childAspectRatio: 0.78,
        ),
        itemCount: cards.length,
        itemBuilder: (context, index) {
          final visible = revealed[index] || matched[index];
          return Padding(
            padding: const EdgeInsets.all(4),
            child: Semantics(
              button: !visible,
              label: visible ? '${cards[index]}' : '${index + 1}',
              child: FilledButton.tonal(
                onPressed: visible
                    ? null
                    : () => widget.controller.apply(
                        PuzzleAction('flip', <String, Object?>{'index': index}),
                      ),
                style: FilledButton.styleFrom(padding: EdgeInsets.zero),
                child: visible
                    ? Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Icon(
                            symbols[(cards[index] - 1) % symbols.length],
                            size: 30,
                          ),
                          Text('${cards[index]}'),
                        ],
                      )
                    : const Icon(Icons.question_mark_rounded),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _merge(BuildContext context) {
    final state = widget.controller.state;
    final board = intList(state.data['board'], length: 16);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Text(
          context.strings.text('game.target', <String, Object?>{
            'target': state.data['target']!,
          }),
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 12),
        _SquareBoard(
          child: GridView.builder(
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
            ),
            itemCount: 16,
            itemBuilder: (context, index) {
              final value = board[index];
              final color = value == 0
                  ? Theme.of(context).colorScheme.surfaceContainerHighest
                  : Color.lerp(
                      const Color(0xffffedd5),
                      const Color(0xffc2410c),
                      (value.bitLength / 13).clamp(0, 1).toDouble(),
                    )!;
              return Container(
                margin: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Theme.of(context).colorScheme.outline,
                  ),
                ),
                alignment: Alignment.center,
                child: value == 0
                    ? null
                    : FittedBox(
                        child: Text(
                          '$value',
                          style: const TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.w900,
                            color: Colors.black,
                          ),
                        ),
                      ),
              );
            },
          ),
        ),
        const SizedBox(height: 12),
        _DirectionControls(
          onDirection: (direction) {
            widget.controller.apply(
              PuzzleAction('swipe', <String, Object?>{'direction': direction}),
            );
          },
        ),
      ],
    );
  }

  Widget _maze(BuildContext context) {
    final state = widget.controller.state;
    final size = state.data['size']! as int;
    final walls = boolList(state.data['walls'], length: size * size);
    final player = state.data['player']! as int;
    final exit = state.data['exit']! as int;
    final scheme = Theme.of(context).colorScheme;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        _SquareBoard(
          child: GridView.builder(
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: size,
            ),
            itemCount: walls.length,
            itemBuilder: (context, index) => ColoredBox(
              color: walls[index]
                  ? scheme.onSurface
                  : scheme.surfaceContainerLowest,
              child: index == player
                  ? Icon(
                      Icons.local_fire_department_rounded,
                      color: scheme.primary,
                    )
                  : index == exit
                  ? const Icon(Icons.star_rounded, color: Color(0xffffa000))
                  : null,
            ),
          ),
        ),
        const SizedBox(height: 12),
        _DirectionControls(
          onDirection: (direction) {
            widget.controller.apply(
              PuzzleAction('move', <String, Object?>{'direction': direction}),
            );
          },
        ),
      ],
    );
  }

  Widget _sudoku(BuildContext context) {
    final state = widget.controller.state;
    final cells = intList(state.data['cells'], length: 81);
    final givens = boolList(state.data['givens'], length: 81);
    final scheme = Theme.of(context).colorScheme;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        _SquareBoard(
          maxSize: 540,
          child: GridView.builder(
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 9,
            ),
            itemCount: 81,
            itemBuilder: (context, index) {
              final row = index ~/ 9;
              final column = index % 9;
              final selected = _selectedSudokuCell == index;
              return Semantics(
                button: !givens[index],
                label: '${row + 1}, ${column + 1}, ${cells[index]}',
                child: InkWell(
                  onTap: givens[index]
                      ? null
                      : () => setState(() => _selectedSudokuCell = index),
                  child: Container(
                    decoration: BoxDecoration(
                      color: selected
                          ? scheme.primaryContainer
                          : givens[index]
                          ? scheme.surfaceContainerHigh
                          : scheme.surface,
                      border: Border(
                        left: BorderSide(
                          color: scheme.outline,
                          width: column % 3 == 0 ? 2 : 0.4,
                        ),
                        top: BorderSide(
                          color: scheme.outline,
                          width: row % 3 == 0 ? 2 : 0.4,
                        ),
                        right: BorderSide(
                          color: scheme.outline,
                          width: column == 8 ? 2 : 0.4,
                        ),
                        bottom: BorderSide(
                          color: scheme.outline,
                          width: row == 8 ? 2 : 0.4,
                        ),
                      ),
                    ),
                    alignment: Alignment.center,
                    child: cells[index] == 0
                        ? null
                        : FittedBox(
                            child: Text(
                              '${cells[index]}',
                              style: TextStyle(
                                fontWeight: givens[index]
                                    ? FontWeight.w900
                                    : FontWeight.w500,
                                fontSize: 22,
                              ),
                            ),
                          ),
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          alignment: WrapAlignment.center,
          spacing: 6,
          runSpacing: 6,
          children: <Widget>[
            for (var value = 1; value <= 9; value++)
              SizedBox.square(
                dimension: 48,
                child: OutlinedButton(
                  onPressed: _selectedSudokuCell == null
                      ? null
                      : () => widget.controller.apply(
                          PuzzleAction('set', <String, Object?>{
                            'index': _selectedSudokuCell!,
                            'value': value,
                          }),
                        ),
                  child: Text('$value'),
                ),
              ),
            IconButton.outlined(
              tooltip: context.strings.text('common.delete'),
              onPressed: _selectedSudokuCell == null
                  ? null
                  : () => widget.controller.apply(
                      PuzzleAction('set', <String, Object?>{
                        'index': _selectedSudokuCell!,
                        'value': 0,
                      }),
                    ),
              icon: const Icon(Icons.backspace_outlined),
            ),
          ],
        ),
      ],
    );
  }

  Widget _sort(BuildContext context) {
    final state = widget.controller.state;
    final raw = state.data['tubes']! as List;
    final tubes = <List<int>>[for (final tube in raw) intList(tube)];
    final colors = <Color>[
      const Color(0xffe11d48),
      const Color(0xff2563eb),
      const Color(0xff16a34a),
      const Color(0xffca8a04),
      const Color(0xff9333ea),
    ];
    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 12,
      runSpacing: 16,
      children: <Widget>[
        for (var tubeIndex = 0; tubeIndex < tubes.length; tubeIndex++)
          Semantics(
            button: true,
            selected: _selectedTube == tubeIndex,
            label: '${tubeIndex + 1}',
            child: InkWell(
              borderRadius: BorderRadius.circular(22),
              onTap: () {
                if (_selectedTube == null) {
                  if (tubes[tubeIndex].isNotEmpty)
                    setState(() => _selectedTube = tubeIndex);
                } else {
                  final source = _selectedTube!;
                  final moved = widget.controller.apply(
                    PuzzleAction('pour', <String, Object?>{
                      'from': source,
                      'to': tubeIndex,
                    }),
                  );
                  setState(
                    () => _selectedTube = moved
                        ? null
                        : tubeIndex == source
                        ? null
                        : source,
                  );
                }
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                width: 66,
                height: 210,
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(
                  color: _selectedTube == tubeIndex
                      ? Theme.of(context).colorScheme.primaryContainer
                      : Theme.of(context).colorScheme.surfaceContainer,
                  border: Border.all(
                    color: _selectedTube == tubeIndex
                        ? Theme.of(context).colorScheme.primary
                        : Theme.of(context).colorScheme.outline,
                    width: _selectedTube == tubeIndex ? 3 : 2,
                  ),
                  borderRadius: const BorderRadius.vertical(
                    bottom: Radius.circular(26),
                    top: Radius.circular(10),
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: <Widget>[
                    for (final value in tubes[tubeIndex].reversed)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Container(
                          width: 44,
                          height: 40,
                          decoration: BoxDecoration(
                            color: colors[(value - 1) % colors.length],
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.black, width: 1.5),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            '$value',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _sequence(BuildContext context) {
    final state = widget.controller.state;
    final sequence = intList(state.data['sequence'], length: 5);
    final choices = intList(state.data['choices'], length: 4);
    final selected = state.data['selected'];
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Wrap(
          alignment: WrapAlignment.center,
          spacing: 8,
          runSpacing: 8,
          children: <Widget>[
            for (final value in sequence) _SequenceValue(value: '$value'),
            const _SequenceValue(value: '?', emphasized: true),
          ],
        ),
        const SizedBox(height: 28),
        Wrap(
          alignment: WrapAlignment.center,
          spacing: 10,
          runSpacing: 10,
          children: <Widget>[
            for (final value in choices)
              SizedBox(
                width: 110,
                child: value == selected
                    ? FilledButton(
                        onPressed: () => _chooseSequence(value),
                        child: Text('$value'),
                      )
                    : OutlinedButton(
                        onPressed: () => _chooseSequence(value),
                        child: Text('$value'),
                      ),
              ),
          ],
        ),
      ],
    );
  }

  void _chooseSequence(int value) {
    widget.controller.apply(
      PuzzleAction('choose', <String, Object?>{'value': value}),
    );
  }
}

class _SquareBoard extends StatelessWidget {
  const _SquareBoard({required this.child, this.maxSize = 600});
  final Widget child;
  final double maxSize;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final size = constraints.maxWidth.clamp(220.0, maxSize).toDouble();
      return SizedBox.square(dimension: size, child: child);
    },
  );
}

class _DirectionControls extends StatelessWidget {
  const _DirectionControls({required this.onDirection});
  final ValueChanged<String> onDirection;

  @override
  Widget build(BuildContext context) {
    Widget button(String direction, IconData icon) => IconButton.filledTonal(
      tooltip: context.strings.text('direction.$direction'),
      onPressed: () => onDirection(direction),
      icon: Icon(icon),
    );
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        button('up', Icons.keyboard_arrow_up_rounded),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            button('left', Icons.keyboard_arrow_left_rounded),
            const SizedBox(width: 48),
            button('right', Icons.keyboard_arrow_right_rounded),
          ],
        ),
        button('down', Icons.keyboard_arrow_down_rounded),
      ],
    );
  }
}

class _SequenceValue extends StatelessWidget {
  const _SequenceValue({required this.value, this.emphasized = false});
  final String value;
  final bool emphasized;

  @override
  Widget build(BuildContext context) => Container(
    width: 62,
    height: 62,
    decoration: BoxDecoration(
      color: emphasized
          ? Theme.of(context).colorScheme.primaryContainer
          : Theme.of(context).colorScheme.surfaceContainer,
      border: Border.all(color: Theme.of(context).colorScheme.outline),
      borderRadius: BorderRadius.circular(16),
    ),
    alignment: Alignment.center,
    child: FittedBox(
      child: Text(
        value,
        style: Theme.of(
          context,
        ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w900),
      ),
    ),
  );
}
