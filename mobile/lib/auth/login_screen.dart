import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            const SizedBox(height: 48),
            Text('ZEROON', style: Theme.of(context).textTheme.labelLarge),
            const SizedBox(height: 96),
            Text('先进入此刻。', style: Theme.of(context).textTheme.headlineMedium),
            const SizedBox(height: 8),
            const Text('使用本地验证码登录，继续你的归零记录。'),
            const SizedBox(height: 32),
            TextField(
              controller: _mobileController,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(labelText: '手机号'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _codeController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: '验证码'),
            ),
            const SizedBox(height: 20),
            OutlinedButton(
              onPressed: isLoading ? null : _requestCode,
              child: const Text('获取验证码'),
            ),
            const SizedBox(height: 12),
            FilledButton(
              onPressed: isLoading ? null : _login,
              child: Text(isLoading ? '处理中...' : '登录'),
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
