'use client';

import { useState, useEffect } from 'react';
import { useRouter } from 'next/navigation';
import {
  GoogleAuthProvider,
  signInWithPopup,
  onAuthStateChanged,
  getAuth,
} from 'firebase/auth';
import { getFirebaseApp, getInitError, demoLogin } from '@/lib/firebase';

export default function LoginPage() {
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);
  const [configError, setConfigError] = useState<string | null>(null);
  const router = useRouter();

  useEffect(() => {
    // Check Firebase config first
    const initError = getInitError();
    if (initError) {
      setConfigError(initError);
      setLoading(false);
      return;
    }

    try {
      const app = getFirebaseApp();
      const auth = getAuth(app);
      const unsubscribe = onAuthStateChanged(auth, (user) => {
        setLoading(false);
        if (user) {
          localStorage.setItem('fmg_user_id', user.email || user.uid);
          router.push('/dashboard');
        }
      });
      return () => unsubscribe();
    } catch (err: any) {
      setConfigError(err.message || 'Firebase initialization failed');
      setLoading(false);
    }
  }, [router]);

  const handleGoogleSignIn = async () => {
    setError(null);
    try {
      const app = getFirebaseApp();
      const auth = getAuth(app);
      const provider = new GoogleAuthProvider();
      const result = await signInWithPopup(auth, provider);
localStorage.setItem('fmg_user_id', result.user.email || result.user.uid);
    } catch (err: any) {
      console.error('Sign in error:', err);
      if (err.code === 'auth/configuration-not-found') {
        setError('Firebase Auth is not configured. Please enable Email/Password or Google sign-in in Firebase Console.');
      } else {
        setError('Failed to sign in. Please try again.');
      }
    }
  };

  if (loading) {
    return (
      <div className="min-h-screen flex items-center justify-center bg-gray-50">
        <div className="animate-spin rounded-full h-12 w-12 border-4 border-brand-500 border-t-transparent"></div>
      </div>
    );
  }

  return (
    <div className="min-h-screen flex items-center justify-center bg-gray-50 px-4">
      <div className="max-w-md w-full">
        <div className="text-center mb-8">
          <h1 className="text-3xl font-bold text-gray-900">Football Mind Gym</h1>
          <p className="text-gray-600 mt-2">Parent Accountability Portal</p>
        </div>

        {configError && (
          <div className="mb-4 p-4 bg-amber-50 border border-amber-200 text-amber-800 rounded-lg">
            <p className="font-medium">Configuration Required</p>
            <p className="text-sm mt-1">{configError}</p>
            <p className="text-sm mt-2">
              Update <code className="bg-amber-100 px-1 rounded">web/.env.production</code> with your Firebase project values.
            </p>
          </div>
        )}

        <div className="card">
          {error && (
            <div className="mb-4 p-4 bg-red-50 border border-red-200 text-red-700 rounded-lg">
              {error}
            </div>
          )}

          <button
            onClick={handleGoogleSignIn}
            disabled={loading || !!configError}
            className="w-full py-3 px-4 bg-white border border-gray-300 rounded-lg font-medium text-gray-700 hover:bg-gray-50 focus:outline-none focus:ring-2 focus:ring-brand-500 focus:border-brand-500 transition-colors flex items-center justify-center gap-3 disabled:opacity-50 disabled:cursor-not-allowed"
          >
            <svg className="w-5 h-5" viewBox="0 0 24 24">
              <path
                fill="currentColor"
                d="M22.56 12.25c0-.78-.07-1.53-.2-2.25H12v4.26h5.92c-.26 1.37-1.04 2.53-2.21 3.31v2.77h3.57c2.08-1.92 3.28-4.74 3.28-8.09z"
              />
              <path
                fill="currentColor"
                d="M12 23c2.97 0 5.46-.98 7.28-2.66l-3.57-2.77c-.98.66-2.23 1.06-3.71 1.06-2.86 0-5.29-1.93-6.16-4.53H2.18v2.84C3.99 20.53 7.7 23 12 23z"
              />
              <path
                fill="currentColor"
                d="M5.84 14.09c-.22-.66-.35-1.36-.35-2.09s.13-1.43.35-2.09V7.07H2.18C1.43 8.55 1 10.22 1 12s.43 3.45 1.18 4.93l2.85-2.22.81-.62z"
              />
              <path
                fill="currentColor"
                d="M12 5.38c1.62 0 3.06.56 4.21 1.64l3.15-3.15C17.45 2.09 14.97 1 12 1 7.7 1 3.99 3.47 2.18 7.07l3.66 2.84c.87-2.6 3.3-4.53 6.16-4.53z"
              />
            </svg>
            Continue with Google
          </button>

          <p className="text-center text-sm text-gray-500 mt-4">
            Only parent accounts with active subscriptions can access the portal.
          </p>

          <button
            onClick={() => demoLogin()}
            disabled={!!configError}
            className="w-full mt-3 py-3 px-4 bg-brand-600 text-white rounded-lg font-medium hover:bg-brand-700 focus:outline-none focus:ring-2 focus:ring-brand-500 focus:border-brand-500 transition-colors disabled:opacity-50 disabled:cursor-not-allowed"
          >
            Try Demo Mode
          </button>
        </div>
      </div>
    </div>
  );
}
