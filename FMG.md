You are an expert Senior Full-Stack Mobile and Cloud Engineer specializing in Flutter, Node.js, and serverless Firebase architecture (Firestore, Cloud Functions, and Auth). 

Your objective is to implement the end-to-end codebase for the "My Gym" companion experience inside the Football Mind Gym (FMG) ecosystem. This system is designed around a Decoupled Hybrid Stack to completely bypass mobile App Store transaction fees by keeping billing strictly on the web, using serverless webhooks to provision native app views.

Follow the technical specifications, database schemas, and implementation rules below to generate clean, production-ready, modular code.

\---

\#\#\# TECH STACK REQUIREMENTS  
1\. Client Mobile Application: Flutter SDK (Dart)  
2\. Local Mobile Database: SQLite / Hive (Dart)  
3\. Backend Serverless Stack: Firebase Auth, Cloud Firestore (NoSQL), Node.js Firebase Cloud Functions  
4\. Payments & Web Billing: Stripe Node.js SDK (integrated with Next.js web checkout)  
5\. Marketing Automation: Encharge REST API integration

\---

\#\#\# MODULE 1: NODE.JS STRIPE WEBHOOK (FIREBASE CLOUD FUNCTION)  
Write a Firebase Cloud Function in Node.js (using Express) to serve as a secure HTTPS POST endpoint at \`/stripeWebhook\`.  
\- It must capture the secure Stripe signature and verify the \`checkout.session.completed\` event.  
\- Parse the session payload metadata to retrieve \`parent\_email\`, \`child\_name\`, and \`plan\_tier\` ('monthly' or 'annual').  
\- If verification passes:  
  1\. Dynamically provision a linked parent-athlete profile structure in Firestore under \`/users/\` using the parent's email as the document root.  
  2\. Call the Encharge API (\`POST https://api.encharge.io/v1/emails\`) to trigger a passwordless welcome invite containing a magic-link setup directly to the parent's email.  
\- Exclude billing pages and native store payment overlays to retain 100% of the web-to-app checkout revenue.

\---

\#\#\# MODULE 2: FIRESTORE DATABASE SCHEMAS  
Implement and enforce the following exact JSON schemas.

\#\#\#\# Document: \`/users/{parentEmail\_doc}\`  
{  
  "uid": "parent\_unique\_id\_string",  
  "email": "parent\_email@example.com",  
  "role": "parent",  
  "linked\_athlete\_uid": "athlete\_auth\_uid\_string",  
  "subscription\_status": "active",  
  "plan\_tier": "annual",  
  "billing\_cycle\_anchor": "2026-08-21T00:00:00Z"  
}

\#\#\#\# Document: \`/users/{athleteAuthUid\_doc}\`  
{  
  "uid": "athlete\_auth\_uid\_string",  
  "parent\_uid": "parent\_unique\_id\_string",  
  "name": "Marcus",  
  "role": "athlete",  
  "assigned\_archetype": "The Resilient Bounceback",  
  "onboarding\_completed": true,  
  "composure\_streak": 29,  
  "last\_completed\_timestamp": "2026-08-20T16:15:30Z",  
  "shirt\_eligible\_flag": false,  
  "shirt\_status": "unclaimed"  
}

\#\#\#\# Subcollection Document: \`/users/{athleteAuthUid}/telemetry/{sessionId}\`  
{  
  "session\_id": "session\_back\_to\_your\_best",  
  "started\_at": "2026-08-21T16:10:00Z",  
  "completed\_at": "2026-08-21T16:15:28Z",  
  "target\_duration\_seconds": 300,  
  "foreground\_playtime\_seconds": 300,  
  "completed\_fully": true  
}

\#\#\#\# Subcollection Document: \`/users/{athleteAuthUid}/schedules/weekly\`  
{  
  "active\_week\_start": "2026-08-17T00:00:00Z",  
  "is\_custom\_mode": false,  
  "days": {  
    "monday": { "session\_id": "session\_nerves\_equal\_performance", "completed": true },  
    "tuesday": { "session\_id": "session\_flow\_trigger", "completed": true },  
    "wednesday": { "session\_id": "rest\_day", "completed": false },  
    "thursday": { "session\_id": "session\_back\_to\_your\_best", "completed": true },  
    "friday": { "session\_id": "session\_play\_your\_next\_game", "completed": false },  
    "saturday": { "session\_id": "match\_day\_rest", "completed": false },  
    "sunday": { "session\_id": "rest\_day", "completed": false }  
  }  
}

\---

\#\#\# MODULE 3: FLUTTER CLIENT BOTTOM TAB ROUTER  
Implement a conditional navigation system in Flutter (using GoRouter or Navigator 2.0).  
\- Upon successful authentication, check the athlete's user profile document inside Firestore.  
\- Read the parent subscription metadata using a reactive stream.  
\- If \`subscription\_status\` \== 'active' or \`is\_parent\_track\_subscriber\` \== true, dynamically inject the "My Gym" tab as the \*\*4th Bottom Navigation Tab\*\* inside the primary client app layout.  
\- If \`onboarding\_completed\` is false, block access to the calendar and force-route the player to the 5-Question Onboarding Survey screen.

\#\#\#\# Onboarding Mapping Logic:  
Assign player archetypes based on their chosen roadblocks:  
1\. "Pre-Match Nerves" \-\> Assign Archetype: "The Calm Operator"  
   \- Active Sessions: Core: "Nerves \= Performance" | Secondary: "Flow Trigger", "Play Your Next Game"  
2\. "The Error Spiral" or "The Form Slump" \-\> Assign Archetype: "The Resilient Bounceback"  
   \- Active Sessions: Core: "Back To Your Best" | Secondary: "Empowered Thinking", "Enjoyment"  
3\. "Tactical Errors" \-\> Assign Archetype: "The Sharp Decision-Maker"  
   \- If position is Attacker: "Ice Cold Finisher" | Secondary: "Better Final Ball"  
   \- If position is Midfielder: "Better Final Ball" | Secondary: "Team Mate 6th Sense"  
   \- If position is Defender: "Defending With Positive Aggression" | Secondary: "Sharpen Your Game"  
4\. "Sideline Distractions" \-\> Assign Archetype: "The Unshakable Competitor"  
   \- Active Sessions: Core: "UNSHAKABLE" | Secondary: "Team Mate 6th Sense", "Play Your Next Game"

\---

\#\#\# MODULE 4: ACTIVE FOREGROUND TELEMETRY & ANTI-CHEAT GUARD (FLUTTER)  
Write the media playback tracking class in Dart utilizing the Flutter \`WidgetsBindingObserver\` and native \`AppLifecycleState\` observers.  
\- Capture the state transition when the native audio visualization session is initiated.  
\- Start a local \`Stopwatch\` tracker.  
\- If the application lifecycle moves from \`resumed\` to \`paused\`, \`inactive\`, or \`detached\` (e.g., backgrounding, opening social media, receiving a phone call), immediately pause the Dart AVPlayer stream AND stop the local stopwatch incrementer.  
\- When the user returns to the foreground (\`resumed\`), restart both streams.  
\- On media completion, verify if the local stopwatch's accumulated foreground time is \>= 95% of the video/audio file's metadata target duration. Only commit \`completed\_fully: true\` to the \`/telemetry/\` subcollection in Firestore if this assertion is met.

\---

\#\#\# MODULE 5: SERVER-SIDE STREAK CALCULATION (FIREBASE CLOUD FUNCTION TRANSACTION)  
Write a Firestore Trigger function in Node.js that listens to the creation of documents under \`/users/{userId}/telemetry/{sessionId}\`.  
\- Use a database Transaction to assert atomic safety.  
\- Retrieve the athlete's \`/users/{userId}\` record.  
\- Compare the current Firestore server-side ISO timestamp against the record's \`last\_completed\_timestamp\`.  
\- Run the calendar day delta math using UTC midnight boundaries:  
  \- If delta \== 1 calendar day: Increment \`composure\_streak\` by 1\.  
  \- If delta \> 1 calendar day: Reset \`composure\_streak\` to 1\.  
  \- If delta \== 0: Retain current streak (already completed training for today).  
\- If \`composure\_streak\` \>= 30, set \`shirt\_eligible\_flag\` \= true and trigger an Encharge API payload to notify FMG administration to package and ship their official Athlete Streak Shirt.

\---

\#\#\# MODULE 6: PARENT ACCOUNTABILITY PORTAL (NEXT.JS & REACT)  
Write the front-end components using Next.js, Tailwind CSS, and Firestore subscriptions.  
\- Build a secure login portal restricted strictly to the Parent email node.  
\- Render the current week's completion grid pulling the reactive Firestore array:  
  \- Green (Completed) if Monday is true.  
  \- Gray (Not Started) if Friday is false.  
\- Render a weekly dynamic conversation starter card pulling based on the child's active archetype string. (Example: If "The Resilient Bounceback", render: "Marcus practiced Back To Your Best this week. On the drive home, avoid analyzing mistakes. Simply ask: 'What was your favorite visual rep this week, and how did it feel?'")

