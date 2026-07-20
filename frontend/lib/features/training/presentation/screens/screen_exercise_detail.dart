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
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        backgroundColor: colorScheme.surface,
        title: Text(
          exercise.name,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
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
        bottom: !showAddButton,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    Semantics(
                      label: 'Exercice de musculation',
                      child: Icon(
                        Icons.fitness_center,
                        size: 64,
                        color: colorScheme.primary,
                      ),
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
              if (exercise.description != null &&
                  exercise.description!.trim().isNotEmpty) ...[
                const Divider(height: 32),
                Semantics(
                  header: true,
                  child: const Text(
                    'Description',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  exercise.description!,
                  style: TextStyle(
                    fontSize: 15,
                    height: 1.5,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
      bottomNavigationBar: showAddButton
          ? SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: ElevatedButton.icon(
                  onPressed: () => Navigator.of(
                    context,
                  ).pop(isSelected ? 'remove_from_program' : 'add_to_program'),
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
    final colorScheme = Theme.of(context).colorScheme;

    return Semantics(
      container: true,
      label: '$label : $value',
      child: ExcludeSemantics(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: colorScheme.primary, size: 24),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 12,
                      color: colorScheme.onSurfaceVariant,
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
            ),
          ],
        ),
      ),
    );
  }
}
