"use strict";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.stripeWebhookHandler = stripeWebhookHandler;
const express_1 = __importDefault(require("express"));
const stripe_1 = require("./services/stripe");
const encharge_1 = require("./services/encharge");
const firestore_1 = require("./services/firestore");
const env_1 = require("./utils/env");
const uuid_1 = require("uuid");
const app = (0, express_1.default)();
// Raw body parser for Stripe signature verification
app.use(express_1.default.raw({ type: 'application/json' }));
async function stripeWebhookHandler(req, res) {
    const signature = req.headers['stripe-signature'];
    const webhookSecret = env_1.env.STRIPE_WEBHOOK_SECRET();
    if (!signature) {
        console.error('Missing stripe-signature header');
        res.status(400).send('Missing stripe-signature header');
        return;
    }
    let event;
    try {
        const payload = req.body.toString('utf8');
        event = (0, stripe_1.verifyWebhookSignature)(payload, signature, webhookSecret);
    }
    catch (err) {
        console.error('Webhook signature verification failed:', err.message);
        res.status(400).send(`Webhook Error: ${err.message}`);
        return;
    }
    if (event.type !== 'checkout.session.completed') {
        console.log(`Ignored event type: ${event.type}`);
        res.status(200).send('OK');
        return;
    }
    const session = event.data.object;
    const metadata = session.metadata;
    if (!metadata?.parent_email || !metadata?.child_name || !metadata?.plan_tier) {
        console.error('Missing required metadata:', metadata);
        res.status(400).send('Missing required metadata');
        return;
    }
    const { parent_email, child_name, plan_tier } = metadata;
    try {
        // Generate a unique athlete UID (in production, this could be a Firebase Auth UID)
        const athleteUid = `athlete_${(0, uuid_1.v4)().slice(0, 8)}`;
        const parentUid = `parent_${(0, uuid_1.v4)().slice(0, 8)}`;
        const billingAnchor = new Date().toISOString();
        // Create parent user document
        const parentUser = {
            uid: parentUid,
            email: parent_email,
            role: 'parent',
            linked_athlete_uid: athleteUid,
            subscription_status: 'active',
            plan_tier,
            billing_cycle_anchor: billingAnchor,
        };
        // Create athlete user document (onboarding_completed = false initially)
        const athleteUser = {
            uid: athleteUid,
            parent_uid: parentUid,
            name: child_name,
            role: 'athlete',
            assigned_archetype: '', // Will be set after onboarding
            onboarding_completed: false,
            composure_streak: 0,
            last_completed_timestamp: '',
            shirt_eligible_flag: false,
            shirt_status: 'unclaimed',
        };
        await (0, firestore_1.upsertParentUser)(parent_email, parentUser);
        await (0, firestore_1.upsertAthleteUser)(athleteUid, athleteUser);
        console.log(`Provisioned parent: ${parent_email} and athlete: ${child_name} (${athleteUid})`);
        // Trigger Encharge welcome email with magic link
        const welcomeTemplateId = env_1.env.ENCHARGE_WELCOME_TEMPLATE_ID();
        if (welcomeTemplateId) {
            // In a real implementation, this magic link would be generated via Firebase Auth
            // and point to the Flutter app's onboarding deep link
            const magicLink = `https://app.fmg.com/onboard?token=${(0, uuid_1.v4)()}`;
            await (0, encharge_1.sendWelcomeInvite)({
                email: parent_email,
                magic_link: magicLink,
                template_id: welcomeTemplateId,
            });
            console.log(`Sent welcome invite to ${parent_email}`);
        }
        else {
            console.warn('ENCHARGE_WELCOME_TEMPLATE_ID not set, skipping welcome email');
        }
        res.status(200).send('OK');
    }
    catch (error) {
        console.error('Stripe webhook processing error:', error);
        res.status(500).send('Internal server error');
    }
}
exports.default = app;
