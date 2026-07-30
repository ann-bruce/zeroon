import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../evidence/evidence_models.dart';
import '../evidence/evidence_repository.dart';
import 'record_models.dart';
import 'record_repository.dart';

final continuityCueDismissalStoreProvider =
    Provider<ContinuityCueDismissalStore>((ref) {
  return SharedPreferencesContinuityCueDismissalStore();
});

final continuityCueNowProvider = Provider<DateTime Function()>((ref) {
  return DateTime.now;
});

final continuityCueProvider = AsyncNotifierProvider.family<
    ContinuityCueController,
    ContinuityCue?,
    String>(ContinuityCueController.new);

abstract interface class ContinuityCueDismissalStore {
  Future<String?> dismissedDayFor(String userId);

  Future<void> dismissForDay(String userId, String localDay);

  Future<String?> availabilityRecordedDayFor(String userId);

  Future<void> markAvailabilityRecordedForDay(String userId, String localDay);
}

class SharedPreferencesContinuityCueDismissalStore
    implements ContinuityCueDismissalStore {
  static const _dismissedKeyPrefix = 'zeroon.continuity-cue.dismissed.';
  static const _availableKeyPrefix =
      'zeroon.continuity-cue.available-recorded.';

  @override
  Future<String?> dismissedDayFor(String userId) async {
    final preferences = await SharedPreferences.getInstance();
    return preferences.getString('$_dismissedKeyPrefix$userId');
  }

  @override
  Future<void> dismissForDay(String userId, String localDay) async {
    final preferences = await SharedPreferences.getInstance();
    final saved =
        await preferences.setString('$_dismissedKeyPrefix$userId', localDay);
    if (!saved) {
      throw StateError('Continuity cue dismissal storage rejected the write');
    }
  }

  @override
  Future<String?> availabilityRecordedDayFor(String userId) async {
    final preferences = await SharedPreferences.getInstance();
    return preferences.getString('$_availableKeyPrefix$userId');
  }

  @override
  Future<void> markAvailabilityRecordedForDay(
      String userId, String localDay) async {
    final preferences = await SharedPreferences.getInstance();
    final saved =
        await preferences.setString('$_availableKeyPrefix$userId', localDay);
    if (!saved) {
      throw StateError(
          'Continuity cue availability storage rejected the write');
    }
  }
}

class ContinuityCueController
    extends FamilyAsyncNotifier<ContinuityCue?, String> {
  Timer? _dayRefreshTimer;

  @override
  Future<ContinuityCue?> build(String userId) async {
    final now = ref.watch(continuityCueNowProvider)();
    _scheduleNextLocalDayRefresh(now);
    final localDay = localDayKey(now);
    final dismissalStore = ref.watch(continuityCueDismissalStoreProvider);
    if (await dismissalStore.dismissedDayFor(userId) == localDay) {
      return null;
    }
    final cue = await ref
        .watch(recordRepositoryProvider)
        .continuityCue(timezone: localTimezoneId(now));
    if (cue != null &&
        await dismissalStore.availabilityRecordedDayFor(userId) != localDay) {
      var shouldRecord = false;
      try {
        await dismissalStore.markAvailabilityRecordedForDay(userId, localDay);
        shouldRecord = true;
      } catch (_) {
        // Evidence remains optional when local deduplication is unavailable.
      }
      if (shouldRecord) {
        unawaited(ref.read(evidenceRepositoryProvider).record(
              EvidenceEvent('RETURN_CUE_AVAILABLE', {
                'recordAgeBucket': recordAgeBucket(cue.createdAt),
                'surface': 'NOW',
              }),
            ));
      }
    }
    return cue;
  }

  Future<void> dismissForToday() async {
    final cue = state.valueOrNull;
    if (cue == null) {
      return;
    }
    final userId = arg;
    try {
      await ref.read(continuityCueDismissalStoreProvider).dismissForDay(
          userId, localDayKey(ref.read(continuityCueNowProvider)()));
    } catch (_) {
      // Dismissing must remain local and quiet even when device storage fails.
    }
    state = const AsyncData(null);
  }

  void recordOpened(ContinuityCue cue) {
    unawaited(ref.read(evidenceRepositoryProvider).record(
          EvidenceEvent('RETURN_CUE_OPENED', {
            'recordAgeBucket': recordAgeBucket(cue.createdAt),
            'surface': 'NOW',
          }),
        ));
  }

  void _scheduleNextLocalDayRefresh(DateTime now) {
    _dayRefreshTimer?.cancel();
    final local = now.toLocal();
    final nextDay = DateTime(local.year, local.month, local.day + 1);
    _dayRefreshTimer = Timer(nextDay.difference(local), ref.invalidateSelf);
    ref.onDispose(() => _dayRefreshTimer?.cancel());
  }
}

String localDayKey(DateTime value) {
  final local = value.toLocal();
  final month = local.month.toString().padLeft(2, '0');
  final day = local.day.toString().padLeft(2, '0');
  return '${local.year}-$month-$day';
}

String localTimezoneId(DateTime value) {
  final totalMinutes = value.timeZoneOffset.inMinutes;
  final sign = totalMinutes < 0 ? '-' : '+';
  final absoluteMinutes = totalMinutes.abs();
  final hours = (absoluteMinutes ~/ 60).toString().padLeft(2, '0');
  final minutes = (absoluteMinutes % 60).toString().padLeft(2, '0');
  return '$sign$hours:$minutes';
}
