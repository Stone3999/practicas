'use strict';

const express = require('express');
const store = require('../lib/store');
const { evaluate, buildAlert } = require('../lib/thresholds');
const sse = require('../lib/sse');
const auth = require('../lib/auth');

const router = express.Router();

/* componente */
router.get('/', (req, res) => {
  const d = store.get();
  res.json({
    racks: d.racks.map(({ latest, ...rack }) => ({
      ...rack,
      latest,
      hasData: latest !== null
    })),
    count: d.racks.length
  });
});

/* componente */
router.get('/:id', (req, res) => {
  const d = store.get();
  const rack = d.racks.find((r) => r.id === req.params.id);
  if (!rack) return res.status(404).json({ error: 'rack no encontrado' });
  res.json(rack);
});

/* componente */
router.post('/', (req, res) => {
  const authCheck = auth.validate(req.headers['x-omnirack-token'], 'rack:configure');
  if (!authCheck.ok) return res.status(401).json({ error: authCheck.reason });
  const d = store.get();
  const body = req.body || {};
  if (!body.id || !body.name) return res.status(400).json({ error: 'id y name son obligatorios' });
  if (d.racks.some((r) => r.id === body.id)) return res.status(409).json({ error: 'el rack ya existe' });
  const rack = {
    id: body.id,
    name: body.name,
    dataCenter: body.dataCenter || 'Unknown',
    location: body.location || 'Sin ubicacion',
    ip: body.ip || '0.0.0.0',
    model: body.model || 'Rack OmniMan',
    camera: body.camera || body.id.toLowerCase(),
    status: 'ok',
    thresholds: body.thresholds || {
      temperature: { warning: 30, alert: 35, unit: 'C' },
      humidity: { warningMin: 20, warningMax: 75, alertMin: 10, alertMax: 85, unit: '%' },
      power: { warning: 8, alert: 9.5, unit: 'kW' },
      door: { openIsAlert: true }
    },
    latest: null
  };
  d.racks.push(rack);
  store.persist();
  sse.broadcast('rack-created', { rackId: rack.id, name: rack.name });
  res.status(201).json(rack);
});

/* componente */
router.put('/:id', (req, res) => {
  const authCheck = auth.validate(req.headers['x-omnirack-token'], 'rack:configure');
  if (!authCheck.ok) return res.status(401).json({ error: authCheck.reason });
  const d = store.get();
  const rack = d.racks.find((r) => r.id === req.params.id);
  if (!rack) return res.status(404).json({ error: 'rack no encontrado' });
  const body = req.body || {};
  if (body.name !== undefined) rack.name = body.name;
  if (body.location !== undefined) rack.location = body.location;
  if (body.ip !== undefined) rack.ip = body.ip;
  if (body.model !== undefined) rack.model = body.model;
  if (body.thresholds !== undefined) rack.thresholds = { ...rack.thresholds, ...body.thresholds };
  store.persist();
  sse.broadcast('rack-updated', { rackId: rack.id, thresholds: rack.thresholds });
  res.json(rack);
});

/* componente */
router.delete('/:id', (req, res) => {
  const authCheck = auth.validate(req.headers['x-omnirack-token'], 'rack:configure');
  if (!authCheck.ok) return res.status(401).json({ error: authCheck.reason });
  const d = store.get();
  const idx = d.racks.findIndex((r) => r.id === req.params.id);
  if (idx === -1) return res.status(404).json({ error: 'rack no encontrado' });
  const [removed] = d.racks.splice(idx, 1);
  d.readings = d.readings.filter((r) => r.rackId !== removed.id);
  store.persist();
  sse.broadcast('rack-deleted', { rackId: removed.id });
  res.json({ ok: true, removed: removed.id });
});

/* componente */
router.post('/:id/data', (req, res) => {
  const d = store.get();
  const rack = d.racks.find((r) => r.id === req.params.id);
  if (!rack) return res.status(404).json({ error: 'rack no encontrado' });

  const body = req.body || {};
  const reading = {
    temperature: Number(body.temperature),
    humidity: Number(body.humidity),
    power: Number(body.power),
    door: !!body.door,
    alert: !!body.alert,
    timestamp: body.timestamp || new Date().toISOString()
  };

  if ([reading.temperature, reading.humidity, reading.power].some((n) => Number.isNaN(n))) {
    return res.status(400).json({ error: 'temperature, humidity y power son numeros obligatorios' });
  }

  const record = store.addReading(rack.id, reading);
  if (!record) return res.status(404).json({ error: 'rack no encontrado' });

  const { status, issues } = evaluate(rack, reading);
  const prevStatus = rack.status;
  store.setRackStatus(rack.id, status);

  let alert = null;
  if (issues.length > 0) {
    alert = buildAlert(rack, reading, issues);
    store.addAlert(alert);
    sse.broadcast('alert', alert);
  }

  sse.broadcast('sensor', {
    rackId: rack.id,
    rackName: rack.name,
    status,
    prevStatus,
    reading: { ...record, alert: alert ? alert.id : null }
  });

  res.status(201).json({ ok: true, status, alert: alert ? { id: alert.id, severity: alert.severity, message: alert.message } : null });
});

/* componente */
router.get('/:id/data', (req, res) => {
  const d = store.get();
  if (!d.racks.some((r) => r.id === req.params.id)) {
    return res.status(404).json({ error: 'rack no encontrado' });
  }
  const readings = store.getReadings(req.params.id, {
    from: req.query.from,
    to: req.query.to,
    limit: req.query.limit || 100
  });
  res.json({ rackId: req.params.id, count: readings.length, readings });
});

/* componente */
router.delete('/:id/data', (req, res) => {
  const authCheck = auth.validate(req.headers['x-omnirack-token'], 'rack:configure');
  if (!authCheck.ok) return res.status(401).json({ error: authCheck.reason });
  const removed = store.deleteReadings(req.params.id, {
    from: req.query.from,
    to: req.query.to
  });
  sse.broadcast('data-purged', { rackId: req.params.id, removed });
  res.json({ ok: true, removed });
});

module.exports = router;
