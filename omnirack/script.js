const fs = require('fs');
const path = require('path');
const dbPath = path.join('backend', 'data', 'db.json');
const db = JSON.parse(fs.readFileSync(dbPath, 'utf8'));

const dcs = ['A', 'B', 'C', 'D'];
const locations = ['CDMX', 'Queretaro', 'GDL', 'MTY'];
const newRacks = [];

for (let i = 0; i < dcs.length; i++) {
  const dc = dcs[i];
  for (let j = 1; j <= 6; j++) {
    const rackId = `DC-${dc}-RACK-0${j}`;
    newRacks.push({
      id: rackId,
      name: `Rack ${j}`,
      dataCenter: dc,
      location: `Sala ${i+1} - ${locations[i]}`,
      ip: `10.0.${i}.${10+j}`,
      model: 'Rack OmniMan 42U',
      camera: `rack-${dc.toLowerCase()}-${j}`,
      status: 'ok',
      thresholds: {
        temperature: { warning: 28, alert: 34, unit: 'C' },
        humidity: { warningMin: 20, warningMax: 75, alertMin: 10, alertMax: 85, unit: '%' },
        power: { warning: 8, alert: 9.5, unit: 'kW' },
        door: { openIsAlert: true }
      },
      latest: {
        rackId: rackId,
        temperature: 20 + Math.random() * 10,
        humidity: 50,
        power: 5,
        door: false,
        alert: false,
        timestamp: new Date().toISOString()
      }
    });
  }
}

db.racks = newRacks;
db.readings = [];
db.alerts = [];

fs.writeFileSync(dbPath, JSON.stringify(db, null, 2));
console.log('db.json updated');
