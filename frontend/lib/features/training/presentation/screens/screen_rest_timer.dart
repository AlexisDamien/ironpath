import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/utils/format_duration.dart';
import '../providers/provider_rest_timer.dart';
import '../../domain/state_rest_timer.dart';

class ScreenRestTimer extends ConsumerStatefulWidget {
  final int? initialSeconds;
  final String? id;

  const ScreenRestTimer({super.key, this.initialSeconds, this.id});

  @override
  ConsumerState<ScreenRestTimer> createState() => _ScreenRestTimerState();
}

class _ScreenRestTimerState extends ConsumerState<ScreenRestTimer> {
  @override
  void initState() {
    super.initState();
    if (widget.id != null && widget.initialSeconds != null) {
      final current = ref.read(providerRestTimer);
      if (current.activeOwnerId != widget.id) {
        Future.microtask(() {
          ref
              .read(providerRestTimer.notifier)
              .start(widget.initialSeconds!, widget.id!);
        });
      }
    }
  }

  String _ownerId(StateRestTimer timerState) {
    return timerState.activeOwnerId ??
        widget.id ??
        'manual-${DateTime.now().millisecondsSinceEpoch}';
  }

  void _applyChange(int minutes, int seconds, StateRestTimer timerState) {
    final total = (minutes * 60) + seconds;
    ref
        .read(providerRestTimer.notifier)
        .setDuration(total, _ownerId(timerState));
  }

