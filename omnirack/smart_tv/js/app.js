// logica
const bars = [
  document.getElementById('bar1'),
  document.getElementById('bar2'),
  document.getElementById('bar3'),
  document.getElementById('bar4'),
  document.getElementById('bar5'),
  document.getElementById('bar6')
];
const dcStatuses = {
  A: document.getElementById('statusA'),
  B: document.getElementById('statusB'),
  C: document.getElementById('statusC'),
  D: document.getElementById('statusD')
};
const btnCCTV = document.getElementById('btnCCTV');
const cctvModal = document.getElementById('cctvModal');

let currentDC = 'A';
let racksData = [];

// logica
btnCCTV.addEventListener('click', () => {
  cctvModal.classList.remove('hidden');
});

const btnCloseApp = document.getElementById('btnCloseApp');
if (btnCloseApp) {
  btnCloseApp.addEventListener('click', () => {
    window.close();
  });
}

function updateDCStatus(dc) {
  const dcRacks = racksData.filter(r => r.dataCenter === dc);
  const statusEl = dcStatuses[dc];
  if (!statusEl) return;
  
  if (dcRacks.some(r => r.status === 'alert' || r.status === 'warning')) {
    statusEl.innerHTML = '⚠️ Alerta';
    statusEl.className = 'dc-status status-alert';
  } else {
    statusEl.innerHTML = '✔️ Estable';
    statusEl.className = 'dc-status status-ok';
  }
}

function renderBars() {
  const dcRacks = racksData.filter(r => r.dataCenter === currentDC);
  // logica
  dcRacks.sort((a, b) => a.name.localeCompare(b.name));
  
  for (let i = 0; i < 6; i++) {
    const rack = dcRacks[i];
    const bar = bars[i];
    if (rack && rack.latest && rack.latest.temperature) {
      let temp = Number(rack.latest.temperature);
      let pct = Math.max(0, Math.min(100, (temp / 50) * 100)); 
      bar.style.height = `${pct}%`;
    } else {
      bar.style.height = `0%`;
    }
  }
}

// logica
async function initRacks() {
  try {
    const res = await fetch('/api/racks');
    if (!res.ok) throw new Error(`HTTP ${res.status}`);
    const body = await res.json();
    racksData = body.racks || body || [];
    
    // logica
    ['A', 'B', 'C', 'D'].forEach(updateDCStatus);
    
    // logica
    renderBars();
  } catch (err) {
    console.error('Error fetching racks:', err);
  }
}
initRacks();

// logica
document.querySelectorAll('.dc-btn').forEach(btn => {
  btn.addEventListener('click', (e) => {
    // logica
    // logica
    const btnEl = e.currentTarget;
    currentDC = btnEl.getAttribute('data-dc');
    renderBars();
  });
  // logica
  btn.addEventListener('card-select', (e) => {
    const btnEl = e.currentTarget;
    currentDC = btnEl.getAttribute('data-dc');
    renderBars();
  });
});

// logica
const ALLOWED_ORIGIN = window.location.origin;
if (window.OmniRackChannel) {
  window.OmniRackChannel.onmessage = (event) => {
    if (event.origin !== '' && event.origin !== ALLOWED_ORIGIN) return;
    
    const { type, payload } = event.data;
    
    if (type === 'sensor' || type === 'alert') {
      const rackId = payload.rackId;
      const index = racksData.findIndex(r => r.id === rackId);
      
      if (index !== -1) {
        if (type === 'sensor') {
          racksData[index].latest = payload.reading;
          racksData[index].status = payload.status;
        } else if (type === 'alert') {
          racksData[index].status = 'alert';
        }
        
        updateDCStatus(racksData[index].dataCenter);
        if (racksData[index].dataCenter === currentDC) {
          renderBars();
        }
      }
    }
  };
}
