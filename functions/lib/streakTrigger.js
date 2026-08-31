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
exports.streakTrigger = void 0;
const logger = __importStar(require("firebase-functions/logger"));
const firestore_1 = require("firebase-functions/v2/firestore");
const firestore_2 = require("./services/firestore");
const encharge_1 = require("./services/encharge");
const env_1 = require("./utils/env");
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
exports.streakTrigger = (0, firestore_1.onDocumentCreated)('users/{athleteUid}/telemetry/{sessionId}', async (event) => {
    const athleteUid = event.params.athleteUid;
    const sessionId = event.params.sessionId;
    const telemetryData = event.data?.data();
    if (!telemetryData) {
        logger.warn('No telemetry data in event');
        return;
    }
    if (!telemetryData.completed_fully) {
        logger.info('Telemetry session not completed fully, skipping streak update');
        return;
    }
    logger.info(`Processing streak for athlete: ${athleteUid}, session: ${sessionId}`);
    try {
        const athleteUser = await (0, firestore_2.getAthleteUser)(athleteUid);
        if (!athleteUser) {
            logger.warn(`Athlete user not found for uid: ${athleteUid}`);
            return;
        }
        const currentTimestamp = new Date();
        const lastCompleted = athleteUser.last_completed_timestamp
            ? new Date(athleteUser.last_completed_timestamp)
            : null;
        let newStreak;
        let updatedFields = {
            last_completed_timestamp: currentTimestamp.toISOString(),
        };
        if (!lastCompleted) {
            // Never completed before - start streak at 1
            newStreak = 1;
            logger.info(`First completion for athlete: ${athleteUid}`);
        }
        else {
            // Calculate days since last completion using UTC midnight boundaries
            const currentMidnight = new Date(Date.UTC(currentTimestamp.getUTCFullYear(), currentTimestamp.getUTCMonth(), currentTimestamp.getUTCDate()));
            const lastMidnight = new Date(Date.UTC(lastCompleted.getUTCFullYear(), lastCompleted.getUTCMonth(), lastCompleted.getUTCDate()));
            const deltaDays = Math.floor((currentMidnight.getTime() - lastMidnight.getTime()) / (1000 * 60 * 60 * 24));
            if (deltaDays === 0) {
                // Same day - no change
                newStreak = athleteUser.composure_streak;
                logger.info(`Same day completion, streak unchanged: ${newStreak}`);
            }
            else if (deltaDays === 1) {
                // Consecutive day - increment
                newStreak = athleteUser.composure_streak + 1;
                logger.info(`Consecutive day completion, streak incremented to: ${newStreak}`);
            }
            else {
                // Gap - reset to 1
                newStreak = 1;
                logger.info(`Gap in training (${deltaDays} days), streak reset to 1`);
            }
            updatedFields.composure_streak = newStreak;
        }
        // Check shirt eligibility
        const shirtTemplateId = env_1.env.ENCHARGE_SHIRT_NOTIFICATION_TEMPLATE_ID();
        if (newStreak >= 30 && !athleteUser.shirt_eligible_flag) {
            updatedFields.shirt_eligible_flag = true;
            logger.info(`Athlete ${athleteUid} reached 30-day streak, shirt eligibility triggered`);
            // Notify FMG admin via Encharge
            if (shirtTemplateId && athleteUser.parent_uid) {
                const parentUser = await (0, firestore_2.getParentUser)(athleteUser.parent_uid);
                if (parentUser) {
                    await (0, encharge_1.sendShirtNotification)({
                        email: parentUser.email,
                        archetype: athleteUser.assigned_archetype,
                        streak: newStreak,
                        template_id: shirtTemplateId,
                    });
                    logger.info(`Shirt notification sent to ${parentUser.email}`);
                }
            }
        }
        // Apply updates
        await (0, firestore_2.updateAthleteStreak)(athleteUid, updatedFields);
        logger.info(`Updated athlete ${athleteUid}: streak=${newStreak}`);
    }
    catch (error) {
        logger.error(`Error processing streak for athlete ${athleteUid}:`, error);
    }
});
