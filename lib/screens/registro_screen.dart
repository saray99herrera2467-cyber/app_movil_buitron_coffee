import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // ✅ Agregado para formateadores
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
  // COLORES BUITRÓN COFFEE (NARANJA CÁLIDO)
  // =========================================================

  static const Color cafePrincipal = Color(0xFFF9A15E);
  static const Color cafeClaro = Color(0xFFFF7043);
  static const Color crema = Color(0xFFFFFBF2);
  static const Color cremaClaro = Color(0xFFFFFFFF);
  static const Color dorado = Color(0xFFFFAB40);
  static const Color textoOscuro = Color(0xFF2D2D2D);
  static const Color textoSuave = Color(0xFF7D6E66);

  // =========================================================
  // REGISTRARSE
  // =========================================================

  void registrarse() async {
    String nombre = nombreController.text.trim();
    String apellido = apellidoController.text.trim();
    String documento = documentoController.text.trim();
    String correo = correoController.text.trim();
    String direccion = direccionController.text.trim();
    String telefono = telefonoController.text.trim();
    String clave = claveController.text.trim();

    if (nombre.isEmpty) { _mostrarMensaje('Por favor, complete su nombre verdadero'); return; }
    if (apellido.isEmpty) { _mostrarMensaje('Por favor, complete su nombre verdadero'); return; }
    
    // 📌 RESTRICTIÓN: Nombre verdadero (Solo letras, min 3)
    final bool nombreValido = RegExp(r"^[a-zA-ZáéíóúÁÉÍÓÚñÑ ]{3,}$").hasMatch(nombre);
    final bool apellidoValido = RegExp(r"^[a-zA-ZáéíóúÁÉÍÓÚñÑ ]{3,}$").hasMatch(apellido);
    if (!nombreValido || !apellidoValido) {
      _mostrarMensaje('Por favor, complete su nombre verdadero (solo letras, mín. 3 caracteres)');
      return;
    }

    if (documento.isEmpty) { _mostrarMensaje('El documento es obligatorio'); return; }
    if (correo.isEmpty) { _mostrarMensaje('El correo es obligatorio'); return; }
    if (direccion.isEmpty) { _mostrarMensaje('La dirección es obligatorio'); return; }
    if (telefono.isEmpty) { _mostrarMensaje('El teléfono es obligatorio'); return; }
    if (clave.isEmpty) { _mostrarMensaje('La contraseña es obligatoria'); return; }

    if (documento.length > 11) { _mostrarMensaje('El documento no puede tener más de 11 dígitos'); return; }
    if (telefono.length > 10) { _mostrarMensaje('El teléfono no puede tener más de 10 dígitos'); return; }

    final bool correoValido = RegExp(r"^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$").hasMatch(correo);
    if (!correoValido) { _mostrarMensaje('Ingresa un correo electrónico válido'); return; }

    if (clave.length < 8) { _mostrarMensaje('La contraseña debe tener al menos 8 caracteres'); return; }

    setState(() { cargando = true; });

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

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(backgroundColor: cafePrincipal, content: Text('Registro realizado. Por favor verifica tu correo.'), behavior: SnackBarBehavior.floating),
      );

      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => VerificacionScreen(email: correo)));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(backgroundColor: Colors.red, content: Text(e.toString().replaceFirst('Exception: ', ''))));
    } finally {
      if (mounted) { setState(() { cargando = false; }); }
    }
  }

  void _mostrarMensaje(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(backgroundColor: cafePrincipal, content: Text(msg, style: const TextStyle(color: Colors.white)), behavior: SnackBarBehavior.floating));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: crema,
      appBar: AppBar(
        backgroundColor: cafePrincipal,
        elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back, color: Colors.white), onPressed: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const LoginPage()))),
        title: const Text('BUITRÓN COFFEE', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold, letterSpacing: 1)),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 25),
            child: Column(
              children: [
                const SizedBox(height: 30),
                Container(
                  width: 105,
                  height: 105,
                  decoration: BoxDecoration(color: cremaClaro, shape: BoxShape.circle, border: Border.all(color: cafeClaro, width: 3), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.12), blurRadius: 10, offset: const Offset(0, 4))]),
                  child: const Icon(Icons.person_add_outlined, size: 55, color: cafePrincipal),
                ),
                const SizedBox(height: 22),
                const Text('CREAR CUENTA', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: cafePrincipal, letterSpacing: 0.5)),
                const SizedBox(height: 7),
                const Text('Regístrate para disfrutar de Buitrón Coffee', textAlign: TextAlign.center, style: TextStyle(fontSize: 14, color: textoSuave)),
                const SizedBox(height: 28),
                _campoTexto(controller: nombreController, labelText: 'Nombre', hintText: 'Escriba su nombre', icono: Icons.person_outline, tipo: TextInputType.name, formatters: [FilteringTextInputFormatter.allow(RegExp(r'[a-zA-ZáéíóúÁÉÍÓÚñÑ ]'))]),
                const SizedBox(height: 16),
                _campoTexto(controller: apellidoController, labelText: 'Apellido', hintText: 'Escriba su apellido', icono: Icons.badge_outlined, tipo: TextInputType.name, formatters: [FilteringTextInputFormatter.allow(RegExp(r'[a-zA-ZáéíóúÁÉÍÓÚñÑ ]'))]),
                const SizedBox(height: 16),
                _campoTexto(controller: documentoController, labelText: 'Número de documento', hintText: 'Ej: 1023456789', icono: Icons.assignment_ind_outlined, tipo: TextInputType.number, maxL: 11, formatters: [FilteringTextInputFormatter.digitsOnly]),
                const SizedBox(height: 16),
                _campoTexto(controller: correoController, labelText: 'Correo electrónico', hintText: 'Correo', icono: Icons.email_outlined, tipo: TextInputType.emailAddress),
                const SizedBox(height: 16),
                _campoTexto(controller: direccionController, labelText: 'Dirección', hintText: 'Dirección', icono: Icons.location_on_outlined, tipo: TextInputType.streetAddress),
                const SizedBox(height: 16),
                _campoTexto(controller: telefonoController, labelText: 'Teléfono', hintText: 'Ej: 3101234567', icono: Icons.phone_outlined, tipo: TextInputType.phone, maxL: 10, formatters: [FilteringTextInputFormatter.digitsOnly]),
                const SizedBox(height: 16),
                TextField(
                  controller: claveController,
                  obscureText: ocultarClave,
                  decoration: InputDecoration(
                    labelText: 'Contraseña',
                    hintText: 'Ingrese una contraseña',
                    labelStyle: const TextStyle(color: textoSuave),
                    prefixIcon: const Icon(Icons.lock_outline, color: cafePrincipal),
                    suffixIcon: IconButton(icon: Icon(ocultarClave ? Icons.visibility_off : Icons.visibility, color: cafeClaro), onPressed: () => setState(() => ocultarClave = !ocultarClave)),
                    filled: true,
                    fillColor: cremaClaro,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: cafeClaro, width: 2)),
                  ),
                ),
                const SizedBox(height: 28),
                SizedBox(
                  width: 260,
                  height: 50,
                  child: InkWell(
                    onTap: cargando ? null : registrarse,
                    borderRadius: BorderRadius.circular(10),
                    child: Container(
                      decoration: BoxDecoration(gradient: const LinearGradient(colors: [cafePrincipal, cafeClaro]), borderRadius: BorderRadius.circular(10), boxShadow: [BoxShadow(color: cafePrincipal.withValues(alpha: 0.3), blurRadius: 10, offset: const Offset(0, 4))]),
                      alignment: Alignment.center,
                      child: cargando 
                        ? const CircularProgressIndicator(color: Colors.white, strokeWidth: 2)
                        : const Text('REGISTRARSE', style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
                    ),
                  ),
                ),
                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _campoTexto({required TextEditingController controller, required String labelText, required String hintText, required IconData icono, required TextInputType tipo, int? maxL, List<TextInputFormatter>? formatters}) {
    return TextField(
      controller: controller,
      keyboardType: tipo,
      maxLength: maxL,
      inputFormatters: formatters,
      decoration: InputDecoration(
        labelText: labelText,
        counterText: '',
        hintText: hintText,
        labelStyle: const TextStyle(color: textoSuave),
        prefixIcon: Icon(icono, color: cafePrincipal),
        filled: true,
        fillColor: cremaClaro,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: cafeClaro, width: 2)),
      ),
    );
  }

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
