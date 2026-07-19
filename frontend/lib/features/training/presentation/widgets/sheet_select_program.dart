import 'package:flutter/material.dart';

import '../../domain/models/workout_program.dart';

Future<WorkoutProgram?> showSelectProgramSheet(
  BuildContext context, {
  required List<WorkoutProgram> programs,
}) {
  return showModalBottomSheet<WorkoutProgram>(
    context: context,
    builder: (context) => SafeArea(
      child: ListView.separated(
        shrinkWrap: true,
        itemCount: programs.length,
        separatorBuilder: (context, index) => const Divider(height: 1),
        itemBuilder: (context, index) {
          final program = programs[index];
          return ListTile(
            title: Text(program.name),
            subtitle: Text(
              '${program.exercises.length} exercice${program.exercises.length > 1 ? 's' : ''}',
            ),
            onTap: () => Navigator.of(context).pop(program),
          );
        },
      ),
    ),
  );
}
