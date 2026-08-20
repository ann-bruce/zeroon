import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zeroon_mobile/evidence/evidence_models.dart';
import 'package:zeroon_mobile/evidence/evidence_repository.dart';
import 'package:zeroon_mobile/l10n/app_localizations.dart';
import 'package:zeroon_mobile/record/record_models.dart';
import 'package:zeroon_mobile/record/record_repository.dart';
import 'package:zeroon_mobile/record/reset_draft_store.dart';
import 'package:zeroon_mobile/record/reset_screen.dart';
import 'package:zeroon_mobile/state/state_controller.dart';
import 'package:zeroon_mobile/state/state_models.dart';

void main() {
  testWidgets('restores and persists one account-scoped Reset draft',
      (tester) async {
    final store = _MemoryResetDraftStore()
      ..values['user-a'] = const ResetDraft(
        intentKey: 'intent-a',
        content: '还没有保存的这一刻',
        goal: '慢慢往前一点',
        showSmallDirection: true,
        stateSessionId: 1,
      );

    await tester.pumpWidget(_testApp(store: store, ownerUid: 'user-a'));
    await tester.pumpAndSettle();

    expect(
      tester.widget<TextField>(find.byType(TextField).first).controller?.text,
      '还没有保存的这一刻',
    );
    expect(find.text('慢慢往前一点'), findsOneWidget);

    await tester.enterText(find.byType(TextField).first, '后来补上的一句');
    await tester.pump(const Duration(milliseconds: 400));

    expect(store.values['user-a']?.content, '后来补上的一句');
    expect(store.values['user-a']?.intentKey, 'intent-a');

    await tester.pumpWidget(const SizedBox());
    await tester.pumpWidget(_testApp(store: store, ownerUid: 'user-a'));
    await tester.pumpAndSettle();

    expect(find.text('后来补上的一句'), findsOneWidget);
  });

  testWidgets('never restores another account draft', (tester) async {
    final store = _MemoryResetDraftStore()
      ..values['user-a'] = const ResetDraft(
        intentKey: 'intent-a',
        content: '只属于 A 的内容',
        goal: '',
        showSmallDirection: false,
      );

    await tester.pumpWidget(_testApp(store: store, ownerUid: 'user-b'));
    await tester.pumpAndSettle();

    expect(find.text('只属于 A 的内容'), findsNothing);
    expect(
      tester.widget<TextField>(find.byType(TextField).first).controller?.text,
      isEmpty,
    );
  });

  testWidgets('explicit discard clears local draft after confirmation',
      (tester) async {
    final store = _MemoryResetDraftStore()
      ..values['user-a'] = const ResetDraft(
        intentKey: 'intent-a',
        content: '准备清除的草稿',
        goal: '',
        showSmallDirection: false,
      );

    await tester.pumpWidget(_testApp(store: store, ownerUid: 'user-a'));
    await tester.pumpAndSettle();
    await tester.drag(find.byType(ListView), const Offset(0, -500));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.byKey(const Key('discard-record-draft')));
    await tester.tap(find.byKey(const Key('discard-record-draft')));
    await tester.pumpAndSettle();

    expect(find.text('清除这份草稿？'), findsOneWidget);
    await tester.tap(find.widgetWithText(TextButton, '清除草稿').last);
    await tester.pumpAndSettle();

    expect(store.values['user-a'], isNull);
    expect(find.text('草稿已经清除。'), findsOneWidget);
    expect(
      tester.widget<TextField>(find.byType(TextField).first).controller?.text,
      isEmpty,
    );
  });
}

Widget _testApp({
  required _MemoryResetDraftStore store,
  required String ownerUid,
}) {
  return ProviderScope(
    overrides: [
      resetDraftStoreProvider.overrideWithValue(store),
      resetDraftOwnerUidProvider.overrideWithValue(ownerUid),
      currentStateProvider.overrideWith(_FakeCurrentStateController.new),
      recordRepositoryProvider.overrideWithValue(_FakeRecordRepository()),
      evidenceRepositoryProvider.overrideWithValue(_NoopEvidenceRepository()),
    ],
    child: const MaterialApp(
      locale: Locale('zh'),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: ResetScreen(),
    ),
  );
}

class _MemoryResetDraftStore implements ResetDraftStore {
  final Map<String, ResetDraft> values = {};

  @override
  Future<void> clear(String ownerUid) async => values.remove(ownerUid);

  @override
  Future<ResetDraft?> read(String ownerUid) async => values[ownerUid];

  @override
  Future<void> write(String ownerUid, ResetDraft draft) async {
    values[ownerUid] = draft;
  }
}

class _FakeCurrentStateController extends CurrentStateController {
  @override
  Future<StateSnapshot> build() async => StateSnapshot(
        state: 'CALM',
        source: 'SYSTEM',
        changedAt: DateTime(2026, 8, 19),
        sessionId: 1,
      );
}

class _FakeRecordRepository extends RecordRepository {
  _FakeRecordRepository() : super(Dio());

  @override
  Future<RecordPage> list({int page = 0, int size = 20}) async {
    return RecordPage(
      items: const [],
      page: page,
      size: size,
      totalElements: 0,
    );
  }
}

class _NoopEvidenceRepository extends EvidenceRepository {
  _NoopEvidenceRepository() : super(Dio());

  @override
  Future<void> record(EvidenceEvent event) async {}
}
