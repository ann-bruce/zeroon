import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zeroon_mobile/auth/auth_models.dart';
import 'package:zeroon_mobile/auth/login_screen.dart';
import 'package:zeroon_mobile/auth/token_store.dart';
import 'package:zeroon_mobile/home/home_shell.dart';
import 'package:zeroon_mobile/home/now_screen.dart';
import 'package:zeroon_mobile/main.dart';
import 'package:zeroon_mobile/record/record_models.dart';
import 'package:zeroon_mobile/record/record_repository.dart';
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
        ],
        child: const MaterialApp(home: NowScreen(session: session)),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('先看见此刻的状态。'), findsOneWidget);
    expect(find.text('当前状态：CALM'), findsOneWidget);
    expect(find.text('用户：13800138000'), findsOneWidget);
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
        ],
        child: const MaterialApp(home: HomeShell(session: _session)),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('先看见此刻的状态。'), findsOneWidget);

    await tester.tap(find.text('Reset'));
    await tester.pumpAndSettle();
    expect(find.text('把这一刻放下来。'), findsOneWidget);

    await tester.tap(find.text('Archive'));
    await tester.pumpAndSettle();
    expect(find.text('已缓存 1 条记录'), findsOneWidget);
    expect(find.text('today I paused'), findsOneWidget);

    await tester.tap(find.text('today I paused'));
    await tester.pumpAndSettle();
    expect(find.text('记录详情'), findsOneWidget);
    expect(find.text('想记录的话'), findsOneWidget);
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
