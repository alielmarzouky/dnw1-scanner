var CACHE_NAME = 'dnw1-scanner-v4';
var URLS_TO_CACHE = [
    './',
    './index.html',
    './manifest.json'
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
    // NEVER cache API calls
    if (!shouldCache(event.request.url)) {
        event.respondWith(
            fetch(event.request).catch(function() {
                return new Response(JSON.stringify({error:'offline'}), {headers:{'Content-Type':'application/json'}});
            })
        );
        return;
    }

    event.respondWith(
        caches.match(event.request).then(function(response) {
            return response || fetch(event.request).then(function(fetchResponse) {
                if (event.request.method === 'GET') {
                    var clone = fetchResponse.clone();
                    caches.open(CACHE_NAME).then(function(cache) { cache.put(event.request, clone) });
                }
                return fetchResponse;
            });
        }).catch(function() { return caches.match('./index.html') })
    );
});
