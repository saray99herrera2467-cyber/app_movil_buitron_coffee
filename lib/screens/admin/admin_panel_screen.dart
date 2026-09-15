import 'package:flutter/material.dart';

// ✅ Rutas correctas (misma carpeta, sin "admin/")
import 'gestion_resenas_screen.dart';
import 'ver_usuario_screen.dart';
import 'pqrs_screen.dart'; // Asegurar que apunta a la del admin
import '../login_screen.dart';
import '../../services/auth_service.dart';
import 'crear_producto_screen.dart';
import 'actualizar_producto_screen.dart';
import 'gestion_pedidos_screen.dart';

class AdminPanelScreen extends StatelessWidget {
  const AdminPanelScreen({super.key});

  // ==========================================================
  // COLORES BUITRÓN COFFEE
  // ==========================================================
  static const Color cafePrincipal = Color(0xFF4E342E);
  static const Color cafeClaro = Color(0xFF795548);
  static const Color crema = Color(0xFFF5EFE6);
  static const Color cremaClaro = Color(0xFFFFFCF7);
  static const Color dorado = Color(0xFFC8A45D);
  static const Color textoOscuro = Color(0xFF3A2925);
  static const Color textoSuave = Color(0xFF756860);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: crema,

      // ======================================================
      // BARRA SUPERIOR
      // ======================================================
      appBar: AppBar(
        title: const Text(
          'PANEL DE ADMINISTRACIÓN',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            letterSpacing: 1,
          ),
        ),
        backgroundColor: cafePrincipal,
        foregroundColor: Colors.white,
        centerTitle: true,
        automaticallyImplyLeading: false, // Sin flecha de regreso por defecto

        // Botón Cerrar Sesión
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Cerrar sesión',
            onPressed: () async {
              await AuthService.logout();
              if (!context.mounted) return;
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => const LoginPage()),
                (ruta) => false,
              );
            },
          ),
        ],
      ),

      // ======================================================
      // CONTENIDO - MENÚ
      // ======================================================
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          const SizedBox(height: 30),

          // Icono y título
          const Center(
            child: Column(
              children: [
                Icon(
                  Icons.admin_panel_settings,
                  size: 70,
                  color: dorado,
                ),
                SizedBox(height: 16),
                Text(
                  'Gestión de la Tienda',
                  style: TextStyle(
                    fontSize: 22,
                    color: textoOscuro,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 6),
                Text(
                  'Selecciona una opción',
                  style: TextStyle(
                    fontSize: 14,
                    color: textoSuave,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 40),

          // ====================================================
          // OPCIÓN 1: Crear Producto
          // ====================================================
          _botonMenu(
            icono: Icons.add_box,
            etiqueta: 'Crear Producto',
            colorFondo: cafePrincipal,
            destino: const CrearProductoScreen(),
            context: context,
          ),
          const SizedBox(height: 16),

          // ====================================================
          // OPCIÓN 2: Actualizar Producto
          // ====================================================
          _botonMenu(
            icono: Icons.edit,
            etiqueta: 'Actualizar Producto',
            colorFondo: cafeClaro,
            destino: const ActualizarProductoScreen(),
            context: context,
          ),
          const SizedBox(height: 16),

          // ====================================================
          // OPCIÓN 3: Gestión de Pedidos
          // ====================================================
          _botonMenu(
            icono: Icons.list_alt,
            etiqueta: 'Gestión de Pedidos',
            colorFondo: cafePrincipal,
            destino: const GestionPedidosScreen(),
            context: context,
          ),
          const SizedBox(height: 16),

          // ====================================================
          // OPCIÓN 4: Gestión de Reseñas
          // ====================================================
          _botonMenu(
            icono: Icons.star,
            etiqueta: 'Gestión de Reseñas',
            colorFondo: cafeClaro,
            destino: const GestionResenasScreen(),
            context: context,
          ),
          const SizedBox(height: 16),

          // ====================================================
          // OPCIÓN 5: Ver Usuarios
          // ====================================================
          _botonMenu(
            icono: Icons.people,
            etiqueta: 'Ver Usuarios',
            colorFondo: cafePrincipal,
            destino: const VerUsuariosScreen(),
            context: context,
          ),
          const SizedBox(height: 16),

          // ====================================================
          // OPCIÓN 6: PQRS
          // ====================================================
          _botonMenu(
            icono: Icons.help_center,
            etiqueta: 'Gestionar PQRS',
            colorFondo: cafeClaro,
            destino: const AdminPqrsScreen(),
            context: context,
          ),
          const SizedBox(height: 30),
        ],
      ),
    );
  }

  // ==========================================================
  // WIDGET: BOTÓN DEL MENÚ
  // ==========================================================
  Widget _botonMenu({
    required IconData icono,
    required String etiqueta,
    required Color colorFondo,
    required Widget destino,
    required BuildContext context,
  }) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        icon: Icon(icono, color: Colors.white, size: 26),
        label: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Text(
            etiqueta,
            style: const TextStyle(
              fontSize: 16,
              color: Colors.white,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: colorFondo,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          alignment: Alignment.centerLeft,
          padding: const EdgeInsets.symmetric(horizontal: 24),
          elevation: 2,
        ),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => destino),
          );
        },
      ),
    );
  }
}