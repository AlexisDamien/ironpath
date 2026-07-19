import 'package:flutter/material.dart';

import '../../../../core/utils/format_date.dart';
import '../../../../core/utils/format_profile.dart';
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
    final currentProfile = profile;
    final username = currentProfile?.username?.trim();

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
                formatProfileDisplayName(
                  firstName: currentProfile?.firstName,
                  lastName: currentProfile?.lastName,
                  username: currentProfile?.username,
                ),
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            if (username != null && username.isNotEmpty) ...[
              const SizedBox(height: 4),
              Center(
                child: Text(
                  '@$username',
                  style: const TextStyle(color: Colors.grey),
                ),
              ),
            ],
            const Divider(height: 32),
            if (currentProfile == null)
              const Text(
                'Complète ton profil pour personnaliser ton suivi.',
                style: TextStyle(color: Colors.grey),
              )
            else ...[
              _ProfileInfoRow(
                icon: Icons.cake_outlined,
                label: 'Date de naissance',
                value: formatApiDate(currentProfile.birthDate),
              ),
              const SizedBox(height: 12),
              _ProfileInfoRow(
                icon: Icons.height,
                label: 'Taille',
                value: currentProfile.height == null
                    ? 'Non renseigné'
                    : '${currentProfile.height} cm',
              ),
              const SizedBox(height: 12),
              _ProfileInfoRow(
                icon: Icons.person_outline,
                label: 'Genre',
                value: formatGender(currentProfile.gender),
              ),
              const SizedBox(height: 12),
              _ProfileInfoRow(
                icon: Icons.flag_outlined,
                label: 'Objectif',
                value: formatObjective(currentProfile.objective),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _ProfileInfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _ProfileInfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.grey),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
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
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
