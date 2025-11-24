import { PrismaClient } from '@prisma/client'

// Ensure Prisma runtime picks a client engine; set to 'binary' by default for local dev
process.env.PRISMA_CLIENT_ENGINE = process.env.PRISMA_CLIENT_ENGINE ?? 'binary'

const prismaClientSingleton = () => {
  return new PrismaClient({
    log: process.env.NODE_ENV === 'development' ? ['query', 'error', 'warn'] : ['error'],
  })
}

declare global {
  var prismaGlobal: undefined | ReturnType<typeof prismaClientSingleton>
}

export const prisma = globalThis.prismaGlobal ?? prismaClientSingleton()

if (process.env.NODE_ENV !== 'production') globalThis.prismaGlobal = prisma

