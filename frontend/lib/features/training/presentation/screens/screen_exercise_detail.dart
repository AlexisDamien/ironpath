import 'package:flutter/material.dart';
import '../../domain/models/exercise.dart';

class ScreenExerciseDetail extends StatelessWidget {
  final Exercise exercise;
  final bool showAddButton;
  final bool isSelected;

  const ScreenExerciseDetail({
    super.key,
    required this.exercise,
    this.showAddButton = false,
    this.isSelected = false,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.surface,
        title: Text(
          exercise.name,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.fitness_center,
                    size: 64,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    exercise.name,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            _buildInfoRow(
              context,
              icon: Icons.sports,
              label: 'Groupe musculaire',
              value: exercise.muscleGroup ?? 'Non défini',
            ),
            const Divider(height: 32),
            _buildInfoRow(
              context,
              icon: Icons.sports_gymnastics,
              label: 'Équipement',
              value: exercise.equipment ?? 'Aucun',
            ),
            if (exercise.description != null) ...[
              const Divider(height: 32),
              const Text(
                'Description',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                exercise.description!,
                style: const TextStyle(
                  fontSize: 15,
                  height: 1.5,
                  color: Colors.grey,
                ),
              ),
            ],
          ],
        ),
      ),
      bottomNavigationBar: showAddButton
          ? Padding(
              padding: const EdgeInsets.all(16),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => Navigator.of(context).pop(
                    isSelected ? 'remove_from_program' : 'add_to_program',
                  ),
                  icon: Icon(
                    isSelected
                        ? Icons.remove_circle_outline
                        : Icons.add_circle_outline,
                  ),
                  label: Text(
                    isSelected
                        ? 'Retirer du programme'
                        : 'Ajouter au programme',
                  ),
                ),
              ),
            )
          : null,
    );
  }

  Widget _buildInfoRow(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Icon(
          icon,
          color: Theme.of(context).colorScheme.primary,
          size: 24,
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                color: Colors.grey,
              ),
            ),
            Text(
              value,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
