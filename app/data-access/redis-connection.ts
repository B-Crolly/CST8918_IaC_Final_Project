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
      reconnectStrategy: (retries) => {
        console.log(`[REDIS] Connection retry attempt ${retries}`)
        if (retries > 3) {
          console.error('[REDIS] Max retries reached, stopping reconnection attempts')
          redisConnectionError = new Error('Redis connection failed after multiple attempts')
          return new Error('Max retries reached')
        }
        return Math.min(retries * 100, 3000) // Increasing backoff
      }
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
  
  client.on('reconnecting', () => {
    console.log('[REDIS] Attempting to reconnect')
  })
  
  // Attempt to connect with a timeout
  const connectPromise = client.connect()
  const timeoutPromise = new Promise((_, reject) => {
    setTimeout(() => reject(new Error('Connection timeout')), 5000)
  })
  
  redis = await Promise.race([connectPromise, timeoutPromise])
    .then(() => client)
    .catch((err) => {
      console.error('[REDIS] Failed to connect:', err.message)
      redisConnectionError = err
      // Return the client anyway, operations will fail and be handled by the app
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