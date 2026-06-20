import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../auth/auth_controller.dart';
import '../auth/auth_models.dart';
import '../growth/growth_screen.dart';
import '../state/state_controller.dart';
import '../state/state_models.dart';

class NowScreen extends ConsumerWidget {
  const NowScreen({super.key, required this.session});

  final AuthSession session;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentState = ref.watch(currentStateProvider);

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            Row(
              children: [
                Text('ZEROON', style: Theme.of(context).textTheme.labelLarge),
                const Spacer(),
                TextButton(
                  onPressed: () =>
                      ref.read(authControllerProvider.notifier).logout(),
                  child: const Text('退出'),
                ),
              ],
            ),
            const SizedBox(height: 96),
            Center(
              child: Container(
                width: 144,
                height: 144,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [Color(0xFFEFFFFF), Color(0xFF55C7D9)],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Color(0x6655C7D9),
                      blurRadius: 42,
                      spreadRadius: 12,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 48),
            Text('先看见此刻的状态。', style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 8),
            Text('用户：${session.user.mobile ?? session.user.uid}'),
            const SizedBox(height: 24),
            currentState.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stackTrace) => _StateError(
                message: error.toString(),
                onRetry: () => ref.invalidate(currentStateProvider),
              ),
              data: (snapshot) => _StatePanel(snapshot: snapshot),
            ),
            const SizedBox(height: 24),
            Card(
              child: ListTile(
                title: const Text('陪伴成长'),
                subtitle: const Text('查看连续归零、累计缓存和陪伴天数'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const GrowthScreen()),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatePanel extends ConsumerWidget {
  const _StatePanel({required this.snapshot});

  final StateSnapshot snapshot;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '当前状态：${snapshot.state}',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 4),
        Text('来源：${snapshot.source}'),
        const SizedBox(height: 4),
        Text('更新时间：${snapshot.changedAt.toLocal()}'),
        const SizedBox(height: 20),
        Text('切换状态', style: Theme.of(context).textTheme.titleSmall),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final state in zeroonStates)
              ChoiceChip(
                label: Text(state),
                selected: snapshot.state == state,
                onSelected: snapshot.state == state
                    ? null
                    : (_) => ref
                        .read(currentStateProvider.notifier)
                        .changeState(state),
              ),
          ],
        ),
      ],
    );
  }
}

class _StateError extends StatelessWidget {
  const _StateError({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('状态读取失败', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Text(message),
            const SizedBox(height: 12),
            OutlinedButton(onPressed: onRetry, child: const Text('重试')),
          ],
        ),
      ),
    );
  }
}
