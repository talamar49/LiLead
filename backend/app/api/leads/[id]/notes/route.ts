import { NextRequest } from 'next/server'
import { z } from 'zod'
import { prisma } from '@/lib/prisma'
import { getUserFromRequest } from '@/lib/auth'
import { successResponse, errorResponse, unauthorizedResponse, notFoundResponse } from '@/lib/api-response'

const createNoteSchema = z.object({
    content: z.string().min(1, 'Note content is required'),
    reminderAt: z.string().optional().nullable().or(z.literal(undefined)),
})

// POST /api/leads/[id]/notes - Add a note to a lead
export async function POST(
    request: NextRequest,
    { params }: { params: Promise<{ id: string }> }
) {
    const user = await getUserFromRequest(request)
    if (!user) {
        return unauthorizedResponse()
    }

    try {
        const { id: leadId } = await params
        const body = await request.json()

        console.log('Received note body:', body)

        const validation = createNoteSchema.safeParse(body)
        if (!validation.success) {
            console.error('Validation error:', validation.error.errors)
            return errorResponse(validation.error.errors[0].message, 400)
        }

        // Check if lead exists and belongs to user
        const lead = await prisma.lead.findFirst({
            where: {
                id: leadId,
                userId: user.id,
            },
        })

        if (!lead) {
            return notFoundResponse('Lead not found')
        }

        const note = await prisma.note.create({
            data: {
                content: validation.data.content,
                reminderAt: validation.data.reminderAt ? new Date(validation.data.reminderAt) : null,
                leadId,
                userId: user.id,
            },
            include: {
                user: {
                    select: {
                        id: true,
                        name: true,
                        avatarUrl: true,
                    },
                },
            },
        })

        return successResponse(note, 'Note added successfully')
    } catch (error) {
        console.error('Create note error:', error)
        return errorResponse('Failed to create note', 500)
    }
}

// GET /api/leads/[id]/notes - Get all notes for a lead
export async function GET(
    request: NextRequest,
    { params }: { params: Promise<{ id: string }> }
) {
    const user = await getUserFromRequest(request)
    if (!user) {
        return unauthorizedResponse()
    }

    try {
        const { id: leadId } = await params

        // Check if lead exists and belongs to user
        const lead = await prisma.lead.findFirst({
            where: {
                id: leadId,
                userId: user.id,
            },
        })

        if (!lead) {
            return notFoundResponse('Lead not found')
        }

        const notes = await prisma.note.findMany({
            where: { leadId },
            include: {
                user: {
                    select: {
                        id: true,
                        name: true,
                        avatarUrl: true,
                    },
                },
            },
            orderBy: { createdAt: 'desc' },
        })

        return successResponse(notes)
    } catch (error) {
        console.error('Get notes error:', error)
        return errorResponse('Failed to fetch notes', 500)
    }
}
