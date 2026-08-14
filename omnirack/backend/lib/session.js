'use strict';

/* componente */
// logica
// logica
// logica
/// Estado compartido de "vinculacion" entre el reloj y el celular: cual rack
/// esta activo y si el enlace esta encendido. Ambos dispositivos consultan y
/// actualizan este mismo estado, asi que detener desde cualquiera detiene al
/// otro, y cambiar el Data Center se refleja en ambos.
let state = {
  activeRackId: 'DC-A-RACK-01',
  linked: false,
  updatedAt: new Date().toISOString()
};

function get() {
  return { ...state };
}

function update(patch) {
  if (patch.activeRackId !== undefined) state.activeRackId = patch.activeRackId;
  if (patch.linked !== undefined) state.linked = !!patch.linked;
  state.updatedAt = new Date().toISOString();
  return get();
}

module.exports = { get, update };
