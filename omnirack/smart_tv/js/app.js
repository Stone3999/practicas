// vars
const cards = {
  A: document.getElementById('dcA'),
  B: document.getElementById('dcB'),
  C: document.getElementById('dcC'),
  D: document.getElementById('dcD')
};

const bgVideo = document.getElementById('bgVideo');
const splash = document.getElementById('splashScreen');
const clockEl = document.getElementById('clock');
const btnClose = document.getElementById('btnCloseApp');

let racksData = [];

// clock
setInterval(() => {
  const d = new Date();
  clockEl.innerText = d.toLocaleTimeString([], {hour: '2-digit', minute:'2-digit'});
}, 1000);

// close
if (btnClose) {
  btnClose.addEventListener('click', () => {
    window.close();
  });
}

// render
function renderCards() {
  ['A', 'B', 'C', 'D'].forEach(dc => {
    const cardRacks = racksData.filter(r => r.dataCenter === dc);
    if (!cardRacks.length) return;
    
    let totalTemp = 0;
    let count = 0;
    let hasAlert = false;
    
    cardRacks.forEach((r, idx) => {
      if (r.latest) {
        totalTemp += Number(r.latest.temperature) || 0;
        count++;
        // Llenar la barra
        if (idx < 6) {
          const barEl = document.getElementById(`bar-${dc}-${idx}`);
          if (barEl) {
            const h = Math.min(100, (Number(r.latest.temperature) / 40) * 100);
            barEl.style.height = h + '%';
            if (r.status === 'alert' || r.status === 'warning') {
              barEl.style.backgroundColor = 'var(--status-alert)';
            } else {
              barEl.style.backgroundColor = 'var(--status-ok)';
            }
          }
        }
      }
      if (r.status === 'alert' || r.status === 'warning') hasAlert = true;
    });
    
    const tempEl = document.getElementById('temp' + dc);
    const statEl = document.getElementById('status' + dc);
    
    if (count > 0) {
      tempEl.innerText = (totalTemp / count).toFixed(1) + '°C';
    }
    
    if (hasAlert) {
      statEl.innerText = '⚠️ Alerta';
      statEl.className = 'status-alert';
    } else {
      statEl.innerText = '✔️ Estable';
      statEl.className = 'status-ok';
    }
  });
}

// init
async function init() {
  try {
    const res = await fetch('/api/racks');
    if (!res.ok) throw new Error(`HTTP ${res.status}`);
    const body = await res.json();
    racksData = body.racks || body || [];
    renderCards();
    
    // simulador visual (demo) si no hay wearable conectado
    setInterval(() => {
      let changed = false;
      racksData.forEach(r => {
        if (r.latest) {
          const fluctuation = (Math.random() * 2) - 1; // -1.0 a +1.0
          let newTemp = r.latest.temperature + fluctuation;
          if (newTemp > 40) newTemp = 40;
          if (newTemp < 15) newTemp = 15;
          r.latest.temperature = newTemp;
          changed = true;
        }
      });
      if (changed) renderCards();
    }, 5000);
    
    // splash
    setTimeout(() => {
      splash.classList.add('hidden');
    }, 500);
    
  } catch (err) {
    console.error(err);
  }
}
init();

// navigation bg video
document.querySelectorAll('.dc-slide').forEach(card => {
  card.addEventListener('card-select', (e) => {
    // lazy load video
    if (bgVideo.src.indexOf('cctv_optimized.mp4') === -1) {
      bgVideo.src = '/assets/videos/cctv_optimized.mp4';
      bgVideo.play().catch(e => console.log(e));
    }
  });
});

const cctvModal = document.getElementById('cctvModal');
const cctvVideo = document.getElementById('cctvVideo');

document.querySelectorAll('.slide-cctv-btn').forEach(btn => {
  btn.addEventListener('click', () => {
    cctvModal.classList.remove('hidden');
    if (cctvVideo.src.indexOf('cctv_v2.mp4') === -1) {
      cctvVideo.src = '/assets/videos/cctv_v2.mp4';
    }
    cctvVideo.play().catch(e => console.log(e));
  });
});

if (cctvModal) {
  cctvModal.addEventListener('click', () => {
    cctvModal.classList.add('hidden');
    cctvVideo.pause();
  });
}

// sse
const ALLOWED_ORIGIN = window.location.origin;
if (window.OmniRackChannel) {
  window.OmniRackChannel.onmessage = (event) => {
    if (event.origin !== '' && event.origin !== ALLOWED_ORIGIN) return;
    
    const { type, payload } = event.data;
    if (type === 'sensor' || type === 'alert') {
      const index = racksData.findIndex(r => r.id === payload.rackId);
      if (index !== -1) {
        if (type === 'sensor') {
          racksData[index].latest = payload.reading;
          racksData[index].status = payload.status;
        } else {
          racksData[index].status = 'alert';
        }
        renderCards();
      }
    }
  };
}
