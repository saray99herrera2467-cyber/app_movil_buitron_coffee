import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import 'login_screen.dart';
import 'restablecer_clave_screen.dart';

class VerificacionScreen extends StatefulWidget {
  final String email;
  final bool esRecuperacion;

  const VerificacionScreen({
    super.key,
    required this.email,
    this.esRecuperacion = false,
  });

  @override
  State<VerificacionScreen> createState() => _VerificacionScreenState();
}

class _VerificacionScreenState extends State<VerificacionScreen> {
  final List<TextEditingController> _controladores = List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());
  bool _cargando = false;

  static const Color naranjaPrincipal = Color(0xFFF9A15E);
  static const Color naranjaIntenso = Color(0xFFFF7043);

  String get _codigoIngresado => _controladores.map((c) => c.text).join();

  Future<void> _verificarCodigo() async {
    if (_codigoIngresado.length != 6) {
      _mostrarMensaje('Ingresa el código completo de 6 dígitos');
      return;
    }

    setState(() => _cargando = true);

    try {
      await AuthService.verificarCodigo(widget.email, _codigoIngresado, esRecuperacion: widget.esRecuperacion);

      if (!mounted) return;

      _mostrarMensaje('¡Código verificado correctamente!', exito: true);
      await Future.delayed(const Duration(milliseconds: 500));

      if (mounted) {
        if (widget.esRecuperacion) {
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const RestablecerClaveScreen()));
        } else {
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const LoginPage()));
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
    if (_cargando) return;
    setState(() => _cargando = true);
    try {
      await AuthService.reenviarCodigo(widget.email, esRecuperacion: widget.esRecuperacion);
      if (mounted) _mostrarMensaje('Código reenviado correctamente.', exito: true);
    } catch (e) {
      if (mounted) _mostrarMensaje(e.toString().replaceFirst('Exception: ', ''));
    } finally {
      if (mounted) setState(() => _cargando = false);
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
    for (var c in _controladores) { c.dispose(); }
    for (var f in _focusNodes) { f.dispose(); }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFBF2),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: naranjaPrincipal),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(child: Image.asset('assets/login.png', height: 100)),
              const SizedBox(height: 24),
              const Text(
                'VERIFICACIÓN DE CUENTA',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF2D2D2D), letterSpacing: 1.2),
              ),
              const SizedBox(height: 12),
              Text(
                'Ingresa el código de 6 dígitos que enviamos a:\n${widget.email}',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 14, color: Color(0xFF7D6E66), height: 1.4),
              ),
              const SizedBox(height: 32),
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
                        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFFC8B8AE))),
                        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: naranjaIntenso, width: 2)),
                        contentPadding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF2D2D2D)),
                      onChanged: (valor) {
                        if (valor.isNotEmpty && index < 5) {
                          _focusNodes[index + 1].requestFocus();
                        } else if (valor.isEmpty && index > 0) {
                          _focusNodes[index - 1].requestFocus();
                        }
                        if (_codigoIngresado.length == 6) FocusScope.of(context).unfocus();
                      },
                    ),
                  );
                }),
              ),
              const SizedBox(height: 40),
              InkWell(
                onTap: _cargando ? null : _verificarCodigo,
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
                      : const Text('CONFIRMAR CÓDIGO', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 1)),
                ),
              ),
              const SizedBox(height: 20),
              TextButton(
                onPressed: _cargando ? null : _reenviarCodigo,
                child: const Text('¿No recibiste el código? Reenviar', style: TextStyle(color: naranjaPrincipal, fontWeight: FontWeight.w600)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
