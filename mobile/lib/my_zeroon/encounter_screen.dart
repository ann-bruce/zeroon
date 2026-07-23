import 'package:flutter/material.dart';

import '../common/zeroon_design.dart';
import '../l10n/l10n_extensions.dart';
import 'my_zeroon_models.dart';

class EncounterScreen extends StatelessWidget {
  const EncounterScreen({
    super.key,
    required this.companion,
    required this.loading,
    required this.onMeet,
    required this.onEnter,
  });

  final MyZeroonCompanion companion;
  final bool loading;
  final Future<void> Function() onMeet;
  final VoidCallback onEnter;

  @override
  Widget build(BuildContext context) {
    return ZeroonScreen(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
        children: [
          const SizedBox(height: 8),
          Center(child: SectionMark(context.l10n.encounterMark)),
          const SizedBox(height: 18),
          const _EncounterFigure(),
          const SizedBox(height: 18),
          if (companion.met)
            _EncounterComplete(
              serial: companion.nameplateSerial,
              onEnter: onEnter,
            )
          else
            _EncounterInvite(loading: loading, onMeet: onMeet),
        ],
      ),
    );
  }
}

class _EncounterFigure extends StatelessWidget {
  const _EncounterFigure();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 286,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: 258,
            height: 258,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  zeroonBlue.withValues(alpha: 0.15),
                  zeroonCyan.withValues(alpha: 0.08),
                  Colors.transparent,
                ],
              ),
            ),
          ),
          Image.asset(
            'assets/zeroon-front.png',
            height: 286,
            fit: BoxFit.contain,
          ),
        ],
      ),
    );
  }
}

class _EncounterInvite extends StatelessWidget {
  const _EncounterInvite({required this.loading, required this.onMeet});

  final bool loading;
  final Future<void> Function() onMeet;

  @override
  Widget build(BuildContext context) {
    return ZeroonCard(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
      child: Column(
        children: [
          Text(context.l10n.encounterTitle,
              style: zeroonSerif(context, size: 30)),
          const SizedBox(height: 10),
          Text(
            context.l10n.encounterBody,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 18),
          ZeroonPrimaryButton(
            label: context.l10n.confirmEncounter,
            loading: loading,
            onPressed: loading ? null : () => onMeet(),
          ),
        ],
      ),
    );
  }
}

class _EncounterComplete extends StatelessWidget {
  const _EncounterComplete({required this.serial, required this.onEnter});

  final String? serial;
  final VoidCallback onEnter;

  @override
  Widget build(BuildContext context) {
    return ZeroonCard(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
      child: Column(
        children: [
          Text(context.l10n.encounterCompleteTitle,
              style: zeroonSerif(context, size: 27)),
          const SizedBox(height: 10),
          Text(
            context.l10n.encounterCompleteBody,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 18),
          SectionMark(context.l10n.nameplate),
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 13, horizontal: 16),
            decoration: BoxDecoration(
              color: zeroonNight,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              serial ?? 'ZR-00000000-0000',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: zeroonIvory,
                fontSize: 16,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.8,
              ),
            ),
          ),
          const SizedBox(height: 16),
          ZeroonPrimaryButton(
            label: context.l10n.enterZeroon,
            onPressed: onEnter,
          ),
        ],
      ),
    );
  }
}

class EncounterErrorScreen extends StatelessWidget {
  const EncounterErrorScreen({
    super.key,
    required this.message,
    required this.onRetry,
  });

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return ZeroonScreen(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: ZeroonCard(
            padding: const EdgeInsets.fromLTRB(18, 18, 18, 18),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(context.l10n.encounterUnavailableTitle,
                    style: zeroonSerif(context, size: 24)),
                const SizedBox(height: 8),
                Text(context.l10n.encounterUnavailableBody),
                const SizedBox(height: 14),
                OutlinedButton(
                  onPressed: onRetry,
                  child: Text(context.l10n.retry),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
