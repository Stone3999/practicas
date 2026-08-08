'use strict';

const express = require('express');
const store = require('../lib/store');
const sse = require('../lib/sse');

const router = express.Router();

/* componente */
router.get('/', (req, res) => {
  const alerts = store.getAlerts({
    acknowledged: req.query.acknowledged !== undefined ? req.query.acknowledged === 'true' : undefined,
    rackId: req.query.rackId,
    limit: req.query.limit || 50
  });
  res.json({ count: alerts.length, alerts });
});

/* componente */
router.post('/:id/ack', (req, res) => {
  const d = store.get();
  const alert = d.alerts.find((a) => a.id === req.params.id);
  if (!alert) return res.status(404).json({ error: 'alerta no encontrada' });
  if (alert.acknowledged) return res.status(409).json({ error: 'alerta ya confirmada', alert });

  const updated = store.updateAlert(alert.id, {
    acknowledged: true,
    acknowledgedAt: new Date().toISOString(),
    acknowledgedBy: req.body && req.body.by ? req.body.by : 'desconocido'
  });
  sse.broadcast('alert-ack', { id: alert.id, rackId: alert.rackId, acknowledgedBy: updated.acknowledgedBy });
  res.json({ ok: true, alert: updated });
});

module.exports = router;
