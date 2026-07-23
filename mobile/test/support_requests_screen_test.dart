import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zeroon_mobile/l10n/app_localizations.dart';
import 'package:zeroon_mobile/support/support_models.dart';
import 'package:zeroon_mobile/support/support_repository.dart';
import 'package:zeroon_mobile/support/support_requests_screen.dart';

void main() {
  testWidgets('empty support list is private, calm, and recoverable', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          supportRepositoryProvider.overrideWithValue(
            _FakeSupportHistoryRepository(items: const []),
          ),
        ],
        child: _localizedApp(const SupportRequestsScreen()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('还没有支持请求'), findsOneWidget);
    expect(find.textContaining('人工回复'), findsOneWidget);
    expect(find.text('再试一次'), findsOneWidget);
  });

  testWidgets('support list failure stays gentle and retryable', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          supportRepositoryProvider.overrideWithValue(
            _FakeSupportHistoryRepository(failList: true),
          ),
        ],
        child: _localizedApp(const SupportRequestsScreen()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('暂时没能读到你的支持请求。'), findsOneWidget);
    expect(find.text('再试一次'), findsOneWidget);
  });

  testWidgets('waiting request shows human reply, status history, and prompt', (
    tester,
  ) async {
    final repository = _FakeSupportHistoryRepository(
      items: [_summary(SupportRequestStatus.waitingForUser)],
      detail: _detail(SupportRequestStatus.waitingForUser),
    );
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          supportRepositoryProvider.overrideWithValue(repository),
        ],
        child: _localizedApp(const SupportRequestsScreen()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('等待你补充'), findsOneWidget);
    expect(find.text('缓存没有刷新'), findsOneWidget);
    await tester.tap(find.text('缓存没有刷新'));
    await tester.pumpAndSettle();

    expect(find.textContaining('需要你补充'), findsWidgets);
    expect(find.text('请告诉我们当时使用的平台。'), findsOneWidget);
    expect(find.text('ZEROON 团队'), findsWidgets);
    expect(find.text('处理进度'), findsOneWidget);
    await tester.drag(find.byType(ListView), const Offset(0, -700));
    await tester.pumpAndSettle();
    expect(find.text('团队正在等待你补充信息。'), findsOneWidget);
  });

  testWidgets('failed follow-up preserves exact draft', (tester) async {
    final repository = _FakeSupportHistoryRepository(
      detail: _detail(SupportRequestStatus.waitingForUser),
      failAdd: true,
    );
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          supportRepositoryProvider.overrideWithValue(repository),
        ],
        child: _localizedApp(
          const SupportRequestDetailScreen(
            reference: 'ZS-1234567890ABCDEF1234',
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    const draft = '  我使用的是 Flutter Web  ';
    await tester.drag(find.byType(ListView), const Offset(0, -700));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const Key('support-follow-up')),
      draft,
    );
    await tester.drag(find.byType(ListView), const Offset(0, -260));
    await tester.pumpAndSettle();
    await tester.tap(find.byType(FilledButton));
    await tester.pumpAndSettle();

    expect(find.text(draft), findsOneWidget);
    expect(find.textContaining('草稿仍保留'), findsOneWidget);
    expect(find.text('重新发送'), findsOneWidget);
    expect(repository.followUps.single, draft);
  });

  testWidgets('successful follow-up is shown locally and leaves waiting state',
      (
    tester,
  ) async {
    final repository = _FakeSupportHistoryRepository(
      detail: _detail(SupportRequestStatus.waitingForUser),
    );
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          supportRepositoryProvider.overrideWithValue(repository),
        ],
        child: _localizedApp(
          const SupportRequestDetailScreen(
            reference: 'ZS-1234567890ABCDEF1234',
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.drag(find.byType(ListView), const Offset(0, -700));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const Key('support-follow-up')),
      '我使用的是 Flutter Web',
    );
    await tester.drag(find.byType(ListView), const Offset(0, -260));
    await tester.pumpAndSettle();
    await tester.tap(find.byType(FilledButton));
    await tester.pump();

    expect(find.text('补充信息已发送。'), findsOneWidget);
    expect(repository.followUps.single, '我使用的是 Flutter Web');
    expect(
      tester
          .widget<TextField>(find.byKey(const Key('support-follow-up')))
          .controller
          ?.text,
      isEmpty,
    );
  });

  testWidgets('closed request does not expose follow-up controls', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          supportRepositoryProvider.overrideWithValue(
            _FakeSupportHistoryRepository(
              detail: _detail(SupportRequestStatus.closed),
            ),
          ),
        ],
        child: _localizedApp(
          const SupportRequestDetailScreen(
            reference: 'ZS-1234567890ABCDEF1234',
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('已关闭'), findsWidgets);
    expect(find.byKey(const Key('support-follow-up')), findsNothing);
    await tester.drag(find.byType(ListView), const Offset(0, -700));
    await tester.pumpAndSettle();
    expect(find.textContaining('无法继续在应用内补充'), findsOneWidget);
  });

  testWidgets('English request detail fits a narrow viewport', (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          supportRepositoryProvider.overrideWithValue(
            _FakeSupportHistoryRepository(
              detail: _detail(SupportRequestStatus.replied),
            ),
          ),
        ],
        child: _localizedApp(
          const SupportRequestDetailScreen(
            reference: 'ZS-1234567890ABCDEF1234',
          ),
          locale: const Locale('en'),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.text('Team replied'), findsWidgets);
    expect(find.text('ZEROON team'), findsWidgets);
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

SupportRequestSummary _summary(SupportRequestStatus status) {
  return SupportRequestSummary(
    reference: 'ZS-1234567890ABCDEF1234',
    category: SupportCategory.productProblem,
    status: status,
    subject: '缓存没有刷新',
    createdAt: DateTime.parse('2026-07-22T06:00:00Z'),
    updatedAt: DateTime.parse('2026-07-23T06:00:00Z'),
  );
}

SupportRequestDetail _detail(SupportRequestStatus status) {
  return SupportRequestDetail(
    reference: 'ZS-1234567890ABCDEF1234',
    category: SupportCategory.productProblem,
    status: status,
    subject: '缓存没有刷新',
    description: '完成归零后，缓存页面没有显示新记录。',
    messages: [
      SupportMessage(
        id: 8,
        actorType: SupportActorType.admin,
        body: '请告诉我们当时使用的平台。',
        createdAt: DateTime.parse('2026-07-23T06:00:00Z'),
      ),
    ],
    statusHistory: [
      SupportStatusChange(
        toStatus: SupportRequestStatus.received,
        actorType: SupportActorType.system,
        createdAt: DateTime.parse('2026-07-22T06:00:00Z'),
      ),
      SupportStatusChange(
        fromStatus: SupportRequestStatus.inReview,
        toStatus: status,
        actorType: SupportActorType.admin,
        createdAt: DateTime.parse('2026-07-23T06:00:00Z'),
      ),
    ],
    createdAt: DateTime.parse('2026-07-22T06:00:00Z'),
    updatedAt: DateTime.parse('2026-07-23T06:00:00Z'),
    closedAt: status == SupportRequestStatus.closed
        ? DateTime.parse('2026-07-23T06:00:00Z')
        : null,
  );
}

class _FakeSupportHistoryRepository extends SupportRepository {
  _FakeSupportHistoryRepository({
    this.items = const [],
    SupportRequestDetail? detail,
    this.failAdd = false,
    this.failList = false,
  })  : detail = detail ?? _detail(SupportRequestStatus.received),
        super(Dio());

  final List<SupportRequestSummary> items;
  SupportRequestDetail detail;
  final bool failAdd;
  final bool failList;
  final List<String> followUps = [];

  @override
  Future<SupportRequestPage> list({int page = 0, int size = 20}) async {
    if (failList) {
      throw DioException(requestOptions: RequestOptions());
    }
    return SupportRequestPage(
      items: items,
      page: page,
      size: size,
      totalElements: items.length,
    );
  }

  @override
  Future<SupportRequestDetail> get(String reference) async => detail;

  @override
  Future<SupportMessage> addMessage(String reference, String body) async {
    followUps.add(body);
    if (failAdd) {
      throw DioException(requestOptions: RequestOptions());
    }
    final message = SupportMessage(
      id: 9,
      actorType: SupportActorType.user,
      body: body,
      createdAt: DateTime.parse('2026-07-23T07:00:00Z'),
    );
    detail = detail.withUserFollowUp(message);
    return message;
  }
}
