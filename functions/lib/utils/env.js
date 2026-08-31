"use strict";
/**
 * Environment variable helper with validation
 */
Object.defineProperty(exports, "__esModule", { value: true });
exports.env = void 0;
exports.getEnv = getEnv;
exports.getRequiredEnv = getRequiredEnv;
function required(name) {
    const value = process.env[name];
    if (!value) {
        throw new Error(`Missing required environment variable: ${name}`);
    }
    return value;
}
function optional(name, defaultValue) {
    return process.env[name] || defaultValue;
}
function getEnv(name) {
    return process.env[name];
}
function getRequiredEnv(name) {
    return required(name);
}
exports.env = {
    STRIPE_SECRET_KEY: () => required('STRIPE_SECRET_KEY'),
    STRIPE_WEBHOOK_SECRET: () => required('STRIPE_WEBHOOK_SECRET'),
    ENCHARGE_API_KEY: () => required('ENCHARGE_API_KEY'),
    ENCHARGE_WELCOME_TEMPLATE_ID: () => optional('ENCHARGE_WELCOME_TEMPLATE_ID'),
    ENCHARGE_SHIRT_NOTIFICATION_TEMPLATE_ID: () => optional('ENCHARGE_SHIRT_NOTIFICATION_TEMPLATE_ID'),
    GCLOUD_PROJECT: () => optional('GCLOUD_PROJECT', 'fmg-app'),
};
