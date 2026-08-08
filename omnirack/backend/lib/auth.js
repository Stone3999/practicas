'use strict';

/* componente */
const crypto = require('crypto');
const store = require('./store');

const TTL_MS = 5 * 60 * 1000; // logica

function generate(scope = 'rack:configure') {
  const d = store.get();
  const token = crypto.randomBytes(18).toString('hex');
  const now = Date.now();
  const record = {
    token,
    scope,
    createdAt: new Date(now).toISOString(),
    expiresAt: new Date(now + TTL_MS).toISOString(),
    used: false
  };
  d.tokens.push(record);
  store.persist();
  return { token: `omni_${token}`, expiresAt: record.expiresAt, scope };
}

function validate(rawToken, scope) {
  const d = store.get();
  const token = String(rawToken || '').replace(/^omni_/, '');
  const now = Date.now();
  const rec = d.tokens.find((t) => t.token === token);
  if (!rec) return { ok: false, reason: 'token invalido' };
  if (rec.used) return { ok: false, reason: 'token ya usado' };
  if (new Date(rec.expiresAt).getTime() < now) return { ok: false, reason: 'token expirado' };
  if (scope && rec.scope !== scope) return { ok: false, reason: 'scope no permitido' };
  rec.used = true;
  store.persist();
  return { ok: true, rec };
}

function listActive() {
  const d = store.get();
  return d.tokens.filter((t) => !t.used && new Date(t.expiresAt).getTime() > Date.now());
}

function revokeAll() {
  const d = store.get();
  d.tokens = [];
  store.persist();
  return true;
}

module.exports = { generate, validate, listActive, revokeAll };
