import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../companion/companion_models.dart';
import '../companion/companion_repository.dart';
import '../common/zeroon_design.dart';
import '../memory/memory_screen.dart';
import 'record_controller.dart';
import 'record_detail_screen.dart';
import 'record_models.dart';

class ArchiveScreen extends ConsumerStatefulWidget {
  const ArchiveScreen({super.key, this.initialDate});

  final DateTime? initialDate;

  @override
  ConsumerState<ArchiveScreen> createState() => _ArchiveScreenState();
}

class _ArchiveScreenState extends ConsumerState<ArchiveScreen> {
  late DateTime? _selectedDate = _dateOnly(widget.initialDate);

  @override
  Widget build(BuildContext context) {
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
          data: (page) => _ArchiveList(
            page: page,
            selectedDate: _selectedDate,
            onClearDate: () => setState(() => _selectedDate = null),
            onSelectDate: (date) => setState(() => _selectedDate = date),
          ),
        ),
      ),
    );
  }
}

class _ArchiveList extends StatelessWidget {
  const _ArchiveList({
    required this.page,
    required this.selectedDate,
    required this.onClearDate,
    required this.onSelectDate,
  });

  final RecordPage page;
  final DateTime? selectedDate;
  final VoidCallback onClearDate;
  final ValueChanged<DateTime> onSelectDate;

  @override
  Widget build(BuildContext context) {
    final visibleItems = selectedDate == null
        ? page.items
        : page.items.where((record) {
            final day = _dateOnly(record.createdAt.toLocal());
            return day == selectedDate;
          }).toList();
    if (visibleItems.isEmpty) {
      return ListView(
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 28),
        children: [
          _ArchiveHeader(
            selectedDate: selectedDate,
            onClearDate: onClearDate,
            availableDates: _availableDates(page.items),
            onSelectDate: onSelectDate,
          ),
          const SizedBox(height: 52),
          Text(
            selectedDate == null ? '还没有归零记录。' : '这一天还没有山海缓存。',
            style: zeroonSerif(context, size: 26),
          ),
          const SizedBox(height: 8),
          Text(
            selectedDate == null
                ? '完成一次 Reset 后，这里会出现你的记录。'
                : '换一天看看，也许有别的东西被保存下来。',
          ),
        ],
      );
    }

    final children = <Widget>[
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _ArchiveHeader(
            selectedDate: selectedDate,
            onClearDate: onClearDate,
            availableDates: _availableDates(page.items),
            onSelectDate: onSelectDate,
          ),
          const SizedBox(height: 22),
          if (selectedDate != null) ...[
            _DateFilterChip(
              date: selectedDate!,
              onClear: onClearDate,
            ),
            const SizedBox(height: 14),
          ],
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              const Expanded(
                child: Text('属于你的记录，不公开，也不喧哗。'),
              ),
              Text(
                '${visibleItems.length}',
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
    for (final record in visibleItems) {
      final day = DateTime(
        record.createdAt.toLocal().year,
        record.createdAt.toLocal().month,
        record.createdAt.toLocal().day,
      );
      if (currentDay != day) {
        if (currentDay != null && !insertedObservation) {
          children.add(const _ArchiveObservationCard());
          insertedObservation = true;
        }
        currentDay = day;
        children.add(_DateLabel(date: record.createdAt));
      }
      children.add(_RecordMemoryCard(record: record));
    }
    if (!insertedObservation) {
      children.add(const _ArchiveObservationCard());
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
  const _ArchiveHeader({
    required this.selectedDate,
    required this.onClearDate,
    required this.availableDates,
    required this.onSelectDate,
  });

  final DateTime? selectedDate;
  final VoidCallback onClearDate;
  final List<DateTime> availableDates;
  final ValueChanged<DateTime> onSelectDate;

  @override
  Widget build(BuildContext context) {
    return ZeroonHeader(
      mark: 'ARCHIVE',
      title: '山海缓存',
      leading: const SizedBox.shrink(),
      action: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextButton(
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const MemoryScreen()),
            ),
            child: const Text('记忆'),
          ),
          TextButton(
            onPressed: () {
              if (selectedDate != null) {
                onClearDate();
                return;
              }
              if (availableDates.isEmpty) {
                return;
              }
              _showDateFilterSheet(
                context: context,
                dates: availableDates,
                onSelectDate: onSelectDate,
              );
            },
            child: Text(selectedDate == null ? '筛选' : '全部'),
          ),
        ],
      ),
    );
  }
}

