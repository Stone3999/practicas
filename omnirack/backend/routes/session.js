'use strict';

const express = require('express');
const store = require('../lib/store');
const session = require('../lib/session');
const sse = require('../lib/sse');

const router = express.Router();

/* componente */
router.get('/', (req, res) => {
  res.json(session.get());
});

/* componente */
router.put('/', (req, res) => {
  const body = req.body || {};

  if (body.activeRackId !== undefined) {
    const d = store.get();
    if (!d.racks.some((r) => r.id === body.activeRackId)) {
      return res.status(404).json({ error: 'rack no encontrado' });
    }
  }

  const updated = session.update(body);
  sse.broadcast('session-updated', updated);
  res.json(updated);
});

module.exports = router;
