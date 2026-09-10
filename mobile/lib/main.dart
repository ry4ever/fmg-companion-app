import 'package:flutter/material.dart' hide Router;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'firebase_options.dart';
import 'lib/routes/app_router.dart' as routes;
import 'lib/providers/auth_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  await Hive.initFlutter();
  await Hive.openBox('local_cache');

  runApp(const ProviderScope(child: FMGApp()));
}

class FMGApp extends ConsumerWidget {
  const FMGApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);
    final isSignedIn = authState.valueOrNull != null;
    final isPremium = ref.watch(isPremiumProvider);
    final onboardingCompleted = ref.watch(onboardingCompletedProvider);
    final cachedStepAsync = ref.watch(cachedStepProvider);
    final cachedStep = cachedStepAsync.valueOrNull ?? 0;

    final router = routes.buildRouter(
      isSignedIn: isSignedIn,
      isPremiumParentTrack: isPremium,
      onboardingCompleted: onboardingCompleted,
      cachedStep: cachedStep,
    );

    return MaterialApp.router(
      title: 'Football Mind Gym',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      routerConfig: router,
    );
  }
}
