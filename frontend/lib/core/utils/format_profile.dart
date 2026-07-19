String formatProfileDisplayName({
  String? firstName,
  String? lastName,
  String? username,
}) {
  final fullName = [firstName, lastName]
      .whereType<String>()
      .map((value) => value.trim())
      .where((value) => value.isNotEmpty)
      .join(' ');

  if (fullName.isNotEmpty) {
    return fullName;
  }

  final normalizedUsername = username?.trim();
  if (normalizedUsername != null && normalizedUsername.isNotEmpty) {
    return normalizedUsername;
  }

  return 'Utilisateur';
}

String formatGender(String? gender) {
  return switch (gender) {
    'MALE' => 'Homme',
    'FEMALE' => 'Femme',
    'OTHER' => 'Autre',
    _ => 'Non renseigné',
  };
}

String formatObjective(String? objective) {
  return switch (objective) {
    'MUSCLE_GAIN' => 'Prise de masse',
    'WEIGHT_LOSS' => 'Perte de poids',
    'MAINTENANCE' => 'Maintien',
    'ENDURANCE' => 'Endurance',
    'STRENGTH' => 'Force',
    _ => 'Non renseigné',
  };
}
