import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/onboarding_state.dart';

/// Onboarding state persistence manager.
///
/// Implements local-first caching strategy:
/// 1. Save progressive answers locally on each question click
/// 2. On app launch, check local cache for partial progress
/// 3. On survey completion, commit to Firestore and clear local cache
class OnboardingStorage {
  static const String _storageKey = 'fmg_onboarding_state';

  /// Persist progressive inputs locally (instant, no network)
  Future<void> saveLocalState(OnboardingState state) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = jsonEncode(state.toJson());
    await prefs.setString(_storageKey, jsonString);
  }

  /// Retrieve cached state upon app launch
  Future<OnboardingState?> retrieveLocalState() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_storageKey);
    if (jsonString != null) {
      try {
        final decoded = jsonDecode(jsonString) as Map<String, dynamic>;
        return OnboardingState.fromJson(decoded);
      } catch (e) {
        // Handle corruption gracefully - reset to default
        return null;
      }
    }
    return null;
  }

  /// Purge cache upon successful final generation
  Future<void> clearLocalState() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_storageKey);
  }
}