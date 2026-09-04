import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/athlete_user.dart';
import '../models/telemetry_session.dart';
import '../models/weekly_schedule.dart';

/// Firestore service mirroring backend CRUD operations exactly.
///
/// Collection paths match the backend:
/// - /users/{parentEmail} (ParentUser)
/// - /users/{athleteAuthUid} (AthleteUser)
/// - /users/{athleteAuthUid}/telemetry/{sessionId}
/// - /users/{athleteAuthUid}/schedules/weekly (doc ID = "weekly")
class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // --- Athlete User Operations ---

  Future<AthleteUser?> getAthleteUser(String athleteUid) async {
    final doc = await _db.collection('users').doc(athleteUid).get();
    if (!doc.exists) return null;
    return AthleteUser.fromMap(doc.data() as Map<String, dynamic>);
  }

  Future<void> upsertAthleteUser(String athleteUid, AthleteUser data) async {
    await _db
        .collection('users')
        .doc(athleteUid)
        .set(data.toMap(), SetOptions(merge: true));
  }

  Future<void> updateAthleteStreak(String athleteUid, Map<String, dynamic> updates) async {
    await _db.collection('users').doc(athleteUid).update(updates);
  }

  // --- Telemetry Operations ---

  Future<void> writeTelemetry(String athleteUid, String sessionId, TelemetrySession data) async {
    await _db
        .collection('users')
        .doc(athleteUid)
        .collection('telemetry')
        .doc(sessionId)
        .set(data.toMap());
  }

  // --- Weekly Schedule Operations ---

  Future<WeeklySchedule?> getWeeklySchedule(String athleteUid) async {
    final doc = await _db
        .collection('users')
        .doc(athleteUid)
        .collection('schedules')
        .doc('weekly')
        .get();
    if (!doc.exists) return null;
    return WeeklySchedule.fromMap(doc.data() as Map<String, dynamic>);
  }

  Stream<WeeklySchedule?> watchWeeklySchedule(String athleteUid) {
    return _db
        .collection('users')
        .doc(athleteUid)
        .collection('schedules')
        .doc('weekly')
        .snapshots()
        .map((doc) {
          if (!doc.exists) return null;
          return WeeklySchedule.fromMap(doc.data() as Map<String, dynamic>);
        });
  }

  Future<void> setWeeklySchedule(String athleteUid, WeeklySchedule data) async {
    await _db
        .collection('users')
        .doc(athleteUid)
        .collection('schedules')
        .doc('weekly')
        .set(data.toMap(), SetOptions(merge: true));
  }

  /// Mark a specific day as completed in the weekly schedule.
  Future<void> markDayCompleted(String athleteUid, String dayKey) async {
    await _db
        .collection('users')
        .doc(athleteUid)
        .collection('schedules')
        .doc('weekly')
        .update({'days.$dayKey.completed': true});
  }

  // --- Reactive Stream ---

  Stream<AthleteUser?> watchAthleteUser(String athleteUid) {
    return _db
        .collection('users')
        .doc(athleteUid)
        .snapshots()
        .map((doc) {
      if (!doc.exists) return null;
      return AthleteUser.fromMap(doc.data() as Map<String, dynamic>);
    });
  }
}
