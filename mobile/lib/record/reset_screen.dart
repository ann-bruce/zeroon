import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../common/zeroon_design.dart';
import '../auth/auth_controller.dart';
import '../evidence/evidence_models.dart';
import '../evidence/evidence_repository.dart';
import '../l10n/l10n_extensions.dart';
import 'record_controller.dart';
import 'record_complete_screen.dart';
import 'record_models.dart';
import 'reset_draft_store.dart';
import '../state/state_controller.dart';
import '../state/state_models.dart';

final resetDraftOwnerUidProvider = Provider<String?>((ref) {
  return ref.watch(authControllerProvider).valueOrNull?.user.uid;
});

class ResetScreen extends ConsumerStatefulWidget {
  const ResetScreen({
    super.key,
    this.onReturnHome,
    this.entrySource = 'NOW',
    this.returnCueRecordAgeBucket,
  });

  final VoidCallback? onReturnHome;
  final String entrySource;
  final String? returnCueRecordAgeBucket;

  @override
  ConsumerState<ResetScreen> createState() => _ResetScreenState();
}

class _ResetScreenState extends ConsumerState<ResetScreen> {
  final _goalController = TextEditingController();
  final _contentController = TextEditingController();
  final _goalFocusNode = FocusNode();
  String? _message;
  bool _saving = false;
  bool _resetRecorded = false;
  bool _showSmallDirection = false;
  int _saveAttempts = 0;
  Timer? _draftSaveDebounce;
  ProviderSubscription<String?>? _draftOwnerSubscription;
  String? _draftOwnerUid;
  String? _draftIntentKey;
  bool _draftReady = false;
  bool _suppressDraftWrites = false;
  bool _hasDraft = false;

  @override
  void initState() {
    super.initState();
    _goalController.addListener(_scheduleDraftSave);
    _contentController.addListener(_scheduleDraftSave);
    _draftOwnerSubscription = ref.listenManual<String?>(
      resetDraftOwnerUidProvider,
      (previous, next) => unawaited(_loadDraft(next)),
      fireImmediately: true,
    );
  }

