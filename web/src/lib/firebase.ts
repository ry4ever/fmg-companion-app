import { initializeApp, getApps, FirebaseApp } from 'firebase/app';
import {
  getAuth,
  Auth,
  GoogleAuthProvider,
  signInWithPopup,
  signOut,
  onAuthStateChanged,
  User,
} from 'firebase/auth';
import {
  getFirestore,
  Firestore,
  doc,
  getDoc,
  enableIndexedDbPersistence,
} from 'firebase/firestore';

let firebaseApp: FirebaseApp | null = null;
let authInstance: Auth | null = null;
let firestoreInstance: Firestore | null = null;
let initError: string | null = null;

function getFirebaseConfig() {
  return {
    apiKey: process.env.NEXT_PUBLIC_FIREBASE_API_KEY,
    authDomain: process.env.NEXT_PUBLIC_FIREBASE_AUTH_DOMAIN,
    projectId: process.env.NEXT_PUBLIC_FIREBASE_PROJECT_ID,
    storageBucket: process.env.NEXT_PUBLIC_FIREBASE_STORAGE_BUCKET,
    messagingSenderId: process.env.NEXT_PUBLIC_FIREBASE_MESSAGING_SENDER_ID,
    appId: process.env.NEXT_PUBLIC_FIREBASE_APP_ID,
  };
}

function isConfigValid(config: ReturnType<typeof getFirebaseConfig>) {
  return Boolean(
    config.apiKey &&
    config.authDomain &&
    config.projectId &&
    config.appId &&
    !config.apiKey.includes('demo-api-key') &&
    !config.appId.includes('0000000000000000')
  );
}

export function getInitError(): string | null {
  return initError;
}

export function getFirebaseApp(): FirebaseApp {
  if (!firebaseApp) {
    try {
      const config = getFirebaseConfig();
      if (!isConfigValid(config)) {
        initError = 'Firebase config is not set. Update web/.env.production with real values from Firebase Console.';
        throw new Error(initError);
      }
      if (!getApps().length) {
        firebaseApp = initializeApp(config);
      } else {
        firebaseApp = getApps()[0] as FirebaseApp;
      }
    } catch (err: any) {
      initError = err.message;
      throw err;
    }
  }
  return firebaseApp;
}

export function getAuthInstance(): Auth {
  if (!authInstance) {
    getFirebaseApp();
    authInstance = getAuth();
  }
  return authInstance;
}

export function getFirestoreInstance(): Firestore {
  if (!firestoreInstance) {
    getFirebaseApp();
    firestoreInstance = getFirestore();
    enableIndexedDbPersistence(firestoreInstance).catch(() => {
      // Silently fail - persistence might already be enabled or blocked
    });
  }
  return firestoreInstance;
}

// Demo data for development without Firebase configuration
export const DEMO_PARENT_DATA = {
  uid: 'demo_parent@example.com',
  email: 'demo_parent@example.com',
  role: 'parent',
  linked_athlete_uid: 'demo_athlete_001',
  subscription_status: 'active',
  plan_tier: 'annual',
  billing_cycle_anchor: Date.now(),
};

export const DEMO_ATHLETE_DATA = {
  uid: 'demo_athlete_001',
  parent_uid: 'demo_parent@example.com',
  name: 'Taylor Rodriguez',
  role: 'athlete',
  assigned_archetype: 'The Resilient Bounceback',
  onboarding_completed: true,
  composure_streak: 3,
  last_completed_timestamp: Date.now(),
  shirt_eligible_flag: false,
  shirt_status: 'none',
};

export const DEMO_WEEKLY_SCHEDULE = {
  active_week_start: new Date('2026-09-08').getTime(),
  is_custom_mode: false,
  days: {
    monday: { completed: true, session_id: 'session_monday_workout' },
    tuesday: { completed: true, session_id: 'session_tuesday_workout' },
    wednesday: { completed: true, session_id: 'session_wednesday_workout' },
    thursday: { completed: false },
    friday: { completed: false },
    saturday: { completed: false },
    sunday: { completed: false },
  },
};

export const isDemoMode = () => {
  // Demo mode only when there's no API key or the key is explicitly the demo-placeholder
  return !process.env.NEXT_PUBLIC_FIREBASE_API_KEY ||
         process.env.NEXT_PUBLIC_FIREBASE_API_KEY.includes('demo-api-key');
};

export const demoLogin = (userEmail: string = 'demo_parent@example.com') => {
  localStorage.setItem('fmg_user_id', userEmail);
  window.location.href = '/dashboard';
};

export {
  GoogleAuthProvider,
  signInWithPopup,
  signOut,
  onAuthStateChanged,
  doc,
  getDoc,
};

export type { User };