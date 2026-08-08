import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'providers/rack_provider.dart';
import 'screens/main_screen.dart';

Future<void> main() async {
  await dotenv.load(fileName: ".env");
  runApp(const OmnirackApp());
}

class OmnirackApp extends StatelessWidget {
  const OmnirackApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => RackProvider()),
      ],
      child: MaterialApp(
        title: 'OMNIRACK',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          scaffoldBackgroundColor: const Color(0xFFF8F8F8),
          primaryColor: const Color(0xFFC81030),
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFFC81030),
            primary: const Color(0xFFC81030),
            secondary: const Color(0xFFE0B840),
            surface: const Color(0xFFFFFFFF),
            onPrimary: const Color(0xFFFFFFFF),
            onSurface: const Color(0xFF181818),
          ),
          appBarTheme: const AppBarTheme(
            backgroundColor: Color(0xFFFFFFFF),
            elevation: 1,
            iconTheme: IconThemeData(color: Color(0xFF181818)),
            titleTextStyle: TextStyle(color: Color(0xFF181818), fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ),
        home: const MainScreen(),
      ),
    );
  }
}
