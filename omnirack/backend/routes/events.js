'use strict';

const express = require('express');
const sse = require('../lib/sse');

const router = express.Router();

/* componente */
router.get('/stream', (req, res) => {
  sse.subscribe(req, res);
});

module.exports = router;
