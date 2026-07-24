import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zeroon_mobile/evidence/beta_notice_screen.dart';
import 'package:zeroon_mobile/l10n/app_localizations.dart';

void main() {
  testWidgets('English Beta notice fits and scrolls on a narrow viewport',
      (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    bool? selectedEvidence;
    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('en'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: BetaNoticeScreen(
          loading: false,
          onContinue: (enabled) async => selectedEvidence = enabled,
          onUnderage: () {},
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Before we begin, a clear boundary.'), findsOneWidget);
    expect(find.text('Adults only'), findsOneWidget);
    expect(tester.takeException(), isNull);

    await tester.scrollUntilVisible(
      find.text('Continue to meet ZEROON'),
      300,
    );
    expect(find.text('Continue to meet ZEROON'), findsOneWidget);
    expect(tester.takeException(), isNull);

    await tester.scrollUntilVisible(
      find.text('I confirm that I am 18 or older'),
      -300,
    );
    await tester.tap(find.text('I confirm that I am 18 or older'));
    await tester.scrollUntilVisible(
      find.text('Continue to meet ZEROON'),
      300,
    );
    await tester.tap(find.text('Continue to meet ZEROON'));
    await tester.pumpAndSettle();

    expect(selectedEvidence, isFalse);
    expect(tester.takeException(), isNull);
  });
}
