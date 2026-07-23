import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../auth/auth_models.dart';
import '../common/zeroon_design.dart';
import '../growth/growth_controller.dart';
import '../l10n/l10n_extensions.dart';
import '../profile/profile_screen.dart';
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
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 20),
        children: [
          Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SectionMark(context.l10n.todayZeroon),
                  const SizedBox(height: 4),
                  Text('${context.l10n.greeting} ${_displayName(session)}',
                      style: Theme.of(context).textTheme.titleLarge),
                ],
              ),
              const Spacer(),
              ZeroonIconButton(
                dark: true,
                semanticLabel: context.l10n.openProfile,
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const ProfileScreen()),
                ),
                child: const Icon(Icons.person_outline),
              ),
            ],
          ),
          const SizedBox(height: 20),
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
            Text(
              context.l10n.todayZeroon,
              style: TextStyle(
                color: zeroonMuted,
                fontSize: 10,
                letterSpacing: 1.4,
              ),
            ),
            const SizedBox(height: 14),
            StateCore(
                state: snapshot.hasActiveSession ? snapshot.state : 'IDLE'),
            const SizedBox(height: 12),
            Text(
              snapshot.hasActiveSession
                  ? localizedStateLabel(context, snapshot.state)
                  : context.l10n.chooseCurrentState,
              style: zeroonSerif(context, size: 26),
            ),
            const SizedBox(height: 3),
            if (snapshot.hasActiveSession)
              Column(
                children: [
                  Text(_stateHint(context, snapshot.state),
                      textAlign: TextAlign.center),
                  _LiveDurationText(snapshot: snapshot),
                ],
              )
            else
              Text(
                context.l10n.chooseStateFirst,
                textAlign: TextAlign.center,
              ),
          ],
        ),
        const SizedBox(height: 16),
        GridView.count(
          crossAxisCount: 3,
          mainAxisSpacing: 8,
          crossAxisSpacing: 8,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          childAspectRatio: 1.22,
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
        const SizedBox(height: 18),
        _ResetTrackCard(
          continuousResetDays: continuousResetDays,
          records: recordPage?.items ?? const [],
        ),
        const SizedBox(height: 12),
        ZeroonPrimaryButton(
          label: snapshot.hasActiveSession
              ? context.l10n.startReset
              : context.l10n.chooseCurrentState,
          onPressed: snapshot.hasActiveSession ? onStartReset : null,
        ),
        const SizedBox(height: 9),
        ZeroonCard(
          color: zeroonGold.withValues(alpha: 0.12),
          padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 10),
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
                    Text(
                      context.l10n.todayArchive,
                      style: TextStyle(color: Color(0xFF9A8D75), fontSize: 10),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      _todayArchiveText(context, latestTodayRecord),
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

  String _stateHint(BuildContext context, String state) {
    return switch (state) {
      'FOCUS' => context.l10n.stateHintFocus,
      'CREATE' => context.l10n.stateHintCreate,
      'TIRED' => context.l10n.stateHintTired,
      'OVERLOAD' => context.l10n.stateHintOverload,
      'CONFUSED' => context.l10n.stateHintConfused,
      _ => context.l10n.stateHintDefault,
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
      padding: const EdgeInsets.fromLTRB(16, 13, 13, 13),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      context.l10n.continuousReset,
                      style: TextStyle(color: zeroonMuted, fontSize: 10),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      continuousResetDays == null
                          ? '--'
                          : context.l10n.dayCount(continuousResetDays!),
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ],
                ),
              ),
              Text(
                context.l10n.tapDateToReview,
                style: TextStyle(color: zeroonMuted, fontSize: 10),
              ),
            ],
          ),
          const SizedBox(height: 10),
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
            width: 27,
            height: 27,
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
          const SizedBox(height: 3),
          Text(
            DateFormat.E(context.localeName).format(date),
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
    return Text(_durationText(context, _elapsedSeconds(widget.snapshot)));
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

String _todayArchiveText(BuildContext context, ZeroRecord? record) {
  if (record == null) {
    return context.l10n.noArchiveToday;
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
              width: 17,
              height: 17,
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
            const SizedBox(height: 5),
            Text(
              localizedStateLabel(context, state),
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
  const _StateError({required this.onRetry});
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return ZeroonCard(
      child: Padding(
        padding: EdgeInsets.zero,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(context.l10n.stateLoadFailed,
                style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),
            OutlinedButton(
              onPressed: onRetry,
              child: Text(context.l10n.retry),
            ),
          ],
        ),
      ),
    );
  }
}
