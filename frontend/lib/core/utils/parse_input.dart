String? parseNullableText(String value) {
  final normalizedValue = value.trim();
  return normalizedValue.isEmpty ? null : normalizedValue;
}

double? parseDecimal(String value) {
  return double.tryParse(value.trim().replaceAll(',', '.'));
}
