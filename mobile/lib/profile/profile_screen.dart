import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../auth/auth_controller.dart';
import '../common/zeroon_design.dart';
import '../data_control/data_control_repository.dart';
import '../l10n/l10n_extensions.dart';
import '../locale/language_picker.dart';
import '../my_zeroon/my_zeroon_controller.dart';
import '../my_zeroon/my_zeroon_models.dart';
import 'profile_controller.dart';
import 'profile_models.dart';

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
            setState(() => _message = context.l10n.profileSaved);
          }
        },
        error: (error, stackTrace) {
          setState(() => _message = context.l10n.profileSaveFailed);
        },
      );
    });

    return ZeroonScreen(
      child: profileState.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => _ProfileError(
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
        setState(() => _message = context.l10n.dataCopied);
      }
    } catch (_) {
      if (mounted) {
        setState(() => _message = context.l10n.dataExportFailed);
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
        title: Text(context.l10n.deleteAccountTitle),
        content: Text(context.l10n.deleteAccountBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(context.l10n.keepForNow),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(context.l10n.confirmDelete),
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
        setState(() => _message = context.l10n.deleteAccountFailed);
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
          title: context.l10n.profileTitle,
          center: true,
          leading: ZeroonIconButton(
            semanticLabel: context.l10n.back,
            child: const Icon(Icons.chevron_left),
            onPressed: () => Navigator.of(context).maybePop(),
          ),
        ),
        const SizedBox(height: 20),
        _MyZeroonCard(
          state: myZeroonState,
          onRetry: onRetryMyZeroon,
        ),
        const SizedBox(height: 12),
        const LanguageSettingCard(),
        const SizedBox(height: 18),
        const _ProfileSectionIntro(),
        const SizedBox(height: 12),
        TextField(
          controller: nicknameController,
          maxLength: 30,
          decoration: InputDecoration(
            labelText: context.l10n.nickname,
            hintText: context.l10n.nicknameHint,
          ),
        ),
        const SizedBox(height: 8),
        _ProfileDropdown(
          label: context.l10n.avatarPreset,
          value: avatarPreset,
          options: _avatarPresets(context),
          onChanged: onAvatarChanged,
        ),
        const SizedBox(height: 14),
        _ProfileDropdown(
          label: context.l10n.ageRange,
          value: ageRange,
          options: _ageRanges(context),
          onChanged: onAgeRangeChanged,
        ),
        const SizedBox(height: 14),
        TextField(
          controller: occupationController,
          maxLength: 40,
          decoration: InputDecoration(
            labelText: context.l10n.occupation,
            hintText: context.l10n.occupationHint,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: selfDescriptionController,
          maxLength: 120,
          minLines: 2,
          maxLines: 3,
          decoration: InputDecoration(
            labelText: context.l10n.selfDescription,
            hintText: context.l10n.selfDescriptionHint,
            alignLabelWithHint: true,
          ),
        ),
        const SizedBox(height: 10),
        ZeroonCard(
          padding: const EdgeInsets.fromLTRB(16, 13, 12, 13),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(context.l10n.allowProfileContext,
                        style: const TextStyle(fontWeight: FontWeight.w700)),
                    const SizedBox(height: 6),
                    Text(
                      context.l10n.allowProfileContextHint,
                      style: const TextStyle(color: zeroonMuted, fontSize: 11),
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
          label: context.l10n.saveProfile,
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
        SectionMark(context.l10n.dataControlTitle),
        const SizedBox(height: 7),
        Text(
          context.l10n.dataControlBody,
          style: const TextStyle(color: zeroonMuted, height: 1.45),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: exporting || deleting ? null : onExport,
            icon: const Icon(Icons.content_copy_outlined, size: 18),
            label: Text(exporting
                ? context.l10n.exportingData
                : context.l10n.exportData),
          ),
        ),
        Align(
          alignment: Alignment.center,
          child: TextButton(
            onPressed: deleting ? null : onLogout,
            child: Text(context.l10n.logout),
          ),
        ),
        Align(
          alignment: Alignment.center,
          child: TextButton(
            onPressed: exporting || deleting ? null : onDelete,
            style: TextButton.styleFrom(
              foregroundColor: const Color(0xFF9A4D4D),
            ),
            child: Text(deleting
                ? context.l10n.deletingAccount
                : context.l10n.deleteAccount),
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
        Text(context.l10n.companionNotMetTitle,
            style: zeroonSerif(context, size: 23)),
        const SizedBox(height: 8),
        Text(
          context.l10n.companionNotMetBody,
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
        Text(context.l10n.companionHereTitle,
            style: zeroonSerif(context, size: 23)),
        const SizedBox(height: 8),
        Text(
          context.l10n.companionHereBody,
          textAlign: TextAlign.center,
        ),
        if (companion.nameplateSerial != null) ...[
          const SizedBox(height: 14),
          SectionMark(context.l10n.nameplate),
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionMark('LET ZEROON KNOW YOU'),
        const SizedBox(height: 7),
        Text(
          context.l10n.profileIntro,
          style: const TextStyle(color: zeroonMuted, height: 1.45),
        ),
      ],
    );
  }
}

class _MyZeroonLoadingCard extends StatelessWidget {
  const _MyZeroonLoadingCard();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const SizedBox(
          width: 18,
          height: 18,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
        const SizedBox(width: 12),
        Text(context.l10n.companionChecking),
      ],
    );
  }
}

class _MyZeroonErrorCard extends StatelessWidget {
  const _MyZeroonErrorCard({required this.onRetry});
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionMark('MY ZEROON'),
        const SizedBox(height: 8),
        Text(context.l10n.encounterUnavailableTitle,
            style: zeroonSerif(context, size: 22)),
        const SizedBox(height: 6),
        Text(context.l10n.encounterUnavailableBody,
            style: const TextStyle(color: zeroonMuted)),
        const SizedBox(height: 12),
        OutlinedButton(
          onPressed: onRetry,
          child: Text(context.l10n.retryShort),
        ),
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
        DropdownMenuItem<String>(
          value: null,
          child: Text(context.l10n.optionalNone),
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
  const _ProfileError({required this.onRetry});
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        Text(context.l10n.profileLoadFailed,
            style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 12),
        OutlinedButton(onPressed: onRetry, child: Text(context.l10n.retry)),
      ],
    );
  }
}

class _ProfileOption {
  const _ProfileOption(this.value, this.label);

  final String value;
  final String label;
}

List<_ProfileOption> _avatarPresets(BuildContext context) => [
      _ProfileOption('ZEROON_DEFAULT', context.l10n.avatarDefault),
      _ProfileOption('MOON', context.l10n.avatarMoon),
      _ProfileOption('MOUNTAIN', context.l10n.avatarMountain),
      _ProfileOption('SEA', context.l10n.avatarSea),
      _ProfileOption('LIGHT', context.l10n.avatarLight),
      _ProfileOption('SEED', context.l10n.avatarSeed),
    ];

List<_ProfileOption> _ageRanges(BuildContext context) => [
      _ProfileOption('UNDER_18', context.l10n.ageUnder18),
      _ProfileOption('18_24', context.l10n.age18To24),
      _ProfileOption('25_34', context.l10n.age25To34),
      _ProfileOption('35_44', context.l10n.age35To44),
      _ProfileOption('45_54', context.l10n.age45To54),
      _ProfileOption('55_PLUS', context.l10n.age55Plus),
      _ProfileOption('PREFER_NOT_TO_SAY', context.l10n.agePreferNot),
    ];

String? _blankToNull(String value) {
  final trimmed = value.trim();
  return trimmed.isEmpty ? null : trimmed;
}
