import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ironpath/features/identity/presentation/screens/screen_login.dart';

void main() {
  testWidgets(
    'ScreenLogin respects the WCAG accessibility guidelines built into Flutter',
    (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(home: ScreenLogin()),
        ),
      );

      final handle = tester.ensureSemantics();

      // Contraste de texte suffisant (WCAG 2.1 AA : ratio 4.5:1 minimum).
      await expectLater(tester, meetsGuideline(textContrastGuideline));

      // Taille minimale des zones tactiles recommandée par Material Design
      // (48x48 dp), cohérente avec les recommandations WCAG "Target Size".
      await expectLater(tester, meetsGuideline(androidTapTargetGuideline));

      // Chaque élément tactile doit porter un label exploitable par un
      // lecteur d'écran (TalkBack/VoiceOver).
      await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));

      handle.dispose();
    },
  );
}
