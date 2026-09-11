import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'providers/carrito_provider.dart';
import 'providers/producto_admin_provider.dart';
import 'screens/login_screen.dart';
import 'screens/catalogo_screen.dart';
import 'screens/admin/admin_panel_screen.dart';
import 'services/api_service.dart';
import 'services/auth_service.dart';

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
      home: const RouteGuard(),
    );
  }
}

class RouteGuard extends StatelessWidget {
  const RouteGuard({super.key});

  @override
  Widget build(BuildContext context) {
    // 🛡️ Widget que decide qué pantalla mostrar según el token y el rol
    return StreamBuilder<AuthState>(
      stream: Supabase.instance.client.auth.onAuthStateChange,
      builder: (context, snapshot) {
        final session = Supabase.instance.client.auth.currentSession;

        // 1. Si NO hay sesión (token), mandamos al Login
        if (session == null) {
          return const LoginPage();
        }

        // 2. Si HAY sesión, consultamos el rol en tiempo real
        return FutureBuilder<Map<String, dynamic>?>(
          future: AuthService.obtenerPerfilActual(),
          builder: (context, profileSnapshot) {
            if (profileSnapshot.connectionState == ConnectionState.waiting) {
              return const Scaffold(body: Center(child: CircularProgressIndicator(color: Color(0xFF4E342E))));
            }

            final perfil = profileSnapshot.data;

            // Si hay token pero el usuario no existe en la tabla (error raro o borrado)
            if (perfil == null) {
              return const LoginPage();
            }

            final idRol = perfil['id_rol'] as int? ?? 1;

            // Redirigir según el rol detectado en el token
            return idRol == 2 ? const AdminPanelScreen() : const CatalogoScreen();
          },
        );
      },
    );
  }
}
