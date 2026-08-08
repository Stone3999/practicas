'use strict';

const express = require('express');
const auth = require('../lib/auth');
const store = require('../lib/store');

const router = express.Router();

/* componente */
router.post('/token', (req, res) => {
  const scope = req.body && req.body.scope ? req.body.scope : 'rack:configure';
  const t = auth.generate(scope);
  res.status(201).json(t);
});

/* componente */
router.get('/tokens', (req, res) => {
  res.json({ count: auth.listActive().length, tokens: auth.listActive() });
});

/* componente */
router.delete('/tokens', (req, res) => {
  auth.revokeAll();
  res.json({ ok: true });
});

module.exports = router;
