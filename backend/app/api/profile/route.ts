import { NextRequest } from 'next/server'
import bcrypt from 'bcryptjs'
import { z } from 'zod'
import { prisma } from '@/lib/prisma'
import { getUserFromRequest } from '@/lib/auth'
import { successResponse, errorResponse, unauthorizedResponse } from '@/lib/api-response'

const updateProfileSchema = z.object({
    name: z.string().min(2).optional(),
    email: z.string().email().optional(),
    avatarUrl: z.string().optional().or(z.literal('')),
    currentPassword: z.string().optional(),
    newPassword: z.string().min(6).optional(),
})

// GET /api/profile - Get user profile
export async function GET(request: NextRequest) {
    const user = await getUserFromRequest(request)
    if (!user) {
        return unauthorizedResponse()
    }

    try {
        const profile = await prisma.user.findUnique({
            where: { id: user.id },
            select: {
                id: true,
                email: true,
                name: true,
                avatarUrl: true,
                createdAt: true,
                updatedAt: true,
            },
        })

        return successResponse(profile)
    } catch (error) {
        console.error('Get profile error:', error)
        return errorResponse('Failed to fetch profile', 500)
    }
}

// PATCH /api/profile - Update user profile
export async function PATCH(request: NextRequest) {
    const user = await getUserFromRequest(request)
    if (!user) {
        return unauthorizedResponse()
    }

    try {
        const body = await request.json()

        const validation = updateProfileSchema.safeParse(body)
        if (!validation.success) {
            return errorResponse(validation.error.issues[0].message, 400)
        }

        const { name, email, avatarUrl, currentPassword, newPassword } = validation.data

        // If changing password, verify current password
        if (newPassword) {
            if (!currentPassword) {
                return errorResponse('Current password is required to set a new password', 400)
            }

            const userWithPassword = await prisma.user.findUnique({
                where: { id: user.id },
            })

            if (!userWithPassword) {
                return errorResponse('User not found', 404)
            }

            const isValidPassword = await bcrypt.compare(currentPassword, userWithPassword.password)
            if (!isValidPassword) {
                return errorResponse('Current password is incorrect', 400)
            }
        }

        // Check if email is already taken by another user
        if (email && email !== user.email) {
            const existingUser = await prisma.user.findUnique({
                where: { email },
            })

            if (existingUser) {
                return errorResponse('Email is already taken', 400)
            }
        }

        // Prepare update data
        const updateData: any = {}
        if (name) updateData.name = name
        if (email) updateData.email = email
        if (avatarUrl !== undefined) updateData.avatarUrl = avatarUrl || null
        if (newPassword) {
            updateData.password = await bcrypt.hash(newPassword, 10)
        }

        const updatedUser = await prisma.user.update({
            where: { id: user.id },
            data: updateData,
            select: {
                id: true,
                email: true,
                name: true,
                avatarUrl: true,
                createdAt: true,
                updatedAt: true,
            },
        })

        return successResponse(updatedUser, 'Profile updated successfully')
    } catch (error) {
        console.error('Update profile error:', error)
        return errorResponse('Failed to update profile', 500)
    }
}
