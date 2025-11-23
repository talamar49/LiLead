import { NextRequest } from 'next/server'
import { z } from 'zod'
import { getUserFromRequest } from '@/lib/auth'
import { successResponse, errorResponse, unauthorizedResponse } from '@/lib/api-response'
import { NotificationService } from '@/lib/notification-service'

const registerTokenSchema = z.object({
    token: z.string().min(1, 'Token is required'),
    platform: z.enum(['ios', 'android', 'web']),
})

const unregisterTokenSchema = z.object({
    token: z.string().min(1, 'Token is required'),
})

// POST /api/notifications/register - Register device token for push notifications
export async function POST(request: NextRequest) {
    const user = await getUserFromRequest(request)
    if (!user) {
        return unauthorizedResponse()
    }

    try {
        const body = await request.json()
        const validation = registerTokenSchema.safeParse(body)

        if (!validation.success) {
            return errorResponse(validation.error.errors[0].message, 400)
        }

        const result = await NotificationService.registerDeviceToken(
            user.id,
            validation.data.token,
            validation.data.platform
        )

        if (!result.success) {
            return errorResponse('Failed to register device token', 500)
        }

        return successResponse({ registered: true }, 'Device token registered successfully')
    } catch (error) {
        console.error('Register token error:', error)
        return errorResponse('Failed to register device token', 500)
    }
}

// DELETE /api/notifications/register - Unregister device token
export async function DELETE(request: NextRequest) {
    const user = await getUserFromRequest(request)
    if (!user) {
        return unauthorizedResponse()
    }

    try {
        const body = await request.json()
        const validation = unregisterTokenSchema.safeParse(body)

        if (!validation.success) {
            return errorResponse(validation.error.errors[0].message, 400)
        }

        const result = await NotificationService.unregisterDeviceToken(validation.data.token)

        if (!result.success) {
            return errorResponse('Failed to unregister device token', 500)
        }

        return successResponse({ unregistered: true }, 'Device token unregistered successfully')
    } catch (error) {
        console.error('Unregister token error:', error)
        return errorResponse('Failed to unregister device token', 500)
    }
}

