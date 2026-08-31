/**
 * Environment variable helper with validation
 */

function required(name: string): string {
  const value = process.env[name];
  if (!value) {
    throw new Error(`Missing required environment variable: ${name}`);
  }
  return value;
}

function optional(name: string, defaultValue?: string): string | undefined {
  return process.env[name] || defaultValue;
}

export function getEnv(name: string): string | undefined {
  return process.env[name];
}

export function getRequiredEnv(name: string): string {
  return required(name);
}

export const env = {
  STRIPE_SECRET_KEY: () => required('STRIPE_SECRET_KEY'),
  STRIPE_WEBHOOK_SECRET: () => required('STRIPE_WEBHOOK_SECRET'),
  ENCHARGE_API_KEY: () => required('ENCHARGE_API_KEY'),
  ENCHARGE_WELCOME_TEMPLATE_ID: () => optional('ENCHARGE_WELCOME_TEMPLATE_ID'),
  ENCHARGE_SHIRT_NOTIFICATION_TEMPLATE_ID: () => optional('ENCHARGE_SHIRT_NOTIFICATION_TEMPLATE_ID'),
  GCLOUD_PROJECT: () => optional('GCLOUD_PROJECT', 'fmg-app'),
} as const;