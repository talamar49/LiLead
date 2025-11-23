import { NotificationService } from './notification-service'
import { initializeFirebaseAdmin } from './firebase-admin'

let schedulerInitialized = false
let intervalId: NodeJS.Timeout | null = null

export function initializeNotificationScheduler() {
    // Only run in Node.js runtime, not Edge runtime
    if (typeof window !== 'undefined' || schedulerInitialized) {
        return
    }

    // Initialize Firebase Admin first
    initializeFirebaseAdmin()

    // Run every minute to check for due reminders using setInterval
    intervalId = setInterval(async () => {
        console.log('Checking for due reminders...')
        try {
            const result = await NotificationService.checkAndSendReminders()
            if (result.success && result.count > 0) {
                console.log(`Processed ${result.count} reminders`)
            }
        } catch (error) {
            console.error('Error in notification scheduler:', error)
        }
    }, 60000) // 60000ms = 1 minute

    schedulerInitialized = true
    console.log('Notification scheduler initialized - checking every minute')
}

export function stopNotificationScheduler() {
    if (intervalId) {
        clearInterval(intervalId)
        intervalId = null
        schedulerInitialized = false
        console.log('Notification scheduler stopped')
    }
}

