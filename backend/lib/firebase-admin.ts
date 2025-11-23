import admin from 'firebase-admin'

// Initialize Firebase Admin SDK
let app: admin.app.App | undefined

export function initializeFirebaseAdmin() {
    if (app) {
        return app
    }

    // Check if Firebase credentials are configured
    const projectId = process.env.FIREBASE_PROJECT_ID
    const privateKey = process.env.FIREBASE_PRIVATE_KEY?.replace(/\\n/g, '\n')
    const clientEmail = process.env.FIREBASE_CLIENT_EMAIL

    if (!projectId || !privateKey || !clientEmail) {
        console.warn('Firebase Admin SDK not initialized: Missing credentials')
        return undefined
    }

    try {
        app = admin.initializeApp({
            credential: admin.credential.cert({
                projectId,
                privateKey,
                clientEmail,
            }),
        })
        console.log('Firebase Admin SDK initialized successfully')
        return app
    } catch (error) {
        console.error('Failed to initialize Firebase Admin SDK:', error)
        return undefined
    }
}

export function getFirebaseAdmin() {
    if (!app) {
        return initializeFirebaseAdmin()
    }
    return app
}

export function getMessaging() {
    const adminApp = getFirebaseAdmin()
    if (!adminApp) {
        return undefined
    }
    return admin.messaging()
}

