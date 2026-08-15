import 'dart:async';

import 'package:flutter/material.dart';

import '../app/controller_scope.dart';
import '../core/localization/app_localizations.dart';
import '../features/gameplay/puzzle_board_view.dart';
import '../features/gameplay/puzzle_session_controller.dart';
import 'result_screen.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  Timer? _timer;
  PuzzleSessionController? _session;
  bool _openedResult = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final session = ControllerScope.read(context).activeSession;
    if (session != _session) {
      _session?.removeListener(_onSessionChanged);
      _session = session;
      _session?.addListener(_onSessionChanged);
    }
    _timer ??= Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted &&
          _session != null &&
          !_session!.isPaused &&
          !_session!.state.solved)
        setState(() {});
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _session?.removeListener(_onSessionChanged);
    super.dispose();
  }

  void _onSessionChanged() {
    if (!mounted) return;
    setState(() {});
    if (_session?.state.solved == true && !_openedResult) {
      _openedResult = true;
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        if (!mounted) return;
        await Navigator.of(context).pushReplacement(
          MaterialPageRoute<void>(builder: (_) => const ResultScreen()),
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final session = _session;
    final strings = context.strings;
    if (session == null) {
      return Scaffold(
        appBar: AppBar(),
        body: Center(child: Text(strings.text('common.error'))),
      );
    }
    final elapsed = _formatDuration(session.elapsed);
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _saveAndLeave();
      },
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            tooltip: strings.text('game.quit'),
            onPressed: _saveAndLeave,
            icon: const Icon(Icons.arrow_back_rounded),
          ),
          title: Text(strings.text(session.module.titleKey)),
          actions: <Widget>[
            IconButton(
              tooltip: strings.text('game.pause'),
              onPressed: _pause,
              icon: const Icon(Icons.pause_rounded),
            ),
          ],
        ),
        body: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final wide = constraints.maxWidth >= 900;
              final board = SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 620),
                    child: PuzzleBoardView(controller: session),
                  ),
                ),
              );
              final sidebar = _GameSidebar(
                session: session,
                elapsed: elapsed,
                onHint: _hint,
                onPause: _pause,
              );
              if (wide) {
                return Row(
                  children: <Widget>[
                    Expanded(child: board),
                    SizedBox(width: 310, child: sidebar),
                  ],
                );
              }
              return Column(
                children: <Widget>[
                  _CompactStatus(session: session, elapsed: elapsed),
                  Expanded(child: board),
                  _BottomActions(
                    session: session,
                    onHint: _hint,
                    onPause: _pause,
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Future<void> _hint() async {
    final session = _session!;
    final result = session.requestHint();
    if (!mounted) return;
    final strings = context.strings;
    switch (result.status) {
      case HintOutcomeStatus.delivered:
      case HintOutcomeStatus.repeated:
        final hint = result.hint!;
        final arguments = Map<String, Object?>.from(hint.arguments);
        final direction = arguments['direction'];
        if (direction is String)
          arguments['direction'] = strings.text('direction.$direction');
        await showModalBottomSheet<void>(
          context: context,
          showDragHandle: true,
          builder: (context) => SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 28),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  const CircleAvatar(
                    radius: 28,
                    child: Icon(Icons.lightbulb_rounded),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    strings.text(hint.messageKey, arguments),
                    style: Theme.of(context).textTheme.titleLarge,
                    textAlign: TextAlign.center,
                  ),
                  if (result.status == HintOutcomeStatus.repeated) ...<Widget>[
                    const SizedBox(height: 10),
                    Text(
                      strings.text('game.hintRepeated'),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ],
              ),
            ),
          ),
        );
      case HintOutcomeStatus.noTokens:
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(strings.text('game.noTokens'))));
      case HintOutcomeStatus.unavailable:
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(strings.text('game.noHint'))));
    }
  }

  Future<void> _pause() async {
    final session = _session!;
    session.pause();
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        icon: const Icon(Icons.pause_circle_outline_rounded, size: 40),
        title: Text(context.strings.text('game.paused')),
        content: Text(context.strings.text('game.pausedBody')),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              session.restart();
              Navigator.pop(context);
            },
            child: Text(context.strings.text('game.restart')),
          ),
          TextButton(
            onPressed: () async {
              await ControllerScope.read(context).persistSession();
              if (!mounted || !context.mounted) return;
              Navigator.of(context).pop();
              Navigator.of(this.context).pop();
            },
            child: Text(context.strings.text('game.quit')),
          ),
          FilledButton(
            onPressed: () {
              session.resume();
              Navigator.pop(context);
            },
            child: Text(context.strings.text('game.resume')),
          ),
        ],
      ),
    );
  }

  Future<void> _saveAndLeave() async {
    _session?.pause();
    await ControllerScope.read(context).persistSession();
    if (mounted) Navigator.of(context).pop();
  }

  String _formatDuration(Duration value) {
    final hours = value.inHours;
    final minutes = value.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = value.inSeconds.remainder(60).toString().padLeft(2, '0');
    return hours > 0 ? '$hours:$minutes:$seconds' : '$minutes:$seconds';
  }
}

