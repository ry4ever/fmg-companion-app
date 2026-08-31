/**
 * Environment variable helper with validation
 */
export declare function getEnv(name: string): string | undefined;
export declare function getRequiredEnv(name: string): string;
export declare const env: {
    readonly STRIPE_SECRET_KEY: () => string;
    readonly STRIPE_WEBHOOK_SECRET: () => string;
    readonly ENCHARGE_API_KEY: () => string;
    readonly ENCHARGE_WELCOME_TEMPLATE_ID: () => string | undefined;
    readonly ENCHARGE_SHIRT_NOTIFICATION_TEMPLATE_ID: () => string | undefined;
    readonly GCLOUD_PROJECT: () => string | undefined;
};
