import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../common/zeroon_design.dart';
import 'record_controller.dart';
import 'record_complete_screen.dart';
import 'record_models.dart';
import '../state/state_controller.dart';
import '../state/state_models.dart';

class ResetScreen extends ConsumerStatefulWidget {
  const ResetScreen({super.key, this.onReturnHome});

  final VoidCallback? onReturnHome;

  @override
  ConsumerState<ResetScreen> createState() => _ResetScreenState();
}

class _ResetScreenState extends ConsumerState<ResetScreen> {
  final _goalController = TextEditingController();
  final _contentController = TextEditingController();
  String? _message;
  bool _saving = false;

  @override
  void dispose() {
    _goalController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentState = ref.watch(currentStateProvider);
    return ZeroonScreen(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 28),
        children: [
          const ZeroonHeader(mark: 'ZERO RECORD', title: '归零', center: true),
          const SizedBox(height: 28),
          currentState.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, stackTrace) => Text('状态读取失败：$error'),
            data: (snapshot) => _LockedStateCard(snapshot: snapshot),
          ),
          const SizedBox(height: 22),
          TextField(
            controller: _contentController,
            maxLines: 4,
            maxLength: 5000,
            decoration: const InputDecoration(
              labelText: '留下一句话',
              hintText: '今天发生了什么？',
              alignLabelWithHint: true,
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _goalController,
            maxLength: 1000,
            decoration: const InputDecoration(
              labelText: '今天想完成什么',
              hintText: '完成一个很小的进展',
            ),
          ),
          const SizedBox(height: 8),
          ZeroonPrimaryButton(
            label: '保存这次归零',
            loading: _saving,
            onPressed: _save,
          ),
          if (_message != null) ...[
            const SizedBox(height: 16),
            Text(_message!, style: const TextStyle(color: Color(0xFF2F6F78))),
          ],
        ],
      ),
    );
  }

  Future<void> _save() async {
    final snapshot = ref.read(currentStateProvider).valueOrNull;
    if (snapshot == null || !snapshot.hasActiveSession) {
      setState(() => _message = '请先回到此刻，选择一个当前状态。');
      return;
    }
    final request = CreateRecordRequest(
      goal: _goalController.text,
      content: _contentController.text,
    );
    if (!request.hasContent) {
      setState(() => _message = '至少写下一点感受、进展或内容。');
      return;
    }

    setState(() {
      _saving = true;
      _message = null;
    });
    try {
      final record =
          await ref.read(recordListProvider.notifier).create(request);
      ref.invalidate(currentStateProvider);
      _goalController.clear();
      _contentController.clear();
      if (!mounted) {
        return;
      }
      setState(() {
        _saving = false;
      });
      await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => RecordCompleteScreen(
            record: record,
            onReturnHome: widget.onReturnHome,
          ),
        ),
      );
    } catch (error) {
      if (mounted) {
        setState(() {
          _saving = false;
          _message = '保存失败：$error';
        });
      }
    }
  }
}

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
            active ? '正在归零的状态' : '还没有选择此刻状态',
            style: const TextStyle(color: zeroonMuted, fontSize: 10),
          ),
          const SizedBox(height: 14),
          StateCore(size: 118, state: snapshot.state),
          const SizedBox(height: 14),
          Text(
            active ? stateLabel(snapshot.state) : '请先回到此刻选择状态',
            style: zeroonSerif(context, size: 24),
          ),
          const SizedBox(height: 6),
          Text(
            active
                ? _durationText(_elapsedSeconds(snapshot))
                : 'ZEROON 会从选择状态开始记录持续时间。',
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

String _durationText(int seconds) {
  if (seconds < 60) {
    return '刚刚开始停留';
  }
  final minutes = seconds ~/ 60;
  if (minutes < 60) {
    return '停留了约 $minutes 分钟';
  }
  final hours = minutes ~/ 60;
  final restMinutes = minutes % 60;
  if (restMinutes == 0) {
    return '停留了约 $hours 小时';
  }
  return '停留了约 $hours 小时 $restMinutes 分钟';
}
