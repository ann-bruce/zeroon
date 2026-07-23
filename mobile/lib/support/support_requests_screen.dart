import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../common/zeroon_design.dart';
import '../l10n/l10n_extensions.dart';
import 'support_models.dart';
import 'support_presentation.dart';
import 'support_repository.dart';

class SupportRequestsScreen extends ConsumerStatefulWidget {
  const SupportRequestsScreen({super.key});

  @override
  ConsumerState<SupportRequestsScreen> createState() =>
      _SupportRequestsScreenState();
}

class _SupportRequestsScreenState extends ConsumerState<SupportRequestsScreen> {
  final List<SupportRequestSummary> _items = [];
  bool _loading = true;
  bool _loadingMore = false;
  bool _failed = false;
  int _nextPage = 0;
  int _totalElements = 0;

  @override
  void initState() {
    super.initState();
    Future.microtask(_loadInitial);
  }

  @override
  Widget build(BuildContext context) {
    return ZeroonScreen(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(22, 18, 22, 0),
            child: ZeroonHeader(
              mark: 'SUPPORT',
              title: context.l10n.supportMyRequests,
              center: true,
              leading: ZeroonIconButton(
                semanticLabel: context.l10n.back,
                onPressed: () => Navigator.of(context).maybePop(),
                child: const Icon(Icons.chevron_left),
              ),
            ),
          ),
          Expanded(child: _buildBody()),
        ],
      ),
    );
  }

  Widget _buildBody() {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_failed && _items.isEmpty) {
      return _SupportLoadError(onRetry: _loadInitial);
    }
    if (_items.isEmpty) {
      return _SupportEmpty(onRefresh: _loadInitial);
    }

    return RefreshIndicator(
      onRefresh: _loadInitial,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(22, 18, 22, 28),
        children: [
          Text(
            context.l10n.supportMyRequestsBody,
            style: const TextStyle(color: zeroonMuted, height: 1.45),
          ),
          const SizedBox(height: 14),
          for (final item in _items) ...[
            _SupportRequestCard(
              item: item,
              onTap: () async {
                await Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) =>
                        SupportRequestDetailScreen(reference: item.reference),
                  ),
                );
                if (mounted) {
                  await _loadInitial();
                }
              },
            ),
            const SizedBox(height: 10),
          ],
          if (_items.length < _totalElements)
            Align(
              alignment: Alignment.center,
              child: TextButton(
                onPressed: _loadingMore ? null : _loadMore,
                child: Text(
                  _loadingMore
                      ? context.l10n.processing
                      : context.l10n.supportLoadMore,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _loadInitial() async {
    if (mounted) {
      setState(() {
        _loading = _items.isEmpty;
        _failed = false;
      });
    }
    try {
      final result = await ref.read(supportRepositoryProvider).list();
      if (!mounted) {
        return;
      }
      setState(() {
        _items
          ..clear()
          ..addAll(result.items);
        _nextPage = result.page + 1;
        _totalElements = result.totalElements;
      });
    } catch (_) {
      if (mounted) {
        setState(() => _failed = true);
        if (_items.isNotEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(context.l10n.supportListRefreshFailed)),
          );
        }
      }
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  Future<void> _loadMore() async {
    setState(() => _loadingMore = true);
    try {
      final result =
          await ref.read(supportRepositoryProvider).list(page: _nextPage);
      if (mounted) {
        setState(() {
          _items.addAll(result.items);
          _nextPage = result.page + 1;
          _totalElements = result.totalElements;
        });
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(context.l10n.supportListRefreshFailed)),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _loadingMore = false);
      }
    }
  }
}

class SupportRequestDetailScreen extends ConsumerStatefulWidget {
  const SupportRequestDetailScreen({super.key, required this.reference});

  final String reference;

  @override
  ConsumerState<SupportRequestDetailScreen> createState() =>
      _SupportRequestDetailScreenState();
}

