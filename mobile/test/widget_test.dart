import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zeroon_mobile/auth/auth_models.dart';
import 'package:zeroon_mobile/auth/login_screen.dart';
import 'package:zeroon_mobile/auth/token_store.dart';
import 'package:zeroon_mobile/companion/companion_models.dart';
import 'package:zeroon_mobile/companion/companion_repository.dart';
import 'package:zeroon_mobile/growth/growth_models.dart';
import 'package:zeroon_mobile/growth/growth_repository.dart';
import 'package:zeroon_mobile/home/home_shell.dart';
import 'package:zeroon_mobile/home/now_screen.dart';
import 'package:zeroon_mobile/main.dart';
import 'package:zeroon_mobile/record/record_models.dart';
import 'package:zeroon_mobile/record/record_repository.dart';
import 'package:zeroon_mobile/record/reset_screen.dart';
import 'package:zeroon_mobile/state/state_controller.dart';
import 'package:zeroon_mobile/state/state_models.dart';

void main() {
  testWidgets('renders login screen when no session is restored', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [tokenStoreProvider.overrideWithValue(_FakeTokenStore())],
        child: const ZeroonApp(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('ZEROON'), findsOneWidget);
    expect(find.text('欢迎回来。'), findsOneWidget);
    expect(find.text('获取验证码'), findsOneWidget);
  });

  testWidgets('renders current session on the Now screen', (tester) async {
    const session = AuthSession(
      accessToken: 'access-token',
      refreshToken: 'refresh-token',
      expiresIn: 1800,
      user: ZeroonUser(
        uid: 'u123',
        mobile: '13800138000',
        currentState: 'CALM',
      ),
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          tokenStoreProvider.overrideWithValue(
            _FakeTokenStore(session: session),
          ),
          currentStateProvider.overrideWith(
            () => _FakeCurrentStateController(),
          ),
          growthRepositoryProvider.overrideWithValue(_FakeGrowthRepository()),
        ],
        child: MaterialApp(
          home: NowScreen(session: session, onStartReset: () {}),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('今天的 ZEROON'), findsOneWidget);
    expect(find.text('平静'), findsWidgets);
    expect(find.text('晚上好，8000'), findsOneWidget);
    await tester.drag(find.byType(ListView), const Offset(0, -500));
    await tester.pumpAndSettle();
    expect(find.text('7 天'), findsOneWidget);
    expect(find.text('点亮日期可回看'), findsOneWidget);
  });

  testWidgets('login screen shows initial error', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [tokenStoreProvider.overrideWithValue(_FakeTokenStore())],
        child: const MaterialApp(
          home: LoginScreen(initialError: 'session expired'),
        ),
      ),
    );

    await tester.drag(find.byType(ListView), const Offset(0, -500));
    await tester.pumpAndSettle();
    expect(find.text('session expired'), findsOneWidget);
  });

  testWidgets('home shell navigates between Now Archive and Growth', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          currentStateProvider.overrideWith(
            () => _FakeCurrentStateController(),
          ),
          recordRepositoryProvider.overrideWithValue(_FakeRecordRepository()),
          companionRepositoryProvider.overrideWithValue(
            _FakeCompanionRepository(),
          ),
          growthRepositoryProvider.overrideWithValue(_FakeGrowthRepository()),
        ],
        child: const MaterialApp(home: HomeShell(session: _session)),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('今天的 ZEROON'), findsOneWidget);
    await tester.drag(find.byType(ListView), const Offset(0, -500));
    await tester.pumpAndSettle();
    expect(find.text('7 天'), findsOneWidget);
    expect(find.text('点亮日期可回看'), findsOneWidget);

    await tester.tap(find.text('19').first);
    await tester.pumpAndSettle();
    expect(find.text('山海缓存'), findsOneWidget);
    expect(find.text('筛选：2026.06.19'), findsOneWidget);
    expect(find.text('today I paused'), findsOneWidget);
    Navigator.of(tester.element(find.text('山海缓存'))).pop();
    await tester.pumpAndSettle();

    await tester.tap(find.text('成长'));
    await tester.pumpAndSettle();
    expect(find.text('连续归零'), findsOneWidget);
    expect(find.text('累计缓存'), findsOneWidget);
    expect(find.text('第一次记录'), findsOneWidget);
    expect(find.text('陪伴天数'), findsOneWidget);
    expect(find.text('我们已经一起走过一年。'), findsOneWidget);
    await tester.tap(find.byIcon(Icons.info_outline));
    await tester.pumpAndSettle();
    expect(find.text('陪伴成长说明'), findsOneWidget);
    expect(find.textContaining('来自你的归零记录'), findsOneWidget);
    expect(find.textContaining('ZEROON 不做诊断'), findsOneWidget);
    Navigator.of(tester.element(find.text('陪伴成长说明'))).pop();
    await tester.pumpAndSettle();
    expect(find.textContaining('数据来源'), findsNothing);

    await tester.tap(find.text('缓存'));
    await tester.pumpAndSettle();
    expect(find.text('山海缓存'), findsOneWidget);
    expect(find.text('筛选'), findsOneWidget);
    expect(find.byIcon(Icons.chevron_left), findsNothing);
    expect(find.text('ZEROON 观察'), findsOneWidget);
    expect(find.text('你已经把这一刻安放下来了。'), findsOneWidget);
    expect(find.text('today I paused'), findsOneWidget);

    await tester.tap(find.text('today I paused'));
    await tester.pumpAndSettle();
    expect(find.text('记录详情'), findsOneWidget);
    expect(find.text('Archive 记忆'), findsOneWidget);
    expect(find.text('私密记录'), findsOneWidget);
    expect(find.text('记录编号 #1'), findsOneWidget);
    expect(find.text('归零状态：平静'), findsOneWidget);
    expect(find.text('想记录的话'), findsOneWidget);
    await tester.drag(find.byType(ListView), const Offset(0, -500));
    await tester.pumpAndSettle();
    expect(find.textContaining('数据来源'), findsNothing);
  });

  testWidgets('reset screen opens completion after record is saved', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          currentStateProvider.overrideWith(
            () => _FakeCurrentStateController(),
          ),
          recordRepositoryProvider.overrideWithValue(_FakeRecordRepository()),
          companionRepositoryProvider.overrideWithValue(
            _FakeCompanionRepository(),
          ),
        ],
        child: const MaterialApp(home: ResetScreen()),
      ),
    );
    await tester.pumpAndSettle();

    await tester.drag(find.byType(ListView), const Offset(0, -500));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField).first, 'today I paused');
    await tester.pumpAndSettle();
    await tester.tap(find.text('保存这次归零'));
    await tester.pumpAndSettle();

    expect(find.text('归零完成'), findsOneWidget);
    expect(find.text('已经替你保存好了。'), findsOneWidget);
    expect(find.text('回到此刻'), findsOneWidget);
    expect(find.text('查看山海缓存'), findsOneWidget);
    expect(find.text('ZEROON 回声'), findsNothing);
    expect(find.text('“你已经把这一刻安放下来了。”'), findsOneWidget);
    expect(find.text('today I paused'), findsOneWidget);
    expect(find.text('再归零一次'), findsNothing);

    await tester.drag(find.byType(ListView), const Offset(0, -220));
    await tester.pumpAndSettle();
    await tester.tap(find.text('查看山海缓存'));
    await tester.pumpAndSettle();
    expect(find.text('山海缓存'), findsOneWidget);
    expect(find.byIcon(Icons.chevron_left), findsNothing);
  });

  testWidgets('archive screen shows observation card for cached records', (
    tester,
  ) async {
    final companionRepository = _FakeCompanionRepository();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          currentStateProvider.overrideWith(
            () => _FakeCurrentStateController(),
          ),
          recordRepositoryProvider.overrideWithValue(_FakeRecordRepository()),
          companionRepositoryProvider.overrideWithValue(companionRepository),
        ],
        child: const MaterialApp(home: HomeShell(session: _session)),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('缓存'));
    await tester.pumpAndSettle();

    expect(find.text('山海缓存'), findsOneWidget);
    expect(find.text('ZEROON 观察'), findsOneWidget);
    expect(find.text('你已经把这一刻安放下来了。'), findsOneWidget);
    expect(companionRepository.lastMessage, isNotNull);
    expect(companionRepository.lastMessage, isNot(contains('医疗')));
    expect(companionRepository.lastMessage, isNot(contains('法律')));
    expect(companionRepository.lastMessage, isNot(contains('心理诊断')));
  });

  testWidgets('archive observation shows unavailable state and retry', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          currentStateProvider.overrideWith(
            () => _FakeCurrentStateController(),
          ),
          recordRepositoryProvider.overrideWithValue(_FakeRecordRepository()),
          companionRepositoryProvider.overrideWithValue(
            _FlakyCompanionRepository(),
          ),
        ],
        child: const MaterialApp(home: HomeShell(session: _session)),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('缓存'));
    await tester.pumpAndSettle();

    expect(find.text('ZEROON 观察暂时不可用。'), findsOneWidget);
    await tester.tap(find.text('重试观察'));
    await tester.pumpAndSettle();

    expect(find.text('你已经把这一刻安放下来了。'), findsOneWidget);
  });
}

