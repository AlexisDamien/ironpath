import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../constants/enums.dart';

final providerUnitSystem = StateProvider<UnitSystem>(
  (ref) => UnitSystem.metric,
);
