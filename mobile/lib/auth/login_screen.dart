import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../common/zeroon_design.dart';
import '../l10n/l10n_extensions.dart';
import '../locale/language_picker.dart';
import '../support/support_screen.dart';
import 'auth_controller.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key, this.initialError});

  final String? initialError;

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _mobileController = TextEditingController(text: '13800138000');
  final _codeController = TextEditingController(text: '000000');
  String? _message;
  bool _requestingCode = false;

  @override
  void dispose() {
    _mobileController.dispose();
    _codeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authControllerProvider);
    final isLoading = authState.isLoading || _requestingCode;
    final hasError = widget.initialError != null || authState.hasError;
    final l10n = context.l10n;

    return ZeroonScreen(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 30),
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Wordmark(),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ZeroonIconButton(
                    semanticLabel: l10n.helpAndContact,
                    onPressed: () => Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) =>
                            const SupportScreen(authenticated: false),
                      ),
                    ),
                    child: const Icon(Icons.help_outline),
                  ),
                  const SizedBox(width: 8),
                  const LanguagePickerButton(),
                ],
              ),
            ],
          ),
          const SizedBox(height: 62),
          Align(
            alignment: Alignment.centerRight,
            child: SizedBox(
              width: 252,
              height: 258,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    width: 230,
                    height: 230,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          zeroonBlue.withValues(alpha: 0.15),
                          zeroonCyan.withValues(alpha: 0.07),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                  Image.asset(
                    'assets/zeroon-front.png',
                    fit: BoxFit.contain,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          SectionMark(l10n.loginMark),
          const SizedBox(height: 10),
          Text(l10n.loginWelcome, style: zeroonSerif(context, size: 30)),
          const SizedBox(height: 8),
          Text(l10n.loginBody),
          const SizedBox(height: 28),
          TextField(
            controller: _mobileController,
            keyboardType: TextInputType.phone,
            decoration: InputDecoration(
              labelText: l10n.mobileNumber,
              prefixText: '+86  ',
            ),
          ),
          const SizedBox(height: 14),
          TextField(
            controller: _codeController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: l10n.verificationCode,
              suffixIcon: TextButton(
                onPressed: isLoading ? null : _requestCode,
                child: Text(l10n.requestCode),
              ),
            ),
          ),
          const SizedBox(height: 18),
          ZeroonPrimaryButton(
            label: l10n.enterZeroon,
            loading: isLoading,
            onPressed: _login,
          ),
          const SizedBox(height: 10),
          Text(
            l10n.loginAgreement,
            textAlign: TextAlign.center,
            style: TextStyle(color: Color(0xFF9F9E9B), fontSize: 9),
          ),
          if (_message != null) ...[
            const SizedBox(height: 16),
            Text(_message!, style: const TextStyle(color: Color(0xFF2F6F78))),
          ],
          if (hasError) ...[
            const SizedBox(height: 16),
            Text(
              l10n.loginUnavailable,
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _requestCode() async {
    setState(() {
      _requestingCode = true;
      _message = null;
    });
    try {
      await ref
          .read(authControllerProvider.notifier)
          .requestCode(_mobileController.text.trim());
      if (mounted) {
        setState(() => _message = context.l10n.localCodeReady);
      }
    } catch (_) {
      if (mounted) {
        setState(() => _message = context.l10n.codeRequestFailed);
      }
    } finally {
      if (mounted) {
        setState(() => _requestingCode = false);
      }
    }
  }

  Future<void> _login() {
    return ref.read(authControllerProvider.notifier).login(
          mobile: _mobileController.text.trim(),
          code: _codeController.text.trim(),
          deviceId: 'zeroon-mobile-dev',
        );
  }
}
