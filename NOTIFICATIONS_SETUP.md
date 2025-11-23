# Push Notifications Setup Guide

This guide explains how to set up Firebase Cloud Messaging (FCM) for push notifications in the LiLead CRM application.

## Overview

The notification system consists of:
- **Backend**: Node.js scheduler that checks for due reminders and sends push notifications via Firebase Admin SDK
- **Mobile**: Flutter app that receives FCM notifications and displays them locally
- **Database**: Tracks device tokens and notification status

## Prerequisites

1. A Firebase project
2. Firebase service account credentials
3. Node.js and npm installed
4. Flutter development environment

## Backend Setup

### 1. Install Dependencies

```bash
cd backend
npm install
```

The following packages are required:
- `firebase-admin`: Firebase Admin SDK for sending push notifications
- `node-cron`: Scheduler for checking due reminders

### 2. Firebase Service Account Setup

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Select your project (or create a new one)
3. Go to **Project Settings** > **Service Accounts**
4. Click **Generate New Private Key**
5. Download the JSON file

### 3. Configure Environment Variables

Create or update your `.env` file in the `backend` directory:

```env
# Database
DATABASE_URL="postgresql://username:password@localhost:5432/lilead"

# JWT Secret (for authentication)
JWT_SECRET="your-super-secret-jwt-key-change-this-in-production"

# Firebase Admin SDK Credentials
FIREBASE_PROJECT_ID="your-firebase-project-id"
FIREBASE_PRIVATE_KEY="-----BEGIN PRIVATE KEY-----\nYour\nPrivate\nKey\nHere\n-----END PRIVATE KEY-----\n"
FIREBASE_CLIENT_EMAIL="firebase-adminsdk-xxxxx@your-project.iam.gserviceaccount.com"
```

**Note**: The private key should include the full key with `\n` characters for line breaks. You can get these values from the downloaded service account JSON file.

#### Extracting values from service account JSON:

If your downloaded file is `serviceAccountKey.json`, extract values like this:

```json
{
  "project_id": "your-firebase-project-id",           // → FIREBASE_PROJECT_ID
  "private_key": "-----BEGIN PRIVATE KEY-----\n...",  // → FIREBASE_PRIVATE_KEY
  "client_email": "firebase-adminsdk-..."             // → FIREBASE_CLIENT_EMAIL
}
```

### 4. Update Database Schema

Run the Prisma migration to add the device tokens table:

```bash
cd backend
npm run db:push
# or
npm run db:migrate
```

### 5. Start the Backend Server

```bash
cd backend
npm run dev
```

The notification scheduler will automatically start and check for due reminders every minute.

## Mobile App Setup (Flutter)

### 1. Install Dependencies

```bash
cd mobile
flutter pub get
```

The following packages are required:
- `firebase_core`: Firebase Core SDK
- `firebase_messaging`: FCM for push notifications
- `flutter_local_notifications`: Local notification display

### 2. Firebase Configuration

#### Android Setup

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Select your project
3. Click on the Android icon to add an Android app
4. Enter your package name (found in `mobile/android/app/build.gradle.kts`)
5. Download the `google-services.json` file
6. Place it in `mobile/android/app/google-services.json`

#### iOS Setup (if targeting iOS)

1. In Firebase Console, add an iOS app
2. Enter your bundle ID (found in `mobile/ios/Runner.xcodeproj/project.pbxproj`)
3. Download `GoogleService-Info.plist`
4. Add it to `mobile/ios/Runner/GoogleService-Info.plist` using Xcode

### 3. Android Configuration

The `AndroidManifest.xml` has already been updated with the necessary permissions and configurations.

Ensure your `mobile/android/app/build.gradle.kts` includes the Google Services plugin:

```kotlin
plugins {
    // ... other plugins
    id("com.google.gms.google-services") version "4.4.0" apply false
}
```

And at the project level `mobile/android/build.gradle.kts`:

```kotlin
buildscript {
    dependencies {
        classpath("com.google.gms:google-services:4.4.0")
    }
}
```

### 4. Run the Mobile App

```bash
cd mobile
flutter run
```

On first launch, the app will:
1. Request notification permissions
2. Register with Firebase and get an FCM token
3. Send the token to the backend API
4. Start listening for notifications

## How It Works

### Creating a Note with Reminder

