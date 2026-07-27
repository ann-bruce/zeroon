import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../evidence/evidence_models.dart';
import '../evidence/evidence_repository.dart';
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

  Future<UserProfile> save(UpdateUserProfileRequest request) async {
    final previous = state.valueOrNull?.aiProfileContextEnabled;
    final saved = await ref.read(profileRepositoryProvider).update(request);
    state = AsyncData(saved);
    if (previous != saved.aiProfileContextEnabled) {
      unawaited(ref.read(evidenceRepositoryProvider).record(
            EvidenceEvent('PROFILE_AI_CONTEXT_CHANGED', {
              'enabled': saved.aiProfileContextEnabled,
              'surface': 'PROFILE',
            }),
          ));
    }
    return saved;
  }
}
