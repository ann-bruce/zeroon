import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zeroon_mobile/l10n/app_localizations.dart';
import 'package:zeroon_mobile/locale/locale_controller.dart';
import 'package:zeroon_mobile/locale/locale_preference.dart';
import 'package:zeroon_mobile/support/support_models.dart';
import 'package:zeroon_mobile/support/support_repository.dart';
import 'package:zeroon_mobile/support/support_screen.dart';

void main() {
  test('uses the approved Outlook fallback by default', () {
    expect(zeroonSupportEmail, 'zeroon_ai@outlook.com');
  });

  testWidgets('signed-out support stays available without calling the API', (
    tester,
  ) async {
    final repository = _FakeSupportRepository();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          supportRepositoryProvider.overrideWithValue(repository),
        ],
        child: _localizedApp(
          const SupportScreen(authenticated: false),
          locale: const Locale('en'),
        ),
      ),
    );

    expect(find.text('Help and feedback'), findsOneWidget);
    expect(find.text(zeroonSupportEmail), findsOneWidget);
    expect(find.textContaining('outside in-app tracking'), findsOneWidget);
    expect(find.textContaining('180 days'), findsOneWidget);
    expect(find.text('Send to the ZEROON team'), findsNothing);
    expect(repository.requests, isEmpty);
  });

  testWidgets('failed submission keeps the draft and offers email fallback', (
    tester,
  ) async {
    final repository = _FakeSupportRepository(fail: true);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          supportRepositoryProvider.overrideWithValue(repository),
        ],
        child: _localizedApp(
          const SupportScreen(authenticated: true),
        ),
      ),
    );

    const draft = '  点击保存后页面没有变化  ';
    await tester.enterText(
      find.byKey(const Key('support-description')),
      draft,
    );
    final submit = find.text('发送给 ZEROON 团队');
    await tester.drag(find.byType(ListView), const Offset(0, -420));
    await tester.pumpAndSettle();
    expect(submit, findsOneWidget);
    await tester.tap(find.byType(FilledButton));
    await tester.pumpAndSettle();

    expect(find.text(draft), findsOneWidget);
    expect(find.text('重新发送'), findsOneWidget);
    expect(find.textContaining('草稿仍保留'), findsOneWidget);
    expect(find.text(zeroonSupportEmail), findsWidgets);
    expect(repository.requests.single.clientSubmissionId, isNotEmpty);
    expect(repository.requests.single.description, draft);
    expect(repository.requests.single.diagnostics, isNull);
  });

  testWidgets('successful submission shows an honest opaque receipt', (
    tester,
  ) async {
    final repository = _FakeSupportRepository();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          supportRepositoryProvider.overrideWithValue(repository),
          initialLocaleStateProvider.overrideWithValue(
            const LocaleState(
              preference: LocalePreference.english,
              pendingAccountSync: false,
              deviceStorageAvailable: true,
            ),
          ),
          systemLocalesProvider.overrideWithValue(const [Locale('en')]),
        ],
        child: _localizedApp(
          const SupportScreen(authenticated: true),
          locale: const Locale('en'),
        ),
      ),
    );

    await tester.enterText(
      find.byKey(const Key('support-description')),
      'A suggestion for the archive',
    );
    await tester.drag(find.byType(ListView), const Offset(0, -320));
    await tester.pumpAndSettle();
    await tester.tap(find.byType(Switch));
    await tester.pump();
    expect(find.text('Information to be sent'), findsOneWidget);
    expect(find.textContaining('App: 1.0.0+1'), findsOneWidget);

    final submit = find.text('Send to the ZEROON team');
    await tester.drag(find.byType(ListView), const Offset(0, -620));
    await tester.pumpAndSettle();
    expect(submit, findsOneWidget);
    await tester.tap(find.byType(FilledButton));
    await tester.pumpAndSettle();

    expect(find.text('Your message was received'), findsOneWidget);
    expect(find.text('ZRN-260723-AB12CD'), findsOneWidget);
    expect(find.textContaining('does not promise'), findsOneWidget);
    expect(find.textContaining('180 days'), findsOneWidget);
    expect(repository.requests.single.diagnosticConsent, isTrue);
    expect(repository.requests.single.diagnostics?.locale, 'en');
  });

  testWidgets('support screen fits a narrow English viewport', (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      ProviderScope(
        child: _localizedApp(
          const SupportScreen(authenticated: false),
          locale: const Locale('en'),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.text(zeroonSupportEmail), findsOneWidget);
  });
}

Widget _localizedApp(
  Widget home, {
  Locale locale = const Locale('zh', 'CN'),
}) {
  return MaterialApp(
    locale: locale,
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: home,
  );
}

class _FakeSupportRepository extends SupportRepository {
  _FakeSupportRepository({this.fail = false}) : super(Dio());

  final bool fail;
  final List<CreateSupportRequest> requests = [];

  @override
  Future<SupportReceipt> create(CreateSupportRequest request) async {
    requests.add(request);
    if (fail) {
      throw DioException(requestOptions: RequestOptions());
    }
    return SupportReceipt(
      reference: 'ZRN-260723-AB12CD',
      category: request.category.wireValue,
      status: 'RECEIVED',
      subject: request.subject,
      createdAt: DateTime.parse('2026-07-23T06:00:00Z'),
    );
  }
}
