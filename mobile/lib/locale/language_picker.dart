import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../auth/auth_controller.dart';
import '../common/zeroon_design.dart';
import '../l10n/app_localizations.dart';
import '../l10n/l10n_extensions.dart';
import 'locale_controller.dart';
import 'locale_preference.dart';

String languagePreferenceLabel(
  AppLocalizations l10n,
  LocalePreference preference,
) {
  return switch (preference) {
    LocalePreference.followSystem => l10n.languageFollowSystem,
    LocalePreference.simplifiedChinese => l10n.languageSimplifiedChinese,
    LocalePreference.english => l10n.languageEnglish,
  };
}

Future<LocalePreference?> showLanguagePreferencePicker(
  BuildContext context,
  LocalePreference current,
) {
  final l10n = context.l10n;
  return showModalBottomSheet<LocalePreference>(
    context: context,
    showDragHandle: true,
    backgroundColor: zeroonPaper,
    builder: (context) => SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 18),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.languageSetting, style: zeroonSerif(context, size: 24)),
            const SizedBox(height: 6),
            Text(l10n.languageSettingHint),
            const SizedBox(height: 10),
            for (final preference in LocalePreference.values)
              ListTile(
                title: Text(languagePreferenceLabel(l10n, preference)),
                contentPadding: EdgeInsets.zero,
                trailing: preference == current
                    ? const Icon(Icons.check, color: zeroonInk)
                    : null,
                onTap: () => Navigator.of(context).pop(preference),
              ),
          ],
        ),
      ),
    ),
  );
}

class LanguagePickerButton extends ConsumerWidget {
  const LanguagePickerButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final localeState = ref.watch(localeControllerProvider);
    return ZeroonIconButton(
      semanticLabel: context.l10n.languagePickerTooltip,
      onPressed: () => _select(context, ref, localeState.preference),
      child: const Icon(Icons.language),
    );
  }

  Future<void> _select(
    BuildContext context,
    WidgetRef ref,
    LocalePreference current,
  ) async {
    final selected = await showLanguagePreferencePicker(context, current);
    if (selected == null || selected == current || !context.mounted) {
      return;
    }

    try {
      await ref
          .read(authControllerProvider.notifier)
          .selectLanguagePreference(selected);
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(context.l10n.languageStorageUnavailable)),
        );
      }
    }
  }
}

class LanguageSettingCard extends ConsumerWidget {
  const LanguageSettingCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final localeState = ref.watch(localeControllerProvider);
    final l10n = context.l10n;
    return ZeroonCard(
      onTap: () => _select(context, ref, localeState.preference),
      child: Row(
        children: [
          const Icon(Icons.language, color: zeroonInk),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.languageSetting,
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 3),
                Text(
                  languagePreferenceLabel(l10n, localeState.preference),
                  style: const TextStyle(color: zeroonMuted, fontSize: 12),
                ),
                if (localeState.pendingAccountSync) ...[
                  const SizedBox(height: 4),
                  Text(
                    l10n.languageSyncPending,
                    style: const TextStyle(color: zeroonMuted, fontSize: 11),
                  ),
                ],
              ],
            ),
          ),
          const Icon(Icons.chevron_right, color: zeroonMuted),
        ],
      ),
    );
  }

  Future<void> _select(
    BuildContext context,
    WidgetRef ref,
    LocalePreference current,
  ) async {
    final selected = await showLanguagePreferencePicker(context, current);
    if (selected == null || selected == current || !context.mounted) {
      return;
    }
    try {
      await ref
          .read(authControllerProvider.notifier)
          .selectLanguagePreference(selected);
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(context.l10n.languageStorageUnavailable)),
        );
      }
    }
  }
}
