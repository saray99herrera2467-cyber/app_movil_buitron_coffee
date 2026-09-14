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

  static const Color cafePrincipal =
  Color(0xFF4E342E);

  static const Color crema =
  Color(0xFFF5EFE6);

  static const Color dorado =
  Color(0xFFC8A45D);

  // =========================================================
  // ENVIAR CÓDIGO DE RECUPERACIÓN
  // =========================================================

  Future<void> _enviarCorreo() async {
    final correo =
    _correoController.text.trim().toLowerCase();

    // -------------------------------------------------------
    // Validar correo vacío
    // -------------------------------------------------------

    if (correo.isEmpty) {
      _mostrarMensaje(
        'Ingresa tu correo electrónico.',
      );
      return;
    }

    // -------------------------------------------------------
    // Validar formato
    // -------------------------------------------------------

    final correoValido = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    ).hasMatch(correo);

    if (!correoValido) {
      _mostrarMensaje(
        'Ingresa un correo electrónico válido.',
      );
      return;
    }

    setState(() {
      _cargando = true;
    });

    try {
      // -----------------------------------------------------
      // IMPORTANTE:
      //
      // Este método utiliza:
      //
      // supabase.auth.resetPasswordForEmail()
      //
      // NO utiliza auth.resend().
      // -----------------------------------------------------

      await AuthService.recuperarClave(correo);

      if (!mounted) return;

      _mostrarMensaje(
        'Solicitud enviada. Revisa tu correo electrónico.',
        exito: true,
      );

      // -----------------------------------------------------
      // Ir a la pantalla para ingresar el código
      // -----------------------------------------------------

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
      if (!mounted) return;

      final mensaje = e
          .toString()
          .replaceFirst('Exception: ', '');

      _mostrarMensaje(mensaje);
    } finally {
      if (mounted) {
        setState(() {
          _cargando = false;
        });
      }
    }
  }

  // =========================================================
  // MOSTRAR MENSAJE
  // =========================================================

  void _mostrarMensaje(
      String msg, {
        bool exito = false,
      }) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor:
        exito ? Colors.green : cafePrincipal,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  // =========================================================
  // DISPOSE
  // =========================================================

  @override
  void dispose() {
    _correoController.dispose();
    super.dispose();
  }

  // =========================================================
  // INTERFAZ
  // =========================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: crema,

      appBar: AppBar(
        title: const Text(
          'RECUPERAR CONTRASEÑA',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: cafePrincipal,
        foregroundColor: Colors.white,
        centerTitle: true,
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),

        child: Column(
          crossAxisAlignment:
          CrossAxisAlignment.stretch,

          children: [
            const SizedBox(height: 20),

            const Icon(
              Icons.lock_reset,
              size: 80,
              color: cafePrincipal,
            ),

            const SizedBox(height: 24),

            const Text(
              '¿Olvidaste tu contraseña?',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: cafePrincipal,
              ),
            ),

            const SizedBox(height: 12),

            const Text(
              'Ingresa el correo electrónico asociado a tu cuenta y te enviaremos un código para recuperar tu contraseña.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.black54,
                fontSize: 15,
              ),
            ),

            const SizedBox(height: 32),

            TextField(
              controller: _correoController,
              keyboardType:
              TextInputType.emailAddress,

              textInputAction:
              TextInputAction.done,

              enabled: !_cargando,

              decoration: InputDecoration(
                labelText: 'Correo electrónico',

                hintText:
                'ejemplo@gmail.com',

                prefixIcon: const Icon(
                  Icons.email_outlined,
                  color: cafePrincipal,
                ),

                filled: true,
                fillColor: Colors.white,

                border: OutlineInputBorder(
                  borderRadius:
                  BorderRadius.circular(12),
                  borderSide:
                  BorderSide.none,
                ),

                focusedBorder:
                OutlineInputBorder(
                  borderRadius:
                  BorderRadius.circular(12),
                  borderSide:
                  const BorderSide(
                    color: dorado,
                    width: 2,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 32),

            SizedBox(
              height: 52,

              child: ElevatedButton(
                onPressed:
                _cargando
                    ? null
                    : _enviarCorreo,

                style:
                ElevatedButton.styleFrom(
                  backgroundColor:
                  cafePrincipal,

                  foregroundColor:
                  Colors.white,

                  disabledBackgroundColor:
                  cafePrincipal.withOpacity(
                    0.5,
                  ),

                  shape:
                  RoundedRectangleBorder(
                    borderRadius:
                    BorderRadius.circular(12),
                  ),
                ),

                child: _cargando
                    ? const SizedBox(
                  width: 24,
                  height: 24,
                  child:
                  CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2,
                  ),
                )
                    : const Text(
                  'ENVIAR CÓDIGO',
                  style: TextStyle(
                    fontWeight:
                    FontWeight.bold,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),

            const Text(
              'Revisa también la carpeta de spam o correo no deseado.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                color: Colors.black45,
              ),
            ),
          ],
        ),
      ),
    );
  }
}