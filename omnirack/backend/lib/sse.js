'use strict';

/* componente */
const { EventEmitter } = require('events');

const hub = new EventEmitter();
hub.setMaxListeners(0);

const clients = new Set();

function subscribe(req, res) {
  res.writeHead(200, {
    'Content-Type': 'text/event-stream',
    'Cache-Control': 'no-cache, no-transform',
    Connection: 'keep-alive',
    'X-Accel-Buffering': 'no',
    'Access-Control-Allow-Origin': '*'
  });
  res.write('retry: 3000\n\n');

  const client = { id: `sse-${Date.now()}-${Math.random().toString(36).slice(2)}`, res };
  clients.add(client);

  const heartbeat = setInterval(() => {
    try {
      res.write(': ping\n\n');
    } catch (_) {
      /* componente */
    }
  }, 25000);

  req.on('close', () => {
    clearInterval(heartbeat);
    clients.delete(client);
  });

  return client;
}

function broadcast(event, data) {
  const payload = `event: ${event}\ndata: ${JSON.stringify(data)}\n\n`;
  for (const c of clients) {
    try {
      c.res.write(payload);
    } catch (_) {
      clients.delete(c);
    }
  }
}

module.exports = { subscribe, broadcast };
