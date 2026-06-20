import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../common/zeroon_design.dart';
import 'record_controller.dart';
import 'record_complete_screen.dart';
import 'record_models.dart';

class ResetScreen extends ConsumerStatefulWidget {
  const ResetScreen({super.key, this.onReturnHome});

  final VoidCallback? onReturnHome;

  @override
  ConsumerState<ResetScreen> createState() => _ResetScreenState();
}

class _ResetScreenState extends ConsumerState<ResetScreen> {
  final _goalController = TextEditingController();
  final _contentController = TextEditingController();
  String _state = recordStates.first;
  String? _message;
  bool _saving = false;

  @override
  void dispose() {
    _goalController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ZeroonScreen(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 28),
        children: [
          const ZeroonHeader(mark: 'ZERO RECORD', title: '归零', center: true),
          const SizedBox(height: 28),
          Text('此刻，你是什么状态？', style: zeroonSerif(context, size: 26)),
          const SizedBox(height: 6),
          const Text('不需要准确，选择最接近的就好。'),
          const SizedBox(height: 18),
          GridView.count(
            crossAxisCount: 3,
            mainAxisSpacing: 9,
            crossAxisSpacing: 9,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            childAspectRatio: 1.08,
            children: [
              for (final state in recordStates)
                _StateTile(
                  state: state,
                  selected: _state == state,
                  onTap: _saving ? null : () => setState(() => _state = state),
                ),
            ],
          ),
          const SizedBox(height: 22),
          TextField(
            controller: _contentController,
            maxLines: 4,
            maxLength: 5000,
            decoration: const InputDecoration(
              labelText: '留下一句话',
              hintText: '今天发生了什么？',
              alignLabelWithHint: true,
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _goalController,
            maxLength: 1000,
            decoration: const InputDecoration(
              labelText: '今天想完成什么',
              hintText: '完成一个很小的进展',
            ),
          ),
          const SizedBox(height: 8),
          ZeroonPrimaryButton(
            label: '保存这次归零',
            loading: _saving,
            onPressed: _save,
          ),
          if (_message != null) ...[
            const SizedBox(height: 16),
            Text(_message!, style: const TextStyle(color: Color(0xFF2F6F78))),
          ],
        ],
      ),
    );
  }

  Future<void> _save() async {
    final request = CreateRecordRequest(
      state: _state,
      goal: _goalController.text,
      content: _contentController.text,
    );
    if (!request.hasContent) {
      setState(() => _message = '至少写下一点感受、进展或内容。');
      return;
    }

    setState(() {
      _saving = true;
      _message = null;
    });
    try {
      final record =
          await ref.read(recordListProvider.notifier).create(request);
      _goalController.clear();
      _contentController.clear();
      if (!mounted) {
        return;
      }
      setState(() {
        _saving = false;
      });
      await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => RecordCompleteScreen(
            record: record,
            onReturnHome: widget.onReturnHome,
          ),
        ),
      );
    } catch (error) {
      if (mounted) {
        setState(() {
          _saving = false;
          _message = '保存失败：$error';
        });
      }
    }
  }
}

class _StateTile extends StatelessWidget {
  const _StateTile({
    required this.state,
    required this.selected,
    required this.onTap,
  });

  final String state;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(15),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected ? zeroonNight : Colors.white.withValues(alpha: 0.62),
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: selected ? zeroonNight : zeroonLine),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: zeroonNight.withValues(alpha: 0.14),
                    blurRadius: 20,
                    offset: const Offset(0, 9),
                  ),
                ]
              : null,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 19,
              height: 19,
              decoration: BoxDecoration(
                color: stateColor(state),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: stateColor(state).withValues(alpha: 0.5),
                    blurRadius: 13,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 7),
            Text(
              stateLabel(state),
              style: TextStyle(
                color: selected ? zeroonIvory : zeroonInk,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 3),
            Text(
              state,
              style: TextStyle(
                color: selected
                    ? zeroonIvory.withValues(alpha: 0.55)
                    : const Color(0xFFA3A29F),
                fontSize: 7,
                letterSpacing: 0.8,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
