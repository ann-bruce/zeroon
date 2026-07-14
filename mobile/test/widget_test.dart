import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zeroon_mobile/auth/auth_models.dart';
import 'package:zeroon_mobile/auth/login_screen.dart';
import 'package:zeroon_mobile/auth/token_store.dart';
import 'package:zeroon_mobile/companion/companion_models.dart';
import 'package:zeroon_mobile/companion/companion_repository.dart';
import 'package:zeroon_mobile/data_control/data_control_repository.dart';
import 'package:zeroon_mobile/growth/growth_models.dart';
import 'package:zeroon_mobile/growth/growth_repository.dart';
import 'package:zeroon_mobile/home/home_shell.dart';
import 'package:zeroon_mobile/home/now_screen.dart';
import 'package:zeroon_mobile/main.dart';
import 'package:zeroon_mobile/memory/memory_models.dart';
import 'package:zeroon_mobile/memory/memory_repository.dart';
import 'package:zeroon_mobile/my_zeroon/my_zeroon_models.dart';
import 'package:zeroon_mobile/my_zeroon/my_zeroon_repository.dart';
import 'package:zeroon_mobile/profile/profile_models.dart';
import 'package:zeroon_mobile/profile/profile_repository.dart';
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

  testWidgets('authenticated user meets ZEROON before entering the app', (
    tester,
  ) async {
    final myZeroonRepository = _FakeMyZeroonRepository();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          tokenStoreProvider
              .overrideWithValue(_FakeTokenStore(session: _session)),
          myZeroonRepositoryProvider.overrideWithValue(myZeroonRepository),
          currentStateProvider.overrideWith(
            () => _FakeCurrentStateController(),
          ),
          recordRepositoryProvider.overrideWithValue(_FakeRecordRepository()),
          growthRepositoryProvider.overrideWithValue(_FakeGrowthRepository()),
        ],
        child: const ZeroonApp(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('与 ZEROON 相遇'), findsOneWidget);
    expect(find.text('确认相遇'), findsOneWidget);
    await tester.tap(find.text('确认相遇'));
    await tester.pumpAndSettle();

    expect(find.text('ZR-20260703-A8K2'), findsOneWidget);
    expect(find.text('进入 ZEROON'), findsOneWidget);
    await tester.tap(find.text('进入 ZEROON'));
    await tester.pumpAndSettle();

    expect(find.text('今天的 ZEROON'), findsOneWidget);
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
          profileRepositoryProvider.overrideWithValue(_FakeProfileRepository()),
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

    await tester.tap(find.text('${_testRecordCreatedAt.day}').first);
    await tester.pumpAndSettle();
    expect(find.text('山海缓存'), findsOneWidget);
    expect(find.text('筛选：$_testRecordDateLabel'), findsOneWidget);
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
    await tester.tap(find.text('筛选'));
    await tester.pumpAndSettle();
    expect(find.text('选择一天回看'), findsOneWidget);
    await tester.tap(find.text(_testRecordDateLabel));
    await tester.pumpAndSettle();
    expect(find.text('筛选：$_testRecordDateLabel'), findsOneWidget);
    expect(find.text('筛选功能后续开放'), findsNothing);

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

  testWidgets('profile screen opens from Now and saves user context', (
    tester,
  ) async {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
            SystemChannels.platform, (call) async => null);
    addTearDown(
      () => TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(SystemChannels.platform, null),
    );
    final profileRepository = _FakeProfileRepository();
    final dataControlRepository = _FakeDataControlRepository();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          currentStateProvider.overrideWith(
            () => _FakeCurrentStateController(),
          ),
          recordRepositoryProvider.overrideWithValue(_FakeRecordRepository()),
          growthRepositoryProvider.overrideWithValue(_FakeGrowthRepository()),
          profileRepositoryProvider.overrideWithValue(profileRepository),
          dataControlRepositoryProvider.overrideWithValue(
            dataControlRepository,
          ),
          tokenStoreProvider.overrideWithValue(
            _FakeTokenStore(session: _session),
          ),
          myZeroonRepositoryProvider.overrideWithValue(
            _FakeMyZeroonRepository(initialMet: true),
          ),
        ],
        child: const MaterialApp(home: HomeShell(session: _session)),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.person_outline));
    await tester.pumpAndSettle();

    expect(find.text('我与 ZEROON'), findsOneWidget);
    expect(find.text('你的 ZEROON 已经在这里'), findsOneWidget);
    expect(find.text('ZR-20260703-A8K2'), findsOneWidget);
    expect(find.text('这是我的 ZEROON'), findsNothing);
    expect(find.textContaining('让 ZEROON 更懂你'), findsOneWidget);
    await tester.enterText(find.byType(TextField).first, 'Bruce');
    await tester.drag(find.byType(ListView).last, const Offset(0, -700));
    await tester.pumpAndSettle();
    expect(find.textContaining('下一次回应起就不再使用'), findsOneWidget);
    await tester.tap(find.byType(Switch));
    await tester.pumpAndSettle();
    await tester.tap(find.text('保存我的信息'));
    await tester.pumpAndSettle();

    expect(profileRepository.saved?.nickname, 'Bruce');
    expect(profileRepository.saved?.aiProfileContextEnabled, isTrue);
    expect(find.text('已经保存。'), findsOneWidget);

    await tester.drag(find.byType(ListView).last, const Offset(0, -600));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('复制我的数据副本'));
    await tester.tap(find.text('复制我的数据副本'));
    await tester.pumpAndSettle();
    expect(dataControlRepository.exportCalls, 1);
    expect(find.text('你的数据副本已复制为 JSON。'), findsOneWidget);

    await tester.ensureVisible(find.text('删除账户与数据'));
    await tester.tap(find.text('删除账户与数据'));
    await tester.pumpAndSettle();
    expect(find.text('删除账户与全部数据？'), findsOneWidget);
    expect(find.textContaining('无法恢复'), findsOneWidget);
    await tester.tap(find.text('先保留'));
    await tester.pumpAndSettle();

    await tester.drag(find.byType(ListView).last, const Offset(0, -300));
    await tester.pumpAndSettle();
    await tester.tap(find.text('删除账户与数据'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('确认删除'));
    await tester.pumpAndSettle();
    expect(dataControlRepository.deleted, isTrue);
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

  testWidgets('memory management keeps source and controls user-owned', (
    tester,
  ) async {
    final memoryRepository = _FakeMemoryRepository();
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
          memoryRepositoryProvider.overrideWithValue(memoryRepository),
        ],
        child: const MaterialApp(home: HomeShell(session: _session)),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('缓存'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('记忆'));
    await tester.pumpAndSettle();

    expect(find.text('ZEROON 记住的'), findsOneWidget);
    expect(find.text('这条记忆来自一段真实记录。'), findsOneWidget);
    expect(find.text('来源 · 一次 Zero Record'), findsOneWidget);
    expect(find.text('允许用于回应参考'), findsOneWidget);
    expect(find.textContaining('默认关闭。开启后才会进入 ZEROON 的回应'), findsOneWidget);
    expect(find.byType(Switch), findsNWidgets(2));

    await tester.tap(find.text('查看来源'));
    await tester.pumpAndSettle();
    expect(find.text('记录详情'), findsOneWidget);
    expect(find.text('记录编号 #1'), findsOneWidget);
    await tester.pageBack();
    await tester.pumpAndSettle();

    await tester.tap(find.text('允许用于回应参考'));
    await tester.pump();
    expect(memoryRepository.lastAiContextEnabled, isTrue);
    expect(find.text('已允许用于回应参考。'), findsOneWidget);
    expect(find.textContaining('开启后，这条记忆可在下一次回应中作为上下文使用'), findsOneWidget);
    ScaffoldMessenger.of(tester.element(find.text('ZEROON 记住的')))
        .hideCurrentSnackBar();
    await tester.pumpAndSettle();

    await tester.tap(find.text('保留在连续记忆中'));
    await tester.pumpAndSettle();
    expect(memoryRepository.lastEnabled, isFalse);
    expect(find.text('已暂停'), findsOneWidget);

    await tester.ensureVisible(find.text('删除这条记忆'));
    await tester.tap(find.text('删除这条记忆'));
    await tester.pumpAndSettle();
    expect(find.text('删除这条记忆？'), findsOneWidget);
    expect(find.textContaining('原始 Zero Record 仍会留在山海缓存中'), findsOneWidget);
    await tester.tap(find.text('先保留'));
    await tester.pumpAndSettle();
    expect(memoryRepository.deleted, isFalse);

    await tester.tap(find.text('删除这条记忆'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('确认删除'));
    await tester.pump();
    expect(memoryRepository.deleted, isTrue);
    expect(find.text('这里还很安静。'), findsOneWidget);
    expect(find.text('这条记忆已经删除。'), findsOneWidget);
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

final _testRecordCreatedAt = DateTime.now();
final _testRecordDateLabel = _formatTestDate(_testRecordCreatedAt);

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
    createdAt: _testRecordCreatedAt,
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

class _FakeMemoryRepository extends MemoryRepository {
  _FakeMemoryRepository() : super(Dio());

  MemoryEntry? _entry = MemoryEntry(
    id: 11,
    type: 'ZERO_RECORD',
    title: '第一次认真停下来',
    summary: '这条记忆来自一段真实记录。',
    importance: 1,
    sourceType: 'ZERO_RECORD',
    sourceId: 1,
    enabled: true,
    aiContextEnabled: false,
    createdAt: DateTime.parse('2026-07-14T08:00:00Z'),
    updatedAt: DateTime.parse('2026-07-14T08:00:00Z'),
  );
  bool? lastEnabled;
  bool? lastAiContextEnabled;
  bool deleted = false;

  @override
  Future<MemoryPage> list({int page = 0, int size = 100}) async {
    return MemoryPage(
      items: _entry == null ? [] : [_entry!],
      page: page,
      size: size,
      totalElements: _entry == null ? 0 : 1,
    );
  }

  @override
  Future<MemoryEntry> updateControls(
    int memoryId,
    UpdateMemoryControlsRequest request,
  ) async {
    final current = _entry!;
    lastEnabled = request.enabled;
    lastAiContextEnabled = request.aiContextEnabled;
    _entry = MemoryEntry(
      id: current.id,
      type: current.type,
      title: current.title,
      summary: current.summary,
      importance: current.importance,
      sourceType: current.sourceType,
      sourceId: current.sourceId,
      expiresAt: current.expiresAt,
      enabled: request.enabled ?? current.enabled,
      aiContextEnabled: request.aiContextEnabled ?? current.aiContextEnabled,
      createdAt: current.createdAt,
      updatedAt: DateTime.parse('2026-07-14T09:00:00Z'),
    );
    return _entry!;
  }

  @override
  Future<void> delete(int memoryId) async {
    deleted = true;
    _entry = null;
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

class _FakeProfileRepository extends ProfileRepository {
  _FakeProfileRepository() : super(Dio());

  UserProfile _profile = const UserProfile(aiProfileContextEnabled: false);
  UpdateUserProfileRequest? saved;

  @override
  Future<UserProfile> get() async {
    return _profile;
  }

  @override
  Future<UserProfile> update(UpdateUserProfileRequest request) async {
    saved = request;
    _profile = UserProfile(
      nickname: request.nickname,
      avatarPreset: request.avatarPreset,
      ageRange: request.ageRange,
      occupation: request.occupation,
      selfDescription: request.selfDescription,
      aiProfileContextEnabled: request.aiProfileContextEnabled,
      createdAt: DateTime.parse('2026-06-24T00:00:00Z'),
      updatedAt: DateTime.parse('2026-06-24T00:00:00Z'),
    );
    return _profile;
  }
}

class _FakeDataControlRepository extends DataControlRepository {
  _FakeDataControlRepository() : super(Dio());

  int exportCalls = 0;
  bool deleted = false;

  @override
  Future<Map<String, dynamic>> exportData() async {
    exportCalls += 1;
    return {
      'schemaVersion': 'zeroon-beta-export-v1',
      'records': [
        {'content': 'today I paused'},
      ],
    };
  }

  @override
  Future<void> deleteAccount() async {
    deleted = true;
  }
}

class _FakeMyZeroonRepository extends MyZeroonRepository {
  _FakeMyZeroonRepository({bool initialMet = false}) : super(Dio()) {
    if (initialMet) {
      _companion = _metCompanion();
    }
  }

  MyZeroonCompanion _companion = const MyZeroonCompanion(met: false);

  @override
  Future<MyZeroonCompanion> get() async {
    return _companion;
  }

  @override
  Future<MyZeroonCompanion> meet([
    MeetMyZeroonRequest request = const MeetMyZeroonRequest(),
  ]) async {
    _companion = _metCompanion(companionKey: request.companionKey);
    return _companion;
  }

  MyZeroonCompanion _metCompanion({String? companionKey = 'ZEROON_DEFAULT'}) {
    return MyZeroonCompanion(
      met: true,
      companionKey: companionKey,
      nameplateSerial: 'ZR-20260703-A8K2',
      metAt: DateTime.parse('2026-07-03T00:00:00Z'),
      createdAt: DateTime.parse('2026-07-03T00:00:00Z'),
      updatedAt: DateTime.parse('2026-07-03T00:00:00Z'),
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

String _formatTestDate(DateTime date) {
  return '${date.year}.${date.month.toString().padLeft(2, '0')}.${date.day.toString().padLeft(2, '0')}';
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
