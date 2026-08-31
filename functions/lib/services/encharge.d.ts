import { EnchargeWelcomePayload, EnchargeShirtNotificationPayload } from '../types/models';
/**
 * Send a passwordless welcome invite to a parent.
 * POST /emails
 */
export declare function sendWelcomeInvite(payload: EnchargeWelcomePayload): Promise<void>;
/**
 * Notify FMG administration about a shirt shipment.
 */
export declare function sendShirtNotification(payload: EnchargeShirtNotificationPayload): Promise<void>;
