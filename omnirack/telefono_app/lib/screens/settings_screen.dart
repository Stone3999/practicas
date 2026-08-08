import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/rack_provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
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
            leading: const Icon(Icons.watch),
            title: const Text('Vincular Wearable'),
            subtitle: const Text('Configurar Data Center y Rack'),
            onTap: () => _showWearableConfigDialog(context),
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

  void _showWearableConfigDialog(BuildContext context) {
    String selectedDc = 'DC-Norte';
    String selectedRack = 'Rack-01';

    final dcs = ['DC-Norte', 'DC-Sur', 'DC-Este', 'DC-Oeste'];
    final racks = ['Rack-01', 'Rack-02', 'Rack-03', 'Rack-04', 'Rack-05', 'Rack-06'];

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Vincular Wearable'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Seleccione el Data Center y el Rack a monitorear.'),
                  const SizedBox(height: 16),
                  DropdownButton(
                    value: selectedDc,
                    isExpanded: true,
                    hint: const Text('Data Center'),
                    items: dcs.map((dc) => DropdownMenuItem(value: dc, child: Text(dc))).toList(),
                    onChanged: (val) {
                      if (val != null) setState(() => selectedDc = val);
                    },
                  ),
                  const SizedBox(height: 16),
                  DropdownButton(
                    value: selectedRack,
                    isExpanded: true,
                    hint: const Text('Rack'),
                    items: racks.map((rack) => DropdownMenuItem(value: rack, child: Text(rack))).toList(),
                    onChanged: (val) {
                      if (val != null) setState(() => selectedRack = val);
                    },
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: const Text('Cancelar', style: TextStyle(color: Colors.grey)),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFC81030)),
                  onPressed: () async {
                    Navigator.pop(dialogContext); // logica
                    final provider = Provider.of<RackProvider>(context, listen: false);
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Escribiendo configuración...')));
                    
                    final success = await provider.writeWearableConfig(selectedDc, selectedRack);
                    if (!context.mounted) return;
                    
                    if (success) {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('¡Wearable configurado con éxito!')));
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Simulación: Wearable configurado con éxito.')));
                    }
                  },
                  child: const Text('Vincular', style: TextStyle(color: Colors.white)),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
