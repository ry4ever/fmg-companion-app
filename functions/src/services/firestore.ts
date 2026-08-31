import * as admin from 'firebase-admin';
import { ParentUser, AthleteUser, TelemetrySession, WeeklySchedule } from '../types/models';

let _db: admin.firestore.Firestore | null = null;

function getDb(): admin.firestore.Firestore {
  if (_db) return _db;
  if (!admin.apps.length) {
    admin.initializeApp({
      credential: admin.credential.applicationDefault(),
      databaseURL: `https://${process.env.GCLOUD_PROJECT || 'fmg-app'}.firestore.io`,
    });
  }
  _db = admin.firestore();
  return _db;
}

const db = getDb();

// --- Parent User Operations ---

export async function getParentUser(parentEmail: string): Promise<ParentUser | null> {
  const doc = await db.collection('users').doc(parentEmail).get();
  if (!doc.exists) return null;
  return doc.data() as ParentUser;
}

export async function upsertParentUser(parentEmail: string, data: ParentUser): Promise<void> {
  await db.collection('users').doc(parentEmail).set(data, { merge: true });
}

// --- Athlete User Operations ---

export async function getAthleteUser(athleteUid: string): Promise<AthleteUser | null> {
  const doc = await db.collection('users').doc(athleteUid).get();
  if (!doc.exists) return null;
  return doc.data() as AthleteUser;
}

export async function upsertAthleteUser(athleteUid: string, data: AthleteUser): Promise<void> {
  await db.collection('users').doc(athleteUid).set(data, { merge: true });
}

export async function updateAthleteStreak(
  athleteUid: string,
  updates: Partial<AthleteUser>
): Promise<void> {
  await db.collection('users').doc(athleteUid).update(updates);
}

// --- Telemetry Operations ---

export async function writeTelemetry(
  athleteUid: string,
  sessionId: string,
  data: TelemetrySession
): Promise<void> {
  await db
    .collection('users')
    .doc(athleteUid)
    .collection('telemetry')
    .doc(sessionId)
    .set(data);
}

// --- Weekly Schedule Operations ---

export async function getWeeklySchedule(athleteUid: string): Promise<WeeklySchedule | null> {
  const doc = await db.collection('users').doc(athleteUid).collection('schedules').doc('weekly').get();
  if (!doc.exists) return null;
  return doc.data() as WeeklySchedule;
}

export async function setWeeklySchedule(athleteUid: string, data: WeeklySchedule): Promise<void> {
  await db
    .collection('users')
    .doc(athleteUid)
    .collection('schedules')
    .doc('weekly')
    .set(data);
}