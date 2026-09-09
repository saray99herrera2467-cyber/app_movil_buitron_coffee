import 'package:flutter/material.dart';
import 'login_screen.dart';
import 'verificacion_screen.dart';
import '../services/auth_service.dart'; 

class RegistroPage extends StatefulWidget {
  const RegistroPage({super.key});

  @override
  State<RegistroPage> createState() => _RegistroPageState();
}

class _RegistroPageState extends State<RegistroPage> {
  // =========================================================
  // CONTROLADORES
  // =========================================================

  final TextEditingController nombreController =
  TextEditingController();

  final TextEditingController apellidoController =
  TextEditingController();

  final TextEditingController documentoController =
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
  bool cargando = false;

  // =========================================================
  // COLORES BUITRÓN COFFEE
  // =========================================================

  static const Color cafePrincipal = Color(0xFF4E342E);
  static const Color cafeClaro = Color(0xFF795548);
  static const Color crema = Color(0xFFF5EFE6);
  static const Color cremaClaro = Color(0xFFFFFCF7);
  static const Color dorado = Color(0xFFC8A45D);
  static const Color textoOscuro = Color(0xFF3A2925);
  static const Color textoSuave = Color(0xFF756860);

  // =========================================================
  // REGISTRARSE
  // =========================================================

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

    if (nombre.isEmpty) { _mostrarMensaje('El nombre es obligatorio'); return; }
    if (apellido.isEmpty) { _mostrarMensaje('El apellido es obligatorio'); return; }
    if (documento.isEmpty) { _mostrarMensaje('El documento es obligatorio'); return; }
    if (correo.isEmpty) { _mostrarMensaje('El correo es obligatorio'); return; }
    if (direccion.isEmpty) { _mostrarMensaje('La dirección es obligatorio'); return; }
    if (telefono.isEmpty) { _mostrarMensaje('El teléfono es obligatorio'); return; }
    if (clave.isEmpty) { _mostrarMensaje('La contraseña es obligatoria'); return; }

    // 📌 RESTRICTIÓN: Documento max 11
    if (documento.length > 11) {
      _mostrarMensaje('El documento no puede tener más de 11 dígitos');
      return;
    }

    // 📌 RESTRICTIÓN: Teléfono max 10
    if (telefono.length > 10) {
      _mostrarMensaje('El teléfono no puede tener más de 10 dígitos');
      return;
    }

    // 📌 VALIDACIÓN DE CORREO (Formato real)
    final bool correoValido = RegExp(r"^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$").hasMatch(correo);
    if (!correoValido) {
      _mostrarMensaje('Ingresa un correo electrónico válido');
      return;
    }

    // 📌 VALIDACIÓN DE CONTRASEÑA (8 caracteres, letras y números)
    if (clave.length < 8) {
      _mostrarMensaje('La contraseña debe tener al menos 8 caracteres');
      return;
    }
    if (!RegExp(r'^(?=.*[A-Za-z])(?=.*\d)[A-Za-z\d]{8,}$').hasMatch(clave)) {
      _mostrarMensaje('La contraseña debe incluir letras y números');
      return;
    }

    setState(() {
      cargando = true;
    });

    // =======================================================
    // INTENTAR REGISTRO EN SUPABASE
    // =======================================================

    try {
      await AuthService.registrar(
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
      // REGISTRO EXITOSO - REDIRIGIR A VERIFICACIÓN
      // =====================================================

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: cafePrincipal,
          content: Text(
            'Registro realizado. Por favor verifica tu correo.',
            style: TextStyle(
              color: Colors.white,
            ),
          ),
          behavior: SnackBarBehavior.floating,
        ),
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => VerificacionScreen(email: correo),
        ),
      );
    } catch (e) {
      // =====================================================
      // ERROR AL REGISTRAR
      // =====================================================

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.red,
          content: Text(
            e.toString().replaceFirst('Exception: ', ''),
            style: const TextStyle(
              color: Colors.white,
            ),
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          cargando = false;
        });
      }
    }
  }

  void _mostrarMensaje(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: cafePrincipal,
        content: Text(msg, style: const TextStyle(color: Colors.white)),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  // =========================================================
  // BUILD
  // =========================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: crema,

      // =======================================================
      // APP BAR
      // =======================================================

      appBar: AppBar(
        backgroundColor: cafePrincipal,
        elevation: 0,

        // FLECHA → LOGIN
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            color: Colors.white,
          ),

          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) =>
                const LoginPage(),
              ),
            );
          },
        ),

        title: const Text(
          'BUITRÓN COFFEE',

          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
            letterSpacing: 1,
          ),
        ),

        centerTitle: true,
      ),

      // =======================================================
      // CUERPO
      // =======================================================

      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 25,
            ),

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
                // DOCUMENTO (max 11)
                // =================================================

                _campoTexto(
                  controller: documentoController,
                  labelText: 'Número de documento',
                  hintText: 'Ej: 1023456789',
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
                  hintText: 'Ej: 3101234567',
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

                  children: [

                    const Text(
                      '¿Ya tienes una cuenta?',

                      style: TextStyle(
                        color: textoSuave,
                      ),
                    ),

                    TextButton(
                      onPressed: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                            const LoginPage(),
                          ),
                        );
                      },

                      child: const Text(
                        'Iniciar sesión',

                        style: TextStyle(
                          color: cafePrincipal,
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
      ),
    );
  }

  // =========================================================
  // WIDGET PARA LOS CAMPOS
  // =========================================================

  Widget _campoTexto({
    required TextEditingController controller,
    required String labelText,
    required String hintText,
    required IconData icono,
    required TextInputType tipo,
    int? maxL, // 👈 Nuevo parámetro
  }) {
    return TextField(
      controller: controller,

      keyboardType: tipo,
      maxLength: maxL, // 👈 Aplicar longitud

      decoration: InputDecoration(
        labelText: labelText,
        counterText: '', // 👈 Ocultar contador inferior
        hintText: hintText,

        labelStyle: const TextStyle(
          color: textoSuave,
        ),

        hintStyle: const TextStyle(
          color: textoSuave,
          fontSize: 14,
        ),

        prefixIcon: Icon(
          icono,
          color: cafePrincipal,
        ),

        filled: true,

        fillColor: cremaClaro,

        border: OutlineInputBorder(
          borderRadius:
          BorderRadius.circular(10),

          borderSide: BorderSide.none,
        ),

        enabledBorder:
        OutlineInputBorder(
          borderRadius:
          BorderRadius.circular(10),

          borderSide: BorderSide.none,
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
    );
  }

  // =========================================================
  // LIBERAR CONTROLADORES
  // =========================================================

  @override
  void dispose() {
    nombreController.dispose();
    apellidoController.dispose();
    correoController.dispose();
    direccionController.dispose();
    telefonoController.dispose();
    claveController.dispose();

    super.dispose();
  }
}