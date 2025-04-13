import { createClient } from 'redis'
import type { RedisClientType, RedisClientOptions } from 'redis'

// Extract host and password from the URL
const redisUrl = new URL(process.env.REDIS_URL || 'redis://localhost:6379')
const host = redisUrl.hostname
const password = redisUrl.password
console.log(`[REDIS] Attempting to connect to Redis at: ${host}`)

// Error state that can be exposed to the application
export let redisConnectionError: Error | null = null;

// Attempt to connect to Redis, expose error if it fails
let redis: RedisClientType<any>

const clientOptions: RedisClientOptions = {
  socket: {
    host,
    port: 6380,
    tls: true,
    rejectUnauthorized: false,
    reconnectStrategy: (retries: number) => {
      console.log(`[REDIS] Reconnection attempt ${retries}`)
      if (retries > 20) {
        console.log('[REDIS] Maximum reconnection attempts reached')
        return new Error('Maximum reconnection attempts reached')
      }
      return Math.min(retries * 100, 3000) // Exponential backoff, max 3s
    }
  },
  password
}

try {
  const client = createClient(clientOptions)
  
  client.on('error', (err) => {
    console.error('[REDIS] Client connection error:', err.message)
    redisConnectionError = err
  })
  
  client.on('connect', () => {
    console.log('[REDIS] Connected successfully')
    redisConnectionError = null
  })

  client.on('reconnecting', () => {
    console.log('[REDIS] Attempting to reconnect...')
  })

  client.on('ready', () => {
    console.log('[REDIS] Client is ready')
  })

  client.on('end', () => {
    console.log('[REDIS] Connection closed')
  })
  
  // Connect in the background
  client.connect().catch((err) => {
    console.error('[REDIS] Failed to connect:', err.message)
    redisConnectionError = err
  })

  redis = client
} catch (error) {
  console.error('[REDIS] Error during Redis initialization:', error)
  redisConnectionError = error instanceof Error ? error : new Error('Unknown Redis error')
  // Create a minimal client that will error correctly
  const client = createClient(clientOptions)
  redis = client
}

export { redis }