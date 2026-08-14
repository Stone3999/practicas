// logica
const focusables = [
  'dcA', 'cctvA',
  'dcB', 'cctvB',
  'dcC', 'cctvC',
  'dcD', 'cctvD'
];

const NAV_MAP = {
  // A
  0: { right: 2, down: 1 },
  1: { right: 3, up: 0 },
  // B
  2: { left: 0, right: 4, down: 3 },
  3: { left: 1, right: 5, up: 2 },
  // C
  4: { left: 2, right: 6, down: 5 },
  5: { left: 3, right: 7, up: 4 },
  // D
  6: { left: 4, down: 7 },
  7: { left: 5, up: 6 }
};

let currentIdx = 0;

function updateFocus(newIdx) {
  if (newIdx === null || newIdx === undefined) return;
  
  const oldEl = document.getElementById(focusables[currentIdx]);
  if (oldEl) {
    oldEl.classList.remove('focused');
    oldEl.setAttribute('tabindex', '-1');
  }
  
  currentIdx = newIdx;
  const newEl = document.getElementById(focusables[currentIdx]);
  if (newEl) {
    newEl.classList.add('focused');
    newEl.setAttribute('tabindex', '0');
    newEl.focus();
  }

  // Desplazar carrusel basado en el Data Center activo
  const track = document.getElementById('carouselTrack');
  const dcIndex = Math.floor(currentIdx / 2); // 0, 1, 2, 3
  if (track) {
    track.style.transform = `translateX(-${dcIndex * 100}%)`;
  }
}

document.addEventListener('keydown', (e) => {
  const map = NAV_MAP[currentIdx];
  let newIdx = currentIdx;
  
  const modal = document.getElementById('cctvModal');
  if (!modal.classList.contains('hidden')) {
    if (e.key === 'Escape' || e.key === 'Enter') {
      modal.classList.add('hidden');
      const cctvVideo = document.getElementById('cctvVideo');
      if (cctvVideo) cctvVideo.pause();
    }
    return;
  }
  
  switch(e.key) {
    case 'ArrowUp': newIdx = map.up; break;
    case 'ArrowDown': newIdx = map.down; break;
    case 'ArrowLeft': newIdx = map.left; break;
    case 'ArrowRight': newIdx = map.right; break;
    case 'Enter':
      const activeEl = document.getElementById(focusables[currentIdx]);
      if (activeEl) {
        if (activeEl.id.startsWith('cctv')) {
          activeEl.click();
        } else {
          activeEl.dispatchEvent(new CustomEvent('card-select', { bubbles: true }));
        }
      }
      return;
    default: return;
  }
  
  if (newIdx !== undefined) {
    e.preventDefault();
    updateFocus(newIdx);
  }
});
