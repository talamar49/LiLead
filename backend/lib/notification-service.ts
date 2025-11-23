import { getMessaging } from './firebase-admin'
import { prisma } from './prisma'

export interface NotificationPayload {
    title: string
    body: string
    data?: Record<string, string>
}

export class NotificationService {
    /**
     * Send push notification to a specific user
     */
    static async sendToUser(userId: string, payload: NotificationPayload) {
        try {
            // Get all device tokens for the user
            const deviceTokens = await prisma.deviceToken.findMany({
                where: { userId },
                select: { token: true, platform: true },
            })

            if (deviceTokens.length === 0) {
                console.log(`No device tokens found for user ${userId}`)
                return { success: false, message: 'No devices registered' }
            }

            const messaging = getMessaging()
            if (!messaging) {
                console.error('Firebase messaging not initialized')
                return { success: false, message: 'Notification service not configured' }
            }

            // Send notifications to all devices
            const tokens = deviceTokens.map(dt => dt.token)
            const message = {
                notification: {
                    title: payload.title,
                    body: payload.body,
                },
                data: payload.data || {},
                tokens,
            }

            const response = await messaging.sendEachForMulticast(message)

            // Clean up invalid tokens
            if (response.failureCount > 0) {
                const failedTokens: string[] = []
                response.responses.forEach((resp, idx) => {
                    if (!resp.success) {
                        failedTokens.push(tokens[idx])
                        console.error(`Failed to send to token ${tokens[idx]}:`, resp.error)
                    }
                })

                // Remove invalid tokens from database
                if (failedTokens.length > 0) {
                    await prisma.deviceToken.deleteMany({
                        where: {
                            token: { in: failedTokens },
                        },
                    })
                    console.log(`Removed ${failedTokens.length} invalid tokens`)
                }
            }

            return {
                success: response.successCount > 0,
                successCount: response.successCount,
                failureCount: response.failureCount,
            }
        } catch (error) {
            console.error('Error sending notification:', error)
            return { success: false, error }
        }
    }

    /**
     * Register a device token for a user
     */
    static async registerDeviceToken(userId: string, token: string, platform: 'ios' | 'android' | 'web') {
        try {
            // Upsert device token (create or update)
            await prisma.deviceToken.upsert({
                where: { token },
                create: {
                    token,
                    platform,
                    userId,
                },
                update: {
                    platform,
                    userId,
                    updatedAt: new Date(),
                },
            })

            return { success: true }
        } catch (error) {
            console.error('Error registering device token:', error)
            return { success: false, error }
        }
    }

    /**
     * Unregister a device token
     */
    static async unregisterDeviceToken(token: string) {
        try {
            await prisma.deviceToken.delete({
                where: { token },
            })

            return { success: true }
        } catch (error) {
            console.error('Error unregistering device token:', error)
            return { success: false, error }
        }
    }

    /**
     * Check and send notifications for due reminders
     */
    static async checkAndSendReminders() {
        try {
            const now = new Date()

            // Find all notes with reminders that are due and haven't been sent
            const dueNotes = await prisma.note.findMany({
                where: {
                    reminderAt: {
                        lte: now,
                    },
                    reminderSent: false,
                },
                include: {
                    lead: true,
                    user: true,
                },
            })

            console.log(`Found ${dueNotes.length} due reminders`)

            for (const note of dueNotes) {
                try {
                    // Send notification
                    const result = await this.sendToUser(note.userId, {
                        title: '🔔 Lead Reminder',
                        body: `Reminder for ${note.lead.name}: ${note.content.substring(0, 100)}${note.content.length > 100 ? '...' : ''}`,
                        data: {
                            type: 'reminder',
                            noteId: note.id,
                            leadId: note.leadId,
                        },
                    })

                    // Mark reminder as sent
                    await prisma.note.update({
                        where: { id: note.id },
                        data: { reminderSent: true },
                    })

                    console.log(`Sent reminder notification for note ${note.id}:`, result)
                } catch (error) {
                    console.error(`Failed to send reminder for note ${note.id}:`, error)
                }
            }

            return { success: true, count: dueNotes.length }
        } catch (error) {
            console.error('Error checking reminders:', error)
            return { success: false, error }
        }
    }
}

