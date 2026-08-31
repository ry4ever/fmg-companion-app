// TypeScript interfaces matching Firestore schemas

// Parent user document (/users/{parentEmail})
export interface ParentUser {
  uid: string;
  email: string;
  role: 'parent';
  linked_athlete_uid: string;
  subscription_status: 'active';
  plan_tier: 'monthly' | 'annual';
  billing_cycle_anchor: string; // ISO timestamp
}

// Athlete user document (/users/{athleteAuthUid})
export interface AthleteUser {
  uid: string;
  parent_uid: string;
  name: string;
  role: 'athlete';
  assigned_archetype: string;
  onboarding_completed: boolean;
  composure_streak: number;
  last_completed_timestamp: string; // ISO timestamp
  shirt_eligible_flag: boolean;
  shirt_status: 'unclaimed' | 'shipped' | 'delivered';
}

// Telemetry session (/users/{athleteAuthUid}/telemetry/{sessionId})
export interface TelemetrySession {
  session_id: string;
  started_at: string; // ISO timestamp
  completed_at: string; // ISO timestamp
  target_duration_seconds: number;
  foreground_playtime_seconds: number;
  completed_fully: boolean;
}

// Weekly schedule (/users/{athleteAuthUid}/schedules/weekly)
export interface DailySchedule {
  session_id?: string;
  completed: boolean;
}

export interface WeeklySchedule {
  active_week_start: string; // ISO timestamp
  is_custom_mode: boolean;
  days: {
    monday: DailySchedule;
    tuesday: DailySchedule;
    wednesday: DailySchedule;
    thursday: DailySchedule;
    friday: DailySchedule;
    saturday: DailySchedule;
    sunday: DailySchedule;
  };
}

// Encharge API types
export interface EnchargeWelcomePayload {
  email: string;
  magic_link: string;
  template_id: string;
}

export interface EnchargeShirtNotificationPayload {
  email: string;
  archetype: string;
  streak: number;
  template_id: string;
}

// Stripe event payload
export interface StripeMetadata {
  parent_email: string;
  child_name: string;
  plan_tier: 'monthly' | 'annual';
}