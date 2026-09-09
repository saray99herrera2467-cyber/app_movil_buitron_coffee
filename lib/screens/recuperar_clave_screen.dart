import 'package:flutter/material.dart';
import '../services/auth_service.dart';

class RecuperarClaveScreen extends StatefulWidget {
  const RecuperarClaveScreen({super.key});

  @override
  State<RecuperarClaveScreen> createState() => _RecuperarClaveScreenState();
}

class _RecuperarClaveScreenState extends State<RecuperarClaveScreen> {
  final TextEditingController _correoController = TextEditingController();
  bool _cargando = false;

  static const Color cafePrincipal = Color(0xFF4E342E);
  static const Color crema = Color(0xFFF5EFE6);
  static const Color dorado = Color(0xFFC8A45D);

  Future<void> _enviarCorreo() async {
    final correo = _correoController.text.trim();
    if (correo.isEmpty) {
      _mostrarMensaje('Ingresa tu correo electrónico');
      return;
    }

    setState(() => _cargando = true);

    try {
      await AuthService.recuperarClave(correo);
      if (!mounted) return;
      
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('¡Correo enviado!'),
          content: const Text('Revisa tu bandeja de entrada (y la carpeta SPAM) para restablecer tu contraseña.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Cerrar diálogo
                Navigator.pop(context); // Volver al Login
              }, 
              child: const Text('ENTENDIDO')
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
        title: const Text('RECUPERAR CONTRASEÑA', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        backgroundColor: cafePrincipal,
        foregroundColor: Colors.white,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Icon(Icons.lock_reset, size: 80, color: cafePrincipal),
            const SizedBox(height: 24),
            const Text(
              '¿Olvidaste tu contraseña?',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: cafePrincipal),
            ),
            const SizedBox(height: 12),
            const Text(
              'Ingresa tu correo y te enviaremos un enlace para que puedas crear una nueva.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.black54),
            ),
            const SizedBox(height: 32),
            TextField(
              controller: _correoController,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                labelText: 'Correo electrónico',
                prefixIcon: const Icon(Icons.email_outlined, color: cafePrincipal),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: dorado, width: 2),
                ),
              ),
            ),
            const SizedBox(height: 32),
            SizedBox(
              height: 52,
              child: ElevatedButton(
                onPressed: _cargando ? null : _enviarCorreo,
                style: ElevatedButton.styleFrom(
                  backgroundColor: cafePrincipal,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: _cargando 
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text('ENVIAR ENLACE', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
