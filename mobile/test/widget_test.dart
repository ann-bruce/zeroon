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
    expect(find.text('先进入此刻。'), findsOneWidget);
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
        child: const MaterialApp(home: NowScreen(session: session)),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('先看见此刻的状态。'), findsOneWidget);
    expect(find.text('当前状态：CALM'), findsOneWidget);
    expect(find.text('用户：13800138000'), findsOneWidget);
    await tester.drag(find.byType(ListView), const Offset(0, -500));
    await tester.pumpAndSettle();
    expect(find.text('陪伴成长'), findsOneWidget);
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

    expect(find.text('session expired'), findsOneWidget);
  });

  testWidgets('home shell navigates between Now Reset and Archive', (
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

    expect(find.text('先看见此刻的状态。'), findsOneWidget);
    await tester.drag(find.byType(ListView), const Offset(0, -500));
    await tester.pumpAndSettle();
    expect(find.text('陪伴成长'), findsOneWidget);

    await tester.tap(find.text('陪伴成长'));
    await tester.pumpAndSettle();
    expect(find.text('连续归零'), findsOneWidget);
    expect(find.text('7天'), findsOneWidget);
    expect(find.text('累计缓存'), findsOneWidget);
    expect(find.text('126条'), findsOneWidget);
    expect(find.text('第一次记录'), findsOneWidget);
    expect(find.text('2026.06.01'), findsOneWidget);
    expect(find.text('陪伴天数'), findsOneWidget);
    expect(find.text('365天'), findsOneWidget);
    await tester.drag(find.byType(ListView), const Offset(0, -500));
    await tester.pumpAndSettle();
    expect(find.text('近期状态观察'), findsOneWidget);
    expect(find.textContaining('不代表固定标签'), findsOneWidget);
    expect(find.text('出现最多：FOCUS'), findsOneWidget);
    expect(find.textContaining('state_history.current_state'), findsOneWidget);

    Navigator.of(tester.element(find.text('陪伴成长'))).pop();
    await tester.pumpAndSettle();

    await tester.tap(find.text('Reset'));
    await tester.pumpAndSettle();
    expect(find.text('把这一刻放下来。'), findsOneWidget);

    await tester.tap(find.text('Archive'));
    await tester.pumpAndSettle();
    expect(find.text('已缓存 1 条记录'), findsOneWidget);
    expect(find.text('Archive 观察'), findsOneWidget);
    expect(find.text('你已经把这一刻安放下来了。'), findsOneWidget);
    expect(find.text('today I paused'), findsOneWidget);

    await tester.tap(find.text('today I paused'));
    await tester.pumpAndSettle();
    expect(find.text('记录详情'), findsOneWidget);
    expect(find.text('Archive 记忆'), findsOneWidget);
    expect(find.text('私密记录'), findsOneWidget);
    expect(find.text('记录编号 #1'), findsOneWidget);
    expect(find.text('想记录的话'), findsOneWidget);
    await tester.drag(find.byType(ListView), const Offset(0, -500));
    await tester.pumpAndSettle();
    expect(find.textContaining('不会公开'), findsOneWidget);
  });

  testWidgets('reset screen shows ZEROON echo after record is saved', (
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

    await tester.enterText(find.byType(TextField).at(2), 'today I paused');
    await tester.drag(find.byType(ListView), const Offset(0, -500));
    await tester.pumpAndSettle();
    await tester.tap(find.text('保存归零记录'));
    await tester.pumpAndSettle();

    expect(find.text('已保存到 Archive：#1'), findsOneWidget);
    await tester.drag(find.byType(ListView), const Offset(0, -500));
    await tester.pumpAndSettle();
    expect(find.text('ZEROON 回声'), findsOneWidget);
    expect(find.text('你已经把这一刻安放下来了。'), findsOneWidget);
    expect(find.textContaining('不能替代'), findsOneWidget);
  });

  testWidgets('archive screen shows observation card for cached records', (
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
        child: const MaterialApp(home: HomeShell(session: _session)),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Archive'));
    await tester.pumpAndSettle();

    expect(find.text('已缓存 1 条记录'), findsOneWidget);
    expect(find.text('Archive 观察'), findsOneWidget);
    expect(find.text('你已经把这一刻安放下来了。'), findsOneWidget);
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

    await tester.tap(find.text('Archive'));
    await tester.pumpAndSettle();

    expect(find.text('Archive 观察暂时不可用。'), findsOneWidget);
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
    mood: 'quiet',
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

  @override
  Future<CompanionMessageResponse> sendMessage(
    CompanionMessageRequest request,
  ) async {
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
