const CACHE_STATIC = 'omnirack-tv-static-v1';
const CACHE_DYNAMIC = 'omnirack-tv-dynamic-v1';

const STATIC_ASSETS = [
  '/index.html',
  '/css/styles.css',
  '/js/app.js',
  '/js/navigation.js',
  '/js/sse-client.js',
  '/manifest.json'
  // logica
];

self.addEventListener('install', (event) => {
  self.skipWaiting();
  event.waitUntil(
    caches.open(CACHE_STATIC).then((cache) => {
      console.log('[SW] Pre-caching static assets');
      return cache.addAll(STATIC_ASSETS);
    })
  );
});

self.addEventListener('activate', (event) => {
  event.waitUntil(
    caches.keys().then((keyList) => {
      return Promise.all(
        keyList.map((key) => {
          if (key !== CACHE_STATIC && key !== CACHE_DYNAMIC) {
            console.log('[SW] Removing old cache', key);
            return caches.delete(key);
          }
        })
      );
    })
  );
  return self.clients.claim();
});

self.addEventListener('fetch', (event) => {
  const url = new URL(event.request.url);

  // logica
  if (url.pathname.includes('/api/events/stream')) {
    return;
  }

  // logica
  if (url.pathname.includes('/api/')) {
    event.respondWith(
      fetchWithTimeout(event.request, 5000)
        .then((response) => {
          return caches.open(CACHE_DYNAMIC).then((cache) => {
            cache.put(event.request.url, response.clone());
            return response;
          });
        })
        .catch(() => {
          return caches.match(event.request);
        })
    );
    return;
  }

  // logica
  if (url.pathname.includes('/assets/videos/')) {
    event.respondWith(
      caches.match(event.request).then((response) => {
        if (response) return response;
        return fetch(event.request).then((networkRes) => {
          return caches.open(CACHE_DYNAMIC).then((cache) => {
            cache.put(event.request.url, networkRes.clone());
            return networkRes;
          });
        });
      })
    );
    return;
  }

  // logica
  event.respondWith(
    caches.match(event.request).then((response) => {
      if (response) return response;
      return fetch(event.request)
        .then((networkRes) => {
          return caches.open(CACHE_DYNAMIC).then((cache) => {
            cache.put(event.request.url, networkRes.clone());
            return networkRes;
          });
        })
        .catch((err) => {
          // logica
          if (event.request.headers.get('accept').includes('text/html')) {
            return caches.match('/index.html');
          }
        });
    })
  );
});

// logica
function fetchWithTimeout(request, timeout) {
  return new Promise((resolve, reject) => {
    const timer = setTimeout(() => reject(new Error('Request timed out')), timeout);
    fetch(request).then((response) => {
      clearTimeout(timer);
      resolve(response);
    }).catch((err) => {
      clearTimeout(timer);
      reject(err);
    });
  });
}
