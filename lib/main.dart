import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'providers/carrito_provider.dart';

import 'screens/carrito_screen.dart';
import 'screens/resenas_screen.dart';
import 'screens/historial_screen.dart';
import 'screens/perfil_screen.dart';
import 'screens/pagos_screen.dart';
import 'screens/mapa_screen.dart';
import 'screens/catalogo_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => CarritoProvider(),
      child: MaterialApp(
        title: 'Buitrón Coffee',

        theme: ThemeData(
          primarySwatch: Colors.brown,
        ),

        debugShowCheckedModeBanner: false,

        home: const MenuPrincipal(),

        routes: {
          '/carrito': (ctx) => const CarritoScreen(),
          '/resenas': (ctx) => const ResenasScreen(),
          '/historial': (ctx) => const HistorialScreen(),
          '/perfil': (ctx) => const PerfilScreen(),
          '/pagos': (ctx) => const PagosScreen(),
          '/mapa': (ctx) => const MapaScreen(),
          '/catalogo': (ctx) => const CatalogoScreen(),
        },
      ),
    );
  }
}

class MenuPrincipal extends StatelessWidget {
  const MenuPrincipal({super.key});

  @override
  Widget build(BuildContext context) {
    final colorRojo = const Color(0xFF9B1C2C);
    final colorFondo = const Color(0xFF2B0F0F);

    return Scaffold(
      backgroundColor: colorFondo,

      appBar: AppBar(
        title: const Text(
          'Buitrón Coffee',
          style: TextStyle(
            color: Colors.white,
          ),
        ),
        backgroundColor: colorRojo,
      ),

      body: ListView(
        padding: const EdgeInsets.all(20),

        children: [

          // CATÁLOGO
          ElevatedButton.icon(
            icon: const Icon(Icons.coffee),
            label: const Text('☕ Catálogo de Productos'),
            style: ElevatedButton.styleFrom(
              backgroundColor: colorRojo,
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              Navigator.pushNamed(context, '/catalogo');
            },
          ),

          const SizedBox(height: 10),

          // CARRITO
          ElevatedButton.icon(
            icon: const Icon(Icons.shopping_cart),
            label: const Text('🛒 Carrito de Compras'),
            style: ElevatedButton.styleFrom(
              backgroundColor: colorRojo,
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              Navigator.pushNamed(context, '/carrito');
            },
          ),

          const SizedBox(height: 10),

          // RESEÑAS
          ElevatedButton.icon(
            icon: const Icon(Icons.star),
            label: const Text('⭐ Reseñas y Calificaciones'),
            style: ElevatedButton.styleFrom(
              backgroundColor: colorRojo,
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              Navigator.pushNamed(context, '/resenas');
            },
          ),

          const SizedBox(height: 10),

          // HISTORIAL
          ElevatedButton.icon(
            icon: const Icon(Icons.history),
            label: const Text('📜 Historial de Compras'),
            style: ElevatedButton.styleFrom(
              backgroundColor: colorRojo,
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              Navigator.pushNamed(context, '/historial');
            },
          ),

          const SizedBox(height: 10),

          // PERFIL
          ElevatedButton.icon(
            icon: const Icon(Icons.person),
            label: const Text('👤 Mi Perfil'),
            style: ElevatedButton.styleFrom(
              backgroundColor: colorRojo,
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              Navigator.pushNamed(context, '/perfil');
            },
          ),

          const SizedBox(height: 10),

          // PAGOS
          ElevatedButton.icon(
            icon: const Icon(Icons.payment),
            label: const Text('💳 Pagos en Línea'),
            style: ElevatedButton.styleFrom(
              backgroundColor: colorRojo,
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              Navigator.pushNamed(context, '/pagos');
            },
          ),

          const SizedBox(height: 10),

          // MAPA
          ElevatedButton.icon(
            icon: const Icon(Icons.location_on),
            label: const Text('🗺️ Ubicación de la Tienda'),
            style: ElevatedButton.styleFrom(
              backgroundColor: colorRojo,
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              Navigator.pushNamed(context, '/mapa');
            },
          ),
        ],
      ),
    );
  }
}