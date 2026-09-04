# FMG Parent Accountability Portal

## Deployment

This project is deployed to [Railway](https://railway.app).

### Local Development

1. Install dependencies:
   ```bash
   npm install
   ```

2. Run the development server:
   ```bash
   npm run dev
   ```

   Open http://localhost:3000 to see the result.

### Production

The app is built and deployed automatically by Railway.

## Features

- **Secure login portal** for parent accounts (email-based)
- **Weekly completion grid** with color-coded status
- **Conversation starter cards** based on athlete archetype

## Architecture

This is a monorepo with three main components:

1. **`mobile/`** - Flutter app (FMG Companion)
2. **`web/`** - Next.js parent portal
3. **`functions/`** - Firebase Cloud Functions (Stripe webhook, streak trigger)

The parent portal is deployed to Railway as a standalone Node.js service.

## Technology Stack

- **Frontend**: Next.js, React, TypeScript, Tailwind CSS
- **Backend**: Node.js (served by Next.js standalone runtime)
- **Authentication**: Firebase Auth (email-link sign-in)
- **Database**: Firestore (parent/athlete profiles, telemetry, weekly schedules)

## Environment Variables

Set these in Railway dashboard:

```env
PORT=3000
NODE_ENV=production
```

## Build Process

1. **Frontend build**: `npm run build` (Next.js creates standalone output)
2. **Railway builds** the Dockerfile and deploys to production

## Project Structure

```
web/
├── .next/ (built output)
├── public/ (static assets)
├── src/
│   ├── app/ (Next.js pages)
│   ├── components/ (React components)
│   ├── lib/ (utilities)
│   └── types/ (TypeScript types)
├── package.json
├── next.config.js
├── tailwind.config.js
└── postcss.config.js
```

## Note

This is the parent accountability portal for the FMG (Football Mind Gym) system. The mobile companion app is in the `mobile/` directory and handles athlete onboarding, telemetry tracking, and session playback.