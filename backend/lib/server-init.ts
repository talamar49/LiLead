// Initialize notification scheduler on server startup
import { initializeNotificationScheduler } from './notification-scheduler'

// Only initialize in Node.js runtime, not in Edge runtime
// Check if we're in a Node.js environment
const isNodeRuntime = typeof process !== 'undefined' && 
                      process.versions && 
                      process.versions.node &&
                      typeof EdgeRuntime === 'undefined'

// Initialize once when the module is loaded (only in Node.js runtime)
if (process.env.NODE_ENV !== 'test' && isNodeRuntime) {
    // Defer initialization to avoid blocking
    setImmediate(() => {
        try {
            initializeNotificationScheduler()
        } catch (error) {
            console.error('Failed to initialize notification scheduler:', error)
        }
    })
}

export { initializeNotificationScheduler }

