import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/rack_provider.dart';
import '../services/rack_link_client.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<RackProvider>(context);
    final isConnected = provider.connectionState == LinkState.connected;
    final isConnecting = provider.connectionState == LinkState.connecting;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F8F8),
      appBar: AppBar(
        title: const Text('Configuración', style: TextStyle(color: Color(0xFF181818), fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFFFFFFFF),
      ),
      body: ListView(
        children: [
          const ListTile(
            title: Text('General', style: TextStyle(color: Color(0xFFC81030), fontWeight: FontWeight.bold)),
          ),
          ListTile(
            leading: Icon(Icons.watch, color: isConnected ? const Color(0xFF40F000) : null),
            title: const Text('Vincular Wearable'),
            subtitle: Text(
              isConnected
                  ? 'Vinculado con ${provider.selectedRackId} (IP local)'
                  : 'Toca para conectar con el rack ${provider.selectedRackId}',
            ),
            trailing: isConnecting
                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                : Icon(isConnected ? Icons.link_off : Icons.chevron_right,
                    color: isConnected ? const Color(0xFF40F000) : null),
            onTap: isConnecting
                ? null
                : () async {
                    if (isConnected) {
                      await provider.disconnect();
                      return;
                    }
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Conectando por IP local...')),
                    );
                    await provider.connect();
                  },
          ),
          ListTile(
            leading: const Icon(Icons.notifications),
            title: const Text('Notificaciones'),
            trailing: Switch(value: true, onChanged: (v) {}),
          ),
          ListTile(
            leading: const Icon(Icons.language),
            title: const Text('Idioma'),
            trailing: const Text('Español'),
            onTap: () {},
          ),
          const Divider(),
          const ListTile(
            title: Text('Cuenta', style: TextStyle(color: Color(0xFFC81030), fontWeight: FontWeight.bold)),
          ),
          ListTile(
            leading: const Icon(Icons.person),
            title: const Text('Perfil'),
            onTap: () {},
          ),
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('Cerrar Sesión'),
            onTap: () {},
          ),
        ],
      ),
    );
  }
}
