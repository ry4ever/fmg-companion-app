import axios, { AxiosInstance } from 'axios';
import { getEnv } from '../utils/env';
import { EnchargeWelcomePayload, EnchargeShirtNotificationPayload } from '../types/models';

let _client: AxiosInstance | null = null;

function getEnchargeClient(): AxiosInstance {
  if (_client) return _client;
  const apiKey = getEnv('ENCHARGE_API_KEY');
  if (!apiKey) {
    throw new Error('ENCHARGE_API_KEY environment variable is not set');
  }
  _client = axios.create({
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
export async function sendWelcomeInvite(payload: EnchargeWelcomePayload): Promise<void> {
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
  } catch (error: any) {
    console.error('Encharge welcome invite error:', error.response?.data || error.message);
    throw error;
  }
}

/**
 * Notify FMG administration about a shirt shipment.
 */
export async function sendShirtNotification(payload: EnchargeShirtNotificationPayload): Promise<void> {
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
  } catch (error: any) {
    console.error('Encharge shirt notification error:', error.response?.data || error.message);
    throw error;
  }
}