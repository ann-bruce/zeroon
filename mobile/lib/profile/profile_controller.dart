import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'profile_models.dart';
import 'profile_repository.dart';

final profileProvider = AsyncNotifierProvider<ProfileController, UserProfile>(
  ProfileController.new,
);

class ProfileController extends AsyncNotifier<UserProfile> {
  @override
  Future<UserProfile> build() {
    return ref.watch(profileRepositoryProvider).get();
  }

  Future<void> save(UpdateUserProfileRequest request) async {
    state = const AsyncLoading<UserProfile>().copyWithPrevious(state);
    state = await AsyncValue.guard(
      () => ref.read(profileRepositoryProvider).update(request),
    );
  }
}
