'use strict';

/* componente */

function evaluate(rack, reading) {
  const t = rack.thresholds;
  const issues = [];
  let severity = 0; // logica

  const consider = (level, metric, message, value, threshold) => {
    issues.push({ level, metric, message, value, threshold });
    if (level === 'alert') severity = Math.max(severity, 2);
    else if (level === 'warning') severity = Math.max(severity, 1);
  };

  // logica
  if (t.temperature) {
    const v = reading.temperature;
    if (v >= t.temperature.alert) {
      consider('alert', 'temperature', `Temperatura critica ${v.toFixed(1)}°C (max ${t.temperature.alert}°C)`, v, t.temperature.alert);
    } else if (v >= t.temperature.warning) {
      consider('warning', 'temperature', `Temperatura elevada ${v.toFixed(1)}°C (aviso ${t.temperature.warning}°C)`, v, t.temperature.warning);
    }
  }

  // logica
  if (t.humidity) {
    const v = reading.humidity;
    if (v <= t.humidity.alertMin || v >= t.humidity.alertMax) {
      consider('alert', 'humidity', `Humedad fuera de rango critico ${v.toFixed(0)}%`, v, `${t.humidity.alertMin}-${t.humidity.alertMax}`);
    } else if (v <= t.humidity.warningMin || v >= t.humidity.warningMax) {
      consider('warning', 'humidity', `Humedad fuera de rango ${v.toFixed(0)}%`, v, `${t.humidity.warningMin}-${t.humidity.warningMax}`);
    }
  }

  // logica
  if (t.power) {
    const v = reading.power;
    if (v >= t.power.alert) {
      consider('alert', 'power', `Consumo critico ${v.toFixed(2)} kW (max ${t.power.alert} kW)`, v, t.power.alert);
    } else if (v >= t.power.warning) {
      consider('warning', 'power', `Consumo elevado ${v.toFixed(2)} kW (aviso ${t.power.warning} kW)`, v, t.power.warning);
    }
  }

  // logica
  if (t.door && t.door.openIsAlert && reading.door) {
    consider('alert', 'door', 'Puerta del rack abierta', true, 'cerrada');
  }

  const status = severity === 2 ? 'alert' : severity === 1 ? 'warning' : 'ok';
  return { status, issues };
}

function buildAlert(rack, reading, issues) {
  const critical = issues.filter((i) => i.level === 'alert');
  const warning = issues.filter((i) => i.level === 'warning');
  const primary = critical[0] || warning[0];
  return {
    id: `ALT-${Date.now()}-${Math.floor(Math.random() * 1000)}`,
    rackId: rack.id,
    rackName: rack.name,
    severity: primary.level,
    metric: primary.metric,
    message: primary.message,
    value: primary.value,
    threshold: primary.threshold,
    issues,
    timestamp: reading.timestamp || new Date().toISOString(),
    acknowledged: false,
    acknowledgedBy: null
  };
}

module.exports = { evaluate, buildAlert };
