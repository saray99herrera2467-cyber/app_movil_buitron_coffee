import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'providers/carrito_provider.dart';
import 'screens/login_screen.dart';

const String supabaseUrl =
    'https://pzlytvmkpbhlmqskizgn.supabase.co';

const String supabasePublishableKey =
    'sb_publishable_RbEe0HHHsIq03mUbVTtebg_W5u9shhW';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ==========================================
  // INICIALIZAR SUPABASE
  // ==========================================

  await Supabase.initialize(
    url: 'https://pzlytvmkpbhlmqskizgn.supabase.co',
    anonKey: 'sb_publishable_RbEe0HHHsIq03mUbVTtebg_W5u9shhW',
  );

  // ==========================================
  // INICIAR APLICACIÓN
  // ==========================================

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<CarritoProvider>(
          create: (_) => CarritoProvider(),
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Buitrón Coffee',

      debugShowCheckedModeBanner: false,

      theme: ThemeData(
        primarySwatch: Colors.red,
        scaffoldBackgroundColor: const Color(0xFFF5F5F5),
      ),

      // IMPORTANTE:
      // En login_screen.dart la clase se llama LoginPage
      home: const LoginPage(),
    );
  }
}