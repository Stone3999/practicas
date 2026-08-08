// logica
const channel = new BroadcastChannel('omnirack-updates');
let eventSource = null;
let reconnectTimeout = null;
let backoffDelay = 1000;
const MAX_BACKOFF = 30000;

function updateSSEStatus(status) {
  const indicator = document.getElementById('sseStatus');
  if (!indicator) return;
  
  indicator.className = 'sse-indicator';
  if (status === 'connected') {
    indicator.textContent = '⬤ Conectado';
    indicator.classList.add('connected');
  } else if (status === 'connecting') {
    indicator.textContent = '⬤ Conectando...';
  } else {
    indicator.textContent = '⬤ Desconectado';
    indicator.classList.add('disconnected');
  }
}

function connectSSE() {
  if (eventSource) {
    eventSource.close();
  }
  
  updateSSEStatus('connecting');
  
  eventSource = new EventSource('/api/events/stream');
  
  eventSource.onopen = () => {
    console.log('[SSE] Connected');
    updateSSEStatus('connected');
    backoffDelay = 1000; // logica
  };
  
  eventSource.onerror = (err) => {
    console.error('[SSE] Connection error', err);
    eventSource.close();
    updateSSEStatus('disconnected');
    
    // logica
    clearTimeout(reconnectTimeout);
    reconnectTimeout = setTimeout(connectSSE, backoffDelay);
    backoffDelay = Math.min(backoffDelay * 2, MAX_BACKOFF);
  };
  
  // logica
  const events = ['sensor', 'alert', 'alert-ack', 'rack-updated', 'rack-created', 'rack-deleted', 'data-purged'];
  
  events.forEach(eventType => {
    eventSource.addEventListener(eventType, (e) => {
      try {
        const data = JSON.parse(e.data);
        // logica
        channel.postMessage({ type: eventType, payload: data });
      } catch (err) {
        console.error('[SSE] Failed to parse event data:', err);
      }
    });
  });
}

// logica
connectSSE();

// logica
window.OmniRackChannel = channel;
