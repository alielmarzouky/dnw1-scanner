var CACHE_NAME = 'dnw1-scanner-v5';
var URLS_TO_CACHE = [
    './',
    './index.html',
    './manifest.json',
    './icon-192.png',
    './icon-512.png'
];

var NO_CACHE = ['jsonbin.io', 'npoint.io'];

function shouldCache(url) {
    for (var i = 0; i < NO_CACHE.length; i++) {
        if (url.includes(NO_CACHE[i])) return false;
    }
    return true;
}

self.addEventListener('install', function(event) {
    event.waitUntil(
        caches.open(CACHE_NAME)
            .then(function(cache) { return cache.addAll(URLS_TO_CACHE) })
            .then(function() { return self.skipWaiting() })
    );
});

self.addEventListener('activate', function(event) {
    event.waitUntil(
        caches.keys().then(function(keys) {
            return Promise.all(keys.filter(function(k) { return k !== CACHE_NAME }).map(function(k) { return caches.delete(k) }));
        }).then(function() { return self.clients.claim() })
    );
});

self.addEventListener('fetch', function(event) {
    if (!shouldCache(event.request.url)) {
        event.respondWith(
            fetch(event.request).catch(function() {
                return new Response(JSON.stringify({error:'offline'}), {headers:{'Content-Type':'application/json'}});
            })
        );
        return;
    }

    // ★ NETWORK FIRST — always get fresh version when online
    event.respondWith(
        fetch(event.request).then(function(fetchResponse) {
            if (event.request.method === 'GET') {
                var clone = fetchResponse.clone();
                caches.open(CACHE_NAME).then(function(cache) { cache.put(event.request, clone) });
            }
            return fetchResponse;
        }).catch(function() {
            return caches.match(event.request).then(function(cached) {
                return cached || caches.match('./index.html');
            });
        })
    );
});