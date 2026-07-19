enum UnitSystem {
  metric,
  imperial;

  String get lengthUnit => this == UnitSystem.metric ? 'cm' : 'in';
  String get weightUnit => this == UnitSystem.metric ? 'kg' : 'lbs';
}

enum StatusAuth {
  initial,
  authenticated,
  unauthenticated,
  loading,
  error,
}

enum StatusProfile {
  idle,
  loading,
  success,
  error,
}

enum StatusBodyMetrics {
  idle,
  loading,
  success,
  error,
}

enum StatusTraining {
  idle,
  loading,
  success,
  error,
}
