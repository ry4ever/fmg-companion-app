import express from 'express';
import { Request, Response } from 'express';
import { verifyWebhookSignature } from './services/stripe';
import { sendWelcomeInvite } from './services/encharge';
import { upsertParentUser, upsertAthleteUser } from './services/firestore';
import { ParentUser, AthleteUser, StripeMetadata } from './types/models';
import { env } from './utils/env';
import { v4 as uuidv4 } from 'uuid';

const app = express();

// Raw body parser for Stripe signature verification
app.use(express.raw({ type: 'application/json' }));

export async function stripeWebhookHandler(req: Request, res: Response): Promise<void> {
  const signature = req.headers['stripe-signature'] as string;
  const webhookSecret = env.STRIPE_WEBHOOK_SECRET();

  if (!signature) {
    console.error('Missing stripe-signature header');
    res.status(400).send('Missing stripe-signature header');
    return;
  }

  let event;
  try {
    const payload = req.body.toString('utf8');
    event = verifyWebhookSignature(payload, signature, webhookSecret);
  } catch (err: any) {
    console.error('Webhook signature verification failed:', err.message);
    res.status(400).send(`Webhook Error: ${err.message}`);
    return;
  }

  if (event.type !== 'checkout.session.completed') {
    console.log(`Ignored event type: ${event.type}`);
    res.status(200).send('OK');
    return;
  }

  const session = event.data.object as any;
  const metadata = session.metadata as StripeMetadata;

  if (!metadata?.parent_email || !metadata?.child_name || !metadata?.plan_tier) {
    console.error('Missing required metadata:', metadata);
    res.status(400).send('Missing required metadata');
    return;
  }

  const { parent_email, child_name, plan_tier } = metadata;

  try {
    // Generate a unique athlete UID (in production, this could be a Firebase Auth UID)
    const athleteUid = `athlete_${uuidv4().slice(0, 8)}`;
    const parentUid = `parent_${uuidv4().slice(0, 8)}`;
    const billingAnchor = new Date().toISOString();

    // Create parent user document
    const parentUser: ParentUser = {
      uid: parentUid,
      email: parent_email,
      role: 'parent',
      linked_athlete_uid: athleteUid,
      subscription_status: 'active',
      plan_tier,
      billing_cycle_anchor: billingAnchor,
    };

    // Create athlete user document (onboarding_completed = false initially)
    const athleteUser: AthleteUser = {
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

    await upsertParentUser(parent_email, parentUser);
    await upsertAthleteUser(athleteUid, athleteUser);

    console.log(`Provisioned parent: ${parent_email} and athlete: ${child_name} (${athleteUid})`);

    // Trigger Encharge welcome email with magic link
    const welcomeTemplateId = env.ENCHARGE_WELCOME_TEMPLATE_ID();
    if (welcomeTemplateId) {
      // In a real implementation, this magic link would be generated via Firebase Auth
      // and point to the Flutter app's onboarding deep link
      const magicLink = `https://app.fmg.com/onboard?token=${uuidv4()}`;
      await sendWelcomeInvite({
        email: parent_email,
        magic_link: magicLink,
        template_id: welcomeTemplateId,
      });
      console.log(`Sent welcome invite to ${parent_email}`);
    } else {
      console.warn('ENCHARGE_WELCOME_TEMPLATE_ID not set, skipping welcome email');
    }

    res.status(200).send('OK');
  } catch (error: any) {
    console.error('Stripe webhook processing error:', error);
    res.status(500).send('Internal server error');
  }
}

export default app;