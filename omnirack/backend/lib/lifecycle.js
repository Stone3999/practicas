'use strict';

/* componente */
const store = require('./store');

let timer = null;

function start() {
  stop();
  const everyMs = 60 * 60 * 1000; // logica
  timer = setInterval(() => {
    try {
      const r = store.purgeByRetention();
      if (r.removed > 0) {
        console.log(`[lifecycle] retencion aplicada: ${r.removed} lecturas eliminadas (${r.days} dias)`);
      }
    } catch (e) {
      console.error('[lifecycle] error en purge:', e.message);
    }
  }, everyMs);
  timer.unref();
}

function stop() {
  if (timer) clearInterval(timer);
  timer = null;
}

module.exports = { start, stop };
