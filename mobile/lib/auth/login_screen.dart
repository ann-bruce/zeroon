import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../common/zeroon_design.dart';
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
    final error = widget.initialError ?? authState.error?.toString();

    return ZeroonScreen(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 30),
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Wordmark(),
              ZeroonIconButton(
                child: const Text('?', style: TextStyle(fontSize: 13)),
                onPressed: () {},
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
          const SectionMark('归零 / ZEROON'),
          const SizedBox(height: 10),
          Text('欢迎回来。', style: zeroonSerif(context, size: 30)),
          const SizedBox(height: 8),
          const Text('这里没有需要证明的事。\n先从此刻开始。'),
          const SizedBox(height: 28),
          TextField(
            controller: _mobileController,
            keyboardType: TextInputType.phone,
            decoration: const InputDecoration(
              labelText: '手机号',
              prefixText: '+86  ',
            ),
          ),
          const SizedBox(height: 14),
          TextField(
            controller: _codeController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: '验证码',
              suffixIcon: TextButton(
                onPressed: isLoading ? null : _requestCode,
                child: const Text('获取验证码'),
              ),
            ),
          ),
          const SizedBox(height: 18),
          ZeroonPrimaryButton(
            label: '进入 ZEROON',
            loading: isLoading,
            onPressed: _login,
          ),
          const SizedBox(height: 10),
          const Text(
            '登录即代表同意《用户协议》与《隐私政策》',
            textAlign: TextAlign.center,
            style: TextStyle(color: Color(0xFF9F9E9B), fontSize: 9),
          ),
          if (_message != null) ...[
            const SizedBox(height: 16),
            Text(_message!, style: const TextStyle(color: Color(0xFF2F6F78))),
          ],
          if (error != null) ...[
            const SizedBox(height: 16),
            Text(
              error,
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
      setState(() => _message = '本地验证码已生成，开发环境默认使用 000000。');
    } catch (error) {
      setState(() => _message = '验证码请求失败：$error');
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
