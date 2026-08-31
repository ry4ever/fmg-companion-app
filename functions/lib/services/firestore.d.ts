import { ParentUser, AthleteUser, TelemetrySession, WeeklySchedule } from '../types/models';
export declare function getParentUser(parentEmail: string): Promise<ParentUser | null>;
export declare function upsertParentUser(parentEmail: string, data: ParentUser): Promise<void>;
export declare function getAthleteUser(athleteUid: string): Promise<AthleteUser | null>;
export declare function upsertAthleteUser(athleteUid: string, data: AthleteUser): Promise<void>;
export declare function updateAthleteStreak(athleteUid: string, updates: Partial<AthleteUser>): Promise<void>;
export declare function writeTelemetry(athleteUid: string, sessionId: string, data: TelemetrySession): Promise<void>;
export declare function getWeeklySchedule(athleteUid: string): Promise<WeeklySchedule | null>;
export declare function setWeeklySchedule(athleteUid: string, data: WeeklySchedule): Promise<void>;
