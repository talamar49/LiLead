import { NextRequest } from 'next/server'
import { z } from 'zod'
import { prisma } from '@/lib/prisma'
import { getUserFromRequest } from '@/lib/auth'
import { successResponse, errorResponse, unauthorizedResponse, notFoundResponse } from '@/lib/api-response'

const updateNoteSchema = z.object({
    content: z.string().min(1, 'Note content is required').optional(),
    reminderAt: z.string().optional().nullable().or(z.literal(undefined)),
})

// PATCH /api/leads/[leadId]/notes/[noteId] - Update a note
export async function PATCH(
    request: NextRequest,
    { params }: { params: Promise<{ id: string; noteId: string }> }
) {
    const user = await getUserFromRequest(request)
    if (!user) {
        return unauthorizedResponse()
    }

    try {
        const { id: leadId, noteId } = await params
        const body = await request.json()

        const validation = updateNoteSchema.safeParse(body)
        if (!validation.success) {
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

        // Check if note exists and belongs to the lead
        const note = await prisma.note.findFirst({
            where: {
                id: noteId,
                leadId,
            },
        })

        if (!note) {
            return notFoundResponse('Note not found')
        }

        // Update the note
        const updatedNote = await prisma.note.update({
            where: { id: noteId },
            data: {
                ...(validation.data.content && { content: validation.data.content }),
                ...(validation.data.reminderAt !== undefined && {
                    reminderAt: validation.data.reminderAt ? new Date(validation.data.reminderAt) : null,
                }),
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

        return successResponse(updatedNote, 'Note updated successfully')
    } catch (error) {
        console.error('Update note error:', error)
        return errorResponse('Failed to update note', 500)
    }
}

// DELETE /api/leads/[leadId]/notes/[noteId] - Delete a note
export async function DELETE(
    request: NextRequest,
    { params }: { params: Promise<{ id: string; noteId: string }> }
) {
    const user = await getUserFromRequest(request)
    if (!user) {
        return unauthorizedResponse()
    }

    try {
        const { id: leadId, noteId } = await params

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

        // Check if note exists and belongs to the lead
        const note = await prisma.note.findFirst({
            where: {
                id: noteId,
                leadId,
            },
        })

        if (!note) {
            return notFoundResponse('Note not found')
        }

        // Delete the note
        await prisma.note.delete({
            where: { id: noteId },
        })

        return successResponse(null, 'Note deleted successfully')
    } catch (error) {
        console.error('Delete note error:', error)
        return errorResponse('Failed to delete note', 500)
    }
}
