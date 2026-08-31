/**
 * Firestore Trigger: Calculate composure streak on telemetry creation.
 *
 * Triggered when a telemetry session is written to:
 * /users/{athleteUid}/telemetry/{sessionId}
 *
 * Logic:
 * - Compare current timestamp with last_completed_timestamp
 * - Delta === 1 day: increment streak by 1
 * - Delta > 1 day: reset streak to 1
 * - Delta === 0: no change (already completed today)
 * - If streak >= 30: set shirt_eligible_flag and notify FMG admin
 */
export declare const streakTrigger: import("firebase-functions/v2/core").CloudFunction<import("firebase-functions/v2/firestore").FirestoreEvent<import("firebase-functions/v2/firestore").QueryDocumentSnapshot | undefined, {
    athleteUid: string;
    sessionId: string;
}>>;
