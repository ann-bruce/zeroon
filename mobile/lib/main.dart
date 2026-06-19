import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

void main() {
  runApp(const ProviderScope(child: ZeroonApp()));
}

final _router = GoRouter(
  routes: [
    GoRoute(path: '/', builder: (context, state) => const HomeScreen()),
  ],
);

class ZeroonApp extends StatelessWidget {
  const ZeroonApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
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
      routerConfig: _router,
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('ZEROON', style: Theme.of(context).textTheme.labelLarge),
              const Spacer(),
              Center(
                child: Container(
                  width: 144,
                  height: 144,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [Color(0xFFEFFFFF), Color(0xFF55C7D9)],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Color(0x6655C7D9),
                        blurRadius: 42,
                        spreadRadius: 12,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 48),
              Text('先看见此刻的状态。', style: Theme.of(context).textTheme.headlineSmall),
              const SizedBox(height: 8),
              const Text('Sprint 0 已建立移动端工程入口。'),
              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }
}

