enum UnitSystem {
  metric,
  imperial;

  String get lengthUnit => this == UnitSystem.metric ? 'cm' : 'in';
  String get weightUnit => this == UnitSystem.metric ? 'kg' : 'lbs';
}
