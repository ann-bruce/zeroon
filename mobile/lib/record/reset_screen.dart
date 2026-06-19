import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'record_controller.dart';
import 'record_models.dart';

class ResetScreen extends ConsumerStatefulWidget {
  const ResetScreen({super.key});

  @override
  ConsumerState<ResetScreen> createState() => _ResetScreenState();
}

class _ResetScreenState extends ConsumerState<ResetScreen> {
  final _moodController = TextEditingController();
  final _goalController = TextEditingController();
  final _contentController = TextEditingController();
  String _state = recordStates.first;
  String? _message;
  bool _saving = false;

  @override
  void dispose() {
    _moodController.dispose();
    _goalController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            Text('Reset', style: Theme.of(context).textTheme.labelLarge),
            const SizedBox(height: 64),
            Text('把这一刻放下来。', style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 8),
            const Text('记录当前状态、今天唯一的小进展，或任何需要被安放的内容。'),
            const SizedBox(height: 24),
            DropdownButtonFormField<String>(
              initialValue: _state,
              decoration: const InputDecoration(labelText: '状态'),
              items: [
                for (final state in recordStates)
                  DropdownMenuItem(value: state, child: Text(state)),
              ],
              onChanged: _saving
                  ? null
                  : (value) => setState(() => _state = value ?? _state),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _moodController,
              maxLength: 200,
              decoration: const InputDecoration(labelText: '此刻感受'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _goalController,
              maxLength: 1000,
              decoration: const InputDecoration(labelText: '今天的小进展'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _contentController,
              maxLines: 5,
              maxLength: 5000,
              decoration: const InputDecoration(labelText: '想记录的话'),
            ),
            const SizedBox(height: 20),
            FilledButton(
              onPressed: _saving ? null : _save,
              child: Text(_saving ? '保存中...' : '保存归零记录'),
            ),
            if (_message != null) ...[
              const SizedBox(height: 16),
              Text(_message!, style: const TextStyle(color: Color(0xFF2F6F78))),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _save() async {
    final request = CreateRecordRequest(
      state: _state,
      mood: _moodController.text,
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
      _moodController.clear();
      _goalController.clear();
      _contentController.clear();
      setState(() => _message = '已保存到 Archive：#${record.id}');
    } catch (error) {
      setState(() => _message = '保存失败：$error');
    } finally {
      if (mounted) {
        setState(() => _saving = false);
      }
    }
  }
}
