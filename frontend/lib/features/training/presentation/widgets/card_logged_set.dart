import 'package:flutter/material.dart';

import '../../../../core/utils/format_duration.dart';
import '../../domain/models/training_session.dart';

class CardLoggedSet extends StatelessWidget {
  final ExerciseSet exerciseSet;
  final String exerciseName;

  const CardLoggedSet({
    super.key,
    required this.exerciseSet,
    required this.exerciseName,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(child: Text('${exerciseSet.setOrder}')),
        title: Text(exerciseName),
        subtitle: Text(
          '${exerciseSet.reps ?? '-'} reps • ${exerciseSet.weightKg ?? '-'} kg • ${formatRestDuration(exerciseSet.restSeconds)} repos',
        ),
      ),
    );
  }
}
