export declare const stripeWebhook: import("firebase-functions/v2/https").HttpsFunction;
export declare const calculateComposureStreak: import("firebase-functions/v2/core").CloudFunction<import("firebase-functions/v2/firestore").FirestoreEvent<import("firebase-functions/v2/firestore").QueryDocumentSnapshot | undefined, {
    athleteUid: string;
    sessionId: string;
}>>;
export declare const version = "1.0.0";
