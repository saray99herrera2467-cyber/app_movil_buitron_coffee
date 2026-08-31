import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'carrito_screen.dart';
import 'catalogo_screen.dart';
import 'login_screen.dart';
import '../services/perfil_service.dart'; // ✅ Importamos NUESTRA API

class PerfilScreen extends StatefulWidget {
  const PerfilScreen({super.key});

  @override
  State<PerfilScreen> createState() => _PerfilScreenState();
}

class _PerfilScreenState extends State<PerfilScreen> {
  // 📌 Instanciamos NUESTRA API / Servicio de Perfil
  final PerfilService _perfilService = PerfilService();

  final TextEditingController _nombreController = TextEditingController();
  final TextEditingController _correoController = TextEditingController();
  final TextEditingController _telefonoController = TextEditingController();
  final TextEditingController _direccionController = TextEditingController();

  bool _cargando = false;
  String? _mensaje;
  bool _esError = false;

  @override
  void initState() {
    super.initState();
    _cargarDatosPerfil();
  }

  // ✅ CARGAR DATOS — SOLO LLAMA A NUESTRA API
  Future<void> _cargarDatosPerfil() async {
    final usuario = Supabase.instance.client.auth.currentUser;
    if (usuario == null) return;

    _correoController.text = usuario.email ?? '';

    try {
      // 🔍 Usamos NUESTRA API para traer los datos desde la tabla
      final datos = await _perfilService.cargarDatosUsuario(usuario.email!);

      if (datos != null) {
        setState(() {
          _nombreController.text = datos['nombre_usuario'] ?? '';
          _telefonoController.text = datos['telefono'] ?? '';
          _direccionController.text = datos['direccion'] ?? '';
        });
      } else {
        // Respaldo: si no está en la tabla, lee desde autenticación
        setState(() {
          _nombreController.text = usuario.userMetadata?['nombre_usuario'] ?? '';
          _telefonoController.text = usuario.userMetadata?['telefono'] ?? '';
          _direccionController.text = usuario.userMetadata?['direccion'] ?? '';
        });
      }
    } catch (e) {
      setState(() {
        _mensaje = '⚠️ ${e.toString()}';
        _esError = true;
      });
    }
  }

  // ✅ GUARDAR CAMBIOS — SOLO LLAMA A NUESTRA API
  Future<void> _guardarCambios() async {
    if (_nombreController.text.trim().isEmpty) {
      setState(() {
        _mensaje = '❌ El nombre no puede estar vacío';
        _esError = true;
      });
      return;
    }

    setState(() {
      _cargando = true;
      _mensaje = null;
      _esError = false;
    });

    try {
      final usuario = Supabase.instance.client.auth.currentUser;
      if (usuario == null) throw Exception('No hay sesión activa');

      // 💾 Usamos NUESTRA API para guardar TODO
      await _perfilService.guardarPerfilCompleto(
        correo: usuario.email!,
        nombre: _nombreController.text.trim(),
        telefono: _telefonoController.text.trim(),
        direccion: _direccionController.text.trim(),
      );

      // ✅ ÉXITO
      setState(() {
        _mensaje = '✅ Perfil actualizado correctamente';
        _esError = false;
      });
    } catch (e) {
      setState(() {
        _mensaje = '❌ ${e.toString()}';
        _esError = true;
      });
    } finally {
      setState(() => _cargando = false);
    }
  }

