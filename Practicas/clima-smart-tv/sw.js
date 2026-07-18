// sw.js
const CACHE_STATIC = 'clima-tv-static-v1';
const CACHE_DYNAMIC = 'clima-tv-dynamic-v1';

const STATIC_ASSETS = [
  '/index.html',
  '/css/styles.css',
  '/js/app.js',
  '/js/weather.js',
  '/js/navigation.js',
  '/manifest.json',
  '/icons/icon-192.png',
  '/icons/icon-512.png',
  '/assets/posters/clear.jpg',
  '/assets/posters/cloudy.jpg',
  '/assets/posters/rain.jpg',
  '/assets/posters/thunder.jpg'
];

self.addEventListener('install', e => {
  e.waitUntil(
    caches.open(CACHE_STATIC).then(cache =>
      Promise.allSettled(
        STATIC_ASSETS.map(url =>
          fetch(url).then(res => {
            if (res.ok) return cache.put(url, res);
          })
        )
      )
    ).then(() => self.skipWaiting())
  );
});

self.addEventListener('activate', e => {
  e.waitUntil(
    caches.keys().then(keys =>
      Promise.all(
        keys
          .filter(k => k !== CACHE_STATIC && k !== CACHE_DYNAMIC)
          .map(k => caches.delete(k))
      )
    ).then(() => self.clients.claim())
  );
});

self.addEventListener('fetch', e => {
  const request = e.request;
  const url = new URL(request.url);

  if (url.hostname === 'api.openweathermap.org') {
    e.respondWith(networkFirst(request));
    return;
  }

  if (request.url.includes('/assets/videos/')) {
    e.respondWith(cacheFirst(request));
    return;
  }

  e.respondWith(cacheFirst(request));
});

async function cacheFirst(request) {
  const cached = await caches.match(request);
  if (cached) return cached;

  const response = await fetch(request);
  if (request.url.startsWith('http') && response.status === 200) {
    const cache = await caches.open(CACHE_DYNAMIC);
    cache.put(request, response.clone());
  }
  return response;
}

async function networkFirst(request) {
  try {
    const response = await fetch(request, { signal: AbortSignal.timeout(5000) });
    if (request.url.startsWith('http') && response.status === 200) {
      const cache = await caches.open(CACHE_DYNAMIC);
      cache.put(request, response.clone());
    }
    return response;
  } catch (err) {
    const cached = await caches.match(request);
    return cached || new Response(JSON.stringify({ error: 'Sin conexion' }), {
      headers: { 'Content-Type': 'application/json' }
    });
  }
}
