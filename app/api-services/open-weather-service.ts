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

  // Check if Redis connection is working
  if (redisConnectionError) {
    throw new Error(`Redis connection error: ${redisConnectionError.message}`)
  }

  try {
    // Try to get from cache if Redis is connected
    const cacheEntry = await redis.get(queryString)
    if (cacheEntry) return JSON.parse(cacheEntry)

    // Fetch from API if not in cache
    const response = await fetch(`${BASE_URL}?${queryString}&appid=${API_KEY}`)
    const data = await response.text() // avoid an unnecessary extra JSON.stringify
    
    // Try to cache it, but don't fail if Redis is down
    try {
      await redis.set(queryString, data, { PX: TEN_MINUTES }) 
    } catch (cacheError) {
      console.error('[WEATHER] Failed to cache weather data:', cacheError)
    }
    
    return JSON.parse(data)
  } catch (error) {
    if (error instanceof Error && error.message.includes('Redis connection error')) {
      throw error; // Re-throw Redis connection errors
    }
    
    // For other errors, try direct API call as fallback
    console.error('[WEATHER] Error fetching weather data, trying direct API call:', error)
    const response = await fetch(`${BASE_URL}?${queryString}&appid=${API_KEY}`)
    const data = await response.json()
    return data
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