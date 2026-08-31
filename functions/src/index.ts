// Re-export functions from modules
// The Firebase emulator will look for files at lib/index.js
// We need the compiled output to be at the right path

import { onRequest } from 'firebase-functions/v2/https';
import { stripeWebhookHandler } from './stripeWebhook';
import { streakTrigger } from './streakTrigger';

// Export Stripe webhook handler (Express-based, deployed via Firebase Functions)
// Using v2 onRequest for emulator compatibility
export const stripeWebhook = onRequest({
  region: 'us-central1',
  secrets: ['STRIPE_WEBHOOK_SECRET', 'STRIPE_SECRET_KEY', 'ENCHARGE_API_KEY'],
}, stripeWebhookHandler);

// Export streak trigger
export const calculateComposureStreak = streakTrigger;

// Export version info
export const version = '1.0.0';