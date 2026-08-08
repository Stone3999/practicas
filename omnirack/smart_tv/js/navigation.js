// logica
const focusables = [
  'dcA', 'dcB', 'dcC', 'dcD',
  'btnMore', 'btnCCTV'
];

// logica
// logica
// logica
const NAV_MAP = {
  0: { down: 1, right: 4 },
  1: { up: 0, down: 2, right: 4 },
  2: { up: 1, down: 3, right: 5 },
  3: { up: 2, right: 5 },
  4: { left: 0, right: 5, down: 5 },
  5: { left: 4, up: 4, down: null, right: null }
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
}

document.addEventListener('keydown', (e) => {
  const map = NAV_MAP[currentIdx];
  let newIdx = currentIdx;
  
  // logica
  const modal = document.getElementById('cctvModal');
  if (!modal.classList.contains('hidden')) {
    if (e.key === 'Escape' || e.key === 'Enter') {
      modal.classList.add('hidden');
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
        activeEl.dispatchEvent(new CustomEvent('card-select', { bubbles: true }));
        activeEl.click();
      }
      return;
    default: return;
  }
  
  if (newIdx !== undefined) {
    e.preventDefault();
    updateFocus(newIdx);
  }
});

// logica
focusables.forEach((id, idx) => {
  const el = document.getElementById(id);
  if (el) {
    el.addEventListener('click', () => {
      updateFocus(idx);
    });
  }
});
