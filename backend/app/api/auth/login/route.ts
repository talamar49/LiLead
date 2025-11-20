import { NextRequest } from 'next/server'
import bcrypt from 'bcryptjs'
import { z } from 'zod'
import { Client } from 'pg'
import { generateToken } from '@/lib/auth'
import { successResponse, errorResponse } from '@/lib/api-response'

const loginSchema = z.object({
    email: z.string().email('Invalid email address'),
    password: z.string().min(1, 'Password is required'),
})

export async function POST(request: NextRequest) {
    try {
        const body = await request.json()

        // Validate input
        const validation = loginSchema.safeParse(body)
        if (!validation.success) {
            return errorResponse(validation.error.errors[0].message, 400)
        }

        const { email, password } = validation.data

        // Query user directly using pg to avoid Prisma runtime issues
        const client = new Client({ connectionString: process.env.DATABASE_URL })
        await client.connect()
        try {
            const res = await client.query(
                `SELECT id, email, name, password, "avatarUrl", "createdAt" FROM users WHERE email = $1 LIMIT 1`,
                [email]
            )

            if (res.rowCount === 0) {
                return errorResponse('Invalid email or password', 401)
            }

            const user = res.rows[0]

            const isValidPassword = await bcrypt.compare(password, user.password)
            if (!isValidPassword) {
                return errorResponse('Invalid email or password', 401)
            }

            const token = generateToken({ userId: user.id, email: user.email })

            return successResponse(
                {
                    user: {
                        id: user.id,
                        email: user.email,
                        name: user.name,
                        avatarUrl: user.avatarUrl,
                        createdAt: user.createdAt,
                    },
                    token,
                },
                'Login successful'
            )
        } finally {
            await client.end()
        }
    } catch (error) {
        console.error('Login error:', error)
        return errorResponse('Internal server error', 500)
    }
}
