import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'screens/login_page.dart';
import 'screens/home_page.dart'; // o tu pantalla principal después del login

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Carga las variables del archivo .env
  await dotenv.load(fileName: ".env");

  // Inicializa Supabase con tus claves
  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL']!,
    anonKey: dotenv.env['SUPABASE_ANON_KEY']!,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Supabase + Flutter 💜',
      theme: ThemeData(primarySwatch: Colors.deepPurple),
      home: AuthGate(), // Pantalla inicial: login o home
    );
  }
}

class AuthGate extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final session = Supabase.instance.client.auth.currentSession;

    // Si el usuario ya está logueado, ve al home
    if (session != null) {
      return const HomePage();
    }

    // Si no, muestra la pantalla de login
    return const LoginPage();
  }
}
