import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../evidence/evidence_models.dart';
import '../evidence/evidence_repository.dart';
import 'memory_models.dart';
import 'memory_repository.dart';

final memoryListProvider =
    AsyncNotifierProvider<MemoryListController, MemoryPage>(
  MemoryListController.new,
);

class MemoryListController extends AsyncNotifier<MemoryPage> {
  @override
  Future<MemoryPage> build() {
    return ref.watch(memoryRepositoryProvider).list();
  }

  Future<void> setEnabled(int memoryId, bool enabled) async {
    final updated = await ref.read(memoryRepositoryProvider).updateControls(
          memoryId,
          UpdateMemoryControlsRequest(enabled: enabled),
        );
    final current = state.valueOrNull;
    if (current != null) {
      state = AsyncData(current.replace(updated));
    }
    _recordControl(enabled ? 'ENABLE' : 'DISABLE');
  }

  Future<void> setAiContextEnabled(int memoryId, bool aiContextEnabled) async {
    final updated = await ref.read(memoryRepositoryProvider).updateControls(
          memoryId,
          UpdateMemoryControlsRequest(aiContextEnabled: aiContextEnabled),
        );
    final current = state.valueOrNull;
    if (current != null) {
      state = AsyncData(current.replace(updated));
    }
    _recordControl(aiContextEnabled ? 'ALLOW_AI' : 'DISALLOW_AI');
  }

  Future<void> delete(int memoryId) async {
    await ref.read(memoryRepositoryProvider).delete(memoryId);
    final current = state.valueOrNull;
    if (current != null) {
      state = AsyncData(current.remove(memoryId));
    }
    _recordControl('DELETE');
  }

  void _recordControl(String action) {
    unawaited(ref.read(evidenceRepositoryProvider).record(
          EvidenceEvent('MEMORY_CONTROL_CHANGED', {
            'action': action,
            'sourceType': 'MEMORY',
          }),
        ));
  }
}
