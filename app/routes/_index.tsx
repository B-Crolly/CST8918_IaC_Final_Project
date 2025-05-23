import { json } from '@remix-run/node'
import { useLoaderData } from '@remix-run/react'
import { fetchWeatherData } from '../api-services/open-weather-service'
import { capitalizeFirstLetter } from '../utils/text-formatting'
import type { MetaFunction } from '@remix-run/node'
import { redisConnectionError } from '../data-access/redis-connection'

export const meta: MetaFunction = () => {
  return [
    { title: 'Remix Weather' },
    {
      name: 'description',
      content: 'A demo web app using Remix and OpenWeather API.',
    },
  ]
}

const location = {
  city: 'Ottawa',
  postalCode: 'K2G 1V8', // Algonquin College, Woodroffe Campus
  lat: 45.3211,
  lon: -75.7391,
  countryCode: 'CA',
}
const units = 'metric'

export async function loader() {
  // TODO: accept query params for location and units
  // TODO: look up location by postal code

  try {
    // Check Redis connection status first
    const hasRedisError = redisConnectionError !== null;
    const redisErrorMessage = hasRedisError && redisConnectionError ? redisConnectionError.message : null;
    
    const data = await fetchWeatherData({
      lat: location.lat,
      lon: location.lon,
      units: units,
    })
    
    return json({
      currentConditions: data,
      cacheStatus: data._cache_status,
      redisError: redisErrorMessage,
      error: null
    })
  } catch (error) {
    console.error('Failed to fetch weather data:', error)
    let errorMessage = 'An unexpected error occurred'
    
    if (error instanceof Error) {
      if (error.message.includes('Redis connection error')) {
        errorMessage = 'Redis server is unavailable. Weather data cannot be cached.'
      } else {
        errorMessage = error.message
      }
    }
    
    return json({ 
      currentConditions: null, 
      cacheStatus: 'ERROR',
      redisError: redisConnectionError?.message,
      error: errorMessage 
    })
  }
}

export default function CurrentConditions() {
  const { currentConditions, error, cacheStatus, redisError } = useLoaderData<typeof loader>()
  
  // If there's a major error, display it
  if (error) {
    return (
      <main style={{
        padding: '1.5rem',
        fontFamily: 'system-ui, sans-serif',
        lineHeight: '1.8',
      }}>
        <h1>Remix Weather App</h1>
        <div style={{
          backgroundColor: '#FEE2E2',
          color: '#B91C1C',
          padding: '1rem',
          borderRadius: '0.25rem',
          marginTop: '1rem',
          marginBottom: '1rem',
          border: '1px solid #F87171'
        }}>
          <h2>Error</h2>
          <p>{error}</p>
        </div>
        <p>
          Please try again later or contact support if this issue persists.
        </p>
      </main>
    )
  }
  
  // Otherwise, display weather data
  const weather = currentConditions.weather[0]
  return (
    <>
      <main
        style={{
          padding: '1.5rem',
          fontFamily: 'system-ui, sans-serif',
          lineHeight: '1.8',
        }}
      >
        <h1>Remix Weather- CI/CD Test 1 & 2</h1>
        
        {/* Redis error notification */}
        {redisError && (
          <div style={{
            backgroundColor: '#FEF3C7',
            color: '#92400E',
            padding: '0.75rem',
            borderRadius: '0.25rem',
            marginTop: '0.5rem',
            marginBottom: '1rem',
            border: '1px solid #F59E0B',
            fontSize: '0.9rem'
          }}>
            <strong>Redis Cache Unavailable:</strong> {redisError}
          </div>
        )}
        
        <p>
          For Algonquin College, Woodroffe Campus <br />
          <span style={{ color: 'hsl(220, 23%, 60%)' }}>
            (LAT: {location.lat}, LON: {location.lon})
          </span>
        </p>
        <h2>Current Conditions</h2>
        <div
          style={{
            display: 'flex',
            flexDirection: 'row',
            gap: '2rem',
            alignItems: 'center',
          }}
        >
          <img src={getWeatherIconUrl(weather.icon)} alt="" />
          <div style={{ fontSize: '2rem' }}>
            {currentConditions.main.temp.toFixed(1)}°C
          </div>
        </div>
        <p
          style={{
            fontSize: '1.2rem',
            fontWeight: '400',
          }}
        >
          {capitalizeFirstLetter(weather.description)}. Feels like{' '}
          {currentConditions.main['feels_like'].toFixed(1)}°C.
          <br />
          <span style={{ color: 'hsl(220, 23%, 60%)', fontSize: '0.85rem' }}>
            updated at{' '}
            {new Intl.DateTimeFormat('en-CA', {
              year: 'numeric',
              month: 'long',
              day: 'numeric',
              hour: 'numeric',
              minute: '2-digit',
            }).format(currentConditions.dt * 1000)}
            {' '}- Cache Status: <span style={{fontWeight: 'bold'}}>{cacheStatus}</span>
          </span>
        </p>
      </main>
      <section
        style={{
          backgroundColor: 'hsl(220, 54%, 96%)',
          padding: '0.5rem 1.5rem 1rem 1.5rem',
          borderRadius: '0.25rem',
        }}
      >
        <h2>Raw Data</h2>
        <pre>{JSON.stringify(currentConditions, null, 2)}</pre>
      </section>
      <hr style={{ marginTop: '2rem' }} />
      <p>
        Learn how to customize this app. Read the{' '}
        <a target="_blank" href="https://remix.run/docs" rel="noreferrer">
          Remix Docs
        </a>
      </p>
    </>
  )
}

function getWeatherIconUrl(iconCode: string) {
  return `http://openweathermap.org/img/wn/${iconCode}@2x.png`
}
