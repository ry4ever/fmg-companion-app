import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../screens/home_screen.dart';
import '../screens/my_gym_screen.dart';
import '../screens/onboarding_screen.dart';
import '../screens/paywall_screen.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>();
final GlobalKey<NavigatorState> _shellNavigatorKey = GlobalKey<NavigatorState>();

GoRouter buildRouter({
  required bool isPremiumParentTrack,
  required bool onboardingCompleted,
  required int cachedStep,
}) {
  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: _initialLocation(
      isPremiumParentTrack,
      onboardingCompleted,
      cachedStep,
    ),
    routes: [
      ShellRoute(
        navigatorKey: _shellNavigatorKey,
        builder: (context, state, child) {
          return Scaffold(
            body: child,
            bottomNavigationBar: _AppBottomBar(
              currentLocation: state.matchedLocation,
              isPremiumParentTrack: isPremiumParentTrack,
              onboardingCompleted: onboardingCompleted,
              cachedStep: cachedStep,
            ),
          );
        },
        routes: [
          GoRoute(path: '/', builder: (context, state) => const HomeScreen()),
          GoRoute(path: '/paywall', builder: (context, state) => const PaywallScreen()),
          GoRoute(
            path: '/onboarding',
            builder: (context, state) {
              final step = int.tryParse(state.uri.queryParameters['step'] ?? '') ?? cachedStep;
              return OnboardingScreen(initialStep: step);
            },
          ),
          GoRoute(path: '/my-gym', builder: (context, state) => const MyGymScreen()),
        ],
      ),
    ],
  );
}

String _initialLocation(bool isPremium, bool onboardingCompleted, int cachedStep) {
  if (!onboardingCompleted) return '/onboarding?step=$cachedStep';
  if (!isPremium) return '/paywall';
  return '/';
}

class _AppBottomBar extends StatelessWidget {
  final String currentLocation;
  final bool isPremiumParentTrack;
  final bool onboardingCompleted;
  final int cachedStep;

  const _AppBottomBar({
    required this.currentLocation,
    required this.isPremiumParentTrack,
    required this.onboardingCompleted,
    required this.cachedStep,
  });

  int get _selectedIndex {
    if (currentLocation.startsWith('/my-gym')) return 3;
    if (currentLocation.startsWith('/paywall')) return 3;
    if (currentLocation.startsWith('/onboarding')) return 3;
    return 0;
  }

  void _onTabTapped(int index, BuildContext context) {
    switch (index) {
      case 0:
        context.go('/');
        break;
      case 1:
        // Calendar tab - placeholder for now
        context.go('/');
        break;
      case 2:
        // Community tab - placeholder for now
        context.go('/');
        break;
      case 3:
        if (!isPremiumParentTrack) {
          context.go('/paywall');
        } else if (!onboardingCompleted) {
          context.go('/onboarding?step=$cachedStep');
        } else {
          context.go('/my-gym');
        }
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: _selectedIndex,
      onTap: (index) => _onTabTapped(index, context),
      type: BottomNavigationBarType.fixed,
      selectedItemColor: Theme.of(context).primaryColor,
      unselectedItemColor: Colors.grey,
      items: [
        const BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: 'Home',
        ),
        const BottomNavigationBarItem(
          icon: Icon(Icons.calendar_month),
          label: 'Calendar',
        ),
        const BottomNavigationBarItem(
          icon: Icon(Icons.people),
          label: 'Community',
        ),
        BottomNavigationBarItem(
          icon: Icon(isPremiumParentTrack ? Icons.lock_open : Icons.lock),
          label: 'My Gym',
        ),
      ],
    );
  }
}