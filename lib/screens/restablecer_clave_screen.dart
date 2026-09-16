import 'package:flutter/material.dart';
import '../services/auth_service.dart';

class RestablecerClaveScreen extends StatefulWidget {
  const RestablecerClaveScreen({super.key});

  @override
  State<RestablecerClaveScreen> createState() => _RestablecerClaveScreenState();
}

class _RestablecerClaveScreenState extends State<RestablecerClaveScreen> {
  final TextEditingController _claveController = TextEditingController();
  final TextEditingController _confirmarController = TextEditingController();
  bool _cargando = false;
  bool _ocultar = true;

  // ✅ PALETA NARANJA CÁLIDO
  static const Color naranjaPrincipal = Color(0xFFF9A15E);
  static const Color crema = Color(0xFFFFFBF2);
  static const Color naranjaIntenso = Color(0xFFFF7043);

  Future<void> _actualizarClave() async {
    final clave = _claveController.text.trim();
    final confirmar = _confirmarController.text.trim();

    if (clave.length < 6) {
      _mostrarMensaje('La contraseña debe tener al menos 6 caracteres');
      return;
    }
    if (clave != confirmar) {
      _mostrarMensaje('Las contraseñas no coinciden');
      return;
    }

    setState(() => _cargando = true);

    try {
      await AuthService.actualizarClave(clave);
      if (!mounted) return;

      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('¡Contraseña actualizada!'),
          content: const Text('Ahora puedes iniciar sesión con tu nueva contraseña.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Cerrar diálogo
                Navigator.of(context).popUntil((route) => route.isFirst); // Volver al inicio
              }, 
              child: const Text('ENTENDIDO', style: TextStyle(color: naranjaIntenso, fontWeight: FontWeight.bold))
            ),
          ],
        )
      );
    } catch (e) {
      _mostrarMensaje('Error: $e');
    } finally {
      if (mounted) setState(() => _cargando = false);
    }
  }

  void _mostrarMensaje(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), behavior: SnackBarBehavior.floating),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: crema,
      appBar: AppBar(
        title: const Text('NUEVA CONTRASEÑA', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        backgroundColor: naranjaPrincipal,
        foregroundColor: Colors.white,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Establece tu nueva clave',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF2D2D2D)),
            ),
            const SizedBox(height: 12),
            const Text(
              'Asegúrate de que sea una contraseña segura y fácil de recordar.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.black54),
            ),
            const SizedBox(height: 32),
            
            // Nueva Clave
            TextField(
              controller: _claveController,
              obscureText: _ocultar,
              decoration: InputDecoration(
                labelText: 'Nueva contraseña',
                prefixIcon: const Icon(Icons.lock_outline, color: naranjaPrincipal),
                suffixIcon: IconButton(
                  icon: Icon(_ocultar ? Icons.visibility_off : Icons.visibility, color: naranjaPrincipal),
                  onPressed: () => setState(() => _ocultar = !_ocultar),
                ),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
              ),
            ),
            const SizedBox(height: 16),

            // Confirmar Clave
            TextField(
              controller: _confirmarController,
              obscureText: _ocultar,
              decoration: InputDecoration(
                labelText: 'Confirmar contraseña',
                prefixIcon: const Icon(Icons.lock_reset, color: naranjaPrincipal),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
              ),
            ),
            
            const SizedBox(height: 32),
            InkWell(
              onTap: _cargando ? null : _actualizarClave,
              borderRadius: BorderRadius.circular(12),
              child: Container(
                height: 52,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(colors: [naranjaPrincipal, naranjaIntenso]),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(color: naranjaPrincipal.withValues(alpha: 0.3), blurRadius: 10, offset: const Offset(0, 4))
                  ],
                ),
                alignment: Alignment.center,
                child: _cargando 
                  ? const CircularProgressIndicator(color: Colors.white, strokeWidth: 2)
                  : const Text('ACTUALIZAR CONTRASEÑA', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
