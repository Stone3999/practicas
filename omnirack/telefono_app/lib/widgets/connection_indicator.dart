import 'package:flutter/material.dart';
import '../services/ble_client.dart';

class ConnectionIndicator extends StatelessWidget {
  final BleConnectionState state;

  const ConnectionIndicator({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    Color color;
    String text;

    switch (state) {
      case BleConnectionState.connected:
        color = const Color(0xFF40F000);
        text = 'Conectado via BLE';
        break;
      case BleConnectionState.scanning:
        color = const Color(0xFFE0B840);
        text = 'Buscando wearable...';
        break;
      case BleConnectionState.simulating:
        color = Colors.blue;
        text = 'Modo simulación';
        break;
      case BleConnectionState.error:
        color = const Color(0xFFC81030);
        text = 'Error de conexión';
        break;
      case BleConnectionState.disconnected:
        color = const Color(0xFF181818);
        text = 'Desconectado';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: const Color(0xFFFFFFFF),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          Text(text, style: const TextStyle(color: Color(0xFF181818))),
        ],
      ),
    );
  }
}
