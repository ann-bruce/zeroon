import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../common/zeroon_design.dart';
import '../record/archive_screen.dart';
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
          message: error.toString(),
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
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 30),
      children: [
        ZeroonHeader(
          mark: 'COMPANION GROWTH',
          title: '陪伴成长',
          center: true,
          leading: ZeroonIconButton(
            child: const Icon(Icons.chevron_left),
            onPressed: () => Navigator.of(context).maybePop(),
          ),
          action: ZeroonIconButton(
            child: const Icon(Icons.info_outline),
            onPressed: () => _showGrowthInfo(context),
          ),
        ),
        const SizedBox(height: 18),
        _GrowthOrbit(days: summary.companionDays),
        const SizedBox(height: 8),
        SectionMark('TOGETHER SINCE ${_formatDate(summary.firstRecordDate)}'),
        const SizedBox(height: 10),
        Text(
          _growthTitle(summary.companionDays),
          textAlign: TextAlign.center,
          style: zeroonSerif(context, size: 24),
        ),
        const SizedBox(height: 8),
        const Text(
          '不是每一天都需要留下什么。\n但你走过的路，正在这里慢慢发光。',
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 22),
        GridView.count(
          crossAxisCount: 2,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          childAspectRatio: 1.16,
          children: [
            _GrowthMetricCard(
              title: '连续归零',
              value: '${summary.continuousResetDays}',
              unit: '天',
              description: '最近一次连续记录',
            ),
            _GrowthMetricCard(
              title: '累计缓存',
              value: '${summary.cachedEntries}',
              unit: '条',
              description: '可见的私人沉淀',
            ),
            _GrowthMetricCard(
              title: '第一次记录',
              value: _formatDate(summary.firstRecordDate),
              unit: '',
              description: '时间从这里开始',
            ),
            _GrowthMetricCard(
              title: '陪伴天数',
              value: '${summary.companionDays}',
              unit: '天',
              description: '包含相遇的第一天',
            ),
          ],
        ),
        const SizedBox(height: 16),
        _StatePatternCard(
          statePattern: statePattern,
          onRetry: onRetryPattern,
        ),
        const SizedBox(height: 14),
        OutlinedButton(
          onPressed: () => Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => const ArchiveScreen(),
            ),
          ),
          style: OutlinedButton.styleFrom(
            foregroundColor: zeroonNight,
            side: BorderSide(color: zeroonNight.withValues(alpha: 0.18)),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            minimumSize: const Size.fromHeight(48),
          ),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('回看这一年的山海缓存'),
              SizedBox(width: 8),
              Icon(Icons.arrow_forward, size: 16),
            ],
          ),
        ),
      ],
    );
  }

  String _growthTitle(int days) {
    if (days >= 365) {
      return '我们已经一起走过一年。';
    }
    if (days > 1) {
      return '我们已经一起走过 $days 天。';
    }
    return '时间从第一条记录开始。';
  }

  String _formatDate(DateTime? date) {
    if (date == null) {
      return '还没有';
    }
    final year = date.year.toString().padLeft(4, '0');
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    return '$year.$month.$day';
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
        loading: () => const Text(
          '正在整理近期状态观察...',
          style: TextStyle(color: Color(0xFFE9DFCC), fontSize: 10),
        ),
        error: (error, stackTrace) => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SectionMark('这一年的 ZEROON'),
            const SizedBox(height: 8),
            Text('近期状态观察暂时不可用。',
                style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            OutlinedButton(onPressed: onRetry, child: const Text('重试观察')),
          ],
        ),
        data: (data) => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SectionMark('这一年的 ZEROON'),
            const SizedBox(height: 6),
            Text(
              _yearlyZeroonCopy(data),
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

  String _yearlyZeroonCopy(StatePatternSummary data) {
    if (data.dominantState == null) {
      return 'ZEROON 还在安静等待更多记录。时间不急，能留下来的东西会慢慢出现。';
    }
    final label = stateLabel(data.dominantState!);
    if (label == '专注') {
      return '你最常回到「专注」，也正在学会把模糊的想法，一点一点放进可以被看见的地方。';
    }
    return '你最常回到「$label」。ZEROON 会记得这些微小的变化，也陪你慢慢看见它们。';
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
          children: const [
            SectionMark('GROWTH NOTE'),
            SizedBox(height: 10),
            Text(
              '陪伴成长说明',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
            ),
            SizedBox(height: 12),
            Text('连续归零、累计缓存和第一次记录来自你的归零记录。'),
            SizedBox(height: 8),
            Text('“这一年的 ZEROON”来自近期状态分布和山海缓存中的可见记录。'),
            SizedBox(height: 8),
            Text('ZEROON 不做诊断，不给你贴固定标签，只帮助你回看自己留下的变化。'),
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
        width: 188,
        height: 188,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Container(
              width: 176,
              height: 176,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: zeroonLine),
              ),
            ),
            Container(
              width: 140,
              height: 140,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: zeroonGold.withValues(alpha: 0.22)),
              ),
            ),
            const Positioned(
              top: 24,
              right: 42,
              child: _OrbitStar(size: 8),
            ),
            const Positioned(
              left: 28,
              bottom: 52,
              child: _OrbitStar(size: 6),
            ),
            const Positioned(
              right: 28,
              bottom: 34,
              child: _OrbitStar(size: 5),
            ),
            Container(
              width: 104,
              height: 104,
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
                    style: zeroonSerif(context, size: 30, color: zeroonIvory),
                  ),
                  const SizedBox(height: 2),
                  const Text(
                    '天',
                    style: TextStyle(
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
  const _GrowthError({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        Text('成长数据读取失败', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        Text(message),
        const SizedBox(height: 12),
        OutlinedButton(onPressed: onRetry, child: const Text('重试')),
      ],
    );
  }
}
