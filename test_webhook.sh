#!/bin/bash

# Test webhook functionality using curl
# This simulates the Stripe webhook request

WEBHOOK_URL="http://localhost:5001/fmg-test/us-central1/stripeWebhook"
WEBHOOK_SECRET="whsec_test_secret_key"

# Create a test Stripe webhook payload with metadata
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

# Test with a dummy signature (for local testing)
# In production, you would generate a proper Stripe signature using the secret key
SIGNATURE="t=1699276800,v1=dummy_signature_for_testing"

echo "Testing webhook endpoint: $WEBHOOK_URL"
echo "Signature: $SIGNATURE"

echo "\n=== Testing webhook ==="
curl -X POST \
  -H "Content-Type: application/json" \
  -H "stripe-signature: $SIGNATURE" \
  -d @test_webhook.json \
  "$WEBHOOK_URL"

echo "\n=== Checking if parent document was created ==="
# Check if parent document was created in Firestore
# This would require accessing the Firestore emulator or checking deployed functions

echo "\n=== Checking if athlete document was created ==="
# Similarly check athlete document

echo "\n=== Test completed ==="