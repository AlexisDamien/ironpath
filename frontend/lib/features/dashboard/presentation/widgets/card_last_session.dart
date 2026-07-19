import 'package:flutter/material.dart';

import '../../../../core/utils/format_date.dart';
import '../../../training/domain/models/training_session.dart';

class CardLastSession extends StatelessWidget {
  final TrainingSession? lastSession;

  const CardLastSession({super.key, this.lastSession});

  @override
  Widget build(BuildContext context) {
    final session = lastSession;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Dernière séance',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 8),
            if (session == null)
              const Text(
                'Aucune séance enregistrée',
                style: TextStyle(color: Colors.grey),
              )
            else ...[
              Text(
                session.name ?? 'Séance libre',
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 4),
              Text(
                '${session.sets.length} set${session.sets.length > 1 ? 's' : ''} • ${formatDate(session.startedAt)}',
                style: const TextStyle(
                  color: Colors.grey,
                  fontSize: 13,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
