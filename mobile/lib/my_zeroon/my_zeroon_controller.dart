import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'my_zeroon_models.dart';
import 'my_zeroon_repository.dart';

final myZeroonProvider =
    AsyncNotifierProvider<MyZeroonController, MyZeroonCompanion>(
  MyZeroonController.new,
);

class MyZeroonController extends AsyncNotifier<MyZeroonCompanion> {
  @override
  Future<MyZeroonCompanion> build() {
    return ref.watch(myZeroonRepositoryProvider).get();
  }

  Future<void> meet() async {
    state = const AsyncLoading<MyZeroonCompanion>().copyWithPrevious(state);
    state = await AsyncValue.guard(
      () => ref.read(myZeroonRepositoryProvider).meet(),
    );
  }
}
