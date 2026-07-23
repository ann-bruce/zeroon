import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'auth/auth_controller.dart';
import 'auth/auth_models.dart';
import 'auth/login_screen.dart';
import 'common/zeroon_design.dart';
import 'evidence/evidence_models.dart';
import 'evidence/evidence_repository.dart';
import 'home/home_shell.dart';
import 'l10n/app_localizations.dart';
import 'locale/locale_controller.dart';
import 'locale/locale_preference.dart';
import 'my_zeroon/encounter_screen.dart';
import 'my_zeroon/my_zeroon_controller.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final localeBootstrap = await bootstrapLocale();
  runApp(
    ProviderScope(
      overrides: [
        initialLocaleStateProvider.overrideWithValue(localeBootstrap.state),
        localePreferenceStoreProvider.overrideWithValue(localeBootstrap.store),
      ],
      child: const ZeroonApp(),
    ),
  );
}

class ZeroonApp extends ConsumerWidget {
  const ZeroonApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sessionState = ref.watch(authControllerProvider);
    final localeState = ref.watch(localeControllerProvider);

    return MaterialApp(
      onGenerateTitle: (context) => AppLocalizations.of(context).appTitle,
      debugShowCheckedModeBanner: false,
      locale: localeState.materialLocale,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      localeListResolutionCallback: (systemLocales, supportedLocales) =>
          resolveSupportedSystemLocale(systemLocales, supportedLocales),
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
        data: (session) => session == null
            ? const LoginScreen()
            : AuthenticatedEntry(session: session),
      ),
    );
  }
}

class AuthenticatedEntry extends ConsumerStatefulWidget {
  const AuthenticatedEntry({super.key, required this.session});

  final AuthSession session;

  @override
  ConsumerState<AuthenticatedEntry> createState() => _AuthenticatedEntryState();
}

class _AuthenticatedEntryState extends ConsumerState<AuthenticatedEntry> {
  bool _holdEncounterAfterMeeting = false;
  bool _encounterViewed = false;
  bool _encounterCompleted = false;
  int _meetAttempts = 0;
  DateTime? _encounterViewedAt;

  @override
  Widget build(BuildContext context) {
    final companionState = ref.watch(myZeroonProvider);

    if (companionState.isLoading && !companionState.hasValue) {
      return const SplashScreen();
    }

    if (companionState.hasError && !companionState.hasValue) {
      return EncounterErrorScreen(
        message: companionState.error.toString(),
        onRetry: () => ref.invalidate(myZeroonProvider),
      );
    }

    final companion = companionState.value;
    if (companion == null) {
      return const SplashScreen();
    }

    if (companion.met && !_holdEncounterAfterMeeting) {
      return HomeShell(session: widget.session);
    }

    if (!companion.met && !_encounterViewed) {
      _encounterViewed = true;
      _encounterViewedAt = DateTime.now();
      unawaited(ref.read(evidenceRepositoryProvider).record(
            EvidenceEvent('ZEROON_ENCOUNTER_VIEWED', {
              'entrySource': 'LOGIN',
              'appVersion': zeroonAppVersion,
            }),
          ));
    }

    return EncounterScreen(
      companion: companion,
      loading: companionState.isLoading,
      onMeet: () async {
        _meetAttempts += 1;
        setState(() => _holdEncounterAfterMeeting = true);
        await ref.read(myZeroonProvider.notifier).meet();
        final met = ref.read(myZeroonProvider).valueOrNull?.met ?? false;
        if (met && !_encounterCompleted) {
          _encounterCompleted = true;
          unawaited(ref.read(evidenceRepositoryProvider).record(
                EvidenceEvent('ZEROON_ENCOUNTER_COMPLETED', {
                  'durationBucket': durationBucket(
                    DateTime.now().difference(
                      _encounterViewedAt ?? DateTime.now(),
                    ),
                  ),
                  'retryCountBucket': retryCountBucket(_meetAttempts - 1),
                }),
              ));
        }
      },
      onEnter: () => setState(() => _holdEncounterAfterMeeting = false),
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