class _CompactStatus extends StatelessWidget {
  const _CompactStatus({required this.session, required this.elapsed});
  final PuzzleSessionController session;
  final String elapsed;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
    child: Row(
      children: <Widget>[
        Expanded(
          child: _StatusChip(
            icon: Icons.touch_app_rounded,
            label: context.strings.text('game.moves', <String, Object?>{
              'count': session.state.moveCount,
            }),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _StatusChip(icon: Icons.timer_outlined, label: elapsed),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _StatusChip(
            icon: Icons.lightbulb_outline_rounded,
            label: '${session.hintTokens}',
          ),
        ),
      ],
    ),
  );
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.icon, required this.label});
  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) => Container(
    height: 48,
    padding: const EdgeInsets.symmetric(horizontal: 10),
    decoration: BoxDecoration(
      color: Theme.of(context).colorScheme.surfaceContainer,
      borderRadius: BorderRadius.circular(14),
    ),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Icon(icon, size: 19),
        const SizedBox(width: 6),
        Flexible(child: Text(label, overflow: TextOverflow.ellipsis)),
      ],
    ),
  );
}

class _BottomActions extends StatelessWidget {
  const _BottomActions({
    required this.session,
    required this.onHint,
    required this.onPause,
  });
  final PuzzleSessionController session;
  final VoidCallback onHint;
  final VoidCallback onPause;

  @override
  Widget build(BuildContext context) => Material(
    elevation: 4,
    child: SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: <Widget>[
            IconButton(
              tooltip: context.strings.text('game.undo'),
              onPressed: session.canUndo ? session.undo : null,
              icon: const Icon(Icons.undo_rounded),
            ),
            IconButton(
              tooltip: context.strings.text('game.redo'),
              onPressed: session.canRedo ? session.redo : null,
              icon: const Icon(Icons.redo_rounded),
            ),
            FilledButton.tonalIcon(
              onPressed: onHint,
              icon: const Icon(Icons.lightbulb_outline_rounded),
              label: Text(context.strings.text('game.hint')),
            ),
            IconButton(
              tooltip: context.strings.text('game.pause'),
              onPressed: onPause,
              icon: const Icon(Icons.pause_rounded),
            ),
          ],
        ),
      ),
    ),
  );
}

class _GameSidebar extends StatelessWidget {
  const _GameSidebar({
    required this.session,
    required this.elapsed,
    required this.onHint,
    required this.onPause,
  });
  final PuzzleSessionController session;
  final String elapsed;
  final VoidCallback onHint;
  final VoidCallback onPause;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.all(20),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Text(
          context.strings.text(session.module.rulesKey),
          style: Theme.of(context).textTheme.bodyLarge,
        ),
        const SizedBox(height: 24),
        _StatusChip(
          icon: Icons.touch_app_rounded,
          label: context.strings.text('game.moves', <String, Object?>{
            'count': session.state.moveCount,
          }),
        ),
        const SizedBox(height: 8),
        _StatusChip(icon: Icons.timer_outlined, label: elapsed),
        const SizedBox(height: 20),
        FilledButton.tonalIcon(
          onPressed: onHint,
          icon: const Icon(Icons.lightbulb_outline_rounded),
          label: Text(context.strings.text('game.hint')),
        ),
        const SizedBox(height: 8),
        Row(
          children: <Widget>[
            Expanded(
              child: OutlinedButton.icon(
                onPressed: session.canUndo ? session.undo : null,
                icon: const Icon(Icons.undo_rounded),
                label: Text(context.strings.text('game.undo')),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: session.canRedo ? session.redo : null,
                icon: const Icon(Icons.redo_rounded),
                label: Text(context.strings.text('game.redo')),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        OutlinedButton.icon(
          onPressed: onPause,
          icon: const Icon(Icons.pause_rounded),
          label: Text(context.strings.text('game.pause')),
        ),
      ],
    ),
  );
}
