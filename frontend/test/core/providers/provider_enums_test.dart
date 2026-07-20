import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ironpath/core/constants/enums.dart';
import 'package:ironpath/core/providers/provider_enums.dart';

void main() {
  test('le système d’unités est métrique par défaut et modifiable', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    expect(container.read(providerUnitSystem), UnitSystem.metric);

    container.read(providerUnitSystem.notifier).state = UnitSystem.imperial;
    expect(container.read(providerUnitSystem), UnitSystem.imperial);
  });
}
