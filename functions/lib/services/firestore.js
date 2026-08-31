"use strict";
var __createBinding = (this && this.__createBinding) || (Object.create ? (function(o, m, k, k2) {
    if (k2 === undefined) k2 = k;
    var desc = Object.getOwnPropertyDescriptor(m, k);
    if (!desc || ("get" in desc ? !m.__esModule : desc.writable || desc.configurable)) {
      desc = { enumerable: true, get: function() { return m[k]; } };
    }
    Object.defineProperty(o, k2, desc);
}) : (function(o, m, k, k2) {
    if (k2 === undefined) k2 = k;
    o[k2] = m[k];
}));
var __setModuleDefault = (this && this.__setModuleDefault) || (Object.create ? (function(o, v) {
    Object.defineProperty(o, "default", { enumerable: true, value: v });
}) : function(o, v) {
    o["default"] = v;
});
var __importStar = (this && this.__importStar) || (function () {
    var ownKeys = function(o) {
        ownKeys = Object.getOwnPropertyNames || function (o) {
            var ar = [];
            for (var k in o) if (Object.prototype.hasOwnProperty.call(o, k)) ar[ar.length] = k;
            return ar;
        };
        return ownKeys(o);
    };
    return function (mod) {
        if (mod && mod.__esModule) return mod;
        var result = {};
        if (mod != null) for (var k = ownKeys(mod), i = 0; i < k.length; i++) if (k[i] !== "default") __createBinding(result, mod, k[i]);
        __setModuleDefault(result, mod);
        return result;
    };
})();
Object.defineProperty(exports, "__esModule", { value: true });
exports.getParentUser = getParentUser;
exports.upsertParentUser = upsertParentUser;
exports.getAthleteUser = getAthleteUser;
exports.upsertAthleteUser = upsertAthleteUser;
exports.updateAthleteStreak = updateAthleteStreak;
exports.writeTelemetry = writeTelemetry;
exports.getWeeklySchedule = getWeeklySchedule;
exports.setWeeklySchedule = setWeeklySchedule;
const admin = __importStar(require("firebase-admin"));
let _db = null;
function getDb() {
    if (_db)
        return _db;
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
async function getParentUser(parentEmail) {
    const doc = await db.collection('users').doc(parentEmail).get();
    if (!doc.exists)
        return null;
    return doc.data();
}
async function upsertParentUser(parentEmail, data) {
    await db.collection('users').doc(parentEmail).set(data, { merge: true });
}
// --- Athlete User Operations ---
async function getAthleteUser(athleteUid) {
    const doc = await db.collection('users').doc(athleteUid).get();
    if (!doc.exists)
        return null;
    return doc.data();
}
async function upsertAthleteUser(athleteUid, data) {
    await db.collection('users').doc(athleteUid).set(data, { merge: true });
}
async function updateAthleteStreak(athleteUid, updates) {
    await db.collection('users').doc(athleteUid).update(updates);
}
// --- Telemetry Operations ---
async function writeTelemetry(athleteUid, sessionId, data) {
    await db
        .collection('users')
        .doc(athleteUid)
        .collection('telemetry')
        .doc(sessionId)
        .set(data);
}
// --- Weekly Schedule Operations ---
async function getWeeklySchedule(athleteUid) {
    const doc = await db.collection('users').doc(athleteUid).collection('schedules').doc('weekly').get();
    if (!doc.exists)
        return null;
    return doc.data();
}
async function setWeeklySchedule(athleteUid, data) {
    await db
        .collection('users')
        .doc(athleteUid)
        .collection('schedules')
        .doc('weekly')
        .set(data);
}
