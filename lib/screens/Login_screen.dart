import 'package:flutter/material.dart';
import 'registro_screen.dart';
import 'catalogo_screen.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController correoController =
  TextEditingController();

  final TextEditingController claveController =
  TextEditingController();

  bool ocultarClave = true;

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

  // ==========================================================
  // INICIAR SESIÓN
  // ==========================================================

  void iniciarSesion() {
    String correo = correoController.text.trim();
    String clave = claveController.text.trim();

    if (correo.isEmpty || clave.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: cafePrincipal,
          content: Text(
            'Por favor, completa todos los campos',
            style: TextStyle(color: Colors.white),
          ),
        ),
      );

      return;
    }

    // ==========================================
    // IR AL CATÁLOGO
    // ==========================================

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => const CatalogoScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: crema,

      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [

              // ==================================================
              // ENCABEZADO
              // ==================================================

              Container(
                width: double.infinity,
                height: 65,

                decoration: const BoxDecoration(
                  color: cafePrincipal,
                ),

                child: const Center(
                  child: Text(
                    'BUITRON COFFEE',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 19,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.5,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 35),

              // ==================================================
              // IMAGEN LOGIN
              // ==================================================

              Container(
                width: 165,
                height: 165,

                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: cremaClaro,

                  border: Border.all(
                    color: dorado,
                    width: 3,
                  ),

                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.12),
                      blurRadius: 12,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),

                child: ClipOval(
                  child: Padding(
                    padding: const EdgeInsets.all(10),

                    child: Image.asset(
                      'assets/login.png',

                      fit: BoxFit.cover,

                      errorBuilder:
                          (context, error, stackTrace) {
                        return const Icon(
                          Icons.local_cafe,
                          size: 75,
                          color: cafePrincipal,
                        );
                      },
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 30),

              // ==================================================
              // TÍTULO
              // ==================================================

              const Text(
                'INICIO DE SESIÓN',

                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: cafePrincipal,
                  letterSpacing: 0.5,
                ),
              ),

              const SizedBox(height: 8),

              const Text(
                'Ingresa a tu cuenta',

                style: TextStyle(
                  fontSize: 14,
                  color: textoSuave,
                ),
              ),

              const SizedBox(height: 28),

              // ==================================================
              // CORREO
              // ==================================================

              Padding(
                padding:
                const EdgeInsets.symmetric(horizontal: 30),

                child: TextField(
                  controller: correoController,

                  keyboardType:
                  TextInputType.emailAddress,

                  decoration: InputDecoration(
                    labelText: 'Correo electrónico',

                    labelStyle: const TextStyle(
                      color: textoSuave,
                    ),

                    prefixIcon: const Icon(
                      Icons.email_outlined,
                      color: cafePrincipal,
                    ),

                    filled: true,

                    fillColor: cremaClaro,

                    border: OutlineInputBorder(
                      borderRadius:
                      BorderRadius.circular(12),

                      borderSide: BorderSide.none,
                    ),

                    enabledBorder: OutlineInputBorder(
                      borderRadius:
                      BorderRadius.circular(12),

                      borderSide: BorderSide.none,
                    ),

                    focusedBorder: OutlineInputBorder(
                      borderRadius:
                      BorderRadius.circular(12),

                      borderSide: const BorderSide(
                        color: dorado,
                        width: 2,
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 18),

              // ==================================================
              // CONTRASEÑA
              // ==================================================

              Padding(
                padding:
                const EdgeInsets.symmetric(horizontal: 30),

                child: TextField(
                  controller: claveController,

                  obscureText: ocultarClave,

                  decoration: InputDecoration(
                    labelText: 'Contraseña',

                    labelStyle: const TextStyle(
                      color: textoSuave,
                    ),

                    prefixIcon: const Icon(
                      Icons.lock_outline,
                      color: cafePrincipal,
                    ),

                    suffixIcon: IconButton(
                      icon: Icon(
                        ocultarClave
                            ? Icons.visibility_off
                            : Icons.visibility,

                        color: cafeClaro,
                      ),

                      onPressed: () {
                        setState(() {
                          ocultarClave =
                          !ocultarClave;
                        });
                      },
                    ),

                    filled: true,

                    fillColor: cremaClaro,

                    border: OutlineInputBorder(
                      borderRadius:
                      BorderRadius.circular(12),

                      borderSide: BorderSide.none,
                    ),

                    enabledBorder: OutlineInputBorder(
                      borderRadius:
                      BorderRadius.circular(12),

                      borderSide: BorderSide.none,
                    ),

                    focusedBorder: OutlineInputBorder(
                      borderRadius:
                      BorderRadius.circular(12),

                      borderSide: const BorderSide(
                        color: dorado,
                        width: 2,
                      ),
                    ),
                  ),
                ),
              ),

              // ==================================================
              // OLVIDASTE CONTRASEÑA
              // ==================================================

              Align(
                alignment: Alignment.centerRight,

                child: Padding(
                  padding: const EdgeInsets.only(
                    right: 25,
                    top: 8,
                  ),

                  child: TextButton(
                    onPressed: () {
                      // Aquí posteriormente
                      // colocaremos recuperar contraseña.
                    },

                    child: const Text(
                      '¿Olvidaste tu contraseña?',

                      style: TextStyle(
                        color: cafePrincipal,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 8),

              // ==================================================
              // BOTÓN INICIAR SESIÓN
              // ==================================================

              SizedBox(
                width: 250,
                height: 50,

                child: ElevatedButton(
                  onPressed: iniciarSesion,

                  style: ElevatedButton.styleFrom(
                    backgroundColor: cafePrincipal,

                    foregroundColor: Colors.white,

                    elevation: 3,

                    shadowColor:
                    Colors.black.withValues(alpha: 0.2),

                    shape: RoundedRectangleBorder(
                      borderRadius:
                      BorderRadius.circular(10),
                    ),
                  ),

                  child: const Text(
                    'INICIAR SESIÓN',

                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // ==================================================
              // REGISTRO
              // ==================================================

              Row(
                mainAxisAlignment:
                MainAxisAlignment.center,

                children: [

                  const Text(
                    '¿No tienes una cuenta?',

                    style: TextStyle(
                      color: textoSuave,
                    ),
                  ),

                  TextButton(
                    onPressed: () {

                      Navigator.push(
                        context,

                        MaterialPageRoute(
                          builder: (context) =>
                          const RegistroPage(),
                        ),
                      );

                    },

                    child: const Text(
                      'Registrarse',

                      style: TextStyle(
                        color: cafePrincipal,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  // ==========================================================
  // LIBERAR CONTROLADORES
  // ==========================================================

  @override
  void dispose() {
    correoController.dispose();
    claveController.dispose();

    super.dispose();
  }
}