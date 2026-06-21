import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../auth/auth_controller.dart';
import '../auth/auth_models.dart';
import '../common/zeroon_design.dart';
import '../growth/growth_controller.dart';
import '../record/record_controller.dart';
import '../record/archive_screen.dart';
import '../record/record_models.dart';
import '../state/state_controller.dart';
import '../state/state_models.dart';

class NowScreen extends ConsumerWidget {
  const NowScreen({
    super.key,
    required this.session,
    required this.onStartReset,
  });

  final AuthSession session;
  final VoidCallback onStartReset;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ZeroonScreen(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
        children: [
          Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SectionMark('TODAY · ZEROON'),
                  const SizedBox(height: 5),
                  Text('晚上好，${_displayName(session)}',
                      style: Theme.of(context).textTheme.titleLarge),
                ],
              ),
              const Spacer(),
              ZeroonIconButton(
                dark: true,
                onPressed: () =>
                    ref.read(authControllerProvider.notifier).logout(),
                child: const Icon(Icons.logout),
              ),
            ],
          ),
          const SizedBox(height: 28),
          _StateHero(onStartReset: onStartReset),
        ],
      ),
    );
  }

  String _displayName(AuthSession session) {
    final value = session.user.mobile ?? session.user.uid;
    if (value.length <= 4) {
      return value;
    }
    return value.substring(value.length - 4);
  }
}

class _StateHero extends ConsumerWidget {
  const _StateHero({required this.onStartReset});

  final VoidCallback onStartReset;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentState = ref.watch(currentStateProvider);
    final growthSummary = ref.watch(growthSummaryProvider);
    final records = ref.watch(recordListProvider);

    return currentState.when(
      loading: () => const _StateLoading(),
      error: (error, stackTrace) => _StateError(
        message: error.toString(),
        onRetry: () => ref.invalidate(currentStateProvider),
      ),
      data: (snapshot) => _StatePanel(
        snapshot: snapshot,
        continuousResetDays: growthSummary.valueOrNull?.continuousResetDays,
        recordPage: records.valueOrNull,
        latestTodayRecord: _latestTodayRecord(records.valueOrNull),
        onStartReset: onStartReset,
      ),
    );
  }
}

class _StatePanel extends ConsumerWidget {
  const _StatePanel({
    required this.snapshot,
    required this.continuousResetDays,
    required this.recordPage,
    required this.latestTodayRecord,
    required this.onStartReset,
  });

  final StateSnapshot snapshot;
  final int? continuousResetDays;
  final RecordPage? recordPage;
  final ZeroRecord? latestTodayRecord;
  final VoidCallback onStartReset;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Column(
          children: [
            const Text(
              '今天的 ZEROON',
              style: TextStyle(
                color: zeroonMuted,
                fontSize: 10,
                letterSpacing: 1.4,
              ),
            ),
            const SizedBox(height: 18),
            StateCore(
                state: snapshot.hasActiveSession ? snapshot.state : 'IDLE'),
            const SizedBox(height: 18),
            Text(
              snapshot.hasActiveSession ? stateLabel(snapshot.state) : '选择此刻状态',
              style: zeroonSerif(context, size: 28),
            ),
            const SizedBox(height: 4),
            if (snapshot.hasActiveSession)
              Column(
                children: [
                  Text(_stateHint(snapshot.state), textAlign: TextAlign.center),
                  _LiveDurationText(snapshot: snapshot),
                ],
              )
            else
              const Text(
                '先选择一个最接近的状态，ZEROON 会从这一刻开始记录。',
                textAlign: TextAlign.center,
              ),
          ],
        ),
        const SizedBox(height: 22),
        GridView.count(
          crossAxisCount: 3,
          mainAxisSpacing: 9,
          crossAxisSpacing: 9,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          childAspectRatio: 1.08,
          children: [
            for (final state in zeroonStates)
              _StateChoice(
                state: state,
                selected: snapshot.hasActiveSession && snapshot.state == state,
                onTap: () =>
                    ref.read(currentStateProvider.notifier).changeState(state),
              ),
          ],
        ),
        const SizedBox(height: 26),
        _ResetTrackCard(
          continuousResetDays: continuousResetDays,
          records: recordPage?.items ?? const [],
        ),
        const SizedBox(height: 14),
        ZeroonPrimaryButton(
          label: snapshot.hasActiveSession ? '开始一次归零' : '先选择此刻状态',
          onPressed: snapshot.hasActiveSession ? onStartReset : null,
        ),
        const SizedBox(height: 10),
        ZeroonCard(
          color: zeroonGold.withValues(alpha: 0.12),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => const ArchiveScreen(),
            ),
          ),
          child: Row(
            children: [
              const CircleAvatar(
                radius: 17,
                backgroundColor: Color(0x20D7B46A),
                child: Icon(
                  Icons.inventory_2_outlined,
                  color: Color(0xFF98763C),
                  size: 16,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '今日山海缓存',
                      style: TextStyle(color: Color(0xFF9A8D75), fontSize: 10),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      _todayArchiveText(latestTodayRecord),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(color: zeroonInk, fontSize: 12),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: zeroonMuted),
            ],
          ),
        ),
      ],
    );
  }

  String _stateHint(String state) {
    return switch (state) {
      'FOCUS' => '今天适合安静地完成一件重要的事。',
      'CREATE' => '把浮现出来的想法先放在这里。',
      'TIRED' => '可以慢一点，只保留最小的一步。',
      'OVERLOAD' => '先把负荷放下来，不急着解决全部。',
      'CONFUSED' => '混乱也可以被看见，然后慢慢归零。',
      _ => '这里没有需要证明的事，先看见此刻。',
    };
  }
}

