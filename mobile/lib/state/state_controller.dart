import 'package:flutter_riverpod/flutter_riverpod.dart';

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
    } catch (error, stackTrace) {
      if (state.hasValue) {
        state = AsyncData(state.requireValue);
        return;
      }
      state = AsyncError(error, stackTrace);
    }
  }
}
