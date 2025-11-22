import { NextRequest } from 'next/server'
import { getUserFromRequest } from '@/lib/auth'
import { successResponse, unauthorizedResponse } from '@/lib/api-response'

export async function GET(request: NextRequest) {
    const user = await getUserFromRequest(request)

    if (!user) {
        return unauthorizedResponse()
    }

    return successResponse(user)
}
