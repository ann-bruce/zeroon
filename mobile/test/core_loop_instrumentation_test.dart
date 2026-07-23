import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zeroon_mobile/evidence/evidence_models.dart';
import 'package:zeroon_mobile/evidence/evidence_repository.dart';
import 'package:zeroon_mobile/state/state_controller.dart';
import 'package:zeroon_mobile/state/state_models.dart';
import 'package:zeroon_mobile/state/state_repository.dart';

void main() {
  test('a successful manual state change emits the reviewed bounded event',
      () async {
    final evidence = _CapturingEvidenceRepository();
    final container = ProviderContainer(
      overrides: [
        stateRepositoryProvider.overrideWithValue(_FakeStateRepository()),
        evidenceRepositoryProvider.overrideWithValue(evidence),
      ],
    );
    addTearDown(container.dispose);
    await container.read(currentStateProvider.future);

    await container.read(currentStateProvider.notifier).changeState('FOCUS');
    await pumpEventQueue();

    expect(container.read(currentStateProvider).requireValue.state, 'FOCUS');
    expect(evidence.events.single.toJson(),
        containsPair('eventName', 'STATE_STARTED'));
    expect(evidence.events.single.properties, {
      'state': 'FOCUS',
      'source': 'MANUAL',
    });
  });
}

class _FakeStateRepository extends StateRepository {
  _FakeStateRepository() : super(Dio());

  @override
  Future<StateSnapshot> getCurrentState() async => StateSnapshot(
        state: 'CALM',
        source: 'SYSTEM',
        changedAt: DateTime.utc(2026, 7, 23),
      );

  @override
  Future<StateSnapshot> changeState(String state) async => StateSnapshot(
        state: state,
        source: 'MANUAL',
        changedAt: DateTime.utc(2026, 7, 23),
        sessionId: 9,
        startedAt: DateTime.utc(2026, 7, 23),
      );
}

class _CapturingEvidenceRepository extends EvidenceRepository {
  _CapturingEvidenceRepository() : super(Dio());

  final List<EvidenceEvent> events = [];

  @override
  Future<void> record(EvidenceEvent event) async {
    events.add(event);
  }
}
