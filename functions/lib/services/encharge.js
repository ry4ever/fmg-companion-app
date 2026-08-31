"use strict";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.sendWelcomeInvite = sendWelcomeInvite;
exports.sendShirtNotification = sendShirtNotification;
const axios_1 = __importDefault(require("axios"));
const env_1 = require("../utils/env");
let _client = null;
function getEnchargeClient() {
    if (_client)
        return _client;
    const apiKey = (0, env_1.getEnv)('ENCHARGE_API_KEY');
    if (!apiKey) {
        throw new Error('ENCHARGE_API_KEY environment variable is not set');
    }
    _client = axios_1.default.create({
        baseURL: 'https://api.encharge.io/v1',
        headers: {
            'Content-Type': 'application/json',
            'Authorization': `Bearer ${apiKey}`,
        },
    });
    return _client;
}
/**
 * Send a passwordless welcome invite to a parent.
 * POST /emails
 */
async function sendWelcomeInvite(payload) {
    const client = getEnchargeClient();
    try {
        const response = await client.post('/emails', {
            email: payload.email,
            magic_link: payload.magic_link,
            template_id: payload.template_id,
        });
        if (response.status !== 200 && response.status !== 201) {
            throw new Error(`Encharge welcome invite failed: ${response.status}`);
        }
    }
    catch (error) {
        console.error('Encharge welcome invite error:', error.response?.data || error.message);
        throw error;
    }
}
/**
 * Notify FMG administration about a shirt shipment.
 */
async function sendShirtNotification(payload) {
    const client = getEnchargeClient();
    try {
        const response = await client.post('/emails', {
            email: payload.email,
            archetype: payload.archetype,
            streak: payload.streak,
            template_id: payload.template_id,
        });
        if (response.status !== 200 && response.status !== 201) {
            throw new Error(`Encharge shirt notification failed: ${response.status}`);
        }
    }
    catch (error) {
        console.error('Encharge shirt notification error:', error.response?.data || error.message);
        throw error;
    }
}
