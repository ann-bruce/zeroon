import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../companion/companion_models.dart';
import '../companion/companion_repository.dart';
import '../common/zeroon_design.dart';
import '../evidence/evidence_models.dart';
import '../evidence/evidence_repository.dart';
import '../l10n/l10n_extensions.dart';
import 'archive_screen.dart';
import 'record_models.dart';

class RecordCompleteScreen extends ConsumerStatefulWidget {
  const RecordCompleteScreen({
    super.key,
    required this.record,
    this.onReturnHome,
  });

  final ZeroRecord record;
  final VoidCallback? onReturnHome;

  @override
  ConsumerState<RecordCompleteScreen> createState() =>
      _RecordCompleteScreenState();
}

class _RecordCompleteScreenState extends ConsumerState<RecordCompleteScreen> {
  String? _quote;
  bool _loadingQuote = true;

  @override
  void initState() {
    super.initState();
    Future.microtask(_loadQuote);
  }

  @override
  Widget build(BuildContext context) {
    return ZeroonScreen(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 28),
        children: [
          ZeroonHeader(
            mark: 'ZEROON',
            title: context.l10n.resetCompleteTitle,
            center: true,
            action: ZeroonIconButton(
              semanticLabel: context.l10n.close,
              child: const Icon(Icons.close),
              onPressed: () => _returnHome(context),
            ),
          ),
          const SizedBox(height: 22),
          Center(
            child: SizedBox(
              width: 176,
              child: Stack(
                alignment: Alignment.center,
                clipBehavior: Clip.none,
                children: [
                  StateCore(size: 142, state: widget.record.state),
                  Positioned(
                    bottom: -10,
                    child: Text(
                      context.l10n.recordTimeValue(
                        localizedTime(context, widget.record.createdAt),
                      ),
                      style: const TextStyle(
                        color: zeroonMuted,
                        fontSize: 7,
                        letterSpacing: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 42),
          Center(
            child: SectionMark(
              '${context.l10n.resetStateMark} · ${localizedStateLabel(context, widget.record.state)}',
            ),
          ),
          const SizedBox(height: 11),
          Text(
            context.l10n.resetSaved,
            textAlign: TextAlign.center,
            style: zeroonSerif(context, size: 27),
          ),
          const SizedBox(height: 8),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 180),
            child: Text(
              _quoteText(context),
              key: ValueKey(_quoteText(context)),
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Color(0xFF666970),
                fontFamily: 'serif',
                fontSize: 15,
                height: 1.8,
              ),
            ),
          ),
          const SizedBox(height: 27),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(17),
            decoration: BoxDecoration(
              color: zeroonGold.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(17),
              border: Border.all(color: zeroonGold.withValues(alpha: 0.28)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  context.l10n.todayRecord,
                  style: TextStyle(color: Color(0xFF9A8D75), fontSize: 8),
                ),
                const SizedBox(height: 8),
                Text(
                  recordPreview(widget.record),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: zeroonInk,
                    fontSize: 12,
                    height: 1.55,
                  ),
                ),
                if (_hasText(widget.record.goal)) ...[
                  const SizedBox(height: 8),
                  Text(
                    '${context.l10n.goalPrefix} ${widget.record.goal!.trim()}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style:
                        const TextStyle(color: Color(0xFF9A8D75), fontSize: 8),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 34),
          ZeroonPrimaryButton(
            label: context.l10n.returnNow,
            onPressed: () => _returnHome(context),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => const ArchiveScreen(entrySource: 'RESET'),
              ),
            ),
            child: Text(context.l10n.viewArchive),
          ),
        ],
      ),
    );
  }

  void _returnHome(BuildContext context) {
    Navigator.of(context).maybePop();
    widget.onReturnHome?.call();
  }

  String _quoteText(BuildContext context) {
    if (_loadingQuote) {
      return '“${context.l10n.reflectionLoading}”';
    }
    return '“${_quote ?? _fallbackQuote(context)}”';
  }

  String _fallbackQuote(BuildContext context) {
    if (_hasText(widget.record.aiSummary)) {
      return widget.record.aiSummary!.trim();
    }
    return context.l10n.completionFallback;
  }

  Future<void> _loadQuote() async {
    final startedAt = DateTime.now();
    try {
      final response = await ref.read(companionRepositoryProvider).sendMessage(
            CompanionMessageRequest(
              message: context.l10n.completionPrompt,
            ),
          );
      unawaited(ref.read(evidenceRepositoryProvider).record(
            EvidenceEvent('REFLECTION_REQUESTED', {
              'surface': 'RESET',
              'contextClasses': response.contextClasses,
            }),
          ));
      unawaited(ref.read(evidenceRepositoryProvider).record(
            EvidenceEvent('REFLECTION_COMPLETED', {
              'outcome': response.outcome,
              'latencyBucket': response.latencyBucket,
              'promptVersion': response.promptVersion,
              'modelAlias': response.modelAlias,
            }),
          ));
      if (!mounted) {
        return;
      }
      setState(() {
        _quote = response.reply.trim();
        _loadingQuote = false;
      });
    } catch (_) {
      unawaited(ref.read(evidenceRepositoryProvider).record(
            EvidenceEvent('REFLECTION_REQUESTED', {
              'surface': 'RESET',
              'contextClasses': <String>[],
            }),
          ));
      unawaited(ref.read(evidenceRepositoryProvider).record(
            EvidenceEvent('REFLECTION_COMPLETED', {
              'outcome': 'FAILED',
              'latencyBucket':
                  latencyBucket(DateTime.now().difference(startedAt)),
              'promptVersion': 'UNKNOWN',
              'modelAlias': 'UNAVAILABLE',
            }),
          ));
      if (!mounted) {
        return;
      }
      setState(() {
        _quote = _fallbackQuote(context);
        _loadingQuote = false;
      });
    }
  }
}

bool _hasText(String? value) => value != null && value.trim().isNotEmpty;
