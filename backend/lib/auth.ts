import { NextRequest } from 'next/server'
import jwt from 'jsonwebtoken'
import { prisma } from './prisma'

const JWT_SECRET = process.env.JWT_SECRET || 'your-secret-key'

export interface TokenPayload {
    userId: string
    email: string
}

export async function verifyToken(token: string): Promise<TokenPayload | null> {
    try {
        const decoded = jwt.verify(token, JWT_SECRET) as TokenPayload
        return decoded
    } catch (error) {
        return null
    }
}

export async function getUserFromRequest(request: NextRequest) {
    const authHeader = request.headers.get('authorization')

    if (!authHeader || !authHeader.startsWith('Bearer ')) {
        return null
    }

    const token = authHeader.substring(7)
    const payload = await verifyToken(token)

    if (!payload) {
        return null
    }

    const user = await prisma.user.findUnique({
        where: { id: payload.userId },
        select: {
            id: true,
            email: true,
            name: true,
            avatarUrl: true,
        },
    })

    return user
}

export function generateToken(payload: TokenPayload): string {
    return jwt.sign(payload, JWT_SECRET, { expiresIn: '30d' })
}
