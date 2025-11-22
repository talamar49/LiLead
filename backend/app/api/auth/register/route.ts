import { NextRequest } from 'next/server'
import bcrypt from 'bcryptjs'
import { z } from 'zod'
import { prisma } from '@/lib/prisma'
import { generateToken } from '@/lib/auth'
import { successResponse, errorResponse } from '@/lib/api-response'

const registerSchema = z.object({
    email: z.string().email('Invalid email address'),
    name: z.string().min(2, 'Name must be at least 2 characters'),
    password: z.string().min(6, 'Password must be at least 6 characters'),
})

export async function POST(request: NextRequest) {
    try {
        const body = await request.json()

        // Validate input
        const validation = registerSchema.safeParse(body)
        if (!validation.success) {
            return errorResponse(validation.error.errors[0].message, 400)
        }

        const { email, name, password } = validation.data

        // Check if user already exists
        const existingUser = await prisma.user.findUnique({
            where: { email },
        })

        if (existingUser) {
            return errorResponse('User with this email already exists', 400)
        }

        // Hash password
        const hashedPassword = await bcrypt.hash(password, 10)

        // Create user
        const user = await prisma.user.create({
            data: {
                email,
                name,
                password: hashedPassword,
            },
            select: {
                id: true,
                email: true,
                name: true,
                avatarUrl: true,
                createdAt: true,
            },
        })

        // Generate token
        const token = generateToken({ userId: user.id, email: user.email })

        return successResponse(
            {
                user,
                token,
            },
            'User registered successfully'
        )
    } catch (error) {
        console.error('Register error:', error)
        return errorResponse('Internal server error', 500)
    }
}
