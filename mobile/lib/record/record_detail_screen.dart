import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'record_controller.dart';

class RecordDetailScreen extends ConsumerWidget {
  const RecordDetailScreen({super.key, required this.recordId});

  final int recordId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final record = ref.watch(recordDetailProvider(recordId));

    return Scaffold(
      appBar: AppBar(title: const Text('记录详情')),
      body: SafeArea(
        child: record.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stackTrace) => Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('读取失败', style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 8),
                Text(error.toString()),
                const SizedBox(height: 12),
                OutlinedButton(
                  onPressed: () =>
                      ref.invalidate(recordDetailProvider(recordId)),
                  child: const Text('重试'),
                ),
              ],
            ),
          ),
          data: (item) => ListView(
            padding: const EdgeInsets.all(24),
            children: [
              Text(item.state, style: Theme.of(context).textTheme.labelLarge),
              const SizedBox(height: 12),
              Text(item.createdAt.toLocal().toString()),
              const SizedBox(height: 24),
              if (item.mood != null)
                _DetailBlock(title: '此刻感受', content: item.mood!),
              if (item.goal != null)
                _DetailBlock(title: '今天的小进展', content: item.goal!),
              if (item.content != null)
                _DetailBlock(title: '想记录的话', content: item.content!),
              if (item.aiSummary != null)
                _DetailBlock(title: 'ZEROON 回声', content: item.aiSummary!),
            ],
          ),
        ),
      ),
    );
  }
}

class _DetailBlock extends StatelessWidget {
  const _DetailBlock({required this.title, required this.content});

  final String title;
  final String content;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Theme.of(context).textTheme.titleSmall),
          const SizedBox(height: 8),
          Text(content),
        ],
      ),
    );
  }
}
