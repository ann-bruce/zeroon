import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zeroon_mobile/evidence/evidence_models.dart';
import 'package:zeroon_mobile/evidence/evidence_repository.dart';
import 'package:zeroon_mobile/record/continuity_cue_controller.dart';
import 'package:zeroon_mobile/record/record_models.dart';
import 'package:zeroon_mobile/record/record_repository.dart';

void main() {
  test('returns an eligible cue and hides it after a same-day dismissal',
      () async {
    final store = _FakeDismissalStore();
    final evidence = _CapturingEvidenceRepository();
    final cue = ContinuityCue(
      recordId: 14,
      state: 'CALM',
      preview: 'A private moment to revisit.',
      createdAt: DateTime.now().subtract(const Duration(days: 4)),
    );
    final repository = _FakeRecordRepository(cue);
    final container = ProviderContainer(
      overrides: [
        recordRepositoryProvider.overrideWithValue(repository),
        continuityCueDismissalStoreProvider.overrideWithValue(store),
        evidenceRepositoryProvider.overrideWithValue(evidence),
      ],
    );
    addTearDown(container.dispose);

    expect(await container.read(continuityCueProvider('user-1').future), cue);
    expect(evidence.events.single.eventName, 'RETURN_CUE_AVAILABLE');
    expect(evidence.events.single.properties, {
      'recordAgeBucket': 'ONE_TO_SIX_DAYS',
      'surface': 'NOW',
    });
    expect(
      repository.requestedTimezone,
      localTimezoneId(DateTime.now()),
    );

    container.invalidate(continuityCueProvider('user-1'));
    expect(await container.read(continuityCueProvider('user-1').future), cue);
    expect(evidence.events, hasLength(1));

    await container
        .read(continuityCueProvider('user-1').notifier)
        .dismissForToday();

    expect(container.read(continuityCueProvider('user-1')).valueOrNull, isNull);
    expect(store.dismissedDays['user-1'], matches(r'^\d{4}-\d{2}-\d{2}$'));
  });

  test('does not request a cue again when it was already dismissed today',
      () async {
    final store = _FakeDismissalStore()..dismissedDays['user-2'] = _todayKey();
    final repository = _FakeRecordRepository(ContinuityCue(
      recordId: 15,
      state: 'FOCUS',
      preview: 'A private moment to revisit.',
      createdAt: DateTime(2026, 7, 20),
    ));
    final container = ProviderContainer(
      overrides: [
        recordRepositoryProvider.overrideWithValue(repository),
        continuityCueDismissalStoreProvider.overrideWithValue(store),
      ],
    );
    addTearDown(container.dispose);

    expect(
        await container.read(continuityCueProvider('user-2').future), isNull);
    expect(repository.cueRequests, isZero);
  });

  test('a cue dismissed today can return after the local day changes',
      () async {
    var now = DateTime(2026, 7, 30, 23, 59);
    final store = _FakeDismissalStore();
    final cue = ContinuityCue(
      recordId: 16,
      state: 'CREATE',
      preview: 'A private moment to revisit.',
      createdAt: DateTime(2026, 7, 20),
    );
    final container = ProviderContainer(
      overrides: [
        continuityCueNowProvider.overrideWithValue(() => now),
        recordRepositoryProvider.overrideWithValue(_FakeRecordRepository(cue)),
        continuityCueDismissalStoreProvider.overrideWithValue(store),
      ],
    );
    addTearDown(container.dispose);

    expect(await container.read(continuityCueProvider('user-3').future), cue);
    await container
        .read(continuityCueProvider('user-3').notifier)
        .dismissForToday();
    expect(container.read(continuityCueProvider('user-3')).valueOrNull, isNull);

    now = DateTime(2026, 7, 31, 0, 1);
    container.invalidate(continuityCueProvider('user-3'));

    expect(await container.read(continuityCueProvider('user-3').future), cue);
  });
}

class _FakeRecordRepository extends RecordRepository {
  _FakeRecordRepository(this._cue) : super(Dio());

  final ContinuityCue? _cue;
  int cueRequests = 0;
  String? requestedTimezone;

  @override
  Future<ContinuityCue?> continuityCue({required String timezone}) async {
    cueRequests += 1;
    requestedTimezone = timezone;
    return _cue;
  }
}

class _FakeDismissalStore implements ContinuityCueDismissalStore {
  final dismissedDays = <String, String>{};
  final availabilityRecordedDays = <String, String>{};

  @override
  Future<String?> availabilityRecordedDayFor(String userId) async =>
      availabilityRecordedDays[userId];

  @override
  Future<String?> dismissedDayFor(String userId) async => dismissedDays[userId];

  @override
  Future<void> dismissForDay(String userId, String localDay) async {
    dismissedDays[userId] = localDay;
  }

  @override
  Future<void> markAvailabilityRecordedForDay(
      String userId, String localDay) async {
    availabilityRecordedDays[userId] = localDay;
  }
}

class _CapturingEvidenceRepository extends EvidenceRepository {
  _CapturingEvidenceRepository() : super(Dio());

  final events = <EvidenceEvent>[];

  @override
  Future<void> record(EvidenceEvent event) async {
    events.add(event);
  }
}

String _todayKey() {
  final now = DateTime.now().toLocal();
  return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
}
