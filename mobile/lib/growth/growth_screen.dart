import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../common/zeroon_design.dart';
import '../l10n/l10n_extensions.dart';
import 'growth_controller.dart';
import 'growth_models.dart';

class GrowthScreen extends ConsumerWidget {
  const GrowthScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summary = ref.watch(growthSummaryProvider);
    final statePattern = ref.watch(statePatternSummaryProvider);

    return ZeroonScreen(
      child: summary.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => _GrowthError(
          onRetry: () => ref.invalidate(growthSummaryProvider),
        ),
        data: (data) => _GrowthContent(
          summary: data,
          statePattern: statePattern,
          onRetryPattern: () => ref.invalidate(statePatternSummaryProvider),
        ),
      ),
    );
  }
}

class _GrowthContent extends StatelessWidget {
  const _GrowthContent({
    required this.summary,
    required this.statePattern,
    required this.onRetryPattern,
  });

  final GrowthSummary summary;
  final AsyncValue<StatePatternSummary> statePattern;
  final VoidCallback onRetryPattern;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
      children: [
        ZeroonHeader(
          mark: 'COMPANION GROWTH',
          title: context.l10n.growthTitle,
          center: true,
          leading: ZeroonIconButton(
            semanticLabel: context.l10n.back,
            child: const Icon(Icons.chevron_left),
            onPressed: () => Navigator.of(context).maybePop(),
          ),
          action: ZeroonIconButton(
            semanticLabel: context.l10n.growthInfoTooltip,
            onPressed: () => _showGrowthInfo(context),
            child: const Icon(Icons.info_outline),
          ),
        ),
        const SizedBox(height: 12),
        _GrowthOrbit(days: summary.companionDays),
        const SizedBox(height: 6),
        SectionMark(
          '${context.l10n.growthTogetherSince} ${_formatDate(context, summary.firstRecordDate)}',
        ),
        const SizedBox(height: 8),
        Text(
          _growthTitle(context, summary.companionDays),
          textAlign: TextAlign.center,
          style: zeroonSerif(context, size: 23),
        ),
        const SizedBox(height: 6),
        Text(
          context.l10n.growthIntro,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),
        GridView.count(
          crossAxisCount: 2,
          mainAxisSpacing: 10,
          crossAxisSpacing: 10,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          childAspectRatio: 1.24,
          children: [
            _GrowthMetricCard(
              title: context.l10n.metricContinuous,
              value: '${summary.continuousResetDays}',
              unit: context.l10n.unitDays,
              description: context.l10n.metricRecentContinuous,
            ),
            _GrowthMetricCard(
              title: context.l10n.metricArchive,
              value: '${summary.cachedEntries}',
              unit: context.l10n.unitRecords,
              description: context.l10n.metricPrivate,
            ),
            _GrowthMetricCard(
              title: context.l10n.metricFirstRecord,
              value: _formatDate(context, summary.firstRecordDate),
              unit: '',
              description: context.l10n.metricTimeStarts,
            ),
            _GrowthMetricCard(
              title: context.l10n.metricCompanionDays,
              value: '${summary.companionDays}',
              unit: context.l10n.unitDays,
              description: context.l10n.metricIncludesMeeting,
            ),
          ],
        ),
        const SizedBox(height: 16),
        _StatePatternCard(
          statePattern: statePattern,
          onRetry: onRetryPattern,
        ),
      ],
    );
  }

  String _growthTitle(BuildContext context, int days) {
    if (days >= 365) {
      return context.l10n.growthTogetherYear;
    }
    if (days > 1) {
      return context.l10n.growthTogetherDays(days);
    }
    return context.l10n.growthStartsFirst;
  }

  String _formatDate(BuildContext context, DateTime? date) {
    if (date == null) {
      return context.l10n.notYet;
    }
    return localizedDate(context, date);
  }
}

class _StatePatternCard extends StatelessWidget {
  const _StatePatternCard({
    required this.statePattern,
    required this.onRetry,
  });