void _showDateFilterSheet({
  required BuildContext context,
  required List<DateTime> dates,
  required ValueChanged<DateTime> onSelectDate,
}) {
  showModalBottomSheet<void>(
    context: context,
    backgroundColor: zeroonPaper,
    showDragHandle: true,
    builder: (sheetContext) {
      return SafeArea(
        top: false,
        child: ListView(
          shrinkWrap: true,
          padding: const EdgeInsets.fromLTRB(24, 4, 24, 24),
          children: [
            const SectionMark('ARCHIVE FILTER'),
            const SizedBox(height: 10),
            Text(
              '选择一天回看',
              style: Theme.of(sheetContext).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            for (final date in dates)
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(_formatDate(date)),
                trailing: const Icon(Icons.chevron_right, size: 18),
                onTap: () {
                  Navigator.of(sheetContext).pop();
                  onSelectDate(date);
                },
              ),
          ],
        ),
      );
    },
  );
}

class _DateFilterChip extends StatelessWidget {
  const _DateFilterChip({required this.date, required this.onClear});

  final DateTime date;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
      decoration: BoxDecoration(
        color: zeroonGold.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: zeroonGold.withValues(alpha: 0.22)),
      ),
      child: Row(
        children: [
          Text(
            '筛选：${_formatDate(date)}',
            style: const TextStyle(color: zeroonInk, fontSize: 12),
          ),
          const Spacer(),
          InkWell(
            onTap: onClear,
            borderRadius: BorderRadius.circular(12),
            child: const Icon(Icons.close, size: 15, color: zeroonMuted),
          ),
        ],
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
  const _ArchiveObservationCard();

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
              message: _observationPrompt(),
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
        _error = '这一次没能回看。你的记录仍然好好保存在这里。';
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
              'ZEROON 正在回看你允许用于陪伴回应的记忆…',
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
              child: const Text('再试一次'),
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
            '只参考你允许用于陪伴回应的记忆',
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

String _observationPrompt() {
  return [
    '请只基于系统提供的、我已经允许用于 AI 的记忆，给一段简短、温和的 ZEROON 观察。',
    '只指出可被用户自己确认的轻微趋势，不做标签化判断，不给指令式建议。',
    '如果没有可用记忆，请坦诚说明暂时没有足够内容，不要猜测。',
  ].join('\n');
}

bool _hasText(String? value) => value != null && value.trim().isNotEmpty;

List<DateTime> _availableDates(List<ZeroRecord> records) {
  final dates = {
    for (final record in records) _dateOnly(record.createdAt.toLocal())!,
  }.toList()
    ..sort((a, b) => b.compareTo(a));
  return dates;
}

DateTime? _dateOnly(DateTime? value) {
  if (value == null) {
    return null;
  }
  return DateTime(value.year, value.month, value.day);
}

String _formatDate(DateTime value) {
  final year = value.year.toString().padLeft(4, '0');
  final month = value.month.toString().padLeft(2, '0');
  final day = value.day.toString().padLeft(2, '0');
  return '$year.$month.$day';
}

String _formatTime(DateTime value) {
  final local = value.toLocal();
  final hour = local.hour.toString().padLeft(2, '0');
  final minute = local.minute.toString().padLeft(2, '0');
  return '$hour:$minute';
}
