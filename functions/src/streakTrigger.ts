import * as logger from 'firebase-functions/logger';
import { onDocumentCreated } from 'firebase-functions/v2/firestore';
import { DocumentData } from 'firebase-admin/firestore';
import { updateAthleteStreak, getAthleteUser, getParentUser } from './services/firestore';
import { sendShirtNotification } from './services/encharge';
import { AthleteUser } from './types/models';
import { env } from './utils/env';

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
export const streakTrigger = onDocumentCreated(
  'users/{athleteUid}/telemetry/{sessionId}',
  async (event: any) => {
    const athleteUid = event.params.athleteUid;
    const sessionId = event.params.sessionId;
    const telemetryData = event.data?.data() as any;

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
      const athleteUser = await getAthleteUser(athleteUid);
      if (!athleteUser) {
        logger.warn(`Athlete user not found for uid: ${athleteUid}`);
        return;
      }

      const currentTimestamp = new Date();
      const lastCompleted = athleteUser.last_completed_timestamp
        ? new Date(athleteUser.last_completed_timestamp)
        : null;

      let newStreak: number;
      let updatedFields: Partial<AthleteUser> = {
        last_completed_timestamp: currentTimestamp.toISOString(),
      };

      if (!lastCompleted) {
        // Never completed before - start streak at 1
        newStreak = 1;
        logger.info(`First completion for athlete: ${athleteUid}`);
      } else {
        // Calculate days since last completion using UTC midnight boundaries
        const currentMidnight = new Date(Date.UTC(
          currentTimestamp.getUTCFullYear(),
          currentTimestamp.getUTCMonth(),
          currentTimestamp.getUTCDate()
        ));

        const lastMidnight = new Date(Date.UTC(
          lastCompleted.getUTCFullYear(),
          lastCompleted.getUTCMonth(),
          lastCompleted.getUTCDate()
        ));

        const deltaDays = Math.floor(
          (currentMidnight.getTime() - lastMidnight.getTime()) / (1000 * 60 * 60 * 24)
        );

        if (deltaDays === 0) {
          // Same day - no change
          newStreak = athleteUser.composure_streak;
          logger.info(`Same day completion, streak unchanged: ${newStreak}`);
        } else if (deltaDays === 1) {
          // Consecutive day - increment
          newStreak = athleteUser.composure_streak + 1;
          logger.info(`Consecutive day completion, streak incremented to: ${newStreak}`);
        } else {
          // Gap - reset to 1
          newStreak = 1;
          logger.info(`Gap in training (${deltaDays} days), streak reset to 1`);
        }

        updatedFields.composure_streak = newStreak;
      }

      // Check shirt eligibility
      const shirtTemplateId = env.ENCHARGE_SHIRT_NOTIFICATION_TEMPLATE_ID();
      if (newStreak >= 30 && !athleteUser.shirt_eligible_flag) {
        updatedFields.shirt_eligible_flag = true;
        logger.info(`Athlete ${athleteUid} reached 30-day streak, shirt eligibility triggered`);

        // Notify FMG admin via Encharge
        if (shirtTemplateId && athleteUser.parent_uid) {
          const parentUser = await getParentUser(athleteUser.parent_uid);
          if (parentUser) {
            await sendShirtNotification({
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
      await updateAthleteStreak(athleteUid, updatedFields);
      logger.info(`Updated athlete ${athleteUid}: streak=${newStreak}`);

    } catch (error: any) {
      logger.error(`Error processing streak for athlete ${athleteUid}:`, error);
    }
  }
);