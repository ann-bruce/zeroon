import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../auth/auth_controller.dart';
import '../common/zeroon_design.dart';
import '../data_control/data_control_repository.dart';
import '../my_zeroon/my_zeroon_controller.dart';
import '../my_zeroon/my_zeroon_models.dart';
import 'profile_controller.dart';
import 'profile_models.dart';

const _avatarPresets = [
  _ProfileOption('ZEROON_DEFAULT', '默认'),
  _ProfileOption('MOON', '月光'),
  _ProfileOption('MOUNTAIN', '山'),
  _ProfileOption('SEA', '海'),
  _ProfileOption('LIGHT', '光'),
  _ProfileOption('SEED', '种子'),
];

const _ageRanges = [
  _ProfileOption('UNDER_18', '18 岁以下'),
  _ProfileOption('18_24', '18 - 24'),
  _ProfileOption('25_34', '25 - 34'),
  _ProfileOption('35_44', '35 - 44'),
  _ProfileOption('45_54', '45 - 54'),
  _ProfileOption('55_PLUS', '55 岁以上'),
  _ProfileOption('PREFER_NOT_TO_SAY', '暂不说明'),
];

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  final _nicknameController = TextEditingController();
  final _occupationController = TextEditingController();
  final _selfDescriptionController = TextEditingController();
  String? _avatarPreset;
  String? _ageRange;
  bool _aiProfileContextEnabled = false;
  bool _initialized = false;
  bool _exporting = false;
  bool _deleting = false;
  String? _message;

  @override
  void dispose() {
    _nicknameController.dispose();
    _occupationController.dispose();
    _selfDescriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final profileState = ref.watch(profileProvider);
    final myZeroonState = ref.watch(myZeroonProvider);

    ref.listen(profileProvider, (previous, next) {
      next.whenOrNull(
        data: (profile) {
          _syncFromProfile(profile);
          if (previous?.isLoading == true) {
            setState(() => _message = '已经保存。');
          }
        },
        error: (error, stackTrace) {
          setState(() => _message = '保存失败：$error');
        },
      );
    });

    return ZeroonScreen(
      child: profileState.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => _ProfileError(
          message: error.toString(),
          onRetry: () => ref.invalidate(profileProvider),
        ),
        data: (profile) {
          _syncFromProfile(profile);
          return _ProfileForm(
            myZeroonState: myZeroonState,
            onRetryMyZeroon: () => ref.invalidate(myZeroonProvider),
            nicknameController: _nicknameController,
            occupationController: _occupationController,
            selfDescriptionController: _selfDescriptionController,
            avatarPreset: _avatarPreset,
            ageRange: _ageRange,
            aiProfileContextEnabled: _aiProfileContextEnabled,
            message: _message,
            saving: profileState.isLoading,
            exporting: _exporting,
            deleting: _deleting,
            onAvatarChanged: (value) => setState(() => _avatarPreset = value),
            onAgeRangeChanged: (value) => setState(() => _ageRange = value),
            onAiContextChanged: (value) =>
                setState(() => _aiProfileContextEnabled = value),
            onSave: _save,
            onExport: _exportData,
            onDelete: _confirmDelete,
            onLogout: _logout,
          );
        },
      ),
    );
  }

  void _syncFromProfile(UserProfile profile) {
    if (_initialized) {
      return;
    }
    _nicknameController.text = profile.nickname ?? '';
    _occupationController.text = profile.occupation ?? '';
    _selfDescriptionController.text = profile.selfDescription ?? '';
    _avatarPreset = profile.avatarPreset;
    _ageRange = profile.ageRange;
    _aiProfileContextEnabled = profile.aiProfileContextEnabled;
    _initialized = true;
  }

  Future<void> _save() async {
    setState(() => _message = null);
    final request = UpdateUserProfileRequest(
      nickname: _blankToNull(_nicknameController.text),
      avatarPreset: _avatarPreset,
      ageRange: _ageRange,
      occupation: _blankToNull(_occupationController.text),
      selfDescription: _blankToNull(_selfDescriptionController.text),
      aiProfileContextEnabled: _aiProfileContextEnabled,
    );
    await ref.read(profileProvider.notifier).save(request);
  }

  Future<void> _logout() async {
    await ref.read(authControllerProvider.notifier).logout();
    if (!mounted) {
      return;
    }
    Navigator.of(context).popUntil((route) => route.isFirst);
  }

  Future<void> _exportData() async {
    setState(() {
      _exporting = true;
      _message = null;
    });
    try {
      final data = await ref.read(dataControlRepositoryProvider).exportData();
      await Clipboard.setData(
        ClipboardData(text: const JsonEncoder.withIndent('  ').convert(data)),
      );
      if (mounted) {
        setState(() => _message = '你的数据副本已复制为 JSON。');
      }
    } catch (_) {
      if (mounted) {
        setState(() => _message = '暂时无法准备数据副本，请稍后再试。');
      }
    } finally {
      if (mounted) {
        setState(() => _exporting = false);
      }
    }
  }

  Future<void> _confirmDelete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('删除账户与全部数据？'),
        content: const Text(
          '你的资料、记录、对话、Memory 和登录会话会立即删除，无法恢复。'
          '去标识化的运行统计可能按隐私说明保留。',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('先保留'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('确认删除'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) {
      return;
    }

    setState(() {
      _deleting = true;
      _message = null;
    });
    try {
      await ref.read(authControllerProvider.notifier).deleteAccount();
      if (mounted) {
        Navigator.of(context).popUntil((route) => route.isFirst);
      }
    } catch (_) {
      if (mounted) {
        setState(() => _message = '删除没有完成，你的数据仍然保留。请稍后再试。');
      }
    } finally {
      if (mounted) {
        setState(() => _deleting = false);
      }
    }
  }
}

