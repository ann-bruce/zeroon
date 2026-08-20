import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../evidence/evidence_models.dart';
import '../evidence/evidence_repository.dart';
import '../l10n/l10n_extensions.dart';
import 'record_controller.dart';
import 'record_models.dart';
import 'reset_screen.dart';

class RecordDetailScreen extends ConsumerStatefulWidget {
  const RecordDetailScreen({
    super.key,
    required this.recordId,
    this.openedFromContinuityCue = false,
  });

  final int recordId;
  final bool openedFromContinuityCue;

  @override
  ConsumerState<RecordDetailScreen> createState() => _RecordDetailScreenState();
}

class _RecordDetailScreenState extends ConsumerState<RecordDetailScreen> {
  bool _viewRecorded = false;
  bool _deleting = false;
  String? _deleteFailure;

  @override
  Widget build(BuildContext context) {
    final record = ref.watch(recordDetailProvider(widget.recordId));

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
                      ref.invalidate(recordDetailProvider(widget.recordId)),
                  child: Text(context.l10n.retry),
                ),
              ],
            ),
          ),
          data: (item) {
            if (!_viewRecorded) {
              _viewRecorded = true;
              unawaited(ref.read(evidenceRepositoryProvider).record(
                    EvidenceEvent('RECORD_DETAIL_VIEWED', {
                      'recordAgeBucket': recordAgeBucket(item.createdAt),
                      'sourceType': 'ZERO_RECORD',
                    }),
                  ));
            }
            return ListView(
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
                const SizedBox(height: 4),
                TextButton(
                  onPressed: _deleting
                      ? null
                      : () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => ResetScreen(
                                entrySource: widget.openedFromContinuityCue
                                    ? 'RETURN_CUE'
                                    : 'RECORD_DETAIL',
                                returnCueRecordAgeBucket:
                                    widget.openedFromContinuityCue
                                        ? recordAgeBucket(item.createdAt)
                                        : null,
                              ),
                            ),
                          );
                        },
                  child: Text(context.l10n.writeNow),
                ),
                const SizedBox(height: 8),
                if (_deleteFailure != null) ...[
                  Text(
                    _deleteFailure!,
                    key: const Key('record-delete-failure'),
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.error,
                        ),
                  ),
                  const SizedBox(height: 8),
                ],
                TextButton(
                  key: const Key('delete-record'),
                  onPressed: _deleting ? null : _confirmDelete,
                  style: TextButton.styleFrom(
                    foregroundColor: Theme.of(context).colorScheme.error,
                  ),
                  child: _deleting
                      ? Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                            const SizedBox(width: 8),
                            Text(context.l10n.deletingRecord),
                          ],
                        )
                      : Text(context.l10n.deleteRecord),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Future<void> _confirmDelete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(context.l10n.deleteRecordTitle),
        content: Text(context.l10n.deleteRecordBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(context.l10n.keepRecord),
          ),
          TextButton(
            key: const Key('confirm-delete-record'),
            onPressed: () => Navigator.of(dialogContext).pop(true),
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.error,
            ),
            child: Text(context.l10n.deleteRecordConfirm),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) {
      return;
    }

    setState(() {
      _deleting = true;
      _deleteFailure = null;
    });
    try {
      await ref.read(recordListProvider.notifier).deleteRecord(widget.recordId);
      if (mounted) {
        Navigator.of(context).pop(true);
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _deleting = false;
          _deleteFailure = context.l10n.recordDeleteFailed;
        });
      }
    }
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