const _session = AuthSession(
  accessToken: 'access-token',
  refreshToken: 'refresh-token',
  expiresIn: 1800,
  user: ZeroonUser(
    uid: 'u123',
    mobile: '13800138000',
    currentState: 'CALM',
  ),
);

class _FakeCurrentStateController extends CurrentStateController {
  @override
  Future<StateSnapshot> build() async {
    return StateSnapshot(
      state: 'CALM',
      source: 'SYSTEM',
      changedAt: DateTime.parse('2026-06-19T00:00:00Z'),
      sessionId: 1,
      startedAt: DateTime.parse('2026-06-19T00:00:00Z'),
      elapsedSeconds: 600,
    );
  }
}

class _FakeTokenStore implements TokenStore {
  _FakeTokenStore({AuthSession? session}) : _session = session;

  AuthSession? _session;

  @override
  Future<void> clear() async {
    _session = null;
  }

  @override
  Future<AuthSession?> read() async {
    return _session;
  }

  @override
  Future<void> save(AuthSession session) async {
    _session = session;
  }
}

class _FakeRecordRepository extends RecordRepository {
  _FakeRecordRepository() : super(Dio());

  final _record = ZeroRecord(
    id: 1,
    state: 'CALM',
    goal: 'first step',
    content: 'today I paused',
    aiSummary: '你已经把这一刻安放下来了。',
    createdAt: DateTime.parse('2026-06-19T00:00:00Z'),
  );

