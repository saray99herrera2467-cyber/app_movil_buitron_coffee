import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import 'catalogo_screen.dart';

import 'restablecer_clave_screen.dart';

class VerificacionScreen extends StatefulWidget {
  final String email;
  final bool esRecuperacion; // ✅ Nuevo: identifica si es para cambio de clave
  
  const VerificacionScreen({
    super.key, 
    required this.email, 
    this.esRecuperacion = false
  });

  @override
  State<VerificacionScreen> createState() => _VerificacionScreenState();
}

class _VerificacionScreenState extends State<VerificacionScreen> {
  // Supabase usa códigos de 6 dígitos
  final List<TextEditingController> _controladores = List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());
  bool _cargando = false;

  String get _codigoIngresado => _controladores.map((c) => c.text).join();

  Future<void> _verificarCodigo() async {
    if (_codigoIngresado.length < 6) {
      _mostrarMensaje('Ingresa el código completo de 6 dígitos');
      return;
    }

    setState(() => _cargando = true);

    try {
      await AuthService.verificarCodigo(
        widget.email, 
        _codigoIngresado, 
        esRecuperacion: widget.esRecuperacion
      );

      if (!mounted) return;

      _mostrarMensaje('¡Código verificado con éxito!', exito: true);

      // Pequeña espera para que vea el mensaje
      await Future.delayed(const Duration(milliseconds: 500));

      if (mounted) {
        if (widget.esRecuperacion) {
          // Si es recuperación, lo mandamos a cambiar la clave
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const RestablecerClaveScreen()),
          );
        } else {
          // Si es registro, lo mandamos al catálogo
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const CatalogoScreen()),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        _mostrarMensaje(e.toString().replaceFirst('Exception: ', ''));
        setState(() => _cargando = false);
      }
    }
  }

  Future<void> _reenviarCodigo() async {
    setState(() => _cargando = true);
    try {
      await AuthService.reenviarCodigo(widget.email, esRecuperacion: widget.esRecuperacion);
      if (mounted) {
        _mostrarMensaje('Código reenviado con éxito a tu correo.', exito: true);
        setState(() => _cargando = false);
      }
    } catch (e) {
      if (mounted) {
        _mostrarMensaje(e.toString().replaceFirst('Exception: ', ''));
        setState(() => _cargando = false);
      }
    }
  }

  void _mostrarMensaje(String msg, {bool exito = false}) {
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
    for (var c in _controladores) {
      c.dispose();
    }
    for (var f in _focusNodes) {
      f.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F5F2),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF4E342E)),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Image.asset(
                  "assets/login.png",
                  height: 100,
                ),
              ),
              const SizedBox(height: 24),

              const Text(
                'VERIFICACIÓN DE CUENTA',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2D2D2D),
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 12),

              Text(
                'Ingresa el código de 6 dígitos que enviamos a:\n${widget.email}',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 14,
                  color: Color(0xFF5A4A42),
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 32),

              // ✅ Campos de Código (6 recuadros)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: List.generate(6, (index) {
                  return SizedBox(
                    width: 45,
                    child: TextField(
                      controller: _controladores[index],
                      focusNode: _focusNodes[index],
                      textAlign: TextAlign.center,
                      keyboardType: TextInputType.number,
                      maxLength: 1,
                      decoration: InputDecoration(
                        counterText: '',
                        filled: true,
                        fillColor: Colors.white,
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(color: Color(0xFFC8B8AE)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(color: Color(0xFF4E342E), width: 2),
                        ),
                        contentPadding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2D2D2D),
                      ),
                      onChanged: (valor) {
                        if (valor.isNotEmpty && index < 5) {
                          _focusNodes[index + 1].requestFocus();
                        } else if (valor.isEmpty && index > 0) {
                          _focusNodes[index - 1].requestFocus();
                        }
                      },
                    ),
                  );
                }),
              ),
              const SizedBox(height: 40),

              // ✅ Botón VERIFICAR
              SizedBox(
                height: 52,
                child: ElevatedButton(
                  onPressed: _cargando ? null : _verificarCodigo,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4E342E),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    elevation: 2,
                  ),
                  child: _cargando
                      ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2.5,
                    ),
                  )
                      : const Text(
                    'CONFIRMAR CÓDIGO',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              TextButton(
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => const CatalogoScreen()),
                  );
                },
                child: const Text(
                  'Saltar por ahora (Solo pruebas)',
                  style: TextStyle(
                    color: Colors.blueGrey,
                    fontSize: 13,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),

              const SizedBox(height: 10),

              TextButton(
                onPressed: _cargando ? null : _reenviarCodigo,
                child: const Text(
                  '¿No recibiste el código? Reenviar',
                  style: TextStyle(
                    color: Color(0xFF4E342E),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