class _ResetTrackCard extends StatelessWidget {
  const _ResetTrackCard({
    required this.continuousResetDays,
    required this.records,
  });

  final int? continuousResetDays;
  final List<ZeroRecord> records;

  @override
  Widget build(BuildContext context) {
    final days = _recentSevenDays();
    final recordDates = {
      for (final record in records) _dateOnly(record.createdAt.toLocal()),
    };

    return ZeroonCard(
      padding: const EdgeInsets.fromLTRB(17, 15, 14, 15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '连续归零',
                      style: TextStyle(color: zeroonMuted, fontSize: 10),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _continuousResetText(continuousResetDays),
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ],
                ),
              ),
              const Text(
                '点亮日期可回看',
                style: TextStyle(color: zeroonMuted, fontSize: 10),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              for (final day in days)
                _ResetTrackDay(
                  date: day,
                  active: recordDates.contains(day),
                  onTap: recordDates.contains(day)
                      ? () => Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => ArchiveScreen(initialDate: day),
                            ),
                          )
                      : null,
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ResetTrackDay extends StatelessWidget {
  const _ResetTrackDay({
    required this.date,
    required this.active,
    required this.onTap,
  });

  final DateTime date;
  final bool active;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final today = _dateOnly(DateTime.now());
    final isToday = date == today;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Column(
        children: [
          Container(
            width: 29,
            height: 29,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: active ? zeroonNight : zeroonBlue.withValues(alpha: 0.10),
              shape: BoxShape.circle,
              border: Border.all(
                color: isToday ? zeroonBlue : Colors.transparent,
              ),
            ),
            child: Text(
              '${date.day}',
              style: TextStyle(
                color: active ? zeroonIvory : zeroonMuted,
                fontSize: 10,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            _weekdayLabel(date),
            style: const TextStyle(color: zeroonMuted, fontSize: 8),
          ),
        ],
      ),
    );
  }
}

class _LiveDurationText extends StatefulWidget {
  const _LiveDurationText({required this.snapshot});

  final StateSnapshot snapshot;

  @override
  State<_LiveDurationText> createState() => _LiveDurationTextState();
}

class _LiveDurationTextState extends State<_LiveDurationText> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  @override
  void didUpdateWidget(covariant _LiveDurationText oldWidget) {
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
    return Text(_durationText(_elapsedSeconds(widget.snapshot)));
  }

  void _startTimer() {
    _timer?.cancel();
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

String _continuousResetText(int? days) {
  if (days == null) {
    return '-- 天';
  }
  return '$days 天';
}

String _todayArchiveText(ZeroRecord? record) {
  if (record == null) {
    return '今天还没有新的山海缓存。';
  }
  return '“${recordPreview(record)}”';
}

ZeroRecord? _latestTodayRecord(RecordPage? page) {
  if (page == null) {
    return null;
  }
  final now = DateTime.now();
  for (final record in page.items) {
    final local = record.createdAt.toLocal();
    if (local.year == now.year &&
        local.month == now.month &&
        local.day == now.day) {
      return record;
    }
  }
  return null;
}

List<DateTime> _recentSevenDays() {
  final today = _dateOnly(DateTime.now());
  return [
    for (var index = 6; index >= 0; index--)
      today.subtract(Duration(days: index)),
  ];
}

DateTime _dateOnly(DateTime value) {
  return DateTime(value.year, value.month, value.day);
}

String _weekdayLabel(DateTime date) {
  return ['一', '二', '三', '四', '五', '六', '日'][date.weekday - 1];
}

class _StateChoice extends StatelessWidget {
  const _StateChoice({
    required this.state,
    required this.selected,
    required this.onTap,
  });

  final String state;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(15),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected ? zeroonNight : Colors.white.withValues(alpha: 0.62),
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: selected ? zeroonNight : zeroonLine),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 19,
              height: 19,
              decoration: BoxDecoration(
                color: stateColor(state),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: stateColor(state).withValues(alpha: 0.45),
                    blurRadius: 13,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 7),
            Text(
              stateLabel(state),
              style: TextStyle(
                color: selected ? zeroonIvory : zeroonInk,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
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

class _StateLoading extends StatelessWidget {
  const _StateLoading();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 84),
      child: Center(child: CircularProgressIndicator()),
    );
  }
}

class _StateError extends StatelessWidget {
  const _StateError({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return ZeroonCard(
      child: Padding(
        padding: EdgeInsets.zero,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('状态读取失败', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Text(message),
            const SizedBox(height: 12),
            OutlinedButton(onPressed: onRetry, child: const Text('重试')),
          ],
        ),
      ),
    );
  }
}
