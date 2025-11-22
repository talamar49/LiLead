import { NextResponse } from 'next/server'

export interface ApiResponse<T = any> {
    success: boolean
    data?: T
    error?: string
    message?: string
}

export function successResponse<T>(data: T, message?: string): NextResponse<ApiResponse<T>> {
    return NextResponse.json({
        success: true,
        data,
        message,
    })
}

export function errorResponse(error: string, status: number = 400): NextResponse<ApiResponse> {
    return NextResponse.json(
        {
            success: false,
            error,
        },
        { status }
    )
}

export function unauthorizedResponse(): NextResponse<ApiResponse> {
    return NextResponse.json(
        {
            success: false,
            error: 'Unauthorized',
        },
        { status: 401 }
    )
}

export function notFoundResponse(message: string = 'Resource not found'): NextResponse<ApiResponse> {
    return NextResponse.json(
        {
            success: false,
            error: message,
        },
        { status: 404 }
    )
}
