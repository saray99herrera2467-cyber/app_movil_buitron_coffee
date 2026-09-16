import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import 'verificacion_screen.dart';

class RecuperarClaveScreen extends StatefulWidget {
  const RecuperarClaveScreen({super.key});

  @override
  State<RecuperarClaveScreen> createState() =>
      _RecuperarClaveScreenState();
}

class _RecuperarClaveScreenState
    extends State<RecuperarClaveScreen> {
  final TextEditingController _correoController =
  TextEditingController();

  bool _cargando = false;

  static const Color cafePrincipal = Color(0xFFF9A15E);
  static const Color crema = Color(0xFFFFFBF2);
  static const Color dorado = Color(0xFFFFAB40);

  Future<void> _enviarCorreo() async {
    final correo = _correoController.text.trim().toLowerCase();

    if (correo.isEmpty) {
      _mostrarMensaje('Ingresa tu correo electrónico.');
      return;
    }

    final correoValido = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    ).hasMatch(correo);

    if (!correoValido) {
      _mostrarMensaje('Ingresa un correo electrónico válido.');
      return;
    }

    setState(() {
      _cargando = true;
    });

    try {
      await AuthService.recuperarClave(correo);

      if (!mounted) return;

      _mostrarMensaje(
        'Solicitud enviada. Revisa tu correo electrónico.',
        exito: true,
      );

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => VerificacionScreen(
            email: correo,
            esRecuperacion: true,
          ),
        ),
      );
    } catch (e) {
      if (mounted) _mostrarMensaje(e.toString().replaceFirst('Exception: ', ''));
    } finally {
      if (mounted) setState(() { _cargando = false; });
    }
  }

  void _mostrarMensaje(String msg, {bool exito = false}) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: exito ? Colors.green : const Color(0xFF9E0000),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  void dispose() {
    _correoController.dispose();
    super.dispose();
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 20),
            const Icon(Icons.lock_reset, size: 80, color: Color(0xFFFF7043)),
            const SizedBox(height: 24),
            const Text(
              '¿Olvidaste tu contraseña?',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF2D2D2D)),
            ),
            const SizedBox(height: 12),
            const Text(
              'Ingresa el correo electrónico asociado a tu cuenta y te enviaremos un código para recuperar tu contraseña.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.black54, fontSize: 15),
            ),
            const SizedBox(height: 32),
            TextField(
              controller: _correoController,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                labelText: 'Correo electrónico',
                hintText: 'ejemplo@gmail.com',
                prefixIcon: const Icon(Icons.email_outlined, color: cafePrincipal),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
                focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFFF7043), width: 2)),
              ),
            ),
            const SizedBox(height: 32),
            InkWell(
              onTap: _cargando ? null : _enviarCorreo,
              borderRadius: BorderRadius.circular(12),
              child: Container(
                height: 52,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(colors: [Color(0xFFF9A15E), Color(0xFFFF7043)]),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(color: const Color(0xFFF9A15E).withValues(alpha: 0.3), blurRadius: 10, offset: const Offset(0, 4))
                  ],
                ),
                alignment: Alignment.center,
                child: _cargando 
                  ? const CircularProgressIndicator(color: Colors.white, strokeWidth: 2)
                  : const Text('ENVIAR CÓDIGO', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Revisa también la carpeta de spam o correo no deseado.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12, color: Colors.black45),
            ),
          ],
        ),
      ),
    );
  }
}
