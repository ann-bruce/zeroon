import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../companion/ai_reflection_card.dart';
import '../companion/companion_models.dart';
import '../companion/companion_repository.dart';
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
  String? _reflection;
  String? _reflectionNotice;
  String? _reflectionError;
  bool _reflecting = false;
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
            if (_reflecting || _reflection != null || _reflectionError != null)
              AiReflectionCard(
                title: 'ZEROON 回声',
                loading: _reflecting,
                loadingText: '正在生成一段轻反思...',
                reply: _reflection,
                notice: _reflectionNotice,
                error: _reflectionError,
                margin: const EdgeInsets.only(top: 16),
              ),
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
      _reflection = null;
      _reflectionNotice = null;
      _reflectionError = null;
      _reflecting = false;
    });
    try {
      final record =
          await ref.read(recordListProvider.notifier).create(request);
      _moodController.clear();
      _goalController.clear();
      _contentController.clear();
      if (!mounted) {
        return;
      }
      setState(() {
        _saving = false;
        _message = '已保存到 Archive：#${record.id}';
        _reflecting = true;
      });
      await _loadReflection(request);
    } catch (error) {
      if (mounted) {
        setState(() {
          _saving = false;
          _reflecting = false;
          _message = '保存失败：$error';
        });
      }
    }
  }

  Future<void> _loadReflection(CreateRecordRequest request) async {
    try {
      final response = await ref.read(companionRepositoryProvider).sendMessage(
            CompanionMessageRequest(message: _reflectionPrompt(request)),
          );
      if (!mounted) {
        return;
      }
      setState(() {
        _reflection = response.reply;
        _reflectionNotice = response.safetyNotice;
        _reflectionError = null;
        _reflecting = false;
      });
    } catch (_) {
      if (!mounted) {
        return;
      }
      setState(() {
        _reflection = null;
        _reflectionNotice = null;
        _reflectionError = 'ZEROON 回声暂时不可用，记录已经保存。';
        _reflecting = false;
      });
    }
  }

  String _reflectionPrompt(CreateRecordRequest request) {
    final parts = <String>[
      '我刚保存了一条归零记录，请给我一段简短、非诊断性的陪伴式回声。',
      '状态：${request.state}',
      if (_hasText(request.mood)) '此刻感受：${request.mood!.trim()}',
      if (_hasText(request.goal)) '今天的小进展：${request.goal!.trim()}',
      if (_hasText(request.content)) '想记录的话：${request.content!.trim()}',
    ];
    return parts.join('\n');
  }
}

bool _hasText(String? value) => value != null && value.trim().isNotEmpty;
