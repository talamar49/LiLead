import { NextRequest } from 'next/server'
import { z } from 'zod'
import { prisma } from '@/lib/prisma'
import { successResponse, errorResponse } from '@/lib/api-response'

const webhookSchema = z.object({
    name: z.string().min(1, 'Name is required'),
    lastName: z.string().optional(),
    phone: z.string().min(1, 'Phone is required'),
    email: z.string().email().optional().or(z.literal('')),
    source: z.enum(['FACEBOOK', 'INSTAGRAM', 'WHATSAPP', 'TIKTOK']).optional(),
    userId: z.string().optional(), // Optional: specify which user to assign the lead to
})

// POST /api/webhook/lead - Receive leads from external sources
export async function POST(request: NextRequest) {
    try {
        // Verify webhook secret
        const webhookSecret = process.env.WEBHOOK_SECRET
        const receivedKey = request.headers.get('x-webhook-key')

        if (webhookSecret && webhookSecret.trim() !== '') {
            if (!receivedKey || receivedKey !== webhookSecret) {
                return errorResponse('Invalid webhook key', 401)
            }
        }

        const body = await request.json()

        const validation = webhookSchema.safeParse(body)
        if (!validation.success) {
            return errorResponse(validation.error.errors[0].message, 400)
        }

        const { name, lastName, phone, email, source, userId } = validation.data

        // If no userId provided, assign to the first user (or implement your own logic)
        let targetUserId = userId
        if (!targetUserId) {
            const firstUser = await prisma.user.findFirst({
                orderBy: { createdAt: 'asc' },
            })

            if (!firstUser) {
                return errorResponse('No users found in the system', 400)
            }

            targetUserId = firstUser.id
        }

        // Check if user exists
        const user = await prisma.user.findUnique({
            where: { id: targetUserId },
        })

        if (!user) {
            return errorResponse('User not found', 404)
        }

        // Create lead
        const lead = await prisma.lead.create({
            data: {
                name,
                lastName,
                phone,
                email: email || null,
                source: source || 'WEBHOOK',
                status: 'NEW',
                userId: targetUserId,
            },
        })

        return successResponse(lead, 'Lead created successfully from webhook')
    } catch (error) {
        console.error('Webhook error:', error)
        return errorResponse('Failed to process webhook', 500)
    }
}
