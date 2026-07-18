import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/provider_training.dart';
import '../../domain/models/training_session.dart';
import '../widgets/card_active_session_exercise.dart';

class ScreenSessionHistory extends ConsumerStatefulWidget {
  const ScreenSessionHistory({super.key});

  @override
  ConsumerState<ScreenSessionHistory> createState() =>
      _ScreenSessionHistoryState();
}

class _ScreenSessionHistoryState extends ConsumerState<ScreenSessionHistory> {
  @override
  void initState() {
    super.initState();
    Future.microtask(
        () => ref.read(providerTraining.notifier).loadSessionHistory());
  }

  String _exerciseName(List exercises, String exerciseId) {
    for (final exercise in exercises) {
      if (exercise.id == exerciseId) return exercise.name as String;
    }
    return exerciseId;
  }

  String _formatDateRange(TrainingSession session) {
    final start = session.startedAt;
    final formattedDate =
        '${start.day.toString().padLeft(2, '0')}/${start.month.toString().padLeft(2, '0')}/${start.year}';
    if (session.endedAt == null) return formattedDate;
    final duration = session.endedAt!.difference(session.startedAt);
    return '$formattedDate • ${duration.inMinutes} min';
  }

  @override
  Widget build(BuildContext context) {
    final trainingState = ref.watch(providerTraining);
    final history = trainingState.sessionHistory;

    if (history.isEmpty) {
      return Center(
        child: Text(
          'Aucune session terminée pour le moment',
          style: TextStyle(
            color:
                Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: history.length,
      itemBuilder: (context, index) {
        final session = history[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ExpansionTile(
            title: Text(session.name ?? 'Session'),
            subtitle: Text(_formatDateRange(session)),
            children: [
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: session.sets.isEmpty
                      ? [
                          const Text('Aucun set enregistré',
                              style: TextStyle(color: Colors.grey))
                        ]
                      : session.sets.map((set) {
                          final name = _exerciseName(
                              trainingState.exercises, set.exerciseId);
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 2),
                            child: Text(
                              '$name — série ${set.setOrder} : ${set.reps ?? '-'} reps • ${set.weightKg ?? '-'} kg • ${formatRestDuration(set.restSeconds)} repos',
                              style: const TextStyle(fontSize: 13),
                            ),
                          );
                        }).toList(),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
