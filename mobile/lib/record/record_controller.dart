import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../growth/growth_controller.dart';
import '../memory/memory_controller.dart';
import 'continuity_cue_controller.dart';
import 'record_models.dart';
import 'record_repository.dart';

final recordListProvider =
    AsyncNotifierProvider<RecordListController, RecordPage>(
  RecordListController.new,
);

final recordDetailProvider =
    FutureProvider.family<ZeroRecord, int>((ref, recordId) {
  return ref.watch(recordRepositoryProvider).get(recordId);
});

class RecordListController extends AsyncNotifier<RecordPage> {
  @override
  Future<RecordPage> build() {
    return ref.watch(recordRepositoryProvider).list();
  }

  Future<ZeroRecord> create(
    CreateRecordRequest request, {
    required String idempotencyKey,
  }) async {
    final record = await ref.read(recordRepositoryProvider).create(
          request,
          idempotencyKey: idempotencyKey,
        );
    ref.invalidateSelf();
    // Growth metrics and Now's streak strip depend on record history.
    ref.invalidate(growthSummaryProvider);
    ref.invalidate(statePatternSummaryProvider);
    return record;
  }

  Future<void> deleteRecord(int recordId) async {
    await ref.read(recordRepositoryProvider).delete(recordId);
    ref.invalidate(recordDetailProvider(recordId));
    ref.invalidateSelf();
    ref.invalidate(memoryListProvider);
    ref.invalidate(growthSummaryProvider);
    ref.invalidate(statePatternSummaryProvider);
    ref.invalidate(continuityCueProvider);
  }
}
