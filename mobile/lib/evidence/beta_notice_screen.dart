import 'package:flutter/material.dart';

import '../common/zeroon_design.dart';
import '../l10n/l10n_extensions.dart';

class BetaNoticeScreen extends StatefulWidget {
  const BetaNoticeScreen({
    super.key,
    required this.loading,
    this.errorMessage,
    required this.onContinue,
    required this.onUnderage,
  });

  final bool loading;
  final String? errorMessage;
  final Future<void> Function(bool evidenceEnabled) onContinue;
  final VoidCallback onUnderage;

  @override
  State<BetaNoticeScreen> createState() => _BetaNoticeScreenState();
}

class _BetaNoticeScreenState extends State<BetaNoticeScreen> {
  bool _adultConfirmed = false;
  bool _evidenceEnabled = false;
  String? _message;

  @override
  Widget build(BuildContext context) {
    return ZeroonScreen(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(24, 28, 24, 32),
        children: [
          const Wordmark(),
          const SizedBox(height: 34),
          SectionMark(context.l10n.betaNoticeMark),
          const SizedBox(height: 10),
          Text(
            context.l10n.betaNoticeTitle,
            style: zeroonSerif(context, size: 30),
          ),
          const SizedBox(height: 12),
          Text(context.l10n.betaNoticeIntro),
          const SizedBox(height: 22),
          ZeroonCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  context.l10n.betaAdultTitle,
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 7),
                Text(context.l10n.betaAdultBody),
                const SizedBox(height: 10),
                Material(
                  color: Colors.transparent,
                  child: CheckboxListTile(
                    contentPadding: EdgeInsets.zero,
                    controlAffinity: ListTileControlAffinity.leading,
                    value: _adultConfirmed,
                    onChanged: widget.loading
                        ? null
                        : (value) => setState(() {
                              _adultConfirmed = value ?? false;
                              _message = null;
                            }),
                    title: Text(context.l10n.betaAdultConfirm),
                  ),
                ),
                Align(
                  alignment: Alignment.centerLeft,
                  child: TextButton(
                    onPressed: widget.loading ? null : widget.onUnderage,
                    child: Text(context.l10n.betaUnderage),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          ZeroonCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  context.l10n.betaEvidenceTitle,
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 8),
                _NoticePoint(text: context.l10n.betaEvidenceCollected),
                _NoticePoint(text: context.l10n.betaEvidenceExcluded),
                _NoticePoint(text: context.l10n.betaEvidenceControl),
                const SizedBox(height: 6),
                Material(
                  color: Colors.transparent,
                  child: SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    value: _evidenceEnabled,
                    onChanged: widget.loading
                        ? null
                        : (value) => setState(() => _evidenceEnabled = value),
                    title: Text(context.l10n.betaEvidenceChoice),
                    subtitle: Text(context.l10n.betaEvidenceOptional),
                  ),
                ),
              ],
            ),
          ),
          if ((_message ?? widget.errorMessage) != null) ...[
            const SizedBox(height: 12),
            Text(
              _message ?? widget.errorMessage!,
              style: const TextStyle(color: Color(0xFF9A4D4D)),
            ),
          ],
          const SizedBox(height: 18),
          ZeroonPrimaryButton(
            label: context.l10n.betaContinue,
            loading: widget.loading,
            onPressed: () async {
              if (!_adultConfirmed) {
                setState(() => _message = context.l10n.betaAdultRequired);
                return;
              }
              await widget.onContinue(_evidenceEnabled);
            },
          ),
          const SizedBox(height: 12),
          Text(
            context.l10n.betaInterviewSeparate,
            textAlign: TextAlign.center,
            style: const TextStyle(color: zeroonMuted, fontSize: 11),
          ),
        ],
      ),
    );
  }
}

class _NoticePoint extends StatelessWidget {
  const _NoticePoint({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 7),
            child: Icon(Icons.circle, size: 5, color: zeroonCyan),
          ),
          const SizedBox(width: 9),
          Expanded(child: Text(text)),
        ],
      ),
    );
  }
}

class BetaUnavailableScreen extends StatelessWidget {
  const BetaUnavailableScreen({
    super.key,
    required this.onRetry,
    required this.onLogout,
  });

  final VoidCallback onRetry;
  final VoidCallback onLogout;

  @override
  Widget build(BuildContext context) {
    return ZeroonScreen(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Wordmark(),
            const SizedBox(height: 28),
            Text(
              context.l10n.betaUnavailableTitle,
              style: zeroonSerif(context, size: 26),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              context.l10n.betaUnavailableBody,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ZeroonPrimaryButton(
              label: context.l10n.retry,
              onPressed: onRetry,
            ),
            TextButton(
              onPressed: onLogout,
              child: Text(context.l10n.logout),
            ),
          ],
        ),
      ),
    );
  }
}