  @override
  void dispose() {
    _draftSaveDebounce?.cancel();
    _draftOwnerSubscription?.close();
    _goalController.dispose();
    _contentController.dispose();
    _goalFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentState = ref.watch(currentStateProvider);
    final recordPage = ref.watch(recordListProvider).valueOrNull;
    final snapshot = currentState.valueOrNull;
    if (snapshot != null && !_resetRecorded) {
      _resetRecorded = true;
      unawaited(ref.read(evidenceRepositoryProvider).record(
            EvidenceEvent('RESET_STARTED', {
              'entrySource': widget.entrySource,
              'activeStatePresent': snapshot.hasActiveSession,
            }),
          ));
    }
    return ZeroonScreen(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 28),
        children: [
          ZeroonHeader(
            mark: 'ZERO RECORD',
            title: context.l10n.resetTitle,
            center: true,
          ),
          const SizedBox(height: 28),
          currentState.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, stackTrace) => Text(context.l10n.stateLoadFailed),
            data: (snapshot) => _LockedStateCard(snapshot: snapshot),
          ),
          const SizedBox(height: 22),
          TextField(
            controller: _contentController,
            maxLines: 4,
            maxLength: 5000,
            decoration: InputDecoration(
              labelText: context.l10n.recordSomethingLabel,
              hintText: context.l10n.recordSomethingHint,
              alignLabelWithHint: true,
            ),
          ),
          const SizedBox(height: 12),
          if (_showSmallDirection)
            TextField(
              key: const Key('small-direction-field'),
              controller: _goalController,
              focusNode: _goalFocusNode,
              maxLength: 1000,
              decoration: InputDecoration(
                labelText: context.l10n.smallProgressLabel,
                hintText: context.l10n.smallProgressHint,
              ),
            )
          else
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton.icon(
                key: const Key('add-small-direction'),
                onPressed: _revealSmallDirection,
                style: TextButton.styleFrom(
                  foregroundColor: zeroonMuted,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 4,
                    vertical: 10,
                  ),
                ),
                icon: const Icon(Icons.add, size: 17),
                label: Text(context.l10n.addSmallDirection),
              ),
            ),
          const SizedBox(height: 8),
          ZeroonPrimaryButton(
            label: context.l10n.saveReset,
            loading: _saving,
            onPressed: () => _save(
              isFirstRecord: recordPage?.totalElements == 0,
            ),
          ),
          if (_hasDraft) ...[
            const SizedBox(height: 6),
            Align(
              alignment: Alignment.center,
              child: TextButton(
                key: const Key('discard-record-draft'),
                onPressed: _saving ? null : _confirmDiscardDraft,
                style: TextButton.styleFrom(foregroundColor: zeroonMuted),
                child: Text(context.l10n.discardRecordDraft),
              ),
            ),
          ],
          if (_message != null) ...[
            const SizedBox(height: 16),
            Text(_message!, style: const TextStyle(color: Color(0xFF2F6F78))),
          ],
        ],
      ),
    );
  }

  void _revealSmallDirection() {
    setState(() => _showSmallDirection = true);
    _scheduleDraftSave();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _goalFocusNode.requestFocus();
      }
    });
  }

  Future<void> _save({required bool isFirstRecord}) async {
    final snapshot = ref.read(currentStateProvider).valueOrNull;
    if (snapshot == null || !snapshot.hasActiveSession) {
      setState(() => _message = context.l10n.chooseStateFromNow);
      return;
    }
    final request = CreateRecordRequest(
      goal: _goalController.text,
      content: _contentController.text,
    );
    if (!request.hasContent) {
      setState(() => _message = context.l10n.recordContentValidation);
      return;
    }

    setState(() {
      _saving = true;
      _message = null;
    });
    _saveAttempts += 1;
    final idempotencyKey = _draftIntentKey ??= _newIntentKey();
    final startedAt = DateTime.now();
    try {
      final record = await ref.read(recordListProvider.notifier).create(
            request,
            idempotencyKey: idempotencyKey,
          );
      unawaited(ref.read(evidenceRepositoryProvider).record(
            EvidenceEvent('RECORD_SAVED', {
              'state': record.state,
              'hasGoal': _hasText(request.goal),
              'hasContent': _hasText(request.content),
              'latencyBucket':
                  latencyBucket(DateTime.now().difference(startedAt)),
              'retryCountBucket': retryCountBucket(_saveAttempts - 1),
            }),
          ));
      final returnCueRecordAgeBucket = widget.returnCueRecordAgeBucket;
      if (returnCueRecordAgeBucket != null) {
        unawaited(ref.read(evidenceRepositoryProvider).record(
              EvidenceEvent('RETURN_CUE_CONTINUED', {
                'recordAgeBucket': returnCueRecordAgeBucket,
                'surface': 'NOW',
              }),
            ));
      }
      ref.invalidate(currentStateProvider);
      _draftSaveDebounce?.cancel();
      final ownerUid = _draftOwnerUid;
      if (ownerUid != null) {
        try {
          await ref.read(resetDraftStoreProvider).clear(ownerUid);
        } catch (_) {
          // A confirmed Record remains saved even if local cleanup fails.
        }
      }
      _suppressDraftWrites = true;
      _goalController.clear();
      _contentController.clear();
      _suppressDraftWrites = false;
      if (!mounted) {
        return;
      }
      setState(() {
        _saving = false;
        _hasDraft = false;
        _draftIntentKey = null;
      });
      await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => RecordCompleteScreen(
            record: record,
            isFirstRecord: isFirstRecord,
            onReturnHome: widget.onReturnHome,
          ),
        ),
      );
    } catch (error) {
      final failure = classifyEvidenceFailure(error);
      unawaited(ref.read(evidenceRepositoryProvider).record(
            EvidenceEvent('RECORD_SAVE_FAILED', {
              'errorClass': failure.errorClass,
              'retryable': failure.retryable,
              'networkStatus': failure.networkStatus,
            }),
          ));
      if (mounted) {
        setState(() {
          _saving = false;
          _message = context.l10n.recordSaveFailed;
        });
      }
    }
  }

  Future<void> _loadDraft(String? ownerUid) async {
    if (_draftOwnerUid == ownerUid && _draftReady) {
      return;
    }
    _draftSaveDebounce?.cancel();
    _draftOwnerUid = ownerUid;
    _draftReady = false;
    if (ownerUid == null) {
      return;
    }

    try {
      final draft = await ref.read(resetDraftStoreProvider).read(ownerUid);
      if (!mounted || _draftOwnerUid != ownerUid) {
        return;
      }
      _draftReady = true;
      if (draft == null) {
        if (_hasCurrentInput) {
          _scheduleDraftSave();
        }
        return;
      }
      if (_hasCurrentInput) {
        _scheduleDraftSave();
        return;
      }
      _suppressDraftWrites = true;
      _draftIntentKey = draft.intentKey;
      _contentController.text = draft.content;
      _goalController.text = draft.goal;
      _suppressDraftWrites = false;
      setState(() {
        _showSmallDirection = draft.showSmallDirection;
        _hasDraft = draft.hasInput;
        if (draft.hasInput) {
          _message = context.l10n.recordDraftRestored;
        }
      });
    } catch (_) {
      if (!mounted || _draftOwnerUid != ownerUid) {
        return;
      }
      _draftReady = true;
      setState(() => _message = context.l10n.recordDraftStorageFailed);
    }
  }

  bool get _hasCurrentInput =>
      _contentController.text.isNotEmpty ||
      _goalController.text.isNotEmpty ||
      _showSmallDirection;

  void _scheduleDraftSave() {
    if (_suppressDraftWrites || !_draftReady || _draftOwnerUid == null) {
      return;
    }
    final hasDraft = _hasCurrentInput;
    if (mounted && _hasDraft != hasDraft) {
      setState(() => _hasDraft = hasDraft);
    }
    _draftSaveDebounce?.cancel();
    _draftSaveDebounce = Timer(
      const Duration(milliseconds: 350),
      () => unawaited(_persistDraft()),
    );
  }

  Future<void> _persistDraft() async {
    final ownerUid = _draftOwnerUid;
    if (ownerUid == null || !_draftReady) {
      return;
    }
    try {
      if (!_hasCurrentInput) {
        await ref.read(resetDraftStoreProvider).clear(ownerUid);
        return;
      }
      final intentKey = _draftIntentKey ??= _newIntentKey();
      final snapshot = ref.read(currentStateProvider).valueOrNull;
      await ref.read(resetDraftStoreProvider).write(
            ownerUid,
            ResetDraft(
              intentKey: intentKey,
              content: _contentController.text,
              goal: _goalController.text,
              showSmallDirection: _showSmallDirection,
              stateSessionId: snapshot?.sessionId,
            ),
          );
    } catch (_) {
      if (mounted && _draftOwnerUid == ownerUid) {
        setState(() => _message = context.l10n.recordDraftStorageFailed);
      }
    }
  }

  String _newIntentKey() {
    final random = Random.secure();
    return List.generate(
      16,
      (_) => random.nextInt(256).toRadixString(16).padLeft(2, '0'),
    ).join();
  }

  Future<void> _confirmDiscardDraft() async {
    final discard = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(context.l10n.discardRecordDraftTitle),
        content: Text(context.l10n.discardRecordDraftBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(context.l10n.back),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(context.l10n.discardRecordDraft),
          ),
        ],
      ),
    );
    if (discard != true || !mounted) {
      return;
    }

    _draftSaveDebounce?.cancel();
    final ownerUid = _draftOwnerUid;
    try {
      if (ownerUid != null) {
        await ref.read(resetDraftStoreProvider).clear(ownerUid);
      }
      _suppressDraftWrites = true;
      _contentController.clear();
      _goalController.clear();
      _suppressDraftWrites = false;
      setState(() {
        _showSmallDirection = false;
        _hasDraft = false;
        _draftIntentKey = null;
        _message = context.l10n.recordDraftDiscarded;
      });
    } catch (_) {
      if (mounted) {
        setState(() => _message = context.l10n.recordDraftStorageFailed);
      }
    }
  }
}

