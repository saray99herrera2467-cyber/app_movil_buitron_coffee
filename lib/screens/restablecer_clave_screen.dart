import 'package:flutter/material.dart';

import '../services/auth_service.dart';

class RestablecerClaveScreen
    extends StatefulWidget {
  const RestablecerClaveScreen({
    super.key,
  });

  @override
  State<RestablecerClaveScreen>
  createState() =>
      _RestablecerClaveScreenState();
}

class _RestablecerClaveScreenState
    extends State<RestablecerClaveScreen> {
  final TextEditingController
  _claveController =
  TextEditingController();

  final TextEditingController
  _confirmarController =
  TextEditingController();

  bool _cargando = false;
  bool _ocultar = true;

  static const Color cafePrincipal =
  Color(0xFF4E342E);

  static const Color crema =
  Color(0xFFF5EFE6);

  // =========================================================
  // ACTUALIZAR CLAVE
  // =========================================================

  Future<void> _actualizarClave() async {
    final clave =
    _claveController.text.trim();

    final confirmar =
    _confirmarController.text.trim();

    if (clave.length < 8) {
      _mostrarMensaje(
        'La contraseña debe tener al menos 8 caracteres.',
      );
      return;
    }

    if (!RegExp(
      r'^(?=.*[A-Za-z])(?=.*\d)[A-Za-z\d]{8,}$',
    ).hasMatch(clave)) {
      _mostrarMensaje(
        'La contraseña debe incluir letras y números.',
      );
      return;
    }

    if (clave != confirmar) {
      _mostrarMensaje(
        'Las contraseñas no coinciden.',
      );
      return;
    }

    setState(() {
      _cargando = true;
    });

    try {
      await AuthService.actualizarClave(
        clave,
      );

      if (!mounted) return;

      await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => AlertDialog(
          title: const Text(
            '¡Contraseña actualizada!',
          ),
          content: const Text(
            'Ahora puedes iniciar sesión con tu nueva contraseña.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);

                Navigator.of(context)
                    .popUntil(
                      (route) => route.isFirst,
                );
              },
              child: const Text(
                'ENTENDIDO',
              ),
            ),
          ],
        ),
      );
    } catch (e) {
      if (!mounted) return;

      _mostrarMensaje(
        e.toString().replaceFirst(
          'Exception: ',
          '',
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _cargando = false;
        });
      }
    }
  }

  // =========================================================
  // MENSAJE
  // =========================================================

  void _mostrarMensaje(
      String msg,
      ) {
    ScaffoldMessenger.of(context)
        .showSnackBar(
      SnackBar(
        content: Text(msg),
        behavior:
        SnackBarBehavior.floating,
      ),
    );
  }

  // =========================================================
  // DISPOSE
  // =========================================================

  @override
  void dispose() {
    _claveController.dispose();
    _confirmarController.dispose();
    super.dispose();
  }

  // =========================================================
  // BUILD
  // =========================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: crema,

      appBar: AppBar(
        title: const Text(
          'NUEVA CONTRASEÑA',
          style: TextStyle(
            fontSize: 16,
            fontWeight:
            FontWeight.bold,
          ),
        ),
        backgroundColor:
        cafePrincipal,
        foregroundColor:
        Colors.white,
        centerTitle: true,
      ),

      body: Padding(
        padding:
        const EdgeInsets.all(24),

        child: Column(
          crossAxisAlignment:
          CrossAxisAlignment.stretch,

          children: [
            const Text(
              'Establece tu nueva clave',
              textAlign:
              TextAlign.center,
              style: TextStyle(
                fontSize: 22,
                fontWeight:
                FontWeight.bold,
                color:
                cafePrincipal,
              ),
            ),

            const SizedBox(height: 12),

            const Text(
              'Asegúrate de que sea una contraseña segura y fácil de recordar.',
              textAlign:
              TextAlign.center,
              style: TextStyle(
                color: Colors.black54,
              ),
            ),

            const SizedBox(height: 32),

            // -------------------------------------------------
            // NUEVA CONTRASEÑA
            // -------------------------------------------------

            TextField(
              controller:
              _claveController,

              obscureText:
              _ocultar,

              decoration:
              InputDecoration(
                labelText:
                'Nueva contraseña',

                prefixIcon:
                const Icon(
                  Icons.lock_outline,
                  color:
                  cafePrincipal,
                ),

                suffixIcon:
                IconButton(
                  icon: Icon(
                    _ocultar
                        ? Icons
                        .visibility_off
                        : Icons.visibility,
                    color:
                    cafePrincipal,
                  ),
                  onPressed: () {
                    setState(() {
                      _ocultar =
                      !_ocultar;
                    });
                  },
                ),

                filled: true,
                fillColor:
                Colors.white,

                border:
                OutlineInputBorder(
                  borderRadius:
                  BorderRadius
                      .circular(
                    12,
                  ),
                  borderSide:
                  BorderSide.none,
                ),
              ),
            ),

            const SizedBox(height: 16),

            // -------------------------------------------------
            // CONFIRMAR CONTRASEÑA
            // -------------------------------------------------

            TextField(
              controller:
              _confirmarController,

              obscureText:
              _ocultar,

              decoration:
              InputDecoration(
                labelText:
                'Confirmar contraseña',

                prefixIcon:
                const Icon(
                  Icons.lock_reset,
                  color:
                  cafePrincipal,
                ),

                filled: true,
                fillColor:
                Colors.white,

                border:
                OutlineInputBorder(
                  borderRadius:
                  BorderRadius
                      .circular(
                    12,
                  ),
                  borderSide:
                  BorderSide.none,
                ),
              ),
            ),

            const SizedBox(height: 32),

            // -------------------------------------------------
            // BOTÓN
            // -------------------------------------------------

            SizedBox(
              height: 52,

              child:
              ElevatedButton(
                onPressed:
                _cargando
                    ? null
                    : _actualizarClave,

                style:
                ElevatedButton
                    .styleFrom(
                  backgroundColor:
                  cafePrincipal,
                  foregroundColor:
                  Colors.white,
                  shape:
                  RoundedRectangleBorder(
                    borderRadius:
                    BorderRadius
                        .circular(
                      12,
                    ),
                  ),
                ),

                child: _cargando
                    ? const SizedBox(
                  width: 24,
                  height: 24,
                  child:
                  CircularProgressIndicator(
                    color:
                    Colors.white,
                  ),
                )
                    : const Text(
                  'ACTUALIZAR CONTRASEÑA',
                  style:
                  TextStyle(
                    fontWeight:
                    FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}