# Notifications Setup Checklist

Use this checklist to ensure your notification system is properly configured.

## Prerequisites
- [ ] Node.js and npm installed
- [ ] Flutter SDK installed
- [ ] Firebase account created
- [ ] PostgreSQL database running

## Backend Setup

### 1. Firebase Configuration
- [ ] Created Firebase project at https://console.firebase.google.com/
- [ ] Generated service account key (Project Settings → Service Accounts → Generate New Private Key)
- [ ] Downloaded the service account JSON file

### 2. Environment Variables
- [ ] Created or updated `backend/.env` file
- [ ] Added `FIREBASE_PROJECT_ID` from service account JSON
- [ ] Added `FIREBASE_PRIVATE_KEY` from service account JSON (include `\n` for line breaks)
- [ ] Added `FIREBASE_CLIENT_EMAIL` from service account JSON
- [ ] Verified `DATABASE_URL` is correct
- [ ] Verified `JWT_SECRET` is set

### 3. Install Dependencies
```bash
cd backend
npm install
```
- [ ] Installed npm packages successfully

### 4. Database Migration
```bash
npm run db:push
```
- [ ] Database schema updated with `device_tokens` table
- [ ] `notes` table updated with `reminderSent` field

### 5. Start Backend
```bash
npm run dev
```
- [ ] Backend server started successfully
- [ ] No Firebase initialization errors in logs
- [ ] Notification scheduler initialized (check logs for "Notification scheduler initialized")

## Mobile App Setup

### 1. Firebase Android App
- [ ] In Firebase Console, added Android app
- [ ] Used package name: `com.lilead.lilead` (or your custom package)
- [ ] Downloaded `google-services.json`
- [ ] Placed file at: `mobile/android/app/google-services.json`

### 2. Install Dependencies
```bash
cd mobile
flutter pub get
```
- [ ] Flutter packages installed successfully
- [ ] No errors during package resolution

### 3. Build and Run
```bash
flutter run
```
- [ ] App builds successfully
- [ ] No Firebase initialization errors
- [ ] App requests notification permissions
- [ ] Notification permission granted

### 4. Verify Token Registration
- [ ] App started and logged in
- [ ] Check backend logs for "FCM Token refreshed" or token registration
- [ ] Check database `device_tokens` table for registered token

## Testing

### 1. Create Test Reminder
- [ ] Opened a lead in the app
- [ ] Created a note with reminder 2-3 minutes in future
- [ ] Note saved successfully

### 2. Wait for Notification
- [ ] Waited for reminder time to pass
- [ ] Backend logs show "Checking for due reminders..." every minute
- [ ] Backend logs show notification sent
- [ ] 🎉 **Received push notification on device!**

### 3. Tap Notification
- [ ] Tapped notification
- [ ] App opened (navigation to lead can be implemented)

## Troubleshooting

If notifications are not working, verify:

### Backend Issues
- [ ] Check `backend/.env` has correct Firebase credentials
- [ ] Check backend server is running
- [ ] Check backend logs for errors
- [ ] Check `device_tokens` table has entries
- [ ] Check `notes` table has note with `reminderAt` in past and `reminderSent = false`

### Mobile Issues
- [ ] `google-services.json` file exists in correct location
- [ ] Notification permissions granted in device settings
- [ ] App has internet connection
- [ ] Check Flutter logs for Firebase initialization errors
- [ ] Try `flutter clean` and `flutter pub get`

### Firebase Issues
- [ ] Firebase project exists and is active
- [ ] Service account key is valid
- [ ] Firebase Cloud Messaging API is enabled
- [ ] Check Firebase Console for error messages

## Verification Commands

### Check Backend Database
```sql
-- Check device tokens
SELECT * FROM device_tokens;

-- Check notes with reminders
SELECT id, content, "reminderAt", "reminderSent" 
FROM notes 
WHERE "reminderAt" IS NOT NULL;
```

### Check Backend Logs
Look for these messages:
- ✅ "Firebase Admin SDK initialized successfully"
- ✅ "Notification scheduler initialized"
- ✅ "Checking for due reminders..."
- ✅ "Sent reminder notification for note [id]"
- ✅ "FCM token registered with backend"

### Check Mobile Logs
Look for these messages:
- ✅ "NotificationService initialized successfully"
- ✅ "FCM Token: ..."
- ✅ "FCM token registered with backend"

## Success Criteria

✅ **Backend**
- Server starts without errors
- Firebase Admin SDK initialized
- Scheduler running and checking every minute
- Can send notifications to registered tokens

✅ **Mobile**
- App starts without errors
- Firebase initialized
- Notification permissions granted
- FCM token registered with backend
- Can receive and display notifications

✅ **End-to-End**
- Create note with reminder
- Receive notification at correct time
- Notification displays properly
- Can tap notification to open app

## Next Steps After Setup

- [ ] Configure iOS notifications (if needed)
- [ ] Set up production environment variables
- [ ] Configure web push notifications (optional)
- [ ] Customize notification content and styling
- [ ] Implement notification tap navigation
- [ ] Add notification preferences UI
- [ ] Monitor notification delivery rates

## Documentation Reference

- Setup Guide: `NOTIFICATIONS_SETUP.md`
- Quick Start: `QUICK_START_NOTIFICATIONS.md`
- Implementation Summary: `NOTIFICATIONS_IMPLEMENTATION_SUMMARY.md`
- API Docs: `backend/API_DOCS.md`

---

**Status**: Once all checkboxes are checked, your notifications are fully set up! 🎉

