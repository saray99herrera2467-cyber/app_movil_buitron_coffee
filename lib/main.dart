import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'providers/carrito_provider.dart';
import 'providers/producto_admin_provider.dart';
import 'screens/login_screen.dart';
import 'services/api_service.dart'; // ✅ Importación agregada

const String supabaseUrl = 'https://pzlytvmkpbhlmqskizgn.supabase.co';
const String supabasePublishableKey = 'sb_publishable_RbEe0HHHsIq03mUbVTtebg_W5u9shhW';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializar Supabase
  await Supabase.initialize(
    url: 'https://pzlytvmkpbhlmqskizgn.supabase.co',
    anonKey: 'sb_publishable_RbEe0HHHsIq03mUbVTtebg_W5u9shhW',

  );

  // ✅ PASAR CONEXIÓN A API SERVICE — ¡ESENCIAL!
  ApiService.inicializarCliente(Supabase.instance.client);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<CarritoProvider>(
          create: (_) => CarritoProvider(),
        ),
        ChangeNotifierProvider<ProductoAdminProvider>(
          create: (_) => ProductoAdminProvider(),
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
        primarySwatch: Colors.brown,
        scaffoldBackgroundColor: const Color(0xFFF5EFE6),
      ),
      home: const LoginPage(),
    );
  }
}