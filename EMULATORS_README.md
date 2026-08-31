# Emulator Setup & Testing Instructions

## Current Status
The backend code compiles successfully, but Firebase CLI installation is failing due to Node version incompatibility (current Node 18, CLI requires >=20).

## Verification Options

### Option 1: Deploy to Test Firebase Project
Use `firebase deploy --only functions` to deploy functions to a test project, then test via webhooks.

### Option 2: Manual Testing via Bash Scripts
Create simple Bash tests that simulate the webhook behavior by calling the functions directly.

### Option 3: Local Node 20 Environment
Set up Node 20 alongside current Node (Node 20.20.2 is available per the npx output).

## Testing Script

Create this script to test webhook behavior:

```bash
#!/bin/bash

WEBHOOK_URL="http://localhost:5001/fmg-test/us-central1/stripeWebhook"
WEBHOOK_SECRET="whsec_test_secret_key"

# Create a test Stripe webhook payload
cat <<EOF > test_webhook.json
{
  "type": "checkout.session.completed",
  "data": {
    "object": {
      "id": "cs_test_session_id",
      "metadata": {
        "parent_email": "test_parent@example.com",
        "child_name": "Test Athlete",
        "plan_tier": "annual"
      }
    }
  }
}
EOF

# Test with signature (in real testing, you'd generate a proper signature)
curl -X POST \
  -H "Content-Type: application/json" \
  -H "stripe-signature: t=timestamp,v1=signature_hash" \
  -d @test_webhook.json \
  "$WEBHOOK_URL" 2>&1
```

## Environment Setup

To use Firebase CLI with Node 20, install Node 20 alongside current Node:

```bash
# Check available Node versions
ls /usr/local/bin/node*

# If Node 20 is available, use it:
/usr/local/bin/node20 -e "console.log('Node 20 working')"

# Or install Node 20 via nvm or similar
nvm install 20
nvm use 20
```

## Testing Plan

1. **Deploy to Test Project**: `firebase deploy --only functions`
2. **Test Webhook**: Use curl with generated signature
3. **Verify Firestore**: Check documents created at `/users/{parentEmail}`
4. **Test Streak Trigger**: Write telemetry and verify streak updates
5. **Parent Portal**: Test login and dashboard functionality

## Manual Testing Commands

```bash
# Check deployed functions
firebase functions:config:set stripe.webhook_secret="whsec_test"

# Test locally with run functions
source .env.functions
gcloud functions serve --host=0.0.0.0 --port=5001

# Or simulate the webhook
curl -X POST http://localhost:5001/stripeWebhook \
  -H "stripe-signature: test" \
  -d '{"test": "payload"}'
```

## Verification Checklist

- [ ] Node 20 installed
- [ ] Firebase CLI working
- [ ] Stripe CLI installed
- [ ] Test Firebase project configured
- [ ] Webhook endpoint responds correctly
- [ ] Firestore documents created with proper schema
- [ ] Encharge API calls logged
- [ ] Streak trigger processes correctly
- [ ] Parent portal authentication works
- [ ] Dashboard displays parent/athlete data