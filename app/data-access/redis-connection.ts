import { createClient, RedisClientType } from 'redis'

const url = process.env.REDIS_URL || 'redis://localhost:6379'
console.log(`[REDIS] Attempting to connect to Redis at: ${url.replace(/:[^:@]*@/, ':***@')}`)

// Error state that can be exposed to the application
export let redisConnectionError: Error | null = null;

// Attempt to connect to Redis, expose error if it fails
let redis: RedisClientType
try {
  const client = createClient({ 
    url,
    socket: {
      // Reduce the reconnection attempts to fail faster
      reconnectStrategy: false // Disable automatic reconnection
    }
  })
  
  client.on('error', (err) => {
    console.error('[REDIS] Client connection error', err)
    redisConnectionError = err
  })
  
  client.on('connect', () => {
    console.log('[REDIS] Connected successfully')
    redisConnectionError = null
  })
  
  // Attempt to connect with a short timeout
  const connectPromise = client.connect()
  const timeoutPromise = new Promise((_, reject) => {
    // Reduce timeout to fail faster - only wait 1 second
    setTimeout(() => reject(new Error('Redis connection timeout')), 1000)
  })
  
  redis = await Promise.race([connectPromise, timeoutPromise])
    .then(() => client)
    .catch((err) => {
      console.error('[REDIS] Failed to connect:', err.message)
      redisConnectionError = err
      // Return the client anyway, but with error state set
      return client
    })
} catch (error) {
  console.error('[REDIS] Error during Redis initialization:', error)
  redisConnectionError = error instanceof Error ? error : new Error('Unknown Redis error')
  // Create a minimal client that will error correctly
  const client = createClient({ url })
  redis = client as unknown as RedisClientType
}

export { redis }