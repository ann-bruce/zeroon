import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../evidence/evidence_models.dart';
import '../evidence/evidence_repository.dart';
import 'state_models.dart';
import 'state_repository.dart';

final currentStateProvider =
    AsyncNotifierProvider<CurrentStateController, StateSnapshot>(
  CurrentStateController.new,
);

class CurrentStateController extends AsyncNotifier<StateSnapshot> {
  @override
  Future<StateSnapshot> build() {
    return ref.watch(stateRepositoryProvider).getCurrentState();
  }

  Future<void> changeState(String nextState) async {
    try {
      final snapshot = await ref.read(stateRepositoryProvider).changeState(
            nextState,
          );
      state = AsyncData(snapshot);
      unawaited(ref.read(evidenceRepositoryProvider).record(
            EvidenceEvent('STATE_STARTED', {
              'state': snapshot.state,
              'source': 'MANUAL',
            }),
          ));
    } catch (error, stackTrace) {
      if (state.hasValue) {
        state = AsyncData(state.requireValue);
        return;
      }
      state = AsyncError(error, stackTrace);
    }
  }
}
