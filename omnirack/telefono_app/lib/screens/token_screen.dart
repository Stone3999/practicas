import 'package:flutter/material.dart';
import '../services/api_service.dart';

class TokenScreen extends StatefulWidget {
  const TokenScreen({super.key});

  @override
  State<TokenScreen> createState() => _TokenScreenState();
}

class _TokenScreenState extends State<TokenScreen> {
  final ApiService _apiService = ApiService();
  String? _token;
  bool _isLoading = false;

  Future<void> _generateToken() async {
    setState(() {
      _isLoading = true;
    });
    final token = await _apiService.generateToken();
    setState(() {
      _token = token;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F8F8),
      appBar: AppBar(
        title: const Text('Generar Token', style: TextStyle(color: Color(0xFF181818))),
        backgroundColor: const Color(0xFFFFFFFF),
        iconTheme: const IconThemeData(color: Color(0xFF181818)),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (_isLoading)
              const CircularProgressIndicator(color: Color(0xFFC81030))
            else if (_token != null) ...[
              const Text('Token generado:', style: TextStyle(fontSize: 18)),
              const SizedBox(height: 10),
              Text(
                _token!,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFA01828),
                ),
              ),
            ] else
              const Text('No hay token generado', style: TextStyle(fontSize: 18)),
            const SizedBox(height: 30),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFC81030),
                foregroundColor: const Color(0xFFFFFFFF),
              ),
              onPressed: _generateToken,
              child: const Text('Generar Nuevo Token'),
            ),
          ],
        ),
      ),
    );
  }
}
