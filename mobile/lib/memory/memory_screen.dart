import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../common/zeroon_design.dart';
import '../l10n/l10n_extensions.dart';
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
                context.l10n.memoryLoadFailedTitle,
                style: zeroonSerif(context, size: 25),
              ),
              const SizedBox(height: 8),
              Text(context.l10n.memoryLoadFailedBody),
              const SizedBox(height: 16),
              OutlinedButton(
                onPressed: () => ref.invalidate(memoryListProvider),
                child: Text(context.l10n.retry),
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
      title: context.l10n.memoryTitle,
      leading: ZeroonIconButton(
        semanticLabel: context.l10n.back,
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _MemoryHeader(),
        const SizedBox(height: 24),
        Text(context.l10n.memoryIntro),
        const SizedBox(height: 6),
        Text(
          context.l10n.memoryIntroControl,
          style: const TextStyle(color: zeroonMuted, fontSize: 11),
        ),
        const SizedBox(height: 8),
        const Divider(color: zeroonLine),
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
          Text(context.l10n.memoryEmptyTitle,
              style: zeroonSerif(context, size: 25)),
          const SizedBox(height: 8),
          Text(context.l10n.memoryEmptyBody),
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
                localizedDate(context, entry.createdAt),
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
              title: Text(context.l10n.keepInMemory),
              subtitle: Text(context.l10n.keepInMemoryHint),
              value: entry.enabled,
              onChanged: _busy ? null : _setEnabled,
            ),
          ),
          Material(
            color: Colors.transparent,
            child: SwitchListTile.adaptive(
              contentPadding: EdgeInsets.zero,
              title: Text(context.l10n.allowResponseReference),
              subtitle: Text(
                _aiPermissionSubtitle(context, entry),
                style: const TextStyle(color: zeroonMuted, fontSize: 11),
              ),
              value: entry.aiContextEnabled,
              onChanged: _busy ? null : _setAiContextEnabled,
            ),
          ),
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
              label: Text(_busy
                  ? context.l10n.memoryProcessing
                  : context.l10n.deleteMemory),
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
        setState(() => _error = context.l10n.memoryChangeFailed);
      }
    } finally {
      if (mounted) {
        setState(() => _busy = false);
      }
    }
  }

  Future<void> _setAiContextEnabled(bool aiContextEnabled) async {
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await ref.read(memoryListProvider.notifier).setAiContextEnabled(
            widget.entry.id,
            aiContextEnabled,
          );
      if (mounted) {
        final paused = !widget.entry.enabled;
        final message = !aiContextEnabled
            ? context.l10n.memoryAiDisabledReceipt
            : paused
                ? context.l10n.memoryAiPausedReceipt
                : context.l10n.memoryAiEnabledReceipt;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message)),
        );
      }
    } catch (_) {
      if (mounted) {
        setState(() => _error = context.l10n.memoryPermissionFailed);
      }
    } finally {
      if (mounted) {
        setState(() => _busy = false);
      }
    }
  }

  String _aiPermissionSubtitle(BuildContext context, MemoryEntry entry) {
    if (!entry.enabled) {
      return entry.aiContextEnabled
          ? context.l10n.memoryPausedPermissionOn
          : context.l10n.memoryPausedPermissionOff;
    }
    return entry.aiContextEnabled
        ? context.l10n.memoryActivePermissionOn
        : context.l10n.memoryActivePermissionOff;
  }

  Future<void> _confirmDelete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(context.l10n.deleteMemoryTitle),
        content: Text(context.l10n.deleteMemoryBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(context.l10n.keepForNow),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(context.l10n.confirmDelete),
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
          SnackBar(content: Text(context.l10n.memoryDeleted)),
        );
      }
    } catch (_) {
      if (mounted) {
        setState(() => _error = context.l10n.memoryDeleteFailed);
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
          Expanded(
            child: Text(
              context.l10n.memorySourceRecord,
              style: const TextStyle(color: zeroonMuted, fontSize: 11),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => RecordDetailScreen(recordId: entry.sourceId!),
              ),
            ),
            child: Text(context.l10n.viewSource),
          ),
        ],
      );
    }
    return Text(
      context.l10n.sourceUnavailable,
      style: const TextStyle(color: zeroonMuted, fontSize: 11),
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
        enabled ? context.l10n.memoryActive : context.l10n.memoryPaused,
        style: TextStyle(
          color: enabled ? const Color(0xFF397887) : zeroonMuted,
          fontSize: 10,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

bool _hasText(String? value) => value != null && value.trim().isNotEmpty;