  final AsyncValue<StatePatternSummary> statePattern;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(15, 13, 15, 14),
      decoration: BoxDecoration(
        color: zeroonNight,
        borderRadius: BorderRadius.circular(15),
        gradient: RadialGradient(
          center: const Alignment(0.9, -1),
          radius: 0.9,
          colors: [
            zeroonCyan.withValues(alpha: 0.20),
            zeroonNight,
          ],
        ),
      ),
      child: statePattern.when(
        loading: () => Text(
          context.l10n.growthObservationLoading,
          style: const TextStyle(color: Color(0xFFE9DFCC), fontSize: 10),
        ),
        error: (error, stackTrace) => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SectionMark(context.l10n.growthYearTitle),
            const SizedBox(height: 8),
            Text(context.l10n.growthObservationUnavailable,
                style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            OutlinedButton(
              onPressed: onRetry,
              child: Text(context.l10n.growthRetryObservation),
            ),
          ],
        ),
        data: (data) => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SectionMark(context.l10n.growthYearTitle),
            const SizedBox(height: 6),
            Text(
              _yearlyZeroonCopy(context, data),
              style: const TextStyle(
                color: Color(0xFFE9DFCC),
                fontFamily: 'serif',
                fontSize: 10,
                height: 1.55,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _yearlyZeroonCopy(BuildContext context, StatePatternSummary data) {
    if (data.dominantState == null) {
      return context.l10n.growthWaiting;
    }
    final label = localizedStateLabel(context, data.dominantState!);
    if (data.dominantState == 'FOCUS') {
      return context.l10n.growthFocusNarrative(label);
    }
    return context.l10n.growthStateNarrative(label);
  }
}

void _showGrowthInfo(BuildContext context) {
  showModalBottomSheet<void>(
    context: context,
    backgroundColor: zeroonPaper,
    showDragHandle: true,
    builder: (context) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(24, 4, 24, 28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SectionMark(context.l10n.growthNoteMark),
            const SizedBox(height: 10),
            Text(
              context.l10n.growthNoteTitle,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 12),
            Text(context.l10n.growthNoteRecords),
            const SizedBox(height: 8),
            Text(context.l10n.growthNotePattern),
            const SizedBox(height: 8),
            Text(context.l10n.growthNoteBoundary),
          ],
        ),
      );
    },
  );
}

class _GrowthMetricCard extends StatelessWidget {
  const _GrowthMetricCard({
    required this.title,
    required this.value,
    required this.unit,
    required this.description,
  });

  final String title;
  final String value;
  final String unit;
  final String description;

  @override
  Widget build(BuildContext context) {
    return ZeroonCard(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(color: zeroonMuted, fontSize: 9)),
          const Spacer(),
          RichText(
            text: TextSpan(
              text: value,
              style: zeroonSerif(context, size: value.length > 6 ? 18 : 26),
              children: [
                if (unit.isNotEmpty)
                  TextSpan(
                    text: unit,
                    style: const TextStyle(
                      color: zeroonMuted,
                      fontSize: 10,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 5),
          Text(
            description,
            style: const TextStyle(color: Color(0xFFAAA8A3), fontSize: 8),
          ),
        ],
      ),
    );
  }
}

class _GrowthOrbit extends StatelessWidget {
  const _GrowthOrbit({required this.days});

  final int days;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: 164,
        height: 164,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Container(
              width: 152,
              height: 152,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: zeroonLine),
              ),
            ),
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: zeroonGold.withValues(alpha: 0.22)),
              ),
            ),
            const Positioned(
              top: 22,
              right: 36,
              child: _OrbitStar(size: 8),
            ),
            const Positioned(
              left: 24,
              bottom: 44,
              child: _OrbitStar(size: 6),
            ),
            const Positioned(
              right: 24,
              bottom: 30,
              child: _OrbitStar(size: 5),
            ),
            Container(
              width: 94,
              height: 94,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: zeroonNight,
                boxShadow: [
                  BoxShadow(
                    color: zeroonCyan.withValues(alpha: 0.26),
                    blurRadius: 42,
                    spreadRadius: 6,
                  ),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '$days',
                    style: zeroonSerif(context, size: 28, color: zeroonIvory),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    context.l10n.unitDays,
                    style: const TextStyle(
                      color: Color(0x88F2EEE6),
                      fontSize: 9,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OrbitStar extends StatelessWidget {
  const _OrbitStar({required this.size});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: zeroonGold,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: zeroonGold.withValues(alpha: 0.55),
            blurRadius: 12,
          ),
        ],
      ),
    );
  }
}

class _GrowthError extends StatelessWidget {
  const _GrowthError({required this.onRetry});
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        Text(context.l10n.growthLoadFailed,
            style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 12),
        OutlinedButton(onPressed: onRetry, child: Text(context.l10n.retry)),
      ],
    );
  }
}
