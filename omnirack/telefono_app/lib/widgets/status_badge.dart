import 'package:flutter/material.dart';

class StatusBadge extends StatelessWidget {
  final String status;

  const StatusBadge({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    Color color;
    switch (status.toLowerCase()) {
      case 'ok':
      case 'normal':
        color = const Color(0xFF40F000);
        break;
      case 'warning':
        color = const Color(0xFFE0B840);
        break;
      case 'alert':
        color = const Color(0xFFC81030);
        break;
      default:
        color = const Color(0xFF181818);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        status.toUpperCase(),
        style: const TextStyle(color: Color(0xFFFFFFFF), fontSize: 12, fontWeight: FontWeight.bold),
      ),
    );
  }
}
