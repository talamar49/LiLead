import { NextRequest } from 'next/server'
import { writeFile, mkdir } from 'fs/promises'
import { join } from 'path'
import { existsSync } from 'fs'
import { getUserFromRequest } from '@/lib/auth'
import { successResponse, errorResponse, unauthorizedResponse } from '@/lib/api-response'

// POST /api/upload/avatar - Upload user avatar
export async function POST(request: NextRequest) {
    const user = await getUserFromRequest(request)
    if (!user) {
        return unauthorizedResponse()
    }

    try {
        const formData = await request.formData()
        const file = formData.get('avatar') as File | null

        if (!file) {
            return errorResponse('No file provided', 400)
        }

        // Validate file type
        const allowedTypes = ['image/jpeg', 'image/jpg', 'image/png', 'image/webp']
        if (!allowedTypes.includes(file.type)) {
            return errorResponse('Invalid file type. Only JPEG, PNG, and WebP are allowed', 400)
        }

        // Validate file size (5MB max)
        const maxSize = 5 * 1024 * 1024 // 5MB
        if (file.size > maxSize) {
            return errorResponse('File size too large. Maximum 5MB allowed', 400)
        }

        // Create unique filename
        const timestamp = Date.now()
        const extension = file.name.split('.').pop() || 'jpg'
        const filename = `avatar-${user.id}-${timestamp}.${extension}`

        // Ensure upload directory exists
        const uploadDir = join(process.cwd(), 'public', 'uploads', 'avatars')
        if (!existsSync(uploadDir)) {
            await mkdir(uploadDir, { recursive: true })
        }

        // Save file
        const buffer = Buffer.from(await file.arrayBuffer())
        const filepath = join(uploadDir, filename)
        await writeFile(filepath, buffer)

        // Return URL
        const avatarUrl = `/uploads/avatars/${filename}`

        return successResponse({ avatarUrl }, 'Avatar uploaded successfully')
    } catch (error) {
        console.error('Upload avatar error:', error)
        return errorResponse('Failed to upload avatar', 500)
    }
}



