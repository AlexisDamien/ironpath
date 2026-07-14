import 'models/body_composition.dart';
import 'models/body_measurement.dart';

enum BodyMetricsStatus { idle, loading, success, error }

class BodyMetricsState {
  final BodyMetricsStatus status;
  final List<BodyMeasurement> measurements;
  final List<BodyComposition> compositions;
  final String? errorMessage;
  final bool isInitialized;

  const BodyMetricsState({
    this.status = BodyMetricsStatus.idle,
    this.measurements = const [],
    this.compositions = const [],
    this.errorMessage,
    this.isInitialized = false,
  });

  BodyMetricsState copyWith({
    BodyMetricsStatus? status,
    List<BodyMeasurement>? measurements,
    List<BodyComposition>? compositions,
    String? errorMessage,
    bool? isInitialized,
  }) {
    return BodyMetricsState(
      status: status ?? this.status,
      measurements: measurements ?? this.measurements,
      compositions: compositions ?? this.compositions,
      errorMessage: errorMessage ?? this.errorMessage,
      isInitialized: isInitialized ?? this.isInitialized,
    );
  }
}