  // ✅ CERRAR SESIÓN
  Future<void> _cerrarSesion() async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cerrar Sesión'),
        content: const Text('¿Salir de tu cuenta?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Salir', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmar == true) {
      await Supabase.instance.client.auth.signOut();
      if (mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const LoginScreen()),
              (_) => false,
        );
      }
    }
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _correoController.dispose();
    _telefonoController.dispose();
    _direccionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final usuario = Supabase.instance.client.auth.currentUser;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F5F2),

      // ✅ MENÚ LATERAL
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(color: Color(0xFF9E0000)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.coffee, color: Colors.white, size: 40),
                  SizedBox(height: 10),
                  Text(
                    'Buitrón Coffee',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'Menú Principal',
                    style: TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                ],
              ),
            ),
            ListTile(
              leading: const Icon(Icons.home, color: Color(0xFF9E0000)),
              title: const Text('Catálogo'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => const CatalogoScreen()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.shopping_cart, color: Color(0xFF9E0000)),
              title: const Text('Carrito'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const CarritoScreen()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.person, color: Color(0xFF9E0000)),
              title: const Text('Mi Perfil'),
              subtitle: Text(usuario?.email ?? 'Sin correo', style: const TextStyle(fontSize: 11)),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: const Icon(Icons.history, color: Color(0xFF9E0000)),
              title: const Text('Historial'),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Historial: Próximamente ✅')),
                );
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.info, color: Colors.grey),
              title: const Text('Acerca de'),
              onTap: () {
                Navigator.pop(context);
                showAboutDialog(
                  context: context,
                  applicationName: 'Buitrón Coffee',
                  applicationVersion: '1.0.0',
                  children: const [Text('Aplicación para venta de café ☕')],
                );
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: const Text('Cerrar Sesión', style: TextStyle(color: Colors.red)),
              onTap: _cerrarSesion,
            ),
          ],
        ),
      ),

      // ✅ BARRA SUPERIOR
      appBar: AppBar(
        backgroundColor: const Color(0xFF9E0000),
        foregroundColor: Colors.white,
        title: const Text(
          'PERFIL',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        elevation: 0,
      ),

      // ✅ PANTALLA — SOLO VISUAL, SIN CÓDIGO DE BASE DE DATOS
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Stack(
                  children: [
                    CircleAvatar(
                      radius: 50,
                      backgroundColor: const Color(0xFF9E0000).withValues(alpha: 0.1),
                      child: const Icon(Icons.person, size: 50, color: Color(0xFF9E0000)),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // ✅ MENSAJE DE ESTADO
              if (_mensaje != null)
                Container(
                  padding: const EdgeInsets.all(12),
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    color: _esError ? Colors.red.shade50 : Colors.green.shade50,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    _mensaje!,
                    style: TextStyle(
                      color: _esError ? Colors.red.shade800 : Colors.green.shade800,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),

              // 👤 NOMBRE
              const Text(
                'Nombre',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Color(0xFF5A4A42)),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _nombreController,
                decoration: InputDecoration(
                  hintText: 'Tu nombre completo',
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(6), borderSide: const BorderSide(color: Color(0xFFC8B8AE))),
                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(6), borderSide: const BorderSide(color: Color(0xFFC8B8AE))),
                  focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(6), borderSide: const BorderSide(color: Color(0xFF9E0000), width: 1.5)),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                ),
                style: const TextStyle(fontSize: 15, color: Color(0xFF2D2D2D)),
              ),
              const SizedBox(height: 20),

              // 📧 CORREO
              const Text(
                'Correo',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Color(0xFF5A4A42)),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _correoController,
                enabled: false,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: const Color(0xFFE8DDD4),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(6), borderSide: const BorderSide(color: Color(0xFFC8B8AE))),
                  disabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(6), borderSide: const BorderSide(color: Color(0xFFC8B8AE))),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                ),
                style: const TextStyle(fontSize: 15, color: Color(0xFF8A7D75)),
              ),
              const SizedBox(height: 20),

              // 📱 TELÉFONO
              const Text(
                'Teléfono',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Color(0xFF5A4A42)),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _telefonoController,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                  hintText: 'Tu número de teléfono',
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(6), borderSide: const BorderSide(color: Color(0xFFC8B8AE))),
                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(6), borderSide: const BorderSide(color: Color(0xFFC8B8AE))),
                  focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(6), borderSide: const BorderSide(color: Color(0xFF9E0000), width: 1.5)),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                ),
                style: const TextStyle(fontSize: 15, color: Color(0xFF2D2D2D)),
              ),
              const SizedBox(height: 20),

              // 🏠 DIRECCIÓN
              const Text(
                'Dirección',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Color(0xFF5A4A42)),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _direccionController,
                maxLines: null,
                keyboardType: TextInputType.streetAddress,
                decoration: InputDecoration(
                  hintText: 'Tu dirección completa',
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(6), borderSide: const BorderSide(color: Color(0xFFC8B8AE))),
                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(6), borderSide: const BorderSide(color: Color(0xFFC8B8AE))),
                  focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(6), borderSide: const BorderSide(color: Color(0xFF9E0000), width: 1.5)),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                ),
                style: const TextStyle(fontSize: 15, color: Color(0xFF2D2D2D)),
              ),
              const SizedBox(height: 32),

              // ✅ BOTÓN ACTUALIZAR
              SizedBox(
                height: 55,
                child: ElevatedButton(
                  onPressed: _cargando ? null : _guardarCambios,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF9E0000),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                    elevation: 0,
                  ),
                  child: _cargando
                      ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : const Text('Actualizar', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}