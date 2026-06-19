import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'auth/auth_controller.dart';
import 'auth/login_screen.dart';
import 'home/home_shell.dart';

void main() {
  runApp(const ProviderScope(child: ZeroonApp()));
}

class ZeroonApp extends ConsumerWidget {
  const ZeroonApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sessionState = ref.watch(authControllerProvider);

    return MaterialApp(
      title: 'ZEROON',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF55C7D9),
          surface: const Color(0xFFF7F2E8),
          brightness: Brightness.light,
        ),
        scaffoldBackgroundColor: const Color(0xFFF7F2E8),
        useMaterial3: true,
      ),
      home: sessionState.when(
        loading: () => const SplashScreen(),
        error: (error, stackTrace) =>
            LoginScreen(initialError: error.toString()),
        data: (session) =>
            session == null ? const LoginScreen() : HomeShell(session: session),
      ),
    );
  }
}

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: SafeArea(child: Center(child: CircularProgressIndicator())),
    );
  }
}
