import 'package:flutter_riverpod/flutter_riverpod.dart';

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

  Future<ZeroRecord> create(CreateRecordRequest request) async {
    final record = await ref.read(recordRepositoryProvider).create(request);
    ref.invalidateSelf();
    return record;
  }
}
