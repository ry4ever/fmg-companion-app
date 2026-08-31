import Stripe from 'stripe';
export declare function getStripe(): Stripe;
export declare function verifyWebhookSignature(payload: string, signatureHeader: string, webhookSecret: string): Stripe.Event;
