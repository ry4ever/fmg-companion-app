"use strict";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.getStripe = getStripe;
exports.verifyWebhookSignature = verifyWebhookSignature;
const stripe_1 = __importDefault(require("stripe"));
const env_1 = require("../utils/env");
let _stripe = null;
function getStripe() {
    if (_stripe)
        return _stripe;
    const secretKey = (0, env_1.getEnv)('STRIPE_SECRET_KEY');
    if (!secretKey) {
        throw new Error('STRIPE_SECRET_KEY environment variable is not set');
    }
    _stripe = new stripe_1.default(secretKey, {
        apiVersion: '2023-10-16',
        typescript: true,
    });
    return _stripe;
}
function verifyWebhookSignature(payload, signatureHeader, webhookSecret) {
    const stripe = getStripe();
    return stripe.webhooks.constructEvent(payload, signatureHeader, webhookSecret);
}
