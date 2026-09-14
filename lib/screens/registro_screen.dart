import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import 'verificacion_screen.dart';

class RegistroPage extends StatefulWidget {
  const RegistroPage({super.key});

  @override
  State<RegistroPage> createState() => _RegistroPageState();
}

class _RegistroPageState extends State<RegistroPage> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _nombreController = TextEditingController();
  final TextEditingController _apellidoController = TextEditingController();
  final TextEditingController _documentoController = TextEditingController();
  final TextEditingController _correoController = TextEditingController();
  final TextEditingController _telefonoController = TextEditingController();
  final TextEditingController _direccionController = TextEditingController();
  final TextEditingController _claveController = TextEditingController();
  final TextEditingController _confirmarClaveController =
  TextEditingController();

  bool _cargando = false;
  bool _ocultarClave = true;
  bool _ocultarConfirmarClave = true;

  static const Color cafePrincipal = Color(0xFF4E342E);
  static const Color cafeClaro = Color(0xFF795548);
  static const Color crema = Color(0xFFF5EFE6);

  @override
  void dispose() {
    _nombreController.dispose();
    _apellidoController.dispose();
    _documentoController.dispose();
    _correoController.dispose();
    _telefonoController.dispose();
    _direccionController.dispose();
    _claveController.dispose();
    _confirmarClaveController.dispose();
    super.dispose();
  }

  // ============================
  // VALIDACIONES
  // ============================

  String? _validarNombre(String? valor) {
    final nombre = valor?.trim() ?? '';

    if (nombre.isEmpty) {
      return 'Ingresa tu nombre';
    }

    if (nombre.length < 2) {
      return 'El nombre es demasiado corto';
    }

    final regex = RegExp(r"^[a-zA-ZáéíóúÁÉÍÓÚñÑüÜ\s]+$");

    if (!regex.hasMatch(nombre)) {
      return 'El nombre solo puede contener letras';
    }

    return null;
  }

  String? _validarApellido(String? valor) {
    final apellido = valor?.trim() ?? '';

    if (apellido.isEmpty) {
      return 'Ingresa tu apellido';
    }

    if (apellido.length < 2) {
      return 'El apellido es demasiado corto';
    }

    final regex = RegExp(r"^[a-zA-ZáéíóúÁÉÍÓÚñÑüÜ\s]+$");

    if (!regex.hasMatch(apellido)) {
      return 'El apellido solo puede contener letras';
    }

    return null;
  }

  String? _validarDocumento(String? valor) {
    final documento = valor?.trim() ?? '';

    if (documento.isEmpty) {
      return 'Ingresa tu documento';
    }

    if (!RegExp(r'^\d+$').hasMatch(documento)) {
      return 'El documento solo puede contener números';
    }

    if (documento.length < 6) {
      return 'El documento debe tener al menos 6 números';
    }

    if (documento.length > 15) {
      return 'El documento es demasiado largo';
    }

    return null;
  }

  String? _validarCorreo(String? valor) {
    final correo = valor?.trim() ?? '';

    if (correo.isEmpty) {
      return 'Ingresa tu correo';
    }

    final regex = RegExp(
      r'^[\w\.-]+@[\w\.-]+\.\w+$',
    );

    if (!regex.hasMatch(correo)) {
      return 'Ingresa un correo válido';
    }

    return null;
  }

  String? _validarTelefono(String? valor) {
    final telefono = valor?.trim() ?? '';

    if (telefono.isEmpty) {
      return 'Ingresa tu teléfono';
    }

    if (!RegExp(r'^\d+$').hasMatch(telefono)) {
      return 'El teléfono solo puede contener números';
    }

    if (telefono.length != 10) {
      return 'El teléfono debe tener 10 números';
    }

    return null;
  }

  String? _validarDireccion(String? valor) {
    final direccion = valor?.trim() ?? '';

    if (direccion.isEmpty) {
      return 'Ingresa tu dirección';
    }

    if (direccion.length < 5) {
      return 'Ingresa una dirección válida';
    }

    return null;
  }

  String? _validarClave(String? valor) {
    final clave = valor ?? '';

    if (clave.isEmpty) {
      return 'Ingresa una contraseña';
    }

    if (clave.length < 8) {
      return 'Debe tener mínimo 8 caracteres';
    }

    if (!RegExp(r'[A-Za-z]').hasMatch(clave)) {
      return 'Debe contener al menos una letra';
    }

    if (!RegExp(r'\d').hasMatch(clave)) {
      return 'Debe contener al menos un número';
    }

    return null;
  }

  String? _validarConfirmarClave(String? valor) {
    final confirmar = valor ?? '';

    if (confirmar.isEmpty) {
      return 'Confirma tu contraseña';
    }

    if (confirmar != _claveController.text) {
      return 'Las contraseñas no coinciden';
    }

    return null;
  }

  // ============================
  // REGISTRAR USUARIO
  // ============================

  Future<void> _registrar() async {
    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!.validate()) {
      return;
    }

    final nombre = _nombreController.text.trim();
    final apellido = _apellidoController.text.trim();
    final documento = _documentoController.text.trim();
    final correo = _correoController.text.trim().toLowerCase();
    final telefono = _telefonoController.text.trim();
    final direccion = _direccionController.text.trim();
    final clave = _claveController.text;

    setState(() {
      _cargando = true;
    });

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

      // Después del registro se solicita el código
      // que Supabase envía al correo.
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => VerificacionScreen(
            email: correo,
            esRecuperacion: false,
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      String mensaje = e.toString();

      // Mensajes más amigables
      if (mensaje.contains('User already registered') ||
          mensaje.contains('already registered')) {
        mensaje = 'Este correo ya está registrado.';
      } else if (mensaje.contains('Invalid email')) {
        mensaje = 'El correo electrónico no es válido.';
      } else if (mensaje.contains('Password')) {
        mensaje = 'La contraseña no cumple los requisitos.';
      } else if (mensaje.contains('Network')) {
        mensaje = 'No hay conexión con el servidor.';
      }

      _mostrarMensaje(mensaje);
    } finally {
      if (mounted) {
        setState(() {
          _cargando = false;
        });
      }
    }
  }

  // ============================
  // MENSAJE
  // ============================

  void _mostrarMensaje(String mensaje) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mensaje),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 4),
      ),
    );
  }

  // ============================
  // CAMPO PERSONALIZADO
  // ============================

  InputDecoration _decoracionCampo({
    required String label,
    required IconData icono,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(
        icono,
        color: cafePrincipal,
      ),
      suffixIcon: suffixIcon,
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 16,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(
          color: cafeClaro,
          width: 2,
        ),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(
          color: Colors.red,
          width: 1,
        ),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(
          color: Colors.red,
          width: 2,
        ),
      ),
    );
  }

  // ============================
  // BUILD
  // ============================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: crema,

      appBar: AppBar(
        title: const Text(
          'CREAR CUENTA',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: cafePrincipal,
        foregroundColor: Colors.white,
        centerTitle: true,
      ),

      body: SafeArea(
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // ============================
                // TITULO
                // ============================

                const Icon(
                  Icons.coffee,
                  size: 60,
                  color: cafePrincipal,
                ),

                const SizedBox(height: 12),

                const Text(
                  'Bienvenido a Buitrón Coffee',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 23,
                    fontWeight: FontWeight.bold,
                    color: cafePrincipal,
                  ),
                ),

                const SizedBox(height: 8),

                const Text(
                  'Crea tu cuenta para continuar',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.black54,
                    fontSize: 15,
                  ),
                ),

                const SizedBox(height: 28),

                // ============================
                // NOMBRE
                // ============================

                TextFormField(
                  controller: _nombreController,
                  textCapitalization: TextCapitalization.words,
                  keyboardType: TextInputType.name,
                  validator: _validarNombre,
                  decoration: _decoracionCampo(
                    label: 'Nombre',
                    icono: Icons.person_outline,
                  ),
                ),

                const SizedBox(height: 16),

                // ============================
                // APELLIDO
                // ============================

                TextFormField(
                  controller: _apellidoController,
                  textCapitalization: TextCapitalization.words,
                  keyboardType: TextInputType.name,
                  validator: _validarApellido,
                  decoration: _decoracionCampo(
                    label: 'Apellido',
                    icono: Icons.person,
                  ),
                ),

                const SizedBox(height: 16),

                // ============================
                // DOCUMENTO
                // ============================

                TextFormField(
                  controller: _documentoController,
                  keyboardType: TextInputType.number,
                  validator: _validarDocumento,
                  maxLength: 15,
                  decoration: _decoracionCampo(
                    label: 'Documento',
                    icono: Icons.badge_outlined,
                  ).copyWith(
                    counterText: '',
                  ),
                ),

                const SizedBox(height: 16),

                // ============================
                // CORREO
                // ============================

                TextFormField(
                  controller: _correoController,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  validator: _validarCorreo,
                  autocorrect: false,
                  decoration: _decoracionCampo(
                    label: 'Correo electrónico',
                    icono: Icons.email_outlined,
                  ),
                ),

                const SizedBox(height: 16),

                // ============================
                // TELEFONO
                // ============================

                TextFormField(
                  controller: _telefonoController,
                  keyboardType: TextInputType.phone,
                  validator: _validarTelefono,
                  maxLength: 10,
                  decoration: _decoracionCampo(
                    label: 'Teléfono',
                    icono: Icons.phone_outlined,
                  ).copyWith(
                    counterText: '',
                  ),
                ),

                const SizedBox(height: 16),

                // ============================
                // DIRECCION
                // ============================

                TextFormField(
                  controller: _direccionController,
                  textCapitalization: TextCapitalization.sentences,
                  validator: _validarDireccion,
                  maxLines: 2,
                  decoration: _decoracionCampo(
                    label: 'Dirección',
                    icono: Icons.location_on_outlined,
                  ),
                ),

                const SizedBox(height: 16),

                // ============================
                // CONTRASEÑA
                // ============================

                TextFormField(
                  controller: _claveController,
                  obscureText: _ocultarClave,
                  validator: _validarClave,
                  onChanged: (_) {
                    // Actualiza la validación de confirmación
                    if (_confirmarClaveController.text.isNotEmpty) {
                      _formKey.currentState?.validate();
                    }
                  },
                  decoration: _decoracionCampo(
                    label: 'Contraseña',
                    icono: Icons.lock_outline,
                    suffixIcon: IconButton(
                      icon: Icon(
                        _ocultarClave
                            ? Icons.visibility_off
                            : Icons.visibility,
                        color: cafePrincipal,
                      ),
                      onPressed: () {
                        setState(() {
                          _ocultarClave = !_ocultarClave;
                        });
                      },
                    ),
                  ),
                ),

                const SizedBox(height: 8),

                const Padding(
                  padding: EdgeInsets.only(left: 4),
                  child: Text(
                    'Mínimo 8 caracteres, incluyendo una letra y un número.',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.black54,
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // ============================
                // CONFIRMAR CONTRASEÑA
                // ============================

                TextFormField(
                  controller: _confirmarClaveController,
                  obscureText: _ocultarConfirmarClave,
                  validator: _validarConfirmarClave,
                  decoration: _decoracionCampo(
                    label: 'Confirmar contraseña',
                    icono: Icons.lock_reset,
                    suffixIcon: IconButton(
                      icon: Icon(
                        _ocultarConfirmarClave
                            ? Icons.visibility_off
                            : Icons.visibility,
                        color: cafePrincipal,
                      ),
                      onPressed: () {
                        setState(() {
                          _ocultarConfirmarClave =
                          !_ocultarConfirmarClave;
                        });
                      },
                    ),
                  ),
                ),

                const SizedBox(height: 30),

                // ============================
                // BOTON REGISTRAR
                // ============================

                SizedBox(
                  height: 54,
                  child: ElevatedButton(
                    onPressed: _cargando ? null : _registrar,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: cafePrincipal,
                      foregroundColor: Colors.white,
                      disabledBackgroundColor:
                      cafePrincipal.withOpacity(0.5),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 2,
                    ),
                    child: _cargando
                        ? const SizedBox(
                      width: 25,
                      height: 25,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        color: Colors.white,
                      ),
                    )
                        : const Text(
                      'CREAR CUENTA',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 18),

                // ============================
                // INFORMACION VERIFICACION
                // ============================

                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: cafeClaro.withOpacity(0.2),
                    ),
                  ),
                  child: const Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.mark_email_read_outlined,
                        color: cafePrincipal,
                        size: 22,
                      ),
                      SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Después de registrarte recibirás un código de '
                              '6 dígitos en tu correo para verificar tu cuenta.',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.black54,
                            height: 1.4,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // ============================
                // VOLVER AL LOGIN
                // ============================

                TextButton(
                  onPressed: _cargando
                      ? null
                      : () {
                    Navigator.pop(context);
                  },
                  child: const Text(
                    '¿Ya tienes una cuenta? Inicia sesión',
                    style: TextStyle(
                      color: cafePrincipal,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}