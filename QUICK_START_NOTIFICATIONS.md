# Quick Start: Enable Push Notifications

Follow these steps to enable push notifications in your LiLead CRM app.

## 1. Backend Setup (5 minutes)

### Install dependencies
```bash
cd backend
npm install
```

### Set up Firebase Admin
1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Create a project or select existing
3. Go to **Project Settings** → **Service Accounts**
4. Click **Generate New Private Key** and download the JSON file

### Configure environment variables
Create `backend/.env` file (or update existing):
```env
DATABASE_URL="postgresql://username:password@localhost:5432/lilead"
JWT_SECRET="your-jwt-secret"

# Firebase credentials (from the downloaded JSON file)
FIREBASE_PROJECT_ID="your-project-id"
FIREBASE_PRIVATE_KEY="-----BEGIN PRIVATE KEY-----\nYour-Key-Here\n-----END PRIVATE KEY-----\n"
FIREBASE_CLIENT_EMAIL="firebase-adminsdk-xxxxx@your-project.iam.gserviceaccount.com"
```

### Update database
```bash
cd backend
npm run db:push
```

### Start backend
```bash
npm run dev
```

✅ Backend is ready! The notification scheduler is now running.

## 2. Mobile App Setup (10 minutes)

### Install dependencies
```bash
cd mobile
flutter pub get
```

### Configure Firebase for Android

1. In [Firebase Console](https://console.firebase.google.com/), select your project
2. Click the **Android** icon to add an Android app
3. Enter package name: `com.lilead.app` (or check `mobile/android/app/build.gradle.kts` for your actual package)
4. Download `google-services.json`
5. Place it at: `mobile/android/app/google-services.json`

### Update Android Gradle (if needed)

Edit `mobile/android/build.gradle.kts` and add:
```kotlin
buildscript {
    dependencies {
        classpath("com.google.gms:google-services:4.4.0")
    }
}
```

Edit `mobile/android/app/build.gradle.kts` and add at the bottom:
```kotlin
apply(plugin = "com.google.gms.google-services")
```

### Run the app
```bash
flutter run
```

On first launch, the app will request notification permissions and register with Firebase.

✅ Mobile app is ready!

## 3. Test Notifications (2 minutes)

1. Open the mobile app and log in
2. Go to any lead
3. Add a note with a reminder time (e.g., 2 minutes from now)
4. Wait for the reminder time
5. You should receive a push notification! 🎉

## Troubleshooting

### "npm not found"
Install Node.js from [nodejs.org](https://nodejs.org/) or use your package manager:
```bash
# Ubuntu/Debian
sudo apt install npm

# macOS
brew install node
```

### "Firebase not initialized"
- Check that environment variables are set correctly in `backend/.env`
- Verify the Firebase credentials are valid
- Check backend logs for error messages

### "No notification received"
- Ensure notification permissions are granted in app settings
- Check that the device token was registered (check `device_tokens` table in database)
- Verify backend scheduler is running (check server logs for "Checking for due reminders...")
- Make sure the reminder time is in the future when creating the note

### "google-services.json not found"
- Download from Firebase Console
- Place it exactly at: `mobile/android/app/google-services.json`
- Run `flutter clean` and `flutter pub get`

## Next Steps

- Read the full documentation: `NOTIFICATIONS_SETUP.md`
- Check API documentation: `backend/API_DOCS.md`
- Configure iOS notifications (if needed)
- Set up production environment variables

## Need Help?

- [Firebase Documentation](https://firebase.google.com/docs)
- [Flutter Firebase Setup](https://firebase.google.com/docs/flutter/setup)
- Check the logs in both backend and mobile app for error messages

