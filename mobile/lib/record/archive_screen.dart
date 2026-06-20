import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../companion/companion_models.dart';
import '../companion/companion_repository.dart';
import '../common/zeroon_design.dart';
import 'record_controller.dart';
import 'record_detail_screen.dart';
import 'record_models.dart';

class ArchiveScreen extends ConsumerWidget {
  const ArchiveScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final records = ref.watch(recordListProvider);

    return ZeroonScreen(
      child: RefreshIndicator(
        onRefresh: () async => ref.invalidate(recordListProvider),
        child: records.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stackTrace) => ListView(
            padding: const EdgeInsets.all(24),
            children: [
              const ZeroonHeader(
                mark: 'ARCHIVE',
                title: '山海缓存',
                leading: SizedBox.shrink(),
              ),
              const SizedBox(height: 36),
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
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 28),
        children: [
          const _ArchiveHeader(),
          const SizedBox(height: 52),
          Text('还没有归零记录。', style: zeroonSerif(context, size: 26)),
          const SizedBox(height: 8),
          const Text('完成一次 Reset 后，这里会出现你的记录。'),
        ],
      );
    }

    final children = <Widget>[
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _ArchiveHeader(),
          const SizedBox(height: 22),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              const Expanded(
                child: Text('属于你的记录，不公开，也不喧哗。'),
              ),
              Text(
                '${page.totalElements}',
                style: zeroonSerif(context, size: 28),
              ),
              const SizedBox(width: 4),
              const Padding(
                padding: EdgeInsets.only(bottom: 5),
                child: Text('条沉淀',
                    style: TextStyle(color: zeroonMuted, fontSize: 10)),
              ),
            ],
          ),
          const SizedBox(height: 18),
          const Divider(color: zeroonLine),
        ],
      ),
    ];

    DateTime? currentDay;
    var insertedObservation = false;
    for (final record in page.items) {
      final day = DateTime(
        record.createdAt.toLocal().year,
        record.createdAt.toLocal().month,
        record.createdAt.toLocal().day,
      );
      if (currentDay != day) {
        if (currentDay != null && !insertedObservation) {
          children.add(_ArchiveObservationCard(page: page));
          insertedObservation = true;
        }
        currentDay = day;
        children.add(_DateLabel(date: record.createdAt));
      }
      children.add(_RecordMemoryCard(record: record));
    }
    if (!insertedObservation) {
      children.add(_ArchiveObservationCard(page: page));
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 28),
      itemCount: children.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) => children[index],
    );
  }
}

class _ArchiveHeader extends StatelessWidget {
  const _ArchiveHeader();

  @override
  Widget build(BuildContext context) {
    return ZeroonHeader(
      mark: 'ARCHIVE',
      title: '山海缓存',
      leading: const SizedBox.shrink(),
      action: TextButton(
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('筛选功能后续开放')),
          );
        },
        child: const Text('筛选'),
      ),
    );
  }
}

class _RecordMemoryCard extends StatelessWidget {
  const _RecordMemoryCard({required this.record});

  final ZeroRecord record;

  @override
  Widget build(BuildContext context) {
    return ZeroonCard(
      padding: const EdgeInsets.all(15),
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => RecordDetailScreen(recordId: record.id),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: stateColor(record.state),
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 7),
              Text(
                stateLabel(record.state),
                style: Theme.of(context).textTheme.titleSmall,
              ),
              const Spacer(),
              Text(
                _formatTime(record.createdAt),
                style: const TextStyle(color: zeroonMuted, fontSize: 10),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            recordPreview(record),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(color: zeroonInk, fontSize: 13),
          ),
          if (_hasText(record.goal)) ...[
            const SizedBox(height: 8),
            Text(
              '目标 · ${record.goal!.trim()}',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: zeroonMuted, fontSize: 10),
            ),
          ],
        ],
      ),
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
        _error = 'ZEROON 观察暂时不可用。';
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: zeroonNight,
        borderRadius: BorderRadius.circular(16),
        gradient: RadialGradient(
          center: const Alignment(0.9, -0.9),
          radius: 1.1,
          colors: [
            zeroonCyan.withValues(alpha: 0.18),
            zeroonNight,
          ],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'ZEROON 观察',
            style: TextStyle(
              color: zeroonGold,
              fontSize: 10,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.6,
            ),
          ),
          const SizedBox(height: 8),
          if (_loading)
            const Text(
              '正在回看最近的归零记录...',
              style: TextStyle(color: zeroonIvory, height: 1.6),
            )
          else if (_hasText(_error)) ...[
            Text(
              _error!,
              style: const TextStyle(color: zeroonIvory, height: 1.6),
            ),
            const SizedBox(height: 8),
            OutlinedButton(
              onPressed: _loadObservation,
              child: const Text('重试观察'),
            ),
          ] else
            Text(
              _reply ?? '',
              style: const TextStyle(
                color: Color(0xFFE6DCC9),
                fontSize: 13,
                height: 1.65,
              ),
            ),
          const SizedBox(height: 10),
          Text(
            '基于最近 ${widget.page.items.take(3).length} 条归零记录',
            style: TextStyle(
              color: zeroonIvory.withValues(alpha: 0.45),
              fontSize: 9,
            ),
          ),
        ],
      ),
    );
  }
}

class _DateLabel extends StatelessWidget {
  const _DateLabel({required this.date});

  final DateTime date;

  @override
  Widget build(BuildContext context) {
    final local = date.toLocal();
    final today = DateTime.now();
    final isToday = local.year == today.year &&
        local.month == today.month &&
        local.day == today.day;
    final month = local.month.toString().padLeft(2, '0');
    final day = local.day.toString().padLeft(2, '0');
    return Padding(
      padding: const EdgeInsets.fromLTRB(3, 0, 3, 2),
      child: Row(
        children: [
          Text(
            isToday ? '今天' : '$month.$day',
            style: Theme.of(context).textTheme.titleSmall,
          ),
          const Spacer(),
          Text(
            '$month.$day',
            style: const TextStyle(color: zeroonMuted, fontSize: 9),
          ),
        ],
      ),
    );
  }
}

String _observationPrompt(RecordPage page) {
  final recentRecords = page.items.take(3).map((record) {
    final parts = <String>[
      record.state,
      if (_hasText(record.goal)) '小进展：${record.goal!.trim()}',
      if (_hasText(record.content)) '记录：${record.content!.trim()}',
    ];
    return '- ${parts.join(' | ')}';
  }).join('\n');

  return [
    '请基于我的 Archive 最近归零记录，给一段简短、温和的 ZEROON 观察。',
    '只指出可被用户自己确认的轻微趋势，不做标签化判断，不给指令式建议。',
    '累计记录：${page.totalElements}',
    '最近记录：',
    recentRecords,
  ].join('\n');
}

bool _hasText(String? value) => value != null && value.trim().isNotEmpty;

String _formatTime(DateTime value) {
  final local = value.toLocal();
  final hour = local.hour.toString().padLeft(2, '0');
  final minute = local.minute.toString().padLeft(2, '0');
  return '$hour:$minute';
}
