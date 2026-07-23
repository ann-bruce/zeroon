import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../l10n/l10n_extensions.dart';
import 'record_controller.dart';
import 'record_models.dart';

class RecordDetailScreen extends ConsumerWidget {
  const RecordDetailScreen({super.key, required this.recordId});

  final int recordId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final record = ref.watch(recordDetailProvider(recordId));

    return Scaffold(
      appBar: AppBar(title: Text(context.l10n.recordDetailTitle)),
      body: SafeArea(
        child: record.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stackTrace) => Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(context.l10n.recordLoadFailed,
                    style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 12),
                OutlinedButton(
                  onPressed: () =>
                      ref.invalidate(recordDetailProvider(recordId)),
                  child: Text(context.l10n.retry),
                ),
              ],
            ),
          ),
          data: (item) => ListView(
            padding: const EdgeInsets.all(24),
            children: [
              Row(
                children: [
                  Text(context.l10n.archiveMemoryMark,
                      style: Theme.of(context).textTheme.labelLarge),
                  const Spacer(),
                  Chip(label: Text(context.l10n.privateRecord)),
                ],
              ),
              const SizedBox(height: 24),
              Text(recordPreview(item),
                  style: Theme.of(context).textTheme.headlineSmall),
              const SizedBox(height: 12),
              Text('${context.l10n.recordNumber} #${item.id}'),
              const SizedBox(height: 4),
              Text(context.l10n.resetStateValue(
                localizedStateLabel(context, item.state),
              )),
              const SizedBox(height: 4),
              Text(context.l10n.recordTimeValue(
                _formatRecordTimeRange(context, item),
              )),
              const SizedBox(height: 24),
              if (item.goal != null)
                _DetailBlock(
                    title: context.l10n.smallProgressTitle,
                    content: item.goal!),
              if (item.content != null)
                _DetailBlock(
                    title: context.l10n.recordWordsTitle,
                    content: item.content!),
              if (item.aiSummary != null)
                _DetailBlock(
                    title: context.l10n.zeroonEchoTitle,
                    content: item.aiSummary!),
            ],
          ),
        ),
      ),
    );
  }
}

String _formatRecordTimeRange(BuildContext context, ZeroRecord record) {
  final startedAt = record.stateStartedAt?.toLocal();
  final endedAt = record.stateEndedAt?.toLocal();
  if (startedAt != null && endedAt != null) {
    return '${localizedTime(context, startedAt)} – ${localizedTime(context, endedAt)}';
  }
  return localizedTime(context, record.createdAt);
}

class _DetailBlock extends StatelessWidget {
  const _DetailBlock({required this.title, required this.content});

  final String title;
  final String content;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: 8),
            Text(content),
          ],
        ),
      ),
    );
  }
}
