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

export function getFirebaseApp(): FirebaseApp {
  if (!firebaseApp) {
    if (!getApps().length) {
      firebaseApp = initializeApp(getFirebaseConfig());
    } else {
      firebaseApp = getApps()[0];
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
    // Enable offline persistence
    enableIndexedDbPersistence(firestoreInstance).catch(() => {
      // Silently fail - persistence might already be enabled or blocked
    });
  }
  return firestoreInstance;
}

export {
  GoogleAuthProvider,
  signInWithPopup,
  signOut,
  onAuthStateChanged,
  doc,
  getDoc,
};

export type { User };