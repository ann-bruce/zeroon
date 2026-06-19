import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../companion/ai_reflection_card.dart';
import '../companion/companion_models.dart';
import '../companion/companion_repository.dart';
import 'record_controller.dart';
import 'record_detail_screen.dart';
import 'record_models.dart';

class ArchiveScreen extends ConsumerWidget {
  const ArchiveScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final records = ref.watch(recordListProvider);

    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async => ref.invalidate(recordListProvider),
          child: records.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, stackTrace) => ListView(
              padding: const EdgeInsets.all(24),
              children: [
                Text('Archive', style: Theme.of(context).textTheme.labelLarge),
                const SizedBox(height: 48),
                Text('读取失败', style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 8),
                Text(error.toString()),
                const SizedBox(height: 12),
                OutlinedButton(
                  onPressed: () => ref.invalidate(recordListProvider),
                  child: const Text('重试'),
                ),
              ],
            ),
            data: (page) => _ArchiveList(page: page),
          ),
        ),
      ),
    );
  }
}

class _ArchiveList extends StatelessWidget {
  const _ArchiveList({required this.page});

  final RecordPage page;

  @override
  Widget build(BuildContext context) {
    if (page.items.isEmpty) {
      return ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Text('Archive', style: Theme.of(context).textTheme.labelLarge),
          const SizedBox(height: 64),
          Text('还没有归零记录。', style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 8),
          const Text('完成一次 Reset 后，这里会出现你的记录。'),
        ],
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(24),
      itemCount: page.items.length + 2,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        if (index == 0) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Archive', style: Theme.of(context).textTheme.labelLarge),
              const SizedBox(height: 24),
              Text('已缓存 ${page.totalElements} 条记录'),
            ],
          );
        }
        if (index == 1) {
          return _ArchiveObservationCard(page: page);
        }
        final record = page.items[index - 2];
        return Card(
          child: ListTile(
            title: Text(
              recordPreview(record),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            subtitle: Text('${record.state} · ${record.createdAt.toLocal()}'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => RecordDetailScreen(recordId: record.id),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _ArchiveObservationCard extends ConsumerStatefulWidget {
  const _ArchiveObservationCard({required this.page});

  final RecordPage page;

  @override
  ConsumerState<_ArchiveObservationCard> createState() =>
      _ArchiveObservationCardState();
}

class _ArchiveObservationCardState
    extends ConsumerState<_ArchiveObservationCard> {
  String? _reply;
  String? _error;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    Future.microtask(_loadObservation);
  }

  Future<void> _loadObservation() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final response = await ref.read(companionRepositoryProvider).sendMessage(
            CompanionMessageRequest(
              message: _observationPrompt(widget.page),
            ),
          );
      if (!mounted) {
        return;
      }
      setState(() {
        _reply = response.reply;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) {
        return;
      }
      setState(() {
        _error = 'Archive 观察暂时不可用。';
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AiReflectionCard(
      title: 'Archive 观察',
      loading: _loading,
      loadingText: '正在回看最近的归零记录...',
      reply: _reply,
      error: _error,
      retryLabel: '重试观察',
      onRetry: _loadObservation,
    );
  }
}

String _observationPrompt(RecordPage page) {
  final recentRecords = page.items.take(3).map((record) {
    final parts = <String>[
      record.state,
      if (_hasText(record.mood)) '感受：${record.mood!.trim()}',
      if (_hasText(record.goal)) '小进展：${record.goal!.trim()}',
      if (_hasText(record.content)) '记录：${record.content!.trim()}',
    ];
    return '- ${parts.join(' | ')}';
  }).join('\n');

  return [
    '请基于我的 Archive 最近归零记录，给一段简短、非诊断性的陪伴式观察。',
    '只指出可被用户自己确认的轻微趋势，不做人格判断，不给医疗、法律、财务或心理诊断建议。',
    '累计记录：${page.totalElements}',
    '最近记录：',
    recentRecords,
  ].join('\n');
}

bool _hasText(String? value) => value != null && value.trim().isNotEmpty;
