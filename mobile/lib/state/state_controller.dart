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
    state = const AsyncLoading();
    state = await AsyncValue.guard(() {
      return ref.read(stateRepositoryProvider).changeState(nextState);
    });
  }
}
