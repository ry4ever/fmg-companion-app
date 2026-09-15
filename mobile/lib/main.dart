import 'package:flutter/material.dart' hide Router;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/foundation.dart' show kIsWeb, kDebugMode;
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'firebase_options.dart';
import 'routes/app_router.dart' as routes;
import 'providers/auth_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Attempt Firebase initialization; gracefully continue on platforms
  // that don't support the native Firebase SDK (e.g., Linux desktop).
  FirebaseOptions? options;
  try {
    options = DefaultFirebaseOptions.currentPlatform;
    await Firebase.initializeApp(options: options);
    setFirebaseAvailable(true);
  } catch (e) {
    // Firebase not available on this platform — continue without it.
    // The app will run in a limited mode; features requiring Firebase
    // (auth, firestore) will be unavailable until configured properly.
    options = null;
    setFirebaseAvailable(false);
  }

  // Redirect Firebase traffic to local emulators in debug mode
  if (kDebugMode && options != null) {
    final emulatorHost = kIsWeb ? 'localhost' : '10.0.2.2';
    await FirebaseAuth.instance.useAuthEmulator(emulatorHost, 9099);
    FirebaseFirestore.instance.useFirestoreEmulator(emulatorHost, 8080);
  }

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
