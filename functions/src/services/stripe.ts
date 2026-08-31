import Stripe from 'stripe';
import { getEnv } from '../utils/env';

let _stripe: Stripe | null = null;

export function getStripe(): Stripe {
  if (_stripe) return _stripe;
  const secretKey = getEnv('STRIPE_SECRET_KEY');
  if (!secretKey) {
    throw new Error('STRIPE_SECRET_KEY environment variable is not set');
  }
  _stripe = new Stripe(secretKey, {
    apiVersion: '2023-10-16',
    typescript: true,
  });
  return _stripe;
}

export function verifyWebhookSignature(
  payload: string,
  signatureHeader: string,
  webhookSecret: string
): Stripe.Event {
  const stripe = getStripe();
  return stripe.webhooks.constructEvent(
    payload,
    signatureHeader,
    webhookSecret
  );
}