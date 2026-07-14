import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../common/zeroon_design.dart';
import '../record/record_detail_screen.dart';
import 'memory_controller.dart';
import 'memory_models.dart';

class MemoryScreen extends ConsumerWidget {
  const MemoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final memories = ref.watch(memoryListProvider);

    return ZeroonScreen(
      child: RefreshIndicator(
        onRefresh: () async => ref.invalidate(memoryListProvider),
        child: memories.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stackTrace) => ListView(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 28),
            children: [
              const _MemoryHeader(),
              const SizedBox(height: 42),
              Text(
                '暂时没能读到这些记忆。',
                style: zeroonSerif(context, size: 25),
              ),
              const SizedBox(height: 8),
              const Text('你的记录还在。可以稍后再回来看看。'),
              const SizedBox(height: 16),
              OutlinedButton(
                onPressed: () => ref.invalidate(memoryListProvider),
                child: const Text('重试'),
              ),
            ],
          ),
          data: (page) => ListView.separated(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 28),
            itemCount: page.items.isEmpty ? 2 : page.items.length + 1,
            separatorBuilder: (_, __) => const SizedBox(height: 14),
            itemBuilder: (context, index) {
              if (index == 0) {
                return const _MemoryIntroduction();
              }
              if (page.items.isEmpty) {
                return const _MemoryEmptyState();
              }
              return _MemoryCard(entry: page.items[index - 1]);
            },
          ),
        ),
      ),
    );
  }
}

class _MemoryHeader extends StatelessWidget {
  const _MemoryHeader();

  @override
  Widget build(BuildContext context) {
    return ZeroonHeader(
      mark: 'MEMORY',
      title: 'ZEROON 记住的',
      leading: ZeroonIconButton(
        onPressed: () => Navigator.of(context).pop(),
        child: const Icon(Icons.chevron_left),
      ),
    );
  }
}

class _MemoryIntroduction extends StatelessWidget {
  const _MemoryIntroduction();

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _MemoryHeader(),
        SizedBox(height: 24),
        Text('这些内容来自你的记录，只属于你。'),
        SizedBox(height: 6),
        Text(
          '你可以暂停一条记忆，也可以把它从 ZEROON 中删除。',
          style: TextStyle(color: zeroonMuted, fontSize: 11),
        ),
        SizedBox(height: 8),
        Divider(color: zeroonLine),
      ],
    );
  }
}

class _MemoryEmptyState extends StatelessWidget {
  const _MemoryEmptyState();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('这里还很安静。', style: zeroonSerif(context, size: 25)),
          const SizedBox(height: 8),
          const Text('完成一次 Reset 后，ZEROON 会把来源清楚的记忆放在这里。'),
        ],
      ),
    );
  }
}

class _MemoryCard extends ConsumerStatefulWidget {
  const _MemoryCard({required this.entry});

  final MemoryEntry entry;

  @override
  ConsumerState<_MemoryCard> createState() => _MemoryCardState();
}

class _MemoryCardState extends ConsumerState<_MemoryCard> {
  bool _busy = false;
  String? _error;

  @override
  Widget build(BuildContext context) {
    final entry = widget.entry;
    return ZeroonCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _StatusPill(enabled: entry.enabled),
              const Spacer(),
              Text(
                _formatDate(entry.createdAt.toLocal()),
                style: const TextStyle(color: zeroonMuted, fontSize: 10),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (_hasText(entry.title)) ...[
            Text(entry.title!, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 7),
          ],
          Text(entry.summary, style: const TextStyle(color: zeroonInk)),
          const SizedBox(height: 12),
          _SourceRow(entry: entry),
          const SizedBox(height: 10),
          const Divider(color: zeroonLine),
          Material(
            color: Colors.transparent,
            child: SwitchListTile.adaptive(
              contentPadding: EdgeInsets.zero,
              title: const Text('保留在连续记忆中'),
              subtitle: const Text('暂停后仍可在这里看到，但不会参与后续回应。'),
              value: entry.enabled,
              onChanged: _busy ? null : _setEnabled,
            ),
          ),
          _AiPermissionState(entry: entry),
          if (_error != null) ...[
            const SizedBox(height: 10),
            Text(
              _error!,
              style: const TextStyle(color: Color(0xFF9C3D3D), fontSize: 11),
            ),
          ],
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton.icon(
              onPressed: _busy ? null : _confirmDelete,
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFF9C3D3D),
              ),
              icon: const Icon(Icons.delete_outline, size: 17),
              label: Text(_busy ? '正在处理...' : '删除这条记忆'),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _setEnabled(bool enabled) async {
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await ref.read(memoryListProvider.notifier).setEnabled(
            widget.entry.id,
            enabled,
          );
    } catch (_) {
      if (mounted) {
        setState(() => _error = '暂时没有改动。请稍后再试。');
      }
    } finally {
      if (mounted) {
        setState(() => _busy = false);
      }
    }
  }

  Future<void> _confirmDelete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('删除这条记忆？'),
        content: const Text(
          'ZEROON 保存的这份记忆会被立即删除。原始 Zero Record 仍会留在山海缓存中。',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('先保留'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('确认删除'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) {
      return;
    }
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await ref.read(memoryListProvider.notifier).delete(widget.entry.id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('这条记忆已经删除。')),
        );
      }
    } catch (_) {
      if (mounted) {
        setState(() => _error = '暂时没能删除。请稍后再试。');
      }
    } finally {
      if (mounted) {
        setState(() => _busy = false);
      }
    }
  }
}

class _SourceRow extends StatelessWidget {
  const _SourceRow({required this.entry});

  final MemoryEntry entry;

  @override
  Widget build(BuildContext context) {
    if (entry.sourceType == 'ZERO_RECORD' && entry.sourceId != null) {
      return Row(
        children: [
          const Expanded(
            child: Text(
              '来源 · 一次 Zero Record',
              style: TextStyle(color: zeroonMuted, fontSize: 11),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => RecordDetailScreen(recordId: entry.sourceId!),
              ),
            ),
            child: const Text('查看来源'),
          ),
        ],
      );
    }
    return const Text(
      '来源暂时不可查看',
      style: TextStyle(color: zeroonMuted, fontSize: 11),
    );
  }
}

class _AiPermissionState extends StatelessWidget {
  const _AiPermissionState({required this.entry});

  final MemoryEntry entry;

  @override
  Widget build(BuildContext context) {
    final permission = entry.aiContextEnabled ? '已允许' : '未允许';
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: zeroonIvory.withValues(alpha: 0.72),
        borderRadius: BorderRadius.circular(13),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.lock_outline, size: 17, color: zeroonMuted),
          const SizedBox(width: 9),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '回应参考权限 · $permission',
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                const SizedBox(height: 3),
                const Text(
                  '这条 Memory 当前不会进入 ZEROON 的回应。',
                  style: TextStyle(color: zeroonMuted, fontSize: 10),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  const _StatusPill({required this.enabled});

  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: enabled
            ? zeroonCyan.withValues(alpha: 0.13)
            : zeroonMuted.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        enabled ? '记忆中' : '已暂停',
        style: TextStyle(
          color: enabled ? const Color(0xFF397887) : zeroonMuted,
          fontSize: 10,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

String _formatDate(DateTime value) {
  return '${value.year}.${value.month.toString().padLeft(2, '0')}.${value.day.toString().padLeft(2, '0')}';
}

bool _hasText(String? value) => value != null && value.trim().isNotEmpty;
