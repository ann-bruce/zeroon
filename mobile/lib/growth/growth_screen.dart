import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'growth_controller.dart';
import 'growth_models.dart';

class GrowthScreen extends ConsumerWidget {
  const GrowthScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summary = ref.watch(growthSummaryProvider);
    final statePattern = ref.watch(statePatternSummaryProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('陪伴成长')),
      body: SafeArea(
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
      padding: const EdgeInsets.all(24),
      children: [
        Text('ZEROON 陪你缓存过的时间。',
            style: Theme.of(context).textTheme.headlineSmall),
        const SizedBox(height: 8),
        const Text('这些数字只记录同行的痕迹，不做排名，也不惩罚中断。'),
        const SizedBox(height: 24),
        _GrowthMetricCard(
          title: '连续归零',
          value: '${summary.continuousResetDays}天',
          description: '今天或昨天为结尾的连续记录天数',
        ),
        _GrowthMetricCard(
          title: '累计缓存',
          value: '${summary.cachedEntries}条',
          description: '当前 Archive 中可见的记录数量',
        ),
        _GrowthMetricCard(
          title: '第一次记录',
          value: _formatDate(summary.firstRecordDate),
          description: '你第一次把状态放进 ZEROON 的日期',
        ),
        _GrowthMetricCard(
          title: '陪伴天数',
          value: '${summary.companionDays}天',
          description: '从注册当天开始计算的包含式天数',
        ),
        const SizedBox(height: 12),
        Text(
          '数据来源：你的归零记录与账号创建时间 · ${summary.timezone}',
          style: Theme.of(context).textTheme.bodySmall,
        ),
        const SizedBox(height: 24),
        _StatePatternCard(
          statePattern: statePattern,
          onRetry: onRetryPattern,
        ),
      ],
    );
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
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: statePattern.when(
          loading: () => const Text('正在整理近期状态观察...'),
          error: (error, stackTrace) => Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('近期状态观察', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              const Text('近期状态观察暂时不可用。'),
              const SizedBox(height: 8),
              OutlinedButton(onPressed: onRetry, child: const Text('重试观察')),
            ],
          ),
          data: (data) => Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('近期状态观察', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              Text(data.observation),
              const SizedBox(height: 12),
              if (data.dominantState != null)
                Text('出现最多：${data.dominantState}'),
              Text('样本数量：${data.sampleSize} 次 · 最近 ${data.days} 天'),
              const SizedBox(height: 12),
              Text(
                '数据来源：${data.dataSources.join(', ')} · ${data.timezone}',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _GrowthMetricCard extends StatelessWidget {
  const _GrowthMetricCard({
    required this.title,
    required this.value,
    required this.description,
  });

  final String title;
  final String value;
  final String description;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 4),
                  Text(description),
                ],
              ),
            ),
            Text(value, style: Theme.of(context).textTheme.headlineSmall),
          ],
        ),
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