  @override
  Widget build(BuildContext context) {
    final timerState = ref.watch(providerRestTimer);
    final notifier = ref.read(providerRestTimer.notifier);
    final isOvertime = timerState.isOvertime;
    final displaySeconds = timerState.isActive
        ? timerState.remainingSeconds
        : (widget.initialSeconds ?? 90);
    final colorScheme = Theme.of(context).colorScheme;
    final textScale = MediaQuery.textScalerOf(context).scale(16) / 16;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        backgroundColor: colorScheme.surface,
        title: const Text('Temps de repos'),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.close),
            tooltip: 'Fermer',
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
      body: SafeArea(
        top: false,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final useVerticalEditor =
                constraints.maxWidth < 390 || textScale > 1.35;

            return SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight - 48,
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (isOvertime) ...[
                        Semantics(
                          liveRegion: true,
                          label:
                              'Dépassement de ${formatClockDuration(timerState.overtimeSeconds)}',
                          child: ExcludeSemantics(
                            child: Column(
                              children: [
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.warning_amber_outlined,
                                      color: colorScheme.error,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      'Dépassement',
                                      style: TextStyle(
                                        color: colorScheme.error,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  '+${formatClockDuration(timerState.overtimeSeconds)}',
                                  style: TextStyle(
                                    fontSize: 64,
                                    fontWeight: FontWeight.bold,
                                    color: colorScheme.error,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ] else if (useVerticalEditor)
                        Column(
                          children: [
                            _TimeUnitStepper(
                              unitLabel: 'Minutes',
                              value: displaySeconds ~/ 60,
                              max: 99,
                              enabled: !timerState.isRunning,
                              onChanged: (minutes) => _applyChange(
                                minutes,
                                displaySeconds % 60,
                                timerState,
                              ),
                            ),
                            const SizedBox(height: 16),
                            _TimeUnitStepper(
                              unitLabel: 'Secondes',
                              value: displaySeconds % 60,
                              max: 59,
                              enabled: !timerState.isRunning,
                              onChanged: (seconds) => _applyChange(
                                displaySeconds ~/ 60,
                                seconds,
                                timerState,
                              ),
                            ),
                          ],
                        )
                      else
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            _TimeUnitStepper(
                              unitLabel: 'Minutes',
                              value: displaySeconds ~/ 60,
                              max: 99,
                              enabled: !timerState.isRunning,
                              onChanged: (minutes) => _applyChange(
                                minutes,
                                displaySeconds % 60,
                                timerState,
                              ),
                            ),
                            const Padding(
                              padding: EdgeInsets.symmetric(horizontal: 8),
                              child: Text(
                                ':',
                                style: TextStyle(
                                  fontSize: 48,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            _TimeUnitStepper(
                              unitLabel: 'Secondes',
                              value: displaySeconds % 60,
                              max: 59,
                              enabled: !timerState.isRunning,
                              onChanged: (seconds) => _applyChange(
                                displaySeconds ~/ 60,
                                seconds,
                                timerState,
                              ),
                            ),
                          ],
                        ),
                      const SizedBox(height: 32),
                      Wrap(
                        spacing: 24,
                        runSpacing: 12,
                        alignment: WrapAlignment.center,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          IconButton(
                            iconSize: 48,
                            icon: const Icon(Icons.replay),
                            tooltip: 'Recommencer le minuteur',
                            onPressed: timerState.isActive
                                ? notifier.reset
                                : null,
                          ),
                          IconButton(
                            iconSize: 64,
                            icon: Icon(
                              timerState.isRunning
                                  ? Icons.pause_circle
                                  : Icons.play_circle,
                            ),
                            tooltip: timerState.isRunning
                                ? 'Mettre le minuteur en pause'
                                : 'Reprendre le minuteur',
                            onPressed: timerState.isActive
                                ? notifier.togglePlayPause
                                : null,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _TimeUnitStepper extends StatefulWidget {
  final String unitLabel;
  final int value;
  final int max;
  final bool enabled;
  final ValueChanged<int> onChanged;

  const _TimeUnitStepper({
    required this.unitLabel,
    required this.value,
    required this.max,
    required this.enabled,
    required this.onChanged,
  });

  @override
  State<_TimeUnitStepper> createState() => _TimeUnitStepperState();
}

class _TimeUnitStepperState extends State<_TimeUnitStepper> {
  late TextEditingController _controller;
  late FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(
      text: widget.value.toString().padLeft(2, '0'),
    );
    _focusNode = FocusNode();
    _focusNode.addListener(_onFocusChange);
  }

  @override
  void didUpdateWidget(covariant _TimeUnitStepper oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!_focusNode.hasFocus && oldWidget.value != widget.value) {
      _controller.text = widget.value.toString().padLeft(2, '0');
    }
  }

  void _onFocusChange() {
    if (!_focusNode.hasFocus) _submit();
  }

  void _submit() {
    final parsed = int.tryParse(_controller.text);
    if (parsed != null) {
      final clamped = parsed.clamp(0, widget.max);
      if (clamped != widget.value) widget.onChanged(clamped);
      _controller.text = clamped.toString().padLeft(2, '0');
    } else {
      _controller.text = widget.value.toString().padLeft(2, '0');
    }
  }

  void _increment() =>
      widget.onChanged((widget.value + 1).clamp(0, widget.max));

  void _decrement() =>
      widget.onChanged((widget.value - 1).clamp(0, widget.max));

  @override
  void dispose() {
    _focusNode.removeListener(_onFocusChange);
    _focusNode.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      container: true,
      label: widget.unitLabel,
      value: '${widget.value}',
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: const Icon(Icons.keyboard_arrow_up),
            tooltip: 'Augmenter les ${widget.unitLabel.toLowerCase()}',
            onPressed: widget.enabled ? _increment : null,
          ),
          SizedBox(
            width: 140,
            child: TextField(
              controller: _controller,
              focusNode: _focusNode,
              enabled: widget.enabled,
              textAlign: TextAlign.center,
              keyboardType: TextInputType.number,
              maxLength: 2,
              style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold),
              decoration: InputDecoration(
                labelText: widget.unitLabel,
                counterText: '',
              ),
              onSubmitted: (_) => _submit(),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.keyboard_arrow_down),
            tooltip: 'Diminuer les ${widget.unitLabel.toLowerCase()}',
            onPressed: widget.enabled ? _decrement : null,
          ),
        ],
      ),
    );
  }
}
