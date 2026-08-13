import 'package:flutter/material.dart';
import 'Login_screen.dart';

class RegistroPage extends StatefulWidget {
  const RegistroPage({super.key});

  @override
  State<RegistroPage> createState() => _RegistroPageState();
}

class _RegistroPageState extends State<RegistroPage> {
  final TextEditingController nombreController =
  TextEditingController();

  final TextEditingController correoController =
  TextEditingController();

  final TextEditingController direccionController =
  TextEditingController();

  final TextEditingController telefonoController =
  TextEditingController();

  final TextEditingController claveController =
  TextEditingController();

  bool ocultarClave = true;

  // =========================================================
  // REGISTRARSE
  // =========================================================

  void registrarse() {
    String nombre = nombreController.text.trim();
    String correo = correoController.text.trim();
    String direccion = direccionController.text.trim();
    String telefono = telefonoController.text.trim();
    String clave = claveController.text.trim();

    // Verificar campos
    if (nombre.isEmpty ||
        correo.isEmpty ||
        direccion.isEmpty ||
        telefono.isEmpty ||
        clave.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Por favor, completa todos los campos',
          ),
        ),
      );

      return;
    }

    // Registro exitoso
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Registro realizado correctamente',
        ),
      ),
    );

    // =========================================================
    // VOLVER AL INICIO DE SESIÓN
    // =========================================================

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => const LoginPage(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      body: SafeArea(
        child: Column(
          children: [

            // =================================================
            // ENCABEZADO
            // =================================================

            Container(
              width: double.infinity,
              height: 45,

              color: const Color(0xFF9E0000),

              child: const Center(
                child: Text(
                  'Registro',

                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),

            // =================================================
            // CAMPOS
            // =================================================

            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [

                    const SizedBox(height: 12),

                    // NOMBRE
                    _campoTexto(
                      controller: nombreController,
                      hintText: 'Escriba su nombre',
                      icono: Icons.person,
                      tipo: TextInputType.name,
                    ),

                    const SizedBox(height: 7),

                    // CORREO
                    _campoTexto(
                      controller: correoController,
                      hintText: 'Correo',
                      icono: Icons.email,
                      tipo: TextInputType.emailAddress,
                    ),

                    const SizedBox(height: 7),

                    // DIRECCIÓN
                    _campoTexto(
                      controller: direccionController,
                      hintText: 'Dirección',
                      icono: Icons.location_on,
                      tipo: TextInputType.streetAddress,
                    ),

                    const SizedBox(height: 7),

                    // TELÉFONO
                    _campoTexto(
                      controller: telefonoController,
                      hintText: 'Teléfono',
                      icono: Icons.phone,
                      tipo: TextInputType.phone,
                    ),

                    const SizedBox(height: 7),

                    // =================================================
                    // CONTRASEÑA
                    // =================================================

                    Padding(
                      padding:
                      const EdgeInsets.symmetric(horizontal: 0),

                      child: SizedBox(
                        height: 38,

                        child: TextField(
                          controller: claveController,

                          obscureText: ocultarClave,

                          textAlign: TextAlign.left,

                          decoration: InputDecoration(
                            hintText: 'Contraseña',

                            hintStyle: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                            ),

                            prefixIcon: const Icon(
                              Icons.lock,
                              size: 18,
                              color: Color(0xFF8B8B8B),
                            ),

                            suffixIcon: IconButton(
                              padding: EdgeInsets.zero,

                              icon: Icon(
                                ocultarClave
                                    ? Icons.visibility_off
                                    : Icons.visibility,

                                size: 18,
                              ),

                              onPressed: () {
                                setState(() {
                                  ocultarClave =
                                  !ocultarClave;
                                });
                              },
                            ),

                            filled: true,

                            fillColor:
                            const Color(0xFFE8E8E8),

                            border: InputBorder.none,

                            contentPadding:
                            const EdgeInsets.symmetric(
                              vertical: 8,
                            ),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 32),

                    // =================================================
                    // BOTÓN REGISTRARSE
                    // =================================================

                    SizedBox(
                      width: 135,
                      height: 42,

                      child: ElevatedButton(
                        onPressed: registrarse,

                        style:
                        ElevatedButton.styleFrom(
                          backgroundColor:
                          const Color(0xFF9E0000),

                          foregroundColor:
                          Colors.white,

                          elevation: 0,

                          shape:
                          RoundedRectangleBorder(
                            borderRadius:
                            BorderRadius.circular(2),
                          ),

                          padding: EdgeInsets.zero,
                        ),

                        child: const Text(
                          'Registrarse',

                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),

      // =========================================================
      // BARRA INFERIOR
      // =========================================================

      bottomNavigationBar: Container(
        height: 50,

        decoration: const BoxDecoration(
          color: Colors.white,

          border: Border(
            top: BorderSide(
              color: Color(0xFF777777),
              width: 1,
            ),
          ),
        ),

        child: Row(
          mainAxisAlignment:
          MainAxisAlignment.spaceAround,

          children: [

            IconButton(
              onPressed: () {},

              icon: const Icon(
                Icons.location_on_outlined,
                color: Color(0xFF777777),
                size: 25,
              ),
            ),

            IconButton(
              onPressed: () {},

              icon: const Icon(
                Icons.home_outlined,
                color: Color(0xFF777777),
                size: 25,
              ),
            ),

            IconButton(
              onPressed: () {},

              icon: const Icon(
                Icons.menu_book_outlined,
                color: Color(0xFF777777),
                size: 25,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // =========================================================
  // WIDGET PARA LOS CAMPOS
  // =========================================================

  Widget _campoTexto({
    required TextEditingController controller,
    required String hintText,
    required IconData icono,
    required TextInputType tipo,
  }) {
    return SizedBox(
      height: 38,

      child: TextField(
        controller: controller,

        keyboardType: tipo,

        decoration: InputDecoration(
          hintText: hintText,

          hintStyle: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.bold,
          ),

          prefixIcon: Icon(
            icono,
            size: 18,
            color: const Color(0xFF777777),
          ),

          filled: true,

          fillColor:
          const Color(0xFFE8E8E8),

          border: InputBorder.none,

          contentPadding:
          const EdgeInsets.symmetric(
            vertical: 8,
          ),
        ),
      ),
    );
  }

  // =========================================================
  // LIBERAR CONTROLADORES
  // =========================================================

  @override
  void dispose() {
    nombreController.dispose();
    correoController.dispose();
    direccionController.dispose();
    telefonoController.dispose();
    claveController.dispose();

    super.dispose();
  }
}