  @override
  Future<ZeroRecord> create(CreateRecordRequest request) async {
    return _record;
  }

  @override
  Future<ZeroRecord> get(int recordId) async {
    return _record;
  }

  @override
  Future<RecordPage> list({int page = 0, int size = 20}) async {
    return RecordPage(
      items: [_record],
      page: page,
      size: size,
      totalElements: 1,
    );
  }
}

class _FakeGrowthRepository extends GrowthRepository {
  _FakeGrowthRepository() : super(Dio());

  @override
  Future<GrowthSummary> getSummary({String timezone = 'Asia/Shanghai'}) async {
    return GrowthSummary(
      continuousResetDays: 7,
      cachedEntries: 126,
      firstRecordDate: DateTime.parse('2026-06-01'),
      companionDays: 365,
      timezone: timezone,
      calculatedAt: DateTime.parse('2026-06-20T00:00:00Z'),
    );
  }

  @override
  Future<StatePatternSummary> getStatePattern({
    String timezone = 'Asia/Shanghai',
    int days = 14,
  }) async {
    return StatePatternSummary(
      days: days,
      sampleSize: 3,
      dominantState: 'FOCUS',
      distribution: const {'CALM': 1, 'FOCUS': 2},
      observation: '最近 14 天，FOCUS 出现较多。这只是近期记录的分布，不代表固定标签。',
      dataSources: const [
        'state_history.current_state',
        'state_history.created_at'
      ],
      timezone: timezone,
      calculatedAt: DateTime.parse('2026-06-20T00:00:00Z'),
    );
  }
}

class _FakeCompanionRepository extends CompanionRepository {
  _FakeCompanionRepository() : super(Dio());

  String? lastMessage;

  @override
  Future<CompanionMessageResponse> sendMessage(
    CompanionMessageRequest request,
  ) async {
    lastMessage = request.message;
    return const CompanionMessageResponse(
      conversationId: 1,
      messageId: 2,
      reply: '你已经把这一刻安放下来了。',
      safetyNotice: 'ZEROON 不能替代医疗、法律、财务或心理咨询。',
    );
  }
}

class _FlakyCompanionRepository extends CompanionRepository {
  _FlakyCompanionRepository() : super(Dio());

  var _failedOnce = false;

  @override
  Future<CompanionMessageResponse> sendMessage(
    CompanionMessageRequest request,
  ) async {
    if (!_failedOnce) {
      _failedOnce = true;
      throw DioException(requestOptions: RequestOptions(path: '/companion'));
    }
    return const CompanionMessageResponse(
      conversationId: 1,
      messageId: 2,
      reply: '你已经把这一刻安放下来了。',
      safetyNotice: 'ZEROON 不能替代医疗、法律、财务或心理咨询。',
    );
  }
}
