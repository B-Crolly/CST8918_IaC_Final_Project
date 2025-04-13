import { redis, redisConnectionError } from '../data-access/redis-connection'

const API_KEY = process.env.WEATHER_API_KEY
const BASE_URL = 'https://api.openweathermap.org/data/2.5/weather'
const TEN_MINUTES = 1000 * 60 * 10 // in milliseconds

interface FetchWeatherDataParams {
  lat: number
  lon: number
  units: 'standard' | 'metric' | 'imperial'
}

export async function fetchWeatherData({
  lat,
  lon,
  units,
}: FetchWeatherDataParams) {
  const queryString = `lat=${lat}&lon=${lon}&units=${units}`

  // Immediately check for Redis errors - fail fast
  if (redisConnectionError) {
    console.warn('[WEATHER] Redis is unavailable, bypassing cache:', redisConnectionError.message)
    // Instead of throwing, immediately fetch from the API
    const response = await fetch(`${BASE_URL}?${queryString}&appid=${API_KEY}`)
    const data = await response.json()
    return {
      ...data,
      _cache_status: 'REDIS_ERROR'  // Add flag to indicate cache status
    }
  }

  try {
    // Try to get from cache
    const cacheEntry = await redis.get(queryString)
    if (cacheEntry) {
      const data = JSON.parse(cacheEntry)
      return {
        ...data,
        _cache_status: 'HIT'  // Add flag to indicate cache hit
      }
    }

    // Fetch from API if not in cache
    const response = await fetch(`${BASE_URL}?${queryString}&appid=${API_KEY}`)
    const data = await response.text() // avoid an unnecessary extra JSON.stringify
    
    // Try to cache it, but don't fail if Redis errors
    try {
      await redis.set(queryString, data, { PX: TEN_MINUTES }) 
    } catch (cacheError) {
      console.error('[WEATHER] Failed to cache weather data:', cacheError)
    }
    
    const parsedData = JSON.parse(data)
    return {
      ...parsedData,
      _cache_status: 'MISS'  // Add flag to indicate cache miss
    }
  } catch (error) {
    console.error('[WEATHER] Error fetching weather data, using direct API call:', error)
    
    // Fallback to direct API call
    const response = await fetch(`${BASE_URL}?${queryString}&appid=${API_KEY}`)
    const data = await response.json()
    return {
      ...data,
      _cache_status: 'ERROR'  // Add flag to indicate error
    }
  }
}

export async function getGeoCoordsForPostalCode(
  postalCode: string,
  countryCode: string,
) {
  const url = `http://api.openweathermap.org/geo/1.0/zip?zip=${postalCode},${countryCode}&appid=${API_KEY}`
  const response = await fetch(url)
  const data = response.json()
  return data
}