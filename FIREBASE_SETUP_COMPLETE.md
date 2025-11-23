# Firebase Setup Verification

Check off each item to verify your Firebase setup is complete:

## Backend Setup
- [ ] Created Firebase project at console.firebase.google.com
- [ ] Downloaded service account JSON file
- [ ] Created/updated `backend/.env` with:
  - [ ] `FIREBASE_PROJECT_ID` (from JSON file)
  - [ ] `FIREBASE_PRIVATE_KEY` (from JSON file, with `\n` characters)
  - [ ] `FIREBASE_CLIENT_EMAIL` (from JSON file)
- [ ] File exists: `backend/.env` (check: `ls backend/.env`)

## Mobile App Setup
- [ ] Added Android app in Firebase Console
- [ ] Downloaded `google-services.json`
- [ ] Placed file at: `mobile/android/app/google-services.json`
- [ ] Verified: `ls mobile/android/app/google-services.json` shows the file

## Database Setup
- [ ] Ran: `cd backend && npm install`
- [ ] Ran: `npx prisma db push`
- [ ] No errors from Prisma migration

## Test Backend
```bash
cd backend
npm run dev
```

Look for in the logs:
- [ ] ✅ "Firebase Admin SDK initialized successfully"
- [ ] ✅ "Notification scheduler initialized"
- [ ] ✅ "Checking for due reminders..." (appears every minute)

## Test Mobile App
```bash
cd mobile
flutter pub get
flutter run
```

Look for in the logs:
- [ ] ✅ "NotificationService initialized successfully"
- [ ] ✅ "FCM Token: ..." (your device token)
- [ ] ✅ "FCM token registered with backend"
- [ ] ✅ No Firebase initialization errors

## Final Test - Send a Notification!

1. [ ] Login to the mobile app
2. [ ] Open any lead
3. [ ] Add a note with reminder 2 minutes in future
4. [ ] Wait 2 minutes
5. [ ] 🎉 **Receive push notification on your device!**

---

## Troubleshooting

### Backend says "Firebase Admin SDK not initialized"
- Check `.env` file has all three Firebase variables
- Check private key includes `\n` characters
- Restart backend server

### Mobile app says "Firebase initialization failed"
- Check `google-services.json` is in correct location
- Run `flutter clean && flutter pub get`
- Check package name matches in Firebase Console and `build.gradle.kts`

### No notification received
- Check backend logs show "Sent reminder notification"
- Check device token is in database: `SELECT * FROM device_tokens;`
- Check notification permissions are enabled on device

---

## Next Steps After Setup Complete

Once all checkboxes are checked, you have:
✅ Fully functional push notifications
✅ Real-time reminders when notes are due
✅ Multi-device support
✅ Background notification delivery

Read the full documentation:
- `NOTIFICATIONS_SETUP.md` - Complete technical guide
- `NOTIFICATIONS_CHECKLIST.md` - Detailed testing checklist
- `QUICK_START_NOTIFICATIONS.md` - Quick reference

**You're all set! 🎉**

