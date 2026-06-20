import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../auth/auth_controller.dart';
import '../auth/auth_models.dart';
import '../common/zeroon_design.dart';
import '../growth/growth_screen.dart';
import '../record/archive_screen.dart';
import '../state/state_controller.dart';
import '../state/state_models.dart';

class NowScreen extends ConsumerWidget {
  const NowScreen({
    super.key,
    required this.session,
    required this.onStartReset,
  });

  final AuthSession session;
  final VoidCallback onStartReset;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ZeroonScreen(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
        children: [
          Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SectionMark('TODAY · ZEROON'),
                  const SizedBox(height: 5),
                  Text('晚上好，${_displayName(session)}',
                      style: Theme.of(context).textTheme.titleLarge),
                ],
              ),
              const Spacer(),
              ZeroonIconButton(
                dark: true,
                onPressed: () =>
                    ref.read(authControllerProvider.notifier).logout(),
                child: const Icon(Icons.logout),
              ),
            ],
          ),
          const SizedBox(height: 28),
          _StateHero(onStartReset: onStartReset),
        ],
      ),
    );
  }

  String _displayName(AuthSession session) {
    final value = session.user.mobile ?? session.user.uid;
    if (value.length <= 4) {
      return value;
    }
    return value.substring(value.length - 4);
  }
}

class _StateHero extends ConsumerWidget {
  const _StateHero({required this.onStartReset});

  final VoidCallback onStartReset;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentState = ref.watch(currentStateProvider);

    return currentState.when(
      loading: () => const _StateLoading(),
      error: (error, stackTrace) => _StateError(
        message: error.toString(),
        onRetry: () => ref.invalidate(currentStateProvider),
      ),
      data: (snapshot) => _StatePanel(
        snapshot: snapshot,
        onStartReset: onStartReset,
      ),
    );
  }
}

class _StatePanel extends ConsumerWidget {
  const _StatePanel({required this.snapshot, required this.onStartReset});

  final StateSnapshot snapshot;
  final VoidCallback onStartReset;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Column(
          children: [
            const Text(
              '今天的 ZEROON',
              style: TextStyle(
                color: zeroonMuted,
                fontSize: 10,
                letterSpacing: 1.4,
              ),
            ),
            const SizedBox(height: 18),
            StateCore(state: snapshot.state),
            const SizedBox(height: 18),
            Text(
              stateLabel(snapshot.state),
              style: zeroonSerif(context, size: 28),
            ),
            const SizedBox(height: 4),
            Text(_stateHint(snapshot.state), textAlign: TextAlign.center),
          ],
        ),
        const SizedBox(height: 26),
        ZeroonCard(
          padding: const EdgeInsets.fromLTRB(17, 15, 14, 15),
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const GrowthScreen()),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '连续归零',
                      style: TextStyle(color: zeroonMuted, fontSize: 10),
                    ),
                    const SizedBox(height: 4),
                    Text('查看陪伴成长',
                        style: Theme.of(context).textTheme.titleMedium),
                  ],
                ),
              ),
              Row(
                children: List.generate(
                  7,
                  (index) => Container(
                    width: 24,
                    height: 24,
                    margin: const EdgeInsets.only(left: 6),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: index < 5
                          ? zeroonNight
                          : zeroonBlue.withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                      border: index == 6
                          ? Border.all(color: zeroonBlue)
                          : Border.all(color: Colors.transparent),
                    ),
                    child: Text(
                      ['一', '二', '三', '四', '五', '六', '日'][index],
                      style: TextStyle(
                        color: index < 5 ? zeroonIvory : zeroonInk,
                        fontSize: 8,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              const Icon(Icons.chevron_right, color: zeroonMuted),
            ],
          ),
        ),
        const SizedBox(height: 14),
        ZeroonPrimaryButton(
          label: '开始一次归零',
          onPressed: onStartReset,
        ),
        const SizedBox(height: 10),
        ZeroonCard(
          color: zeroonGold.withValues(alpha: 0.12),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => const ArchiveScreen(),
            ),
          ),
          child: Row(
            children: const [
              CircleAvatar(
                radius: 17,
                backgroundColor: Color(0x20D7B46A),
                child: Icon(
                  Icons.inventory_2_outlined,
                  color: Color(0xFF98763C),
                  size: 16,
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('今日山海缓存',
                        style:
                            TextStyle(color: Color(0xFF9A8D75), fontSize: 10)),
                    SizedBox(height: 3),
                    Text('“完成了一次真实环境验证。”',
                        style: TextStyle(color: zeroonInk, fontSize: 12)),
                  ],
                ),
              ),
              Icon(Icons.chevron_right, color: zeroonMuted),
            ],
          ),
        ),
        const SizedBox(height: 22),
        Text('切换状态', style: Theme.of(context).textTheme.titleSmall),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final state in zeroonStates)
              ChoiceChip(
                label: Text(stateLabel(state)),
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

  String _stateHint(String state) {
    return switch (state) {
      'FOCUS' => '今天适合安静地完成一件重要的事。',
      'CREATE' => '把浮现出来的想法先放在这里。',
      'TIRED' => '可以慢一点，只保留最小的一步。',
      'OVERLOAD' => '先把负荷放下来，不急着解决全部。',
      'CONFUSED' => '混乱也可以被看见，然后慢慢归零。',
      _ => '这里没有需要证明的事，先看见此刻。',
    };
  }
}

class _StateLoading extends StatelessWidget {
  const _StateLoading();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 84),
      child: Center(child: CircularProgressIndicator()),
    );
  }
}

class _StateError extends StatelessWidget {
  const _StateError({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return ZeroonCard(
      child: Padding(
        padding: EdgeInsets.zero,
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
