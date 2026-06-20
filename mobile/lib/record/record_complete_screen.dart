import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../companion/companion_models.dart';
import '../companion/companion_repository.dart';
import '../common/zeroon_design.dart';
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
            title: '归零完成',
            leading: const Wordmark(),
            action: ZeroonIconButton(
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
                      'RECORDED · ${_formatTime(widget.record.createdAt)}',
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
            child: SectionMark('本次状态 · ${stateLabel(widget.record.state)}'),
          ),
          const SizedBox(height: 11),
          Text(
            '已经替你保存好了。',
            textAlign: TextAlign.center,
            style: zeroonSerif(context, size: 27),
          ),
          const SizedBox(height: 8),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 180),
            child: Text(
              _quoteText,
              key: ValueKey(_quoteText),
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
                const Text(
                  '今天的记录',
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
                    '目标 · ${widget.record.goal!.trim()}',
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
            label: '回到此刻',
            onPressed: () => _returnHome(context),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const ArchiveScreen()),
            ),
            child: const Text('查看山海缓存'),
          ),
        ],
      ),
    );
  }

  void _returnHome(BuildContext context) {
    Navigator.of(context).maybePop();
    widget.onReturnHome?.call();
  }

  String get _quoteText {
    if (_loadingQuote) {
      return '“ZEROON 正在把这一刻轻轻收好。”';
    }
    return '“${_quote ?? _fallbackQuote}”';
  }

  String get _fallbackQuote {
    if (_hasText(widget.record.aiSummary)) {
      return widget.record.aiSummary!.trim();
    }
    return '这一次归零已经完成。\n不用急着解释，先让它被好好保存。';
  }

  Future<void> _loadQuote() async {
    try {
      final response = await ref.read(companionRepositoryProvider).sendMessage(
            CompanionMessageRequest(
              message: _completionPrompt(widget.record),
            ),
          );
      if (!mounted) {
        return;
      }
      setState(() {
        _quote = response.reply.trim();
        _loadingQuote = false;
      });
    } catch (_) {
      if (!mounted) {
        return;
      }
      setState(() {
        _quote = _fallbackQuote;
        _loadingQuote = false;
      });
    }
  }
}

bool _hasText(String? value) => value != null && value.trim().isNotEmpty;

String _formatTime(DateTime value) {
  final local = value.toLocal();
  final hour = local.hour.toString().padLeft(2, '0');
  final minute = local.minute.toString().padLeft(2, '0');
  return '$hour:$minute';
}

String _completionPrompt(ZeroRecord record) {
  final parts = <String>[
    '请基于我刚完成的一次归零记录，给一句简短、温和、像 ZEROON 说的话。',
    '不要诊断，不要建议过多，只确认这一刻已经被保存。',
    '状态：${stateLabel(record.state)}',
    if (_hasText(record.goal)) '目标：${record.goal!.trim()}',
    if (_hasText(record.content)) '记录：${record.content!.trim()}',
  ];
  return parts.join('\n');
}
