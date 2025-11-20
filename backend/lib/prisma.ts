// Ensure Prisma runtime picks a client engine; set to 'binary' by default for local dev
// Ensure Prisma runtime picks a client engine; set to 'binary' by default for local dev
process.env.PRISMA_CLIENT_ENGINE = process.env.PRISMA_CLIENT_ENGINE ?? 'binary'

// Use require so we can set env vars before loading the runtime.
// eslint-disable-next-line @typescript-eslint/no-var-requires
const { PrismaClient } = require('@prisma/client') as typeof import('@prisma/client')

let _prismaClient: import('@prisma/client').PrismaClient | null = null

const clientOptions: any = {
  log: process.env.NODE_ENV === 'development' ? ['query', 'error', 'warn'] : ['error'],
}

function createPrismaClient() {
  return new PrismaClient(clientOptions)
}

// Lazy proxy to avoid constructing PrismaClient during module import
export const prisma = new Proxy(
  {},
  {
    get(_, prop) {
      if (!_prismaClient) {
        _prismaClient = createPrismaClient()
        if (process.env.NODE_ENV !== 'production') {
          ;(globalThis as any).prisma = _prismaClient
        }
      }
      // @ts-ignore - forward property access to real client
      return (_prismaClient as any)[prop]
    },
    apply(_, thisArg, argArray) {
      if (!_prismaClient) _prismaClient = createPrismaClient()
      // @ts-ignore
      return (_prismaClient as any).apply(thisArg, argArray)
    },
  }
)