class _ProfileForm extends StatelessWidget {
  const _ProfileForm({
    required this.myZeroonState,
    required this.onRetryMyZeroon,
    required this.nicknameController,
    required this.occupationController,
    required this.selfDescriptionController,
    required this.avatarPreset,
    required this.ageRange,
    required this.aiProfileContextEnabled,
    required this.message,
    required this.saving,
    required this.exporting,
    required this.deleting,
    required this.onAvatarChanged,
    required this.onAgeRangeChanged,
    required this.onAiContextChanged,
    required this.onSave,
    required this.onExport,
    required this.onDelete,
    required this.onLogout,
  });

  final AsyncValue<MyZeroonCompanion> myZeroonState;
  final VoidCallback onRetryMyZeroon;
  final TextEditingController nicknameController;
  final TextEditingController occupationController;
  final TextEditingController selfDescriptionController;
  final String? avatarPreset;
  final String? ageRange;
  final bool aiProfileContextEnabled;
  final String? message;
  final bool saving;
  final bool exporting;
  final bool deleting;
  final ValueChanged<String?> onAvatarChanged;
  final ValueChanged<String?> onAgeRangeChanged;
  final ValueChanged<bool> onAiContextChanged;
  final VoidCallback onSave;
  final VoidCallback onExport;
  final VoidCallback onDelete;
  final VoidCallback onLogout;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(22, 18, 22, 28),
      children: [
        ZeroonHeader(
          mark: 'MY ZEROON',
          title: '我与 ZEROON',
          center: true,
          leading: ZeroonIconButton(
            child: const Icon(Icons.chevron_left),
            onPressed: () => Navigator.of(context).maybePop(),
          ),
        ),
        const SizedBox(height: 20),
        _MyZeroonCard(
          state: myZeroonState,
          onRetry: onRetryMyZeroon,
        ),
        const SizedBox(height: 18),
        const _ProfileSectionIntro(),
        const SizedBox(height: 12),
        TextField(
          controller: nicknameController,
          maxLength: 30,
          decoration: const InputDecoration(
            labelText: '昵称',
            hintText: 'ZEROON 可以怎样称呼你',
          ),
        ),
        const SizedBox(height: 8),
        _ProfileDropdown(
          label: '头像预设',
          value: avatarPreset,
          options: _avatarPresets,
          onChanged: onAvatarChanged,
        ),
        const SizedBox(height: 14),
        _ProfileDropdown(
          label: '年龄段',
          value: ageRange,
          options: _ageRanges,
          onChanged: onAgeRangeChanged,
        ),
        const SizedBox(height: 14),
        TextField(
          controller: occupationController,
          maxLength: 40,
          decoration: const InputDecoration(
            labelText: '职业 / 身份',
            hintText: '学生、设计师、创业者，或其他你愿意留下的身份',
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: selfDescriptionController,
          maxLength: 120,
          minLines: 2,
          maxLines: 3,
          decoration: const InputDecoration(
            labelText: '一句话自我描述',
            hintText: '你希望 ZEROON 怎样理解你',
            alignLabelWithHint: true,
          ),
        ),
        const SizedBox(height: 10),
        ZeroonCard(
          padding: const EdgeInsets.fromLTRB(16, 13, 12, 13),
          child: Row(
            children: [
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('允许 ZEROON 使用我的信息',
                        style: TextStyle(fontWeight: FontWeight.w700)),
                    SizedBox(height: 6),
                    Text(
                      '开启后，ZEROON 只会参考你主动填写的昵称、年龄段、职业 / 身份和自我描述。关闭后，下一次回应起就不再使用。',
                      style: TextStyle(color: zeroonMuted, fontSize: 11),
                    ),
                  ],
                ),
              ),
              Switch(
                value: aiProfileContextEnabled,
                onChanged: onAiContextChanged,
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),
        ZeroonPrimaryButton(
          label: '保存我的信息',
          loading: saving,
          onPressed: onSave,
        ),
        if (message != null) ...[
          const SizedBox(height: 12),
          Text(message!, style: const TextStyle(color: Color(0xFF2F6F78))),
        ],
        const SizedBox(height: 28),
        _DataControlSection(
          exporting: exporting,
          deleting: deleting,
          onExport: onExport,
          onDelete: onDelete,
          onLogout: onLogout,
        ),
      ],
    );
  }
}