class _SupportRequestDetailScreenState
    extends ConsumerState<SupportRequestDetailScreen> {
  final _followUpController = TextEditingController();
  SupportRequestDetail? _detail;
  bool _loading = true;
  bool _loadFailed = false;
  bool _sending = false;
  bool _sendFailed = false;

  @override
  void initState() {
    super.initState();
    Future.microtask(_load);
  }

  @override
  void dispose() {
    _followUpController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ZeroonScreen(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(22, 18, 22, 0),
            child: ZeroonHeader(
              mark: 'SUPPORT',
              title: context.l10n.supportRequestDetailTitle,
              center: true,
              leading: ZeroonIconButton(
                semanticLabel: context.l10n.back,
                onPressed: () => Navigator.of(context).maybePop(),
                child: const Icon(Icons.chevron_left),
              ),
            ),
          ),
          Expanded(child: _buildBody()),
        ],
      ),
    );
  }

  Widget _buildBody() {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_loadFailed || _detail == null) {
      return _SupportLoadError(onRetry: _load);
    }
    final detail = _detail!;
    return ListView(
      padding: const EdgeInsets.fromLTRB(22, 18, 22, 28),
      children: [
        _SupportStatusCard(detail: detail),
        const SizedBox(height: 12),
        _OriginalRequestCard(detail: detail),
        const SizedBox(height: 20),
        SectionMark(context.l10n.supportConversationTitle),
        const SizedBox(height: 10),
        if (detail.messages.isEmpty)
          Text(
            context.l10n.supportNoReplies,
            style: const TextStyle(color: zeroonMuted),
          )
        else
          for (final message in detail.messages) ...[
            _SupportMessageCard(message: message),
            const SizedBox(height: 9),
          ],
        const SizedBox(height: 18),
        SectionMark(context.l10n.supportProgressTitle),
        const SizedBox(height: 10),
        for (final change in detail.statusHistory)
          _SupportHistoryRow(change: change),
        const SizedBox(height: 20),
        if (detail.status == SupportRequestStatus.closed)
          ZeroonCard(
            child: Text(
              context.l10n.supportClosedFollowUp,
              style: const TextStyle(color: zeroonMuted, height: 1.4),
            ),
          )
        else
          _buildFollowUp(detail),
      ],
    );
  }

  Widget _buildFollowUp(SupportRequestDetail detail) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (detail.status == SupportRequestStatus.waitingForUser) ...[
          Text(
            context.l10n.supportWaitingPrompt,
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
        ],
        TextField(
          key: const Key('support-follow-up'),
          controller: _followUpController,
          minLines: 3,
          maxLines: 6,
          maxLength: 2000,
          enabled: !_sending,
          decoration: InputDecoration(
            labelText: context.l10n.supportFollowUpLabel,
            hintText: context.l10n.supportFollowUpHint,
            alignLabelWithHint: true,
          ),
        ),
        if (_sendFailed) ...[
          const SizedBox(height: 5),
          Text(
            context.l10n.supportFollowUpFailed,
            style: TextStyle(color: Theme.of(context).colorScheme.error),
          ),
        ],
        const SizedBox(height: 10),
        ZeroonPrimaryButton(
          label: _sendFailed
              ? context.l10n.supportRetryFollowUp
              : context.l10n.supportSendFollowUp,
          loading: _sending,
          onPressed: _sendFollowUp,
        ),
      ],
    );
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _loadFailed = false;
    });
    try {
      final detail =
          await ref.read(supportRepositoryProvider).get(widget.reference);
      if (mounted) {
        setState(() => _detail = detail);
      }
    } catch (_) {
      if (mounted) {
        setState(() => _loadFailed = true);
      }
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  Future<void> _sendFollowUp() async {
    final body = _followUpController.text;
    if (body.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.supportFollowUpValidation)),
      );
      return;
    }
    setState(() {
      _sending = true;
      _sendFailed = false;
    });
    try {
      final message = await ref
          .read(supportRepositoryProvider)
          .addMessage(widget.reference, body);
      if (!mounted) {
        return;
      }
      _followUpController.clear();
      setState(() => _detail = _detail!.withUserFollowUp(message));
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.supportFollowUpSent)),
      );
      try {
        final refreshed =
            await ref.read(supportRepositoryProvider).get(widget.reference);
        if (mounted) {
          setState(() => _detail = refreshed);
        }
      } catch (_) {
        // The accepted message remains visible locally; refresh can be retried
        // by reopening the detail without misreporting the successful send.
      }
    } catch (_) {
      if (mounted) {
        setState(() => _sendFailed = true);
      }
    } finally {
      if (mounted) {
        setState(() => _sending = false);
      }
    }
  }
}

class _SupportRequestCard extends StatelessWidget {
  const _SupportRequestCard({required this.item, required this.onTap});

  final SupportRequestSummary item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ZeroonCard(
      onTap: onTap,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _StatusChip(status: item.status),
                const SizedBox(height: 9),
                Text(
                  item.subject,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 5),
                Text(
                  '${supportCategoryLabel(context.l10n, item.category)} · '
                  '${_formatDate(context, item.updatedAt)}',
                  style: const TextStyle(color: zeroonMuted, fontSize: 11),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          const Icon(Icons.chevron_right, color: zeroonMuted),
        ],
      ),
    );
  }
}

class _SupportStatusCard extends StatelessWidget {
  const _SupportStatusCard({required this.detail});

