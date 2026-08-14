import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/rack_provider.dart';
import '../services/rack_link_client.dart';
import '../widgets/alert_banner.dart';
import '../widgets/connection_indicator.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<RackProvider>(context);
    final data = provider.currentData;

    bool isAlert = false;
    String alertMessage = '';

    if (data != null) {
      if (data.temperature >= 35) {
        isAlert = true;
        alertMessage = '¡Alerta de temperatura alta! (${data.temperature.toStringAsFixed(1)}°C)';
      } else if (data.door == 'OPEN') {
        isAlert = true;
        alertMessage = '¡Alerta! La puerta del rack está ABIERTA.';
      } else if (data.alert == 1) {
        isAlert = true;
        alertMessage = '¡Alerta general del sistema!';
      }
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF8F8F8),
      appBar: AppBar(
        title: const Text('OMNIRACK - Dashboard', style: TextStyle(color: Color(0xFF181818), fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFFFFFFFF),
      ),
      body: Column(
        children: [
          ConnectionIndicator(state: provider.connectionState),
          _DataCenterSelector(provider: provider),
          _ConnectButton(provider: provider),
          if (isAlert) AlertBanner(message: alertMessage),
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Estado de los Racks',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 1.2,
              ),
              itemCount: 6,
              itemBuilder: (context, index) {
                final rackNum = index + 1;
                // logica
                double temp = 25.0 + (index * 1.5); 
                bool hasAlert = false;

                if (rackNum == 1 && data != null) {
                  temp = data.temperature;
                  hasAlert = data.isAlert || data.temperature >= 35;
                } else if (rackNum == 3) {
                  temp = 36.5; // logica
                  hasAlert = true;
                }

                return Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Rack $rackNum',
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        const Spacer(),
                        Row(
                          children: [
                            const Icon(Icons.thermostat, color: Colors.grey, size: 20),
                            const SizedBox(width: 4),
                            Text(
                              '${temp.toStringAsFixed(1)} °C',
                              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                            ),
                          ],
                        ),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: hasAlert ? const Color(0xFFC81030).withAlpha(26) : const Color(0xFF40F000).withAlpha(26),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            hasAlert ? 'ALERTA' : 'NORMAL',
                            style: TextStyle(
                              color: hasAlert ? const Color(0xFFC81030) : const Color(0xFF2E9900),
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// logica
// logica
/// Botón único: Conectar vincula el celular al rack seleccionado (IP local
/// del backend) y enciende la sesión compartida; al tocarlo de nuevo,
/// Detener la apaga, y el reloj se detiene también.
class _ConnectButton extends StatelessWidget {
  final RackProvider provider;

  const _ConnectButton({required this.provider});

  @override
  Widget build(BuildContext context) {
    final state = provider.connectionState;
    final isConnected = state == LinkState.connected;
    final isConnecting = state == LinkState.connecting;
    final isActive = isConnected || isConnecting;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton.icon(
          onPressed: () => isActive ? provider.disconnect() : provider.connect(),
          icon: isConnecting
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                )
              : Icon(isConnected ? Icons.link_off : Icons.link),
          label: Text(isConnected ? 'Detener' : (isConnecting ? 'Conectando...' : 'Conectar')),
          style: ElevatedButton.styleFrom(
            backgroundColor: isActive ? const Color(0xFF40F000) : const Color(0xFFC81030),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
        ),
      ),
    );
  }
}

// logica
// logica
/// Selector de Data Center (A-D). Cambiarlo aquí re-vincula al Rack 1 de
/// ese DC y, si ya estamos conectados, se refleja de inmediato en el reloj.
class _DataCenterSelector extends StatelessWidget {
  final RackProvider provider;

  const _DataCenterSelector({required this.provider});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      child: Row(
        children: [
          const Text('Data Center:', style: TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(width: 8),
          Expanded(
            child: Wrap(
              spacing: 8,
              children: RackProvider.dataCenters.map((dc) {
                final selected = provider.dataCenter == dc;
                return ChoiceChip(
                  label: Text('DC-$dc'),
                  selected: selected,
                  selectedColor: const Color(0xFFC81030),
                  labelStyle: TextStyle(color: selected ? Colors.white : const Color(0xFF181818)),
                  onSelected: (_) => provider.selectDataCenter(dc),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}