class _DataControlSection extends StatelessWidget {
  const _DataControlSection({
    required this.exporting,
    required this.deleting,
    required this.onExport,
    required this.onDelete,
    required this.onLogout,
  });

  final bool exporting;
  final bool deleting;
  final VoidCallback onExport;
  final VoidCallback onDelete;
  final VoidCallback onLogout;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionMark('DATA & PRIVACY'),
        const SizedBox(height: 7),
        const Text(
          '你可以带走自己的数据，也可以随时离开。',
          style: TextStyle(color: zeroonMuted, height: 1.45),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: exporting || deleting ? null : onExport,
            icon: const Icon(Icons.content_copy_outlined, size: 18),
            label: Text(exporting ? '正在准备数据副本...' : '复制我的数据副本'),
          ),
        ),
        Align(
          alignment: Alignment.center,
          child: TextButton(
            onPressed: deleting ? null : onLogout,
            child: const Text('退出登录'),
          ),
        ),
        Align(
          alignment: Alignment.center,
          child: TextButton(
            onPressed: exporting || deleting ? null : onDelete,
            style: TextButton.styleFrom(
              foregroundColor: const Color(0xFF9A4D4D),
            ),
            child: Text(deleting ? '正在删除...' : '删除账户与数据'),
          ),
        ),
      ],
    );
  }
}

class _MyZeroonCard extends StatelessWidget {
  const _MyZeroonCard({
    required this.state,
    required this.onRetry,
  });

  final AsyncValue<MyZeroonCompanion> state;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return ZeroonCard(
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 18),
      color: Colors.white.withValues(alpha: 0.72),
      child: state.when(
        loading: () => const _MyZeroonLoadingCard(),
        error: (error, stackTrace) => _MyZeroonErrorCard(
          message: error.toString(),
          onRetry: onRetry,
        ),
        data: (companion) {
          if (companion.met) {
            return _MyZeroonMetCard(companion: companion);
          }
          return const _MyZeroonNotMetCard();
        },
      ),
    );
  }
}

