import 'package:flutter/material.dart';

import '../../../../core/widgets/component_modal_header.dart';
import '../../domain/models/workout_program.dart';

Future<WorkoutProgram?> showSelectProgramSheet(
  BuildContext context, {
  required List<WorkoutProgram> programs,
}) {
  return showModalBottomSheet<WorkoutProgram>(
    context: context,
    isScrollControlled: true,
    builder: (sheetContext) => SafeArea(
      top: false,
      child: FractionallySizedBox(
        heightFactor: 0.72,
        child: Column(
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(24, 12, 8, 0),
              child: ComponentModalHeader(title: 'Choisir un programme'),
            ),
            Expanded(
              child: ListView.separated(
                itemCount: programs.length,
                separatorBuilder: (context, index) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final program = programs[index];
                  return ListTile(
                    title: Text(program.name),
                    subtitle: Text(
                      '${program.exercises.length} exercice${program.exercises.length > 1 ? 's' : ''}',
                    ),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () => Navigator.of(sheetContext).pop(program),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
