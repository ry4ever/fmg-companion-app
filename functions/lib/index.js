"use strict";
// Re-export functions from modules
// The Firebase emulator will look for files at lib/index.js
// We need the compiled output to be at the right path
Object.defineProperty(exports, "__esModule", { value: true });
exports.version = exports.calculateComposureStreak = exports.stripeWebhook = void 0;
const https_1 = require("firebase-functions/v2/https");
const stripeWebhook_1 = require("./stripeWebhook");
const streakTrigger_1 = require("./streakTrigger");
// Export Stripe webhook handler (Express-based, deployed via Firebase Functions)
// Using v2 onRequest for emulator compatibility
exports.stripeWebhook = (0, https_1.onRequest)({
    region: 'us-central1',
    secrets: ['STRIPE_WEBHOOK_SECRET', 'STRIPE_SECRET_KEY', 'ENCHARGE_API_KEY'],
}, stripeWebhook_1.stripeWebhookHandler);
// Export streak trigger
exports.calculateComposureStreak = streakTrigger_1.streakTrigger;
// Export version info
exports.version = '1.0.0';