When a user creates a note with a `reminderAt` date/time:

1. The note is saved in the database with `reminderSent: false`
2. Backend scheduler checks every minute for notes where:
   - `reminderAt <= current_time`
   - `reminderSent = false`
3. For each due reminder:
   - Backend fetches user's device tokens
   - Sends push notification via FCM to all user devices
   - Marks note as `reminderSent: true`

### Notification Flow

```
┌─────────────┐
│   Backend   │
│  Scheduler  │
└──────┬──────┘
       │ Every minute
       │ Checks due reminders
       ▼
┌─────────────┐
│  Firebase   │
│     FCM     │
└──────┬──────┘
       │ Sends push
       │ notification
       ▼
┌─────────────┐
│   Mobile    │
│     App     │
└─────────────┘
```

### Device Token Management

- **Registration**: When the app starts, it registers the FCM token with the backend
- **Refresh**: FCM tokens are automatically refreshed and re-registered
- **Cleanup**: Invalid tokens are automatically removed when notification delivery fails
- **Unregistration**: When a user logs out, the token is unregistered

## API Endpoints

### POST `/api/notifications/register`

Register a device token for push notifications.

**Request Body:**
```json
{
  "token": "FCM_DEVICE_TOKEN",
  "platform": "android" // or "ios" or "web"
}
```

**Response:**
```json
{
  "success": true,
  "message": "Device token registered successfully",
  "data": {
    "registered": true
  }
}
```

### DELETE `/api/notifications/register`

Unregister a device token.

**Request Body:**
```json
{
  "token": "FCM_DEVICE_TOKEN"
}
```

## Testing

### Test Push Notifications Manually

You can test notifications using the Firebase Console:

1. Go to **Firebase Console** > **Cloud Messaging**
2. Click **Send your first message**
3. Enter notification title and body
4. Select your app
5. Send test message

### Test Scheduled Reminders

1. Create a note with a reminder time 2-3 minutes in the future
2. Wait for the scheduler to pick it up (runs every minute)
3. You should receive a push notification on your device

### Debugging

Enable debug logging:

**Backend:**
The notification service logs to the console. Check the server logs.

**Mobile:**
Flutter prints debug messages to the console. Use `flutter logs` to see them.

## Troubleshooting

### No notifications received

1. **Check Firebase credentials**: Ensure environment variables are set correctly
2. **Verify FCM token**: Check if the token was registered in the database (`device_tokens` table)
3. **Check permissions**: Ensure the app has notification permissions
4. **Backend logs**: Check if the scheduler is running and sending notifications
5. **Firebase console**: Verify FCM is enabled and configured correctly

### Notifications not sending from backend

1. **Verify Firebase Admin SDK initialization**: Check backend logs for initialization errors
2. **Check database**: Verify notes have correct `reminderAt` times and `reminderSent` is false
3. **Scheduler running**: Ensure the backend server is running and scheduler is active

### Android notifications not showing

1. **Check notification channel**: Ensure the channel is created (it's done automatically)
2. **App permissions**: Go to Settings > Apps > LiLead > Notifications and ensure they're enabled
3. **Battery optimization**: Disable battery optimization for the app

## Production Considerations

1. **Environment Variables**: Use secure environment variable management (e.g., AWS Secrets Manager, Docker secrets)
2. **Scaling**: For high volume, consider using a message queue (e.g., Bull, Redis) instead of cron
3. **Monitoring**: Add monitoring for notification delivery rates and failures
4. **Rate Limiting**: Implement rate limiting to prevent notification spam
5. **Error Handling**: Implement retry logic for failed notifications
6. **Timezone Handling**: Ensure reminder times are stored and handled correctly across timezones

## Security Notes

- Never commit `.env` files or Firebase service account keys to version control
- Use `.gitignore` to exclude sensitive files
- Rotate Firebase credentials periodically
- Implement proper authentication for all notification endpoints
- Validate and sanitize all notification content

## Additional Resources

- [Firebase Cloud Messaging Documentation](https://firebase.google.com/docs/cloud-messaging)
- [Firebase Admin SDK Documentation](https://firebase.google.com/docs/admin/setup)
- [Flutter Firebase Messaging Plugin](https://pub.dev/packages/firebase_messaging)
- [Flutter Local Notifications](https://pub.dev/packages/flutter_local_notifications)

