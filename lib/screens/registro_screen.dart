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

<<<<<<< Updated upstream
=======
  final TextEditingController apellidoController =
  TextEditingController();

  final TextEditingController documentoController =
  TextEditingController();

>>>>>>> Stashed changes
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

<<<<<<< Updated upstream
  void registrarse() {
    String nombre = nombreController.text.trim();
    String correo = correoController.text.trim();
    String direccion = direccionController.text.trim();
    String telefono = telefonoController.text.trim();
    String clave = claveController.text.trim();
=======
  void registrarse() async {
    String nombre =
    nombreController.text.trim();

    String apellido =
    apellidoController.text.trim();

    String documento =
    documentoController.text.trim();

    String correo =
    correoController.text.trim();

    String direccion =
    direccionController.text.trim();

    String telefono =
    telefonoController.text.trim();

    String clave =
    claveController.text.trim();

    // =======================================================
    // VERIFICAR CAMPOS
    // =======================================================
>>>>>>> Stashed changes

    // Verificar campos
    if (nombre.isEmpty ||
<<<<<<< Updated upstream
=======
        apellido.isEmpty ||
        documento.isEmpty ||
>>>>>>> Stashed changes
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

<<<<<<< Updated upstream
    // Registro exitoso
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Registro realizado correctamente',
=======
    if (documento.length > 11) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: cafePrincipal,
          content: Text('El documento no puede exceder los 11 dígitos'),
        ),
      );
      return;
    }

    if (telefono.length > 10) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: cafePrincipal,
          content: Text('El teléfono no puede exceder los 10 dígitos'),
        ),
      );
      return;
    }

    setState(() {
      cargando = true;
    });

    // =======================================================
    // INTENTAR REGISTRO EN SUPABASE
    // =======================================================

    try {
      final usuario = await AuthService.registrar(
        nombreUsuario: nombre,
        apellido: apellido,
        documento: documento,
        correo: correo,
        clave: clave,
        telefono: telefono,
        direccion: direccion,
      );

      if (!mounted) return;

      // =====================================================
      // REGISTRO EXITOSO - REDIRIGIR SEGÚN ROL
      // =====================================================

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: cafePrincipal,
          content: Text(
            'Registro realizado correctamente',
            style: TextStyle(
              color: Colors.white,
            ),
          ),
>>>>>>> Stashed changes
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

<<<<<<< Updated upstream
            // =================================================
            // CAMPOS
            // =================================================
=======
            child: Column(
              children: [

                const SizedBox(height: 30),

                // =================================================
                // ICONO
                // =================================================

                Container(
                  width: 105,
                  height: 105,

                  decoration: BoxDecoration(
                    color: cremaClaro,
                    shape: BoxShape.circle,

                    border: Border.all(
                      color: dorado,
                      width: 3,
                    ),

                    boxShadow: [
                      BoxShadow(
                        color: Colors.black
                            .withValues(alpha: 0.12),
                        blurRadius: 10,
                        offset:
                        const Offset(0, 4),
                      ),
                    ],
                  ),

                  child: const Icon(
                    Icons.person_add_outlined,
                    size: 55,
                    color: cafePrincipal,
                  ),
                ),

                const SizedBox(height: 22),

                // =================================================
                // TÍTULO
                // =================================================

                const Text(
                  'CREAR CUENTA',

                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: cafePrincipal,
                    letterSpacing: 0.5,
                  ),
                ),

                const SizedBox(height: 7),

                const Text(
                  'Regístrate para disfrutar de Buitrón Coffee',

                  textAlign: TextAlign.center,

                  style: TextStyle(
                    fontSize: 14,
                    color: textoSuave,
                  ),
                ),

                const SizedBox(height: 28),

                // =================================================
                // NOMBRE
                // =================================================

                _campoTexto(
                  controller: nombreController,
                  labelText: 'Nombre',
                  hintText: 'Escriba su nombre',
                  icono: Icons.person_outline,
                  tipo: TextInputType.name,
                ),

                const SizedBox(height: 16),

                // =================================================
                // APELLIDO
                // =================================================

                _campoTexto(
                  controller: apellidoController,
                  labelText: 'Apellido',
                  hintText: 'Escriba su apellido',
                  icono: Icons.badge_outlined,
                  tipo: TextInputType.name,
                ),

                const SizedBox(height: 16),

                // =================================================
                // DOCUMENTO
                // =================================================

                _campoTexto(
                  controller: documentoController,
                  labelText: 'Número de documento',
                  hintText: 'Escriba su documento',
                  icono: Icons.assignment_ind_outlined,
                  tipo: TextInputType.number,
                  maxL: 11,
                ),

                const SizedBox(height: 16),

                // =================================================
                // CORREO
                // =================================================

                _campoTexto(
                  controller: correoController,
                  labelText: 'Correo electrónico',
                  hintText: 'Correo',
                  icono: Icons.email_outlined,
                  tipo: TextInputType.emailAddress,
                ),

                const SizedBox(height: 16),

                // =================================================
                // DIRECCIÓN
                // =================================================

                _campoTexto(
                  controller: direccionController,
                  labelText: 'Dirección',
                  hintText: 'Dirección',
                  icono: Icons.location_on_outlined,
                  tipo: TextInputType.streetAddress,
                ),

                const SizedBox(height: 16),

                // =================================================
                // TELÉFONO
                // =================================================

                _campoTexto(
                  controller: telefonoController,
                  labelText: 'Teléfono',
                  hintText: 'Teléfono',
                  icono: Icons.phone_outlined,
                  tipo: TextInputType.phone,
                  maxL: 10,
                ),

                const SizedBox(height: 16),

                // =================================================
                // CONTRASEÑA
                // =================================================

                TextField(
                  controller: claveController,

                  obscureText: ocultarClave,

                  decoration: InputDecoration(
                    labelText: 'Contraseña',

                    hintText: 'Ingrese una contraseña',

                    labelStyle: const TextStyle(
                      color: textoSuave,
                    ),

                    hintStyle: const TextStyle(
                      color: textoSuave,
                      fontSize: 14,
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
                      BorderRadius.circular(10),

                      borderSide:
                      BorderSide.none,
                    ),

                    enabledBorder:
                    OutlineInputBorder(
                      borderRadius:
                      BorderRadius.circular(10),

                      borderSide:
                      BorderSide.none,
                    ),

                    focusedBorder:
                    OutlineInputBorder(
                      borderRadius:
                      BorderRadius.circular(10),

                      borderSide:
                      const BorderSide(
                        color: dorado,
                        width: 2,
                      ),
                    ),

                    contentPadding:
                    const EdgeInsets.symmetric(
                      horizontal: 15,
                      vertical: 15,
                    ),
                  ),

                  style: const TextStyle(
                    color: textoOscuro,
                    fontSize: 14,
                  ),
                ),

                const SizedBox(height: 28),

                // =================================================
                // BOTÓN REGISTRARSE
                // =================================================

                SizedBox(
                  width: 260,
                  height: 50,

                  child: ElevatedButton(
                    onPressed: cargando ? null : registrarse,

                    style:
                    ElevatedButton.styleFrom(
                      backgroundColor:
                      cafePrincipal,

                      foregroundColor:
                      Colors.white,

                      elevation: 2,

                      shape:
                      RoundedRectangleBorder(
                        borderRadius:
                        BorderRadius.circular(10),
                      ),
                    ),

                    child: cargando
                        ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2.5,
                      ),
                    )
                        : const Text(
                      'REGISTRARSE',

                      style: TextStyle(
                        fontSize: 15,
                        fontWeight:
                        FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // =================================================
                // VOLVER AL LOGIN
                // =================================================

                Row(
                  mainAxisAlignment:
                  MainAxisAlignment.center,
>>>>>>> Stashed changes

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
    int? maxL,
  }) {
    return SizedBox(
      height: 38,

<<<<<<< Updated upstream
      child: TextField(
        controller: controller,

        keyboardType: tipo,

        decoration: InputDecoration(
          hintText: hintText,
=======
      keyboardType: tipo,
      maxLength: maxL,

      decoration: InputDecoration(
        labelText: labelText,
        counterText: '',
        hintText: hintText,
>>>>>>> Stashed changes

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
<<<<<<< Updated upstream
=======
    apellidoController.dispose();
    documentoController.dispose();
>>>>>>> Stashed changes
    correoController.dispose();
    direccionController.dispose();
    telefonoController.dispose();
    claveController.dispose();

    super.dispose();
  }
}