class _MyZeroonNotMetCard extends StatelessWidget {
  const _MyZeroonNotMetCard();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const _ZeroonFigure(size: 168),
        const SizedBox(height: 8),
        const SectionMark('MY ZEROON'),
        const SizedBox(height: 10),
        Text('还没有与 ZEROON 相遇', style: zeroonSerif(context, size: 23)),
        const SizedBox(height: 8),
        const Text(
          '首次登录后会先完成相遇，再启用 ZEROON 的记录和回看功能。',
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

class _MyZeroonMetCard extends StatelessWidget {
  const _MyZeroonMetCard({required this.companion});

  final MyZeroonCompanion companion;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const _ZeroonFigure(size: 178),
        const SizedBox(height: 8),
        const SectionMark('MY ZEROON'),
        const SizedBox(height: 10),
        Text('你的 ZEROON 已经在这里', style: zeroonSerif(context, size: 23)),
        const SizedBox(height: 8),
        const Text(
          '我在这里。以后你留下的此刻，我都会陪你一起回看。',
          textAlign: TextAlign.center,
        ),
        if (companion.nameplateSerial != null) ...[
          const SizedBox(height: 14),
          const SectionMark('NAMEPLATE'),
          const SizedBox(height: 7),
          Text(
            companion.nameplateSerial!,
            style: const TextStyle(
              color: zeroonNight,
              fontSize: 15,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.6,
            ),
          ),
        ],
      ],
    );
  }
}

class _ZeroonFigure extends StatelessWidget {
  const _ZeroonFigure({required this.size});

  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: size * 0.9,
            height: size * 0.9,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  zeroonBlue.withValues(alpha: 0.14),
                  zeroonCyan.withValues(alpha: 0.08),
                  Colors.transparent,
                ],
              ),
            ),
          ),
          Image.asset(
            'assets/zeroon-front.png',
            height: size,
            fit: BoxFit.contain,
          ),
        ],
      ),
    );
  }
}

class _ProfileSectionIntro extends StatelessWidget {
  const _ProfileSectionIntro();

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionMark('LET ZEROON KNOW YOU'),
        SizedBox(height: 7),
        Text(
          '让 ZEROON 更懂你。以下信息都可以留空，只用于帮助它理解你留下的记录。',
          style: TextStyle(color: zeroonMuted, height: 1.45),
        ),
      ],
    );
  }
}

class _MyZeroonLoadingCard extends StatelessWidget {
  const _MyZeroonLoadingCard();

  @override
  Widget build(BuildContext context) {
    return const Row(
      children: [
        SizedBox(
          width: 18,
          height: 18,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
        SizedBox(width: 12),
        Text('正在确认你的 ZEROON...'),
      ],
    );
  }
}

class _MyZeroonErrorCard extends StatelessWidget {
  const _MyZeroonErrorCard({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionMark('MY ZEROON'),
        const SizedBox(height: 8),
        Text('暂时没有见到 ZEROON', style: zeroonSerif(context, size: 22)),
        const SizedBox(height: 6),
        Text(message, style: const TextStyle(color: zeroonMuted)),
        const SizedBox(height: 12),
        OutlinedButton(onPressed: onRetry, child: const Text('再试一次')),
      ],
    );
  }
}

class _ProfileDropdown extends StatelessWidget {
  const _ProfileDropdown({
    required this.label,
    required this.value,
    required this.options,
    required this.onChanged,
  });

  final String label;
  final String? value;
  final List<_ProfileOption> options;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      initialValue: value,
      decoration: InputDecoration(labelText: label),
      items: [
        const DropdownMenuItem<String>(
          value: null,
          child: Text('暂不填写'),
        ),
        for (final option in options)
          DropdownMenuItem<String>(
            value: option.value,
            child: Text(option.label),
          ),
      ],
      onChanged: onChanged,
    );
  }
}

class _ProfileError extends StatelessWidget {
  const _ProfileError({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        Text('我的信息读取失败', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        Text(message),
        const SizedBox(height: 12),
        OutlinedButton(onPressed: onRetry, child: const Text('重试')),
      ],
    );
  }
}

class _ProfileOption {
  const _ProfileOption(this.value, this.label);

  final String value;
  final String label;
}

String? _blankToNull(String value) {
  final trimmed = value.trim();
  return trimmed.isEmpty ? null : trimmed;
}
