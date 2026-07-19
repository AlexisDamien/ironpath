String formatDate(DateTime date) {
  final day = date.day.toString().padLeft(2, '0');
  final month = date.month.toString().padLeft(2, '0');
  return '$day/$month/${date.year}';
}

String formatApiDate(String? value, {String fallback = 'Non renseigné'}) {
  if (value == null || value.trim().isEmpty) {
    return fallback;
  }

  final parsedDate = DateTime.tryParse(value);
  return parsedDate == null ? value : formatDate(parsedDate);
}

String formatDateForApi(DateTime date) {
  final month = date.month.toString().padLeft(2, '0');
  final day = date.day.toString().padLeft(2, '0');
  return '${date.year}-$month-$day';
}
