import { NextRequest } from 'next/server'
import { prisma } from '@/lib/prisma'
import { getUserFromRequest } from '@/lib/auth'
import { successResponse, errorResponse, unauthorizedResponse } from '@/lib/api-response'

// GET /api/stats - Get dashboard statistics
export async function GET(request: NextRequest) {
    const user = await getUserFromRequest(request)
    if (!user) {
        return unauthorizedResponse()
    }

    try {
        // Get counts by status
        const [newCount, inProcessCount, closedCount, notRelevantCount] = await Promise.all([
            prisma.lead.count({ where: { userId: user.id, status: 'NEW' } }),
            prisma.lead.count({ where: { userId: user.id, status: 'IN_PROCESS' } }),
            prisma.lead.count({ where: { userId: user.id, status: 'CLOSED' } }),
            prisma.lead.count({ where: { userId: user.id, status: 'NOT_RELEVANT' } }),
        ])

        // Get counts by source
        const [facebookCount, instagramCount, whatsappCount, tiktokCount, manualCount, webhookCount] = await Promise.all([
            prisma.lead.count({ where: { userId: user.id, source: 'FACEBOOK' } }),
            prisma.lead.count({ where: { userId: user.id, source: 'INSTAGRAM' } }),
            prisma.lead.count({ where: { userId: user.id, source: 'WHATSAPP' } }),
            prisma.lead.count({ where: { userId: user.id, source: 'TIKTOK' } }),
            prisma.lead.count({ where: { userId: user.id, source: 'MANUAL' } }),
            prisma.lead.count({ where: { userId: user.id, source: 'WEBHOOK' } }),
        ])

        // Get total leads
        const totalLeads = newCount + inProcessCount + closedCount + notRelevantCount

        // Get conversion rate (closed / total)
        const conversionRate = totalLeads > 0 ? (closedCount / totalLeads) * 100 : 0

        // Get recent leads (last 7 days)
        const sevenDaysAgo = new Date()
        sevenDaysAgo.setDate(sevenDaysAgo.getDate() - 7)

        const recentLeads = await prisma.lead.count({
            where: {
                userId: user.id,
                createdAt: {
                    gte: sevenDaysAgo,
                },
            },
        })

        const stats = {
            byStatus: {
                new: newCount,
                inProcess: inProcessCount,
                closed: closedCount,
                notRelevant: notRelevantCount,
            },
            bySource: {
                facebook: facebookCount,
                instagram: instagramCount,
                whatsapp: whatsappCount,
                tiktok: tiktokCount,
                manual: manualCount,
                webhook: webhookCount,
            },
            total: totalLeads,
            conversionRate: Math.round(conversionRate * 10) / 10, // Round to 1 decimal
            recentLeads,
        }

        return successResponse(stats)
    } catch (error) {
        console.error('Get stats error:', error)
        return errorResponse('Failed to fetch statistics', 500)
    }
}
