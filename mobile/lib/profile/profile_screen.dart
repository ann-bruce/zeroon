import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../auth/auth_controller.dart';
import '../common/zeroon_design.dart';
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
            nicknameController: _nicknameController,
            occupationController: _occupationController,
            selfDescriptionController: _selfDescriptionController,
            avatarPreset: _avatarPreset,
            ageRange: _ageRange,
            aiProfileContextEnabled: _aiProfileContextEnabled,
            message: _message,
            saving: profileState.isLoading,
            onAvatarChanged: (value) => setState(() => _avatarPreset = value),
            onAgeRangeChanged: (value) => setState(() => _ageRange = value),
            onAiContextChanged: (value) =>
                setState(() => _aiProfileContextEnabled = value),
            onSave: _save,
            onLogout: () {
              _logout();
            },
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
}

class _ProfileForm extends StatelessWidget {
  const _ProfileForm({
    required this.nicknameController,
    required this.occupationController,
    required this.selfDescriptionController,
    required this.avatarPreset,
    required this.ageRange,
    required this.aiProfileContextEnabled,
    required this.message,
    required this.saving,
    required this.onAvatarChanged,
    required this.onAgeRangeChanged,
    required this.onAiContextChanged,
    required this.onSave,
    required this.onLogout,
  });

  final TextEditingController nicknameController;
  final TextEditingController occupationController;
  final TextEditingController selfDescriptionController;
  final String? avatarPreset;
  final String? ageRange;
  final bool aiProfileContextEnabled;
  final String? message;
  final bool saving;
  final ValueChanged<String?> onAvatarChanged;
  final ValueChanged<String?> onAgeRangeChanged;
  final ValueChanged<bool> onAiContextChanged;
  final VoidCallback onSave;
  final VoidCallback onLogout;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 28),
      children: [
        ZeroonHeader(
          mark: 'MY ZEROON',
          title: '我与 ZEROON',
          center: true,
          leading: ZeroonIconButton(
            child: const Icon(Icons.chevron_left),
            onPressed: () => Navigator.of(context).maybePop(),
          ),
          action: ZeroonIconButton(
            onPressed: onLogout,
            child: const Icon(Icons.logout),
          ),
        ),
        const SizedBox(height: 20),
        ZeroonCard(
          padding: const EdgeInsets.fromLTRB(18, 17, 18, 18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SectionMark('PRIVATE PROFILE'),
              const SizedBox(height: 9),
              Text('这些信息只用于帮助 ZEROON 更好理解你留下的记录。',
                  style: zeroonSerif(context, size: 22)),
              const SizedBox(height: 8),
              const Text('你可以随时修改，也可以留空。这里不是公开主页。'),
            ],
          ),
        ),
        const SizedBox(height: 16),
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
                      '开启后，ZEROON 会在生成观察和回应时参考这些自我介绍。关闭后不会使用。',
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
