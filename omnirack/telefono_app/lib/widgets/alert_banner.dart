import 'package:flutter/material.dart';

class AlertBanner extends StatelessWidget {
  final String message;

  const AlertBanner({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: const Color(0xFFC81030),
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          const Icon(Icons.warning, color: Color(0xFFFFFFFF)),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(color: Color(0xFFFFFFFF), fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}