bool _hasText(String? value) => value != null && value.trim().isNotEmpty;

class _LockedStateCard extends StatefulWidget {
  const _LockedStateCard({required this.snapshot});

  final StateSnapshot snapshot;

  @override
  State<_LockedStateCard> createState() => _LockedStateCardState();
}

class _LockedStateCardState extends State<_LockedStateCard> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  @override
  void didUpdateWidget(covariant _LockedStateCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.snapshot.sessionId != widget.snapshot.sessionId ||
        oldWidget.snapshot.startedAt != widget.snapshot.startedAt) {
      _startTimer();
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final snapshot = widget.snapshot;
    final active = snapshot.hasActiveSession;
    return ZeroonCard(
      color: active
          ? Colors.white.withValues(alpha: 0.62)
          : zeroonGold.withValues(alpha: 0.10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            active
                ? context.l10n.currentResetState
                : context.l10n.noStateSelected,
            style: const TextStyle(color: zeroonMuted, fontSize: 10),
          ),
          const SizedBox(height: 14),
          StateCore(size: 118, state: snapshot.state),
          const SizedBox(height: 14),
          Text(
            active
                ? localizedStateLabel(context, snapshot.state)
                : context.l10n.chooseStateFromNow,
            style: zeroonSerif(context, size: 24),
          ),
          const SizedBox(height: 6),
          Text(
            active
                ? _durationText(context, _elapsedSeconds(snapshot))
                : context.l10n.resetDurationHint,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  void _startTimer() {
    _timer?.cancel();
    if (!widget.snapshot.hasActiveSession) {
      return;
    }
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) {
        setState(() {});
      }
    });
  }
}

int _elapsedSeconds(StateSnapshot snapshot) {
  final startedAt = snapshot.startedAt;
  if (startedAt == null) {
    return snapshot.elapsedSeconds;
  }
  final liveSeconds = DateTime.now().difference(startedAt.toLocal()).inSeconds;
  return liveSeconds > snapshot.elapsedSeconds
      ? liveSeconds
      : snapshot.elapsedSeconds;
}

String _durationText(BuildContext context, int seconds) {
  if (seconds < 60) {
    return context.l10n.justStarted;
  }
  final minutes = seconds ~/ 60;
  if (minutes < 60) {
    return context.l10n.minutesStayed(minutes);
  }
  final hours = minutes ~/ 60;
  final restMinutes = minutes % 60;
  if (restMinutes == 0) {
    return context.l10n.hoursStayed(hours);
  }
  return context.l10n.hoursMinutesStayed(hours, restMinutes);
}
