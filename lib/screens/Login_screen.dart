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
  // INICIAR SESIÓN
  // ==========================================================

  void iniciarSesion() {
    String correo = correoController.text.trim();
    String clave = claveController.text.trim();

    if (correo.isEmpty || clave.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Por favor, completa todos los campos',
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
      backgroundColor: const Color(0xFFF8F5F2),

      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [

              // ================================================
              // ENCABEZADO
              // ================================================

              Container(
                width: double.infinity,
                height: 55,

                decoration: const BoxDecoration(
                  color: Color(0xFF9E0000),
                ),

                child: const Center(
                  child: Text(
                    'BUITRON COFFEE',

                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 35),

              // ================================================
              // LOGO
              // ================================================

              Container(
                width: 140,
                height: 140,

                decoration: BoxDecoration(
                  shape: BoxShape.circle,

                  border: Border.all(
                    color: const Color(0xFF5B4636),
                    width: 2,
                  ),
                ),

                child: const Icon(
                  Icons.local_cafe,
                  size: 75,
                  color: Color(0xFF5B4636),
                ),
              ),

              const SizedBox(height: 35),

              // ================================================
              // TITULO
              // ================================================

              const Text(
                'INICIO DE SESIÓN',

                style: TextStyle(
                  fontSize: 23,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF5B4636),
                ),
              ),

              const SizedBox(height: 25),

              // ================================================
              // CORREO
              // ================================================

              Padding(
                padding:
                const EdgeInsets.symmetric(horizontal: 30),

                child: TextField(
                  controller: correoController,

                  keyboardType:
                  TextInputType.emailAddress,

                  decoration: InputDecoration(
                    labelText: 'Correo electrónico',

                    prefixIcon: const Icon(
                      Icons.email_outlined,
                      color: Color(0xFF9E0000),
                    ),

                    filled: true,

                    fillColor: Colors.white,

                    border: OutlineInputBorder(
                      borderRadius:
                      BorderRadius.circular(8),

                      borderSide:
                      BorderSide.none,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 18),

              // ================================================
              // CONTRASEÑA
              // ================================================

              Padding(
                padding:
                const EdgeInsets.symmetric(horizontal: 30),

                child: TextField(
                  controller: claveController,

                  obscureText: ocultarClave,

                  decoration: InputDecoration(
                    labelText: 'Contraseña',

                    prefixIcon: const Icon(
                      Icons.lock_outline,
                      color: Color(0xFF9E0000),
                    ),

                    suffixIcon: IconButton(
                      icon: Icon(
                        ocultarClave
                            ? Icons.visibility_off
                            : Icons.visibility,

                        color:
                        const Color(0xFF9E0000),
                      ),

                      onPressed: () {
                        setState(() {
                          ocultarClave =
                          !ocultarClave;
                        });
                      },
                    ),

                    filled: true,

                    fillColor: Colors.white,

                    border: OutlineInputBorder(
                      borderRadius:
                      BorderRadius.circular(8),

                      borderSide:
                      BorderSide.none,
                    ),
                  ),
                ),
              ),

              // ================================================
              // OLVIDASTE CONTRASEÑA
              // ================================================

              Align(
                alignment:
                Alignment.centerRight,

                child: Padding(
                  padding: const EdgeInsets.only(
                    right: 30,
                    top: 10,
                  ),

                  child: TextButton(
                    onPressed: () {
                      // Aquí posteriormente
                      // colocaremos recuperar contraseña.
                    },

                    child: const Text(
                      '¿Olvidaste tu contraseña?',

                      style: TextStyle(
                        color:
                        Color(0xFF9E0000),
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 10),

              // ================================================
              // BOTÓN INICIAR SESIÓN
              // ================================================

              SizedBox(
                width: 250,
                height: 48,

                child: ElevatedButton(
                  onPressed: iniciarSesion,

                  style:
                  ElevatedButton.styleFrom(
                    backgroundColor:
                    const Color(0xFF9E0000),

                    foregroundColor:
                    Colors.white,

                    shape:
                    RoundedRectangleBorder(
                      borderRadius:
                      BorderRadius.circular(5),
                    ),
                  ),

                  child: const Text(
                    'INICIAR SESIÓN',

                    style: TextStyle(
                      fontWeight:
                      FontWeight.bold,

                      fontSize: 15,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 18),

              // ================================================
              // REGISTRO
              // ================================================

              Row(
                mainAxisAlignment:
                MainAxisAlignment.center,

                children: [

                  const Text(
                    '¿No tienes una cuenta? ',

                    style: TextStyle(
                      color: Colors.black54,
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
                        color:
                        Color(0xFF9E0000),

                        fontWeight:
                        FontWeight.bold,
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