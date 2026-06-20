import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'auth/auth_controller.dart';
import 'auth/login_screen.dart';
import 'common/zeroon_design.dart';
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
          seedColor: zeroonCyan,
          surface: zeroonPaper,
          brightness: Brightness.light,
        ),
        scaffoldBackgroundColor: zeroonPaper,
        textTheme: const TextTheme(
          headlineMedium: TextStyle(
            color: zeroonInk,
            fontSize: 30,
            fontWeight: FontWeight.w600,
            letterSpacing: -0.8,
            height: 1.25,
          ),
          headlineSmall: TextStyle(
            color: zeroonInk,
            fontSize: 26,
            fontWeight: FontWeight.w600,
            letterSpacing: -0.6,
            height: 1.25,
          ),
          titleLarge: TextStyle(
            color: zeroonInk,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
          titleMedium: TextStyle(
            color: zeroonInk,
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
          titleSmall: TextStyle(
            color: zeroonInk,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
          bodyMedium: TextStyle(
            color: Color(0xFF666970),
            fontSize: 13,
            height: 1.6,
          ),
          bodySmall: TextStyle(
            color: zeroonMuted,
            fontSize: 11,
            height: 1.55,
          ),
          labelLarge: TextStyle(
            color: zeroonInk,
            fontSize: 12,
            fontWeight: FontWeight.w800,
            letterSpacing: 2.8,
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white.withValues(alpha: 0.66),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: zeroonLine),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: zeroonLine),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: zeroonCyan),
          ),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: zeroonPaper,
          foregroundColor: zeroonInk,
          elevation: 0,
          centerTitle: true,
        ),
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
