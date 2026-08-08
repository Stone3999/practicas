'use strict';

/* componente */
const fs = require('fs');
const path = require('path');

const DATA_DIR = path.join(__dirname, '..', 'data');
const DB_FILE = path.join(DATA_DIR, 'db.json');
const SEED_FILE = path.join(DATA_DIR, 'racks.seed.json');

let db = null;

function load() {
  if (fs.existsSync(DB_FILE)) {
    try {
      db = JSON.parse(fs.readFileSync(DB_FILE, 'utf8'));
      return db;
    } catch (e) {
      console.error('[store] db.json corrupto, regenerando desde seed:', e.message);
    }
  }
  db = JSON.parse(fs.readFileSync(SEED_FILE, 'utf8'));
  db.meta.createdAt = new Date().toISOString();
  persist();
  return db;
}

function persist() {
  const tmp = DB_FILE + '.tmp';
  fs.mkdirSync(DATA_DIR, { recursive: true });
  fs.writeFileSync(tmp, JSON.stringify(db, null, 2));
  fs.renameSync(tmp, DB_FILE);
}

function get() {
  if (!db) load();
  return db;
}

/* componente */
function addReading(rackId, reading) {
  const d = get();
  const rack = d.racks.find((r) => r.id === rackId);
  if (!rack) return null;

  const record = {
    rackId,
    temperature: reading.temperature,
    humidity: reading.humidity,
    power: reading.power,
    door: !!reading.door,
    alert: !!reading.alert,
    timestamp: reading.timestamp || new Date().toISOString()
  };

  d.readings.push(record);
  if (!rack.latest || (record.timestamp > rack.latest.timestamp)) {
    rack.latest = record;
  }

  const max = Number(process.env.MAX_READINGS_PER_RACK) || db.meta.maxReadingsPerRack || 5000;
  const rackReadings = d.readings.filter((r) => r.rackId === rackId);
  const overflow = rackReadings.length - max;
  if (overflow > 0) {
    const toDrop = new Set(rackReadings.slice(0, overflow).map((r) => r));
    d.readings = d.readings.filter((r) => !toDrop.has(r));
  }

  persist();
  return record;
}

/* componente */
function getReadings(rackId, { from, to, limit = 100 } = {}) {
  const d = get();
  let list = d.readings.filter((r) => r.rackId === rackId);
  if (from) list = list.filter((r) => r.timestamp >= from);
  if (to) list = list.filter((r) => r.timestamp <= to);
  list.sort((a, b) => a.timestamp.localeCompare(b.timestamp));
  return list.slice(-Number(limit));
}

/* componente */
function deleteReadings(rackId, { from, to } = {}) {
  const d = get();
  let list = d.readings.filter((r) => r.rackId === rackId);
  if (from) list = list.filter((r) => r.timestamp >= from);
  if (to) list = list.filter((r) => r.timestamp <= to);
  const ids = new Set(list);
  d.readings = d.readings.filter((r) => !ids.has(r));
  const rack = d.racks.find((r) => r.id === rackId);
  if (rack && rack.latest && ids.has(rack.latest)) {
    rack.latest = d.readings.filter((r) => r.rackId === rackId).slice(-1)[0] || null;
  }
  persist();
  return list.length;
}

/* componente */
function purgeByRetention() {
  const d = get();
  const days = Number(process.env.DATA_RETENTION_DAYS) || d.meta.retentionDays || 30;
  const cutoff = new Date(Date.now() - days * 24 * 60 * 60 * 1000).toISOString();
  const before = d.readings.length;
  d.readings = d.readings.filter((r) => r.timestamp >= cutoff);
  const removed = before - d.readings.length;
  if (removed > 0) persist();
  return { removed, cutoff, days };
}

function setRackStatus(rackId, status) {
  const d = get();
  const rack = d.racks.find((r) => r.id === rackId);
  if (!rack) return null;
  rack.status = status;
  persist();
  return rack;
}

function addAlert(alert) {
  const d = get();
  d.alerts.push(alert);
  persist();
  return alert;
}

function updateAlert(id, patch) {
  const d = get();
  const a = d.alerts.find((x) => x.id === id);
  if (!a) return null;
  Object.assign(a, patch);
  persist();
  return a;
}

function getAlerts({ acknowledged, rackId, limit = 50 } = {}) {
  const d = get();
  let list = d.alerts.slice();
  if (acknowledged !== undefined) list = list.filter((a) => a.acknowledged === acknowledged);
  if (rackId) list = list.filter((a) => a.rackId === rackId);
  list.sort((a, b) => b.timestamp.localeCompare(a.timestamp));
  return list.slice(0, Number(limit));
}

module.exports = {
  load,
  get,
  persist,
  addReading,
  getReadings,
  deleteReadings,
  purgeByRetention,
  setRackStatus,
  addAlert,
  updateAlert,
  getAlerts
};
