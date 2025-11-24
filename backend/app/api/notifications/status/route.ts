import { NextRequest } from 'next/server'
import { successResponse } from '@/lib/api-response'

// Import and initialize the scheduler when this route is first accessed
// This ensures it runs in the Node.js runtime, not Edge runtime
let schedulerInitialized = false

export const runtime = 'nodejs' // Force Node.js runtime for this route

export async function GET(request: NextRequest) {
    if (!schedulerInitialized) {
        try {
            // Dynamically import to avoid Edge runtime issues
            const { initializeNotificationScheduler } = await import('@/lib/server-init')
            initializeNotificationScheduler()
            schedulerInitialized = true
        } catch (error) {
            console.error('Failed to initialize scheduler:', error)
        }
    }

    return successResponse({ 
        scheduler: schedulerInitialized ? 'running' : 'failed',
        message: 'Notification system status'
    })
}



