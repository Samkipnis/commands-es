// Offline cache for "Команди ES". Bump VERSION whenever index.html or the audio folder changes.
const VERSION = 'komandy-es-v3';
const SHELL = ['./', './index.html', './manifest.webmanifest', './icons/icon-192.png', './icons/icon-512.png', './icons/apple-touch-icon.png', './audio/index.json'];

self.addEventListener('install', e => {
  e.waitUntil((async () => {
    const cache = await caches.open(VERSION);
    await cache.addAll(SHELL);
    // Pre-cache every bundled audio file listed in audio/index.json, so audio works offline from day one.
    try {
      const index = await (await cache.match('./audio/index.json')).json();
      const files = [...new Set(Object.values(index))].map(f => './audio/' + f);
      for (let i = 0; i < files.length; i += 10) await cache.addAll(files.slice(i, i + 10));
    } catch (err) { /* no bundled audio yet */ }
    await self.skipWaiting();
  })());
});

self.addEventListener('activate', e => {
  e.waitUntil(caches.keys()
    .then(keys => Promise.all(keys.filter(k => k !== VERSION).map(k => caches.delete(k))))
    .then(() => self.clients.claim()));
});

// Serve from cache first (works offline), refresh the cache in the background.
self.addEventListener('fetch', e => {
  const req = e.request;
  if (req.method !== 'GET' || new URL(req.url).origin !== location.origin || req.headers.has('range')) return;
  e.respondWith(caches.open(VERSION).then(async cache => {
    const hit = await cache.match(req, {ignoreSearch: true});
    const net = fetch(req).then(res => { if (res.ok) cache.put(req, res.clone()); return res; }).catch(() => hit);
    return hit || net;
  }));
});
