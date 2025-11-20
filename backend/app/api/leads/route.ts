import { NextRequest } from 'next/server'
import { z } from 'zod'
import { prisma } from '@/lib/prisma'
import { getUserFromRequest } from '@/lib/auth'
import { successResponse, errorResponse, unauthorizedResponse } from '@/lib/api-response'

const createLeadSchema = z.object({
    name: z.string().min(1, 'Name is required'),
    lastName: z.string().optional(),
    phone: z.string().min(1, 'Phone is required'),
    email: z.string().email().optional().or(z.literal('')),
    source: z.enum(['FACEBOOK', 'INSTAGRAM', 'WHATSAPP', 'TIKTOK', 'MANUAL', 'WEBHOOK']).optional(),
    customFields: z.record(z.any()).optional(),
})

// GET /api/leads - Get all leads for authenticated user
export async function GET(request: NextRequest) {
    const user = await getUserFromRequest(request)
    if (!user) {
        return unauthorizedResponse()
    }

    try {
        const { searchParams } = new URL(request.url)
        const status = searchParams.get('status')
        const source = searchParams.get('source')

        const where: any = { userId: user.id }

        if (status) {
            where.status = status
        }

        if (source) {
            where.source = source
        }

        const leads = await prisma.lead.findMany({
            where,
            include: {
                notes: {
                    orderBy: { createdAt: 'desc' },
                    take: 5,
                },
            },
            orderBy: { createdAt: 'desc' },
        })

        return successResponse(leads)
    } catch (error) {
        console.error('Get leads error:', error)
        return errorResponse('Failed to fetch leads', 500)
    }
}

// POST /api/leads - Create a new lead
export async function POST(request: NextRequest) {
    const user = await getUserFromRequest(request)
    if (!user) {
        return unauthorizedResponse()
    }

    try {
        const body = await request.json()

        const validation = createLeadSchema.safeParse(body)
        if (!validation.success) {
            return errorResponse(validation.error.errors[0].message, 400)
        }

        const { name, lastName, phone, email, source, customFields } = validation.data

        const lead = await prisma.lead.create({
            data: {
                name,
                lastName,
                phone,
                email: email || null,
                source: source || 'MANUAL',
                customFields: customFields || null,
                userId: user.id,
            },
            include: {
                notes: true,
            },
        })

        return successResponse(lead, 'Lead created successfully')
    } catch (error) {
        console.error('Create lead error:', error)
        return errorResponse('Failed to create lead', 500)
    }
}
