import 'package:flutter/material.dart';
import 'catalogo_screen.dart';

class VerificacionScreen extends StatefulWidget {
  const VerificacionScreen({super.key});

  @override
  State<VerificacionScreen> createState() => _VerificacionScreenState();
}

class _VerificacionScreenState extends State<VerificacionScreen> {
  final List<TextEditingController> _controladores = List.generate(4, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(4, (_) => FocusNode());
  bool _cargando = false;

  String get _codigoIngresado => _controladores.map((c) => c.text).join();

  Future<void> _verificarCodigo() async {
    if (_codigoIngresado.length < 4) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor ingresa el código completo de 4 dígitos'),
          backgroundColor: Color(0xFF9E0000),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() => _cargando = true);

    await Future.delayed(const Duration(seconds: 1));

    if (!mounted) return;
    setState(() => _cargando = false);

    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const CatalogoScreen()),
      );
    }
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
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ✅ Logo centrado
              Center(
                child: Image.asset(
                  "assets/login.png",
                  height: 100,
                ),
              ),
              const SizedBox(height: 24),

              // ✅ Título
              const Text(
                'VERIFICACIÓN',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2D2D2D),
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 12),

              // ✅ Subtítulo
              const Text(
                'Ingresa el código de 4 dígitos que enviamos a tu correo electrónico',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Color(0xFF5A4A42),
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 32),

              // ✅ Campos de Código (4 recuadros)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: List.generate(4, (index) {
                  return SizedBox(
                    width: 60,
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
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(6),
                          borderSide: const BorderSide(color: Color(0xFFC8B8AE)),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(6),
                          borderSide: const BorderSide(color: Color(0xFFC8B8AE)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(6),
                          borderSide: const BorderSide(color: Color(0xFF9E0000), width: 1.5),
                        ),
                        contentPadding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF2D2D2D),
                      ),
                      onChanged: (valor) {
                        if (valor.isNotEmpty && index < 3) {
                          _focusNodes[index + 1].requestFocus();
                        } else if (valor.isEmpty && index > 0) {
                          _focusNodes[index - 1].requestFocus();
                        }
                      },
                    ),
                  );
                }),
              ),
              const SizedBox(height: 32),

              // ✅ Botón VERIFICAR
              SizedBox(
                height: 48,
                child: ElevatedButton(
                  onPressed: _cargando ? null : _verificarCodigo,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF9E0000),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6),
                    ),
                    elevation: 0,
                  ),
                  child: _cargando
                      ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                      : const Text(
                    'VERIFICAR',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 1,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // ✅ Reenviar código
              TextButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Código reenviado'),
                      backgroundColor: Color(0xFF9E0000),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                },
                style: TextButton.styleFrom(
                  foregroundColor: const Color(0xFF9E0000),
                ),
                child: const Text(
                  '¿No recibiste el código? Reenviar',
                  style: TextStyle(fontSize: 14),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}