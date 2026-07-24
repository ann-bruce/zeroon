import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../common/zeroon_design.dart';
import '../l10n/app_localizations.dart';
import '../l10n/l10n_extensions.dart';
import '../locale/locale_controller.dart';
import 'support_models.dart';
import 'support_presentation.dart';
import 'support_repository.dart';
import 'support_requests_screen.dart';

const zeroonSupportEmail = String.fromEnvironment(
  'ZEROON_SUPPORT_EMAIL',
  defaultValue: 'zeroon_ai@outlook.com',
);
const zeroonAppVersion = String.fromEnvironment(
  'ZEROON_APP_VERSION',
  defaultValue: '1.0.0',
);
const zeroonAppBuild = String.fromEnvironment(
  'ZEROON_APP_BUILD',
  defaultValue: '1',
);

class SupportScreen extends ConsumerStatefulWidget {
  const SupportScreen({super.key, required this.authenticated});

  final bool authenticated;

  @override
  ConsumerState<SupportScreen> createState() => _SupportScreenState();
}

class _SupportScreenState extends ConsumerState<SupportScreen> {
  final _descriptionController = TextEditingController();
  final _submissionId = _uuidV4();
  SupportCategory _category = SupportCategory.productProblem;
  SupportDiagnosticEnvelope? _diagnostics;
  SupportReceipt? _receipt;
  bool _submitting = false;
  bool _failed = false;

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return ZeroonScreen(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(22, 18, 22, 28),
        children: [
          ZeroonHeader(
            mark: 'SUPPORT',
            title: l10n.supportTitle,
            center: true,
            leading: ZeroonIconButton(
              semanticLabel: l10n.back,
              onPressed: () => Navigator.of(context).maybePop(),
              child: const Icon(Icons.chevron_left),
            ),
          ),
          const SizedBox(height: 22),
          Text(
            widget.authenticated
                ? l10n.supportIntro
                : l10n.supportSignedOutBody,
            style: const TextStyle(color: zeroonMuted, height: 1.45),
          ),
          const SizedBox(height: 14),
          _SupportEmailCard(onCopy: () => _copy(zeroonSupportEmail)),
          const SizedBox(height: 8),
          Text(
            l10n.supportRetentionNote,
            style: const TextStyle(color: zeroonMuted, fontSize: 12),
          ),
          if (widget.authenticated) ...[
            const SizedBox(height: 12),
            const _SupportRequestsEntryCard(),
          ],
          if (!widget.authenticated) ...[
            const SizedBox(height: 14),
            Text(
              l10n.supportExternalBoundary,
              style: const TextStyle(color: zeroonMuted, fontSize: 12),
            ),
            const SizedBox(height: 8),
            Text(
              l10n.supportNonEmergency,
              style: const TextStyle(color: zeroonMuted, fontSize: 12),
            ),
          ] else if (_receipt != null) ...[
            const SizedBox(height: 24),
            _SupportReceiptCard(
              receipt: _receipt!,
              onCopy: () => _copy(_receipt!.reference),
              onView: () => Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => SupportRequestDetailScreen(
                    reference: _receipt!.reference,
                  ),
                ),
              ),
            ),
          ] else ...[
            const SizedBox(height: 24),
            _buildForm(l10n),
          ],
        ],
      ),
    );
  }

  Widget _buildForm(AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DropdownButtonFormField<SupportCategory>(
          initialValue: _category,
          decoration: InputDecoration(labelText: l10n.supportCategoryLabel),
          items: [
            for (final category in SupportCategory.values)
              DropdownMenuItem(
                value: category,
                child: Text(supportCategoryLabel(l10n, category)),
              ),
          ],
          onChanged: _submitting
              ? null
              : (value) {
                  if (value != null) {
                    setState(() => _category = value);
                  }
                },
        ),
        const SizedBox(height: 14),
        TextField(
          key: const Key('support-description'),
          controller: _descriptionController,
          minLines: 5,
          maxLines: 9,
          maxLength: 4000,
          enabled: !_submitting,
          decoration: InputDecoration(
            labelText: l10n.supportDescriptionLabel,
            hintText: l10n.supportDescriptionHint,
            alignLabelWithHint: true,
          ),
        ),
        const SizedBox(height: 4),
        ZeroonCard(
          padding: const EdgeInsets.fromLTRB(16, 13, 12, 13),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.supportDiagnosticsTitle,
                          style: const TextStyle(fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          l10n.supportDiagnosticsHint,
                          style: const TextStyle(
                            color: zeroonMuted,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Switch(
                    value: _diagnostics != null,
                    onChanged: _submitting
                        ? null
                        : (enabled) => setState(() {
                              _diagnostics =
                                  enabled ? _buildDiagnostics() : null;
                            }),
                  ),
                ],
              ),
              if (_diagnostics != null) ...[
                const Divider(height: 22),
                Text(
                  l10n.supportDiagnosticsPreviewTitle,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 7),
                _diagnosticLine(
                  l10n.supportDiagnosticApp,
                  '${_diagnostics!.appVersion}+${_diagnostics!.build}',
                ),
                _diagnosticLine(
                  l10n.supportDiagnosticPlatform,
                  _diagnostics!.platform,
                ),
                _diagnosticLine(
                  l10n.supportDiagnosticLocale,
                  _diagnostics!.locale,
                ),
                _diagnosticLine(
                  l10n.supportDiagnosticTime,
                  _diagnostics!.timestamp.toLocal().toIso8601String(),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 9),
        Text(
          l10n.supportPrivacyNote,
          style: const TextStyle(color: zeroonMuted, fontSize: 11, height: 1.4),
        ),
        if (_failed) ...[
          const SizedBox(height: 14),
          Text(
            l10n.supportSubmitFailed,
            style: TextStyle(color: Theme.of(context).colorScheme.error),
          ),
          const SizedBox(height: 5),
          TextButton.icon(
            onPressed: () => _copy(zeroonSupportEmail),
            icon: const Icon(Icons.content_copy_outlined, size: 16),
            label: const Text(zeroonSupportEmail),
          ),
        ],
        const SizedBox(height: 18),
        ZeroonPrimaryButton(
          label: _failed ? l10n.supportRetrySubmit : l10n.supportSubmit,
          loading: _submitting,
          onPressed: _submit,
        ),
        const SizedBox(height: 10),
        Text(
          l10n.supportNonEmergency,
          style: const TextStyle(color: zeroonMuted, fontSize: 11),
        ),
      ],
    );
  }

  Widget _diagnosticLine(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 3),
      child: Text(
        '$label: $value',
        style: const TextStyle(color: zeroonMuted, fontSize: 11),
      ),
    );
  }

  Future<void> _copy(String value) async {
    await Clipboard.setData(ClipboardData(text: value));
    if (!mounted) {
      return;
    }
    final message = value == zeroonSupportEmail
        ? context.l10n.supportEmailCopied
        : context.l10n.supportReferenceCopied;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  Future<void> _submit() async {
    final description = _descriptionController.text;
    if (description.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.supportValidationDescription)),
      );
      return;
    }

    setState(() {
      _submitting = true;
      _failed = false;
    });
    try {
      final receipt = await ref.read(supportRepositoryProvider).create(
            CreateSupportRequest(
              clientSubmissionId: _submissionId,
              category: _category,
              subject: _subjectFrom(description.trim()),
              description: description,
              diagnosticConsent: _diagnostics != null,
              diagnostics: _diagnostics,
            ),
          );
      if (mounted) {
        setState(() => _receipt = receipt);
      }
    } catch (_) {
      if (mounted) {
        setState(() => _failed = true);
      }
    } finally {
      if (mounted) {
        setState(() => _submitting = false);
      }
    }
  }

  SupportDiagnosticEnvelope _buildDiagnostics() {
    final locale = ref
        .read(localeControllerProvider)
        .effectiveLocale(ref.read(systemLocalesProvider));
    final platform = kIsWeb ? 'web' : defaultTargetPlatform.name;
    return SupportDiagnosticEnvelope(
      appVersion: zeroonAppVersion,
      build: zeroonAppBuild,
      platform: platform,
      osFamily: kIsWeb ? null : platform,
      locale: locale.languageCode == 'zh' ? 'zh-CN' : 'en',
      timestamp: DateTime.now().toUtc(),
    );
  }
}

class SupportSettingCard extends StatelessWidget {
  const SupportSettingCard({super.key});

  @override
  Widget build(BuildContext context) {
    return ZeroonCard(
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => const SupportScreen(authenticated: true),
        ),
      ),
      child: Row(
        children: [
          const Icon(Icons.help_outline, color: zeroonInk),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  context.l10n.helpAndContact,
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 3),
                Text(
                  context.l10n.supportSettingHint,
                  style: const TextStyle(color: zeroonMuted, fontSize: 12),
                ),
              ],
            ),
          ),
          const Icon(Icons.chevron_right, color: zeroonMuted),
        ],
      ),
    );
  }
}

class _SupportEmailCard extends StatelessWidget {
  const _SupportEmailCard({required this.onCopy});

  final VoidCallback onCopy;

  @override
  Widget build(BuildContext context) {
    return ZeroonCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            context.l10n.supportEmailTitle,
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 6),
          const SelectableText(
            zeroonSupportEmail,
            style: TextStyle(color: zeroonInk),
          ),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerLeft,
            child: OutlinedButton.icon(
              onPressed: onCopy,
              icon: const Icon(Icons.content_copy_outlined, size: 16),
              label: Text(context.l10n.supportCopyEmail),
            ),
          ),
        ],
      ),
    );
  }
}

class _SupportRequestsEntryCard extends StatelessWidget {
  const _SupportRequestsEntryCard();

  @override
  Widget build(BuildContext context) {
    return ZeroonCard(
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => const SupportRequestsScreen(),
        ),
      ),
      child: Row(
        children: [
          const Icon(Icons.inbox_outlined, color: zeroonInk),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  context.l10n.supportMyRequests,
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 3),
                Text(
                  context.l10n.supportMyRequestsHint,
                  style: const TextStyle(color: zeroonMuted, fontSize: 12),
                ),
              ],
            ),
          ),
          const Icon(Icons.chevron_right, color: zeroonMuted),
        ],
      ),
    );
  }
}

class _SupportReceiptCard extends StatelessWidget {
  const _SupportReceiptCard({
    required this.receipt,
    required this.onCopy,
    required this.onView,
  });

  final SupportReceipt receipt;
  final VoidCallback onCopy;
  final VoidCallback onView;

  @override
  Widget build(BuildContext context) {
    return ZeroonCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.check_circle_outline, color: Color(0xFF2F6F78)),
          const SizedBox(height: 10),
          Text(
            context.l10n.supportReceiptTitle,
            style: zeroonSerif(context, size: 22),
          ),
          const SizedBox(height: 7),
          Text(context.l10n.supportReceiptBody),
          const SizedBox(height: 16),
          Text(
            context.l10n.supportReferenceLabel,
            style: const TextStyle(color: zeroonMuted, fontSize: 11),
          ),
          const SizedBox(height: 4),
          SelectableText(
            receipt.reference,
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          OutlinedButton.icon(
            onPressed: onCopy,
            icon: const Icon(Icons.content_copy_outlined, size: 16),
            label: Text(context.l10n.supportCopyReference),
          ),
          const SizedBox(height: 6),
          TextButton.icon(
            onPressed: onView,
            icon: const Icon(Icons.open_in_new, size: 16),
            label: Text(context.l10n.supportViewRequest),
          ),
        ],
      ),
    );
  }
}

String _subjectFrom(String description) {
  final firstLine = description.split(RegExp(r'[\r\n]')).first.trim();
  return firstLine.length <= 120 ? firstLine : firstLine.substring(0, 120);
}

String _uuidV4() {
  final bytes = List<int>.generate(16, (_) => Random.secure().nextInt(256));
  bytes[6] = (bytes[6] & 0x0f) | 0x40;
  bytes[8] = (bytes[8] & 0x3f) | 0x80;
  final hex =
      bytes.map((byte) => byte.toRadixString(16).padLeft(2, '0')).join();
  return '${hex.substring(0, 8)}-${hex.substring(8, 12)}-'
      '${hex.substring(12, 16)}-${hex.substring(16, 20)}-'
      '${hex.substring(20)}';
}
