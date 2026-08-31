'use client';

import { useEffect, useState } from 'react';
import { CompletionGrid } from '@/components/CompletionGrid';
import { ConversationStarter } from '@/components/ConversationStarter';
import { getFirestoreInstance, doc, getDoc } from '@/lib/firebase';
import { ParentUser, AthleteUser, WeeklySchedule } from '@/types/models';
import { useRouter } from 'next/navigation';

export default function DashboardPage() {
  const [parent, setParent] = useState<ParentUser | null>(null);
  const [athlete, setAthlete] = useState<AthleteUser | null>(null);
  const [weeklySchedule, setWeeklySchedule] = useState<WeeklySchedule | null>(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);
  const router = useRouter();

  useEffect(() => {
    const loadUserData = async () => {
      try {
        setLoading(true);
        setError(null);

        const firestore = getFirestoreInstance();

        // Get current user ID from auth (simplified - in practice you'd get from auth state)
        // For demo, we'll use a placeholder or check URL params
        const userId = localStorage.getItem('fmg_user_id') || 'demo_parent@example.com';

        // Get parent document
        const parentDoc = await getDoc(doc(firestore, 'users', userId));
        if (!parentDoc.exists()) {
          throw new Error('Parent account not found');
        }

        const parentData = parentDoc.data() as ParentUser;
        if (parentData.role !== 'parent') {
          throw new Error('Access denied: Parent account required');
        }

        setParent(parentData);

        // Get athlete document
        const athleteDoc = await getDoc(doc(firestore, 'users', parentData.linked_athlete_uid));
        if (!athleteDoc.exists()) {
          throw new Error('Athlete profile not found');
        }

        const athleteData = athleteDoc.data() as AthleteUser;
        setAthlete(athleteData);

        // Get weekly schedule
        const scheduleDoc = await getDoc(
          doc(firestore, 'users', parentData.linked_athlete_uid, 'schedules', 'weekly')
        );
        if (scheduleDoc.exists()) {
          setWeeklySchedule(scheduleDoc.data() as WeeklySchedule);
        }

      } catch (err: any) {
        console.error('Dashboard load error:', err);
        setError(err.message || 'Failed to load dashboard data');
      } finally {
        setLoading(false);
      }
    };

    loadUserData();
  }, [router]);

  // Handle login redirect
  useEffect(() => {
    // Check if user is authenticated via localStorage (simplified)
    const isAuthenticated = !!localStorage.getItem('fmg_user_id');
    if (!isAuthenticated) {
      router.push('/login');
    }
  }, [router]);

  if (loading) {
    return (
      <div className="min-h-screen flex items-center justify-center bg-gray-50">
        <div className="animate-spin rounded-full h-12 w-12 border-4 border-brand-500 border-t-transparent"></div>
      </div>
    );
  }

  if (error) {
    return (
      <div className="min-h-screen flex items-center justify-center bg-gray-50">
        <div className="text-center">
          <h2 className="text-xl font-semibold text-gray-900 mb-4">{error}</h2>
          <button
            onClick={() => router.push('/login')}
            className="px-6 py-3 bg-brand-600 text-white rounded-lg hover:bg-brand-700 transition-colors"
          >
            Return to Login
          </button>
        </div>
      </div>
    );
  }

  if (!parent || !athlete) {
    return (
      <div className="min-h-screen flex items-center justify-center bg-gray-50">
        <div className="text-center">
          <h2 className="text-xl font-semibold text-gray-900 mb-4">Loading dashboard...</h2>
        </div>
      </div>
    );
  }

  return (
    <div className="min-h-screen bg-gray-50">
      <header className="bg-white shadow-sm border-b">
        <div className="max-w-7xl mx-auto px-6 py-4">
          <div className="flex items-center justify-between">
            <div className="flex items-center gap-4">
              <div className="flex-shrink-0">
                <div className="h-10 w-10 bg-gray-200 rounded-full flex items-center justify-center">
                  {athlete.name.charAt(0).toUpperCase()}
                </div>
              </div>
              <div>
                <h1 className="text-2xl font-bold text-gray-900">
                  Welcome, {parent.email.split('@')[0]}
                </h1>
                <p className="text-sm text-gray-500">
                  Monitoring {athlete.name}'s progress
                </p>
              </div>
            </div>
            <div className="flex items-center gap-4">
              <div className="text-sm text-gray-500">
                Plan: {parent.plan_tier === 'annual' ? 'Annual' : 'Monthly'} •{" "}
                Status: <span className="font-medium">{parent.subscription_status}</span>
              </div>
              <button
                onClick={() => {
                  localStorage.removeItem('fmg_user_id');
                  router.push('/login');
                }}
                className="px-4 py-2 bg-gray-100 hover:bg-gray-200 rounded-lg text-sm text-gray-600"
              >
                Sign Out
              </button>
            </div>
          </div>
        </div>
      </header>

      <main className="max-w-7xl mx-auto px-6 py-8">
        <div className="grid gap-6 md:grid-cols-2 lg:grid-cols-3">
          {/* Completion Grid - takes full width on md and up */}
          <div className="col-span-1 md:col-span-2">
            <CompletionGrid
              weeklySchedule={weeklySchedule}
              athleteName={athlete.name}
            />
          </div>

          {/* Conversation Starter */}
          <div className="col-span-1">
            <ConversationStarter
              archetype={athlete.assigned_archetype || 'The Resilient Bounceback'}
              athleteName={athlete.name}
            />
          </div>

          {/* Athlete Stats */}
          <div className="col-span-1">
            <div className="card">
              <h3 className="text-lg font-semibold text-gray-900 mb-4">Athlete Stats</h3>
              <div className="space-y-3">
                <div className="flex items-center justify-between text-sm">
                  <span>Name:</span>
                  <span className="font-medium">{athlete.name}</span>
                </div>
                <div className="flex items-center justify-between text-sm">
                  <span>Archetype:</span>
                  <span className="font-medium capitalize">{athlete.assigned_archetype}</span>
                </div>
                <div className="flex items-center justify-between text-sm">
                  <span>Current Streak:</span>
                  <span className={`font-medium ${
                    athlete.composure_streak >= 30 ? 'text-green-600' : 'text-gray-600'
                  }`}>
                    {athlete.composure_streak} days
                  </span>
                </div>
                <div className="flex items-center justify-between text-sm">
                  <span>Shirt Eligible:</span>
                  <span className={`font-medium ${
                    athlete.shirt_eligible_flag ? 'text-green-600' : 'text-gray-600'
                  }`}>
                    {athlete.shirt_eligible_flag ? 'Yes' : 'No'}
                  </span>
                </div>
                {athlete.shirt_eligible_flag && (
                  <p className="mt-2 text-xs text-green-600">
                    Shirt notification sent to FMG administration!
                  </p>
                )}
              </div>
            </div>
          </div>
        </div>
      </main>
    </div>
  );
}