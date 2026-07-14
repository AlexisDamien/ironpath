import 'package:flutter/material.dart';
import '../../domain/models/profile.dart';

class CardProfile extends StatelessWidget {
  final Profile? profile;
  final VoidCallback onEdit;

  const CardProfile({
    super.key,
    required this.profile,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                Center(
                  child: CircleAvatar(
                    radius: 40,
                    backgroundColor:
                        Theme.of(context).colorScheme.primaryContainer,
                    child: Icon(
                      Icons.person,
                      size: 40,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ),
                Positioned(
                  top: 0,
                  right: 0,
                  child: IconButton(
                    icon: const Icon(Icons.edit_outlined),
                    onPressed: onEdit,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Center(
              child: Text(
                profile != null
                    ? '${profile!.firstName ?? ''} ${profile!.lastName ?? ''}'
                            .trim()
                            .isEmpty
                        ? profile!.username ?? 'Utilisateur'
                        : '${profile!.firstName ?? ''} ${profile!.lastName ?? ''}'
                            .trim()
                    : 'Utilisateur',
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            if (profile?.username != null) ...[
              const SizedBox(height: 4),
              Center(
                child: Text(
                  '@${profile!.username}',
                  style: const TextStyle(color: Colors.grey),
                ),
              ),
            ],
            const Divider(height: 32),
            if (profile != null) ...[
              _buildInfoRow(Icons.cake_outlined, 'Date de naissance',
                  profile!.birthDate ?? 'Non renseigné'),
              const SizedBox(height: 12),
              _buildInfoRow(
                  Icons.height,
                  'Taille',
                  profile!.height != null
                      ? '${profile!.height} cm'
                      : 'Non renseigné'),
              const SizedBox(height: 12),
              _buildInfoRow(Icons.person_outline, 'Genre',
                  _formatGender(profile!.gender)),
              const SizedBox(height: 12),
              _buildInfoRow(Icons.flag_outlined, 'Objectif',
                  _formatObjective(profile!.objective)),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.grey),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
            Text(
              value,
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ],
    );
  }

  String _formatGender(String? gender) {
    return switch (gender) {
      'MALE' => 'Homme',
      'FEMALE' => 'Femme',
      'OTHER' => 'Autre',
      _ => 'Non renseigné',
    };
  }

  String _formatObjective(String? objective) {
    return switch (objective) {
      'MUSCLE_GAIN' => 'Prise de masse',
      'WEIGHT_LOSS' => 'Perte de poids',
      'MAINTENANCE' => 'Maintien',
      'ENDURANCE' => 'Endurance',
      'STRENGTH' => 'Force',
      _ => 'Non renseigné',
    };
  }
}
