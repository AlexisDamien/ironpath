import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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

  String _format(int totalSeconds) {
    final minutes = totalSeconds ~/ 60;
    final seconds = totalSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
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

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.surface,
        title: const Text('Temps de repos'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (isOvertime) ...[
              Text(
                'Dépassement',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.error,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '+${_format(timerState.overtimeSeconds)}',
                style: TextStyle(
                  fontSize: 72,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.error,
                ),
              ),
            ] else
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  _TimeUnitStepper(
                    value: displaySeconds ~/ 60,
                    max: 99,
                    enabled: !timerState.isRunning,
                    onChanged: (minutes) =>
                        _applyChange(minutes, displaySeconds % 60, timerState),
                  ),
                  const Padding(
                    padding: EdgeInsets.only(bottom: 32),
                    child: Text(':',
                        style: TextStyle(
                            fontSize: 48, fontWeight: FontWeight.bold)),
                  ),
                  _TimeUnitStepper(
                    value: displaySeconds % 60,
                    max: 59,
                    enabled: !timerState.isRunning,
                    onChanged: (seconds) =>
                        _applyChange(displaySeconds ~/ 60, seconds, timerState),
                  ),
                ],
              ),
            const SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  iconSize: 48,
                  icon: const Icon(Icons.replay),
                  onPressed: timerState.isActive ? notifier.reset : null,
                ),
                const SizedBox(width: 24),
                IconButton(
                  iconSize: 64,
                  icon: Icon(timerState.isRunning
                      ? Icons.pause_circle
                      : Icons.play_circle),
                  onPressed:
                      timerState.isActive ? notifier.togglePlayPause : null,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _TimeUnitStepper extends StatefulWidget {
  final int value;
  final int max;
  final bool enabled;
  final ValueChanged<int> onChanged;

  const _TimeUnitStepper({
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
    _controller =
        TextEditingController(text: widget.value.toString().padLeft(2, '0'));
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
    if (!_focusNode.hasFocus) {
      _submit();
    }
  }

  void _submit() {
    final parsed = int.tryParse(_controller.text);
    if (parsed != null) {
      final clamped = parsed.clamp(0, widget.max);
      if (clamped != widget.value) {
        widget.onChanged(clamped);
      }
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
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          icon: const Icon(Icons.keyboard_arrow_up),
          onPressed: widget.enabled ? _increment : null,
        ),
        SizedBox(
          width: 110,
          child: TextField(
            controller: _controller,
            focusNode: _focusNode,
            enabled: widget.enabled,
            textAlign: TextAlign.center,
            keyboardType: TextInputType.number,
            maxLength: 2,
            style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold),
            decoration: const InputDecoration(
              border: InputBorder.none,
              isDense: true,
              counterText: '',
            ),
            onSubmitted: (_) => _submit(),
          ),
        ),
        IconButton(
          icon: const Icon(Icons.keyboard_arrow_down),
          onPressed: widget.enabled ? _decrement : null,
        ),
      ],
    );
  }
}
