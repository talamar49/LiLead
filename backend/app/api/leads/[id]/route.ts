import { NextRequest } from 'next/server'
import { z } from 'zod'
import { prisma } from '@/lib/prisma'
import { getUserFromRequest } from '@/lib/auth'
import { successResponse, errorResponse, unauthorizedResponse, notFoundResponse } from '@/lib/api-response'

const updateLeadSchema = z.object({
    name: z.string().min(1).optional(),
    lastName: z.string().optional(),
    phone: z.string().min(1).optional(),
    email: z.string().email().optional().or(z.literal('')),
    status: z.enum(['NEW', 'IN_PROCESS', 'CLOSED', 'NOT_RELEVANT']).optional(),
    source: z.enum(['FACEBOOK', 'INSTAGRAM', 'WHATSAPP', 'TIKTOK', 'MANUAL', 'WEBHOOK']).optional(),
    customFields: z.record(z.any()).optional(),
})

// GET /api/leads/[id] - Get a single lead
export async function GET(
    request: NextRequest,
    { params }: { params: Promise<{ id: string }> }
) {
    const user = await getUserFromRequest(request)
    if (!user) {
        return unauthorizedResponse()
    }

    try {
        const { id } = await params

        const lead = await prisma.lead.findFirst({
            where: {
                id,
                userId: user.id,
            },
            include: {
                notes: {
                    orderBy: { createdAt: 'desc' },
                    include: {
                        user: {
                            select: {
                                id: true,
                                name: true,
                                avatarUrl: true,
                            },
                        },
                    },
                },
            },
        })

        if (!lead) {
            return notFoundResponse('Lead not found')
        }

        return successResponse(lead)
    } catch (error) {
        console.error('Get lead error:', error)
        return errorResponse('Failed to fetch lead', 500)
    }
}

// PATCH /api/leads/[id] - Update a lead
export async function PATCH(
    request: NextRequest,
    { params }: { params: Promise<{ id: string }> }
) {
    const user = await getUserFromRequest(request)
    if (!user) {
        return unauthorizedResponse()
    }

    try {
        const { id } = await params
        const body = await request.json()

        const validation = updateLeadSchema.safeParse(body)
        if (!validation.success) {
            return errorResponse(validation.error.errors[0].message, 400)
        }

        // Check if lead exists and belongs to user
        const existingLead = await prisma.lead.findFirst({
            where: {
                id,
                userId: user.id,
            },
        })

        if (!existingLead) {
            return notFoundResponse('Lead not found')
        }

        const lead = await prisma.lead.update({
            where: { id },
            data: {
                ...validation.data,
                email: validation.data.email || null,
            },
            include: {
                notes: {
                    orderBy: { createdAt: 'desc' },
                },
            },
        })

        return successResponse(lead, 'Lead updated successfully')
    } catch (error) {
        console.error('Update lead error:', error)
        return errorResponse('Failed to update lead', 500)
    }
}

// DELETE /api/leads/[id] - Delete a lead
export async function DELETE(
    request: NextRequest,
    { params }: { params: Promise<{ id: string }> }
) {
    const user = await getUserFromRequest(request)
    if (!user) {
        return unauthorizedResponse()
    }

    try {
        const { id } = await params

        // Check if lead exists and belongs to user
        const existingLead = await prisma.lead.findFirst({
            where: {
                id,
                userId: user.id,
            },
        })

        if (!existingLead) {
            return notFoundResponse('Lead not found')
        }

        await prisma.lead.delete({
            where: { id },
        })

        return successResponse(null, 'Lead deleted successfully')
    } catch (error) {
        console.error('Delete lead error:', error)
        return errorResponse('Failed to delete lead', 500)
    }
}
