import '../../../core/constants/enums.dart';
import 'models/body_composition.dart';
import 'models/body_measurement.dart';

export '../../../core/constants/enums.dart' show StatusBodyMetrics;

class StateBodyMetrics {
  final StatusBodyMetrics status;
  final List<BodyMeasurement> measurements;
  final List<BodyComposition> compositions;
  final String? errorMessage;
  final bool isInitialized;

  const StateBodyMetrics({
    this.status = StatusBodyMetrics.idle,
    this.measurements = const [],
    this.compositions = const [],
    this.errorMessage,
    this.isInitialized = false,
  });

  StateBodyMetrics copyWith({
    StatusBodyMetrics? status,
    List<BodyMeasurement>? measurements,
    List<BodyComposition>? compositions,
    String? errorMessage,
    bool? isInitialized,
    bool clearErrorMessage = false,
  }) {
    return StateBodyMetrics(
      status: status ?? this.status,
      measurements: measurements ?? this.measurements,
      compositions: compositions ?? this.compositions,
      errorMessage: clearErrorMessage
          ? null
          : errorMessage ?? this.errorMessage,
      isInitialized: isInitialized ?? this.isInitialized,
    );
  }
}