  final SupportRequestDetail detail;

  @override
  Widget build(BuildContext context) {
    return ZeroonCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _StatusChip(status: detail.status),
          const SizedBox(height: 9),
          Text(
            supportStatusExplanation(context.l10n, detail.status),
            style: const TextStyle(height: 1.4),
          ),
          const SizedBox(height: 12),
          Text(
            '${context.l10n.supportReferenceLabel}: ${detail.reference}',
            style: const TextStyle(color: zeroonMuted, fontSize: 11),
          ),
        ],
      ),
    );
  }
}

class _OriginalRequestCard extends StatelessWidget {
  const _OriginalRequestCard({required this.detail});

  final SupportRequestDetail detail;

  @override
  Widget build(BuildContext context) {
    return ZeroonCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            supportCategoryLabel(context.l10n, detail.category),
            style: const TextStyle(color: zeroonMuted, fontSize: 11),
          ),
          const SizedBox(height: 7),
          Text(
            detail.subject,
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          SelectableText(detail.description),
          const SizedBox(height: 10),
          Text(
            _formatDateTime(context, detail.createdAt),
            style: const TextStyle(color: zeroonMuted, fontSize: 11),
          ),
        ],
      ),
    );
  }
}

class _SupportMessageCard extends StatelessWidget {
  const _SupportMessageCard({required this.message});

  final SupportMessage message;

  @override
  Widget build(BuildContext context) {
    final fromTeam = message.actorType == SupportActorType.admin;
    return Align(
      alignment: fromTeam ? Alignment.centerLeft : Alignment.centerRight,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 310),
        child: ZeroonCard(
          color: fromTeam
              ? const Color(0xFFEAF3F3)
              : Colors.white.withValues(alpha: 0.68),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                supportActorLabel(context.l10n, message.actorType),
                style: const TextStyle(
                  color: zeroonMuted,
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 6),
              SelectableText(message.body),
              const SizedBox(height: 7),
              Text(
                _formatDateTime(context, message.createdAt),
                style: const TextStyle(color: zeroonMuted, fontSize: 10),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SupportHistoryRow extends StatelessWidget {
  const _SupportHistoryRow({required this.change});

  final SupportStatusChange change;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 8,
            height: 8,
            margin: const EdgeInsets.only(top: 5),
            decoration: const BoxDecoration(
              color: zeroonCyan,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  supportStatusLabel(context.l10n, change.toStatus),
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 2),
                Text(
                  '${supportActorLabel(context.l10n, change.actorType)} · '
                  '${_formatDateTime(context, change.createdAt)}',
                  style: const TextStyle(color: zeroonMuted, fontSize: 11),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.status});

  final SupportRequestStatus status;

  @override
  Widget build(BuildContext context) {
    final color = switch (status) {
      SupportRequestStatus.waitingForUser => const Color(0xFF8A6222),
      SupportRequestStatus.replied => const Color(0xFF2F6F78),
      SupportRequestStatus.closed => zeroonMuted,
      _ => zeroonInk,
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.09),
        borderRadius: BorderRadius.circular(99),
      ),
      child: Text(
        supportStatusLabel(context.l10n, status),
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _SupportEmpty extends StatelessWidget {
  const _SupportEmpty({required this.onRefresh});

  final VoidCallback onRefresh;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.inbox_outlined, color: zeroonMuted, size: 34),
            const SizedBox(height: 12),
            Text(
              context.l10n.supportEmptyTitle,
              style: zeroonSerif(context, size: 22),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 7),
            Text(
              context.l10n.supportEmptyBody,
              textAlign: TextAlign.center,
              style: const TextStyle(color: zeroonMuted, height: 1.4),
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: onRefresh,
              child: Text(context.l10n.supportRefresh),
            ),
          ],
        ),
      ),
    );
  }
}

class _SupportLoadError extends StatelessWidget {
  const _SupportLoadError({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              context.l10n.supportLoadFailed,
              textAlign: TextAlign.center,
              style: const TextStyle(color: zeroonMuted),
            ),
            const SizedBox(height: 12),
            OutlinedButton(
              onPressed: onRetry,
              child: Text(context.l10n.supportRefresh),
            ),
          ],
        ),
      ),
    );
  }
}

String _formatDate(BuildContext context, DateTime value) {
  return MaterialLocalizations.of(context).formatShortDate(value.toLocal());
}

String _formatDateTime(BuildContext context, DateTime value) {
  final local = value.toLocal();
  final date = MaterialLocalizations.of(context).formatShortDate(local);
  final time = MaterialLocalizations.of(context).formatTimeOfDay(
    TimeOfDay.fromDateTime(local),
  );
  return '$date · $time';
}
