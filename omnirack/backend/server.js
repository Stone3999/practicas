'use strict';

/* componente */
require('dotenv').config();

const path = require('path');
const express = require('express');
const cors = require('cors');

const store = require('./lib/store');
const lifecycle = require('./lib/lifecycle');
const sse = require('./lib/sse');

const racksRouter = require('./routes/racks');
const alertsRouter = require('./routes/alerts');
const authRouter = require('./routes/auth');
const eventsRouter = require('./routes/events');

const PORT = Number(process.env.PORT) || 3000;
const app = express();

app.use(cors());
app.use(express.json({ limit: '1mb' }));

// logica
app.get('/api/health', (req, res) => {
  const d = store.get();
  res.json({
    ok: true,
    project: d.meta.project,
    org: d.meta.org,
    time: new Date().toISOString(),
    uptime: process.uptime(),
    clientsSSE: sse ? 'activo' : 'inactivo'
  });
});

// logica
app.get('/api/meta', (req, res) => {
  const d = store.get();
  res.json({
    retentionDays: Number(process.env.DATA_RETENTION_DAYS) || d.meta.retentionDays,
    maxReadingsPerRack: Number(process.env.MAX_READINGS_PER_RACK) || d.meta.maxReadingsPerRack,
    totalReadings: d.readings.length,
    totalAlerts: d.alerts.length,
    purgeEndpoint: 'POST /api/data/purge'
  });
});

// logica
app.post('/api/data/purge', (req, res) => {
  const r = store.purgeByRetention();
  sse.broadcast('data-purged', { scope: 'retencion', ...r });
  res.json({ ok: true, ...r });
});

// logica
app.use('/api/racks', racksRouter);
app.use('/api/alerts', alertsRouter);
app.use('/api/auth', authRouter);
app.use('/api/events', eventsRouter);

// logica
const tvDir = path.join(__dirname, '..', 'smart_tv');
app.use(express.static(tvDir));

// logica
app.get('/', (req, res) => res.sendFile(path.join(tvDir, 'index.html')));

// logica
app.use('/api', (req, res) => res.status(404).json({ error: 'endpoint no existe' }));

store.load();
lifecycle.start();

app.listen(PORT, () => {
  console.log(`[omnirack] API lista en http://localhost:${PORT}`);
  console.log(`[omnirack] Smart TV (PWA) en http://localhost:${PORT}/`);
  console.log(`[omnirack] SSE en http://localhost:${PORT}/api/events/stream`);
});
