export interface ParentUser {
    uid: string;
    email: string;
    role: 'parent';
    linked_athlete_uid: string;
    subscription_status: 'active';
    plan_tier: 'monthly' | 'annual';
    billing_cycle_anchor: string;
}
export interface AthleteUser {
    uid: string;
    parent_uid: string;
    name: string;
    role: 'athlete';
    assigned_archetype: string;
    onboarding_completed: boolean;
    composure_streak: number;
    last_completed_timestamp: string;
    shirt_eligible_flag: boolean;
    shirt_status: 'unclaimed' | 'shipped' | 'delivered';
}
export interface TelemetrySession {
    session_id: string;
    started_at: string;
    completed_at: string;
    target_duration_seconds: number;
    foreground_playtime_seconds: number;
    completed_fully: boolean;
}
export interface DailySchedule {
    session_id?: string;
    completed: boolean;
}
export interface WeeklySchedule {
    active_week_start: string;
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
export interface StripeMetadata {
    parent_email: string;
    child_name: string;
    plan_tier: 'monthly' | 'annual';
}
