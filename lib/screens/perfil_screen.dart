import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../services/perfil_service.dart';
import '../services/auth_service.dart';
import 'catalogo_screen.dart';

class PerfilScreen extends StatefulWidget {
  const PerfilScreen({super.key});

  @override
  State<PerfilScreen> createState() => _PerfilScreenState();
}

class _PerfilScreenState extends State<PerfilScreen> {
  // ============================================================
  // SERVICIO
  // ============================================================

  final PerfilService _perfilService = PerfilService();

  // ============================================================
  // CONTROLADORES
  // ============================================================

  final TextEditingController _nombreController =
  TextEditingController();

  final TextEditingController _correoController =
  TextEditingController();

  final TextEditingController _telefonoController =
  TextEditingController();

  final TextEditingController _direccionController =
  TextEditingController();

  // ============================================================
  // VARIABLES
  // ============================================================

  bool _cargando = true;
  bool _guardando = false;

  // ============================================================
  // COLORES BUITRÓN COFFEE
  // ============================================================

  static const Color cafePrincipal = Color(0xFF4E342E);
  static const Color cafeClaro = Color(0xFF795548);
  static const Color crema = Color(0xFFF5EFE6);
  static const Color cremaClaro = Color(0xFFFFFCF7);
  static const Color dorado = Color(0xFFC8A45D);
  static const Color textoOscuro = Color(0xFF3A2925);
  static const Color textoSuave = Color(0xFF756860);

  // ============================================================
  // INIT
  // ============================================================

  @override
  void initState() {
    super.initState();
    _cargarPerfil();
  }

  // ============================================================
  // DISPOSE
  // ============================================================

  @override
  void dispose() {
    _nombreController.dispose();
    _correoController.dispose();
    _telefonoController.dispose();
    _direccionController.dispose();

    super.dispose();
  }

  // ============================================================
  // CARGAR PERFIL
  // ============================================================

  Future<void> _cargarPerfil() async {
    try {
      // ✅ Obtener el correo desde la sesión local en lugar de Supabase Auth
      final correo = await AuthService.obtenerCorreoSesion();

      if (correo == null || correo.isEmpty) {
        if (!mounted) return;
        setState(() => _cargando = false);
        return;
      }

      _correoController.text = correo;

      final datos = await _perfilService.cargarDatosUsuario(correo);

      if (!mounted) return;

      if (datos != null) {
        _nombreController.text = (datos['nombre_usuario'] ?? '').toString();
        _telefonoController.text = (datos['telefono'] ?? '').toString();
        _direccionController.text = (datos['direccion'] ?? '').toString();
      }

      setState(() => _cargando = false);
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _cargando = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: cafePrincipal,
          content: Text(
            'No se pudieron cargar los datos: $e',
            style: const TextStyle(
              color: Colors.white,
            ),
          ),
        ),
      );
    }
  }

  // ============================================================
  // EDITAR PERFIL
  // ============================================================

  void _mostrarEditarPerfil() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: cremaClaro,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(22),
        ),
      ),
      builder: (modalContext) {
        return Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 22,
            bottom:
            MediaQuery.of(modalContext)
                .viewInsets
                .bottom +
                20,
          ),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [

                // ==================================================
                // INDICADOR
                // ==================================================

                Center(
                  child: Container(
                    width: 45,
                    height: 5,
                    decoration: BoxDecoration(
                      color: cafeClaro,
                      borderRadius:
                      BorderRadius.circular(10),
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // ==================================================
                // TÍTULO
                // ==================================================

                const Center(
                  child: Text(
                    'Editar perfil',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: cafePrincipal,
                    ),
                  ),
                ),

                const SizedBox(height: 25),

                // ==================================================
                // NOMBRE
                // ==================================================

                TextField(
                  controller: _nombreController,

                  decoration: InputDecoration(
                    labelText: 'Nombre',
                    labelStyle: const TextStyle(
                      color: textoSuave,
                    ),

                    prefixIcon: const Icon(
                      Icons.person_outline,
                      color: cafePrincipal,
                    ),

                    filled: true,
                    fillColor: Colors.white,

                    border: OutlineInputBorder(
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
                  ),
                ),

                const SizedBox(height: 15),

                // ==================================================
                // CORREO
                // ==================================================

                TextField(
                  controller: _correoController,
                  enabled: false,

                  decoration: InputDecoration(
                    labelText: 'Correo',
                    labelStyle: const TextStyle(
                      color: textoSuave,
                    ),

                    prefixIcon: const Icon(
                      Icons.email_outlined,
                      color: cafeClaro,
                    ),

                    filled: true,
                    fillColor: const Color(0xFFE9E3DC),

                    border: OutlineInputBorder(
                      borderRadius:
                      BorderRadius.circular(10),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),

                const SizedBox(height: 15),

                // ==================================================
                // TELÉFONO
                // ==================================================

                TextField(
                  controller: _telefonoController,
                  keyboardType: TextInputType.phone,

                  decoration: InputDecoration(
                    labelText: 'Teléfono',
                    labelStyle: const TextStyle(
                      color: textoSuave,
                    ),

                    prefixIcon: const Icon(
                      Icons.phone_outlined,
                      color: cafePrincipal,
                    ),

                    filled: true,
                    fillColor: Colors.white,

                    border: OutlineInputBorder(
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
                  ),
                ),

                const SizedBox(height: 15),

                // ==================================================
                // DIRECCIÓN
                // ==================================================

                TextField(
                  controller: _direccionController,

                  decoration: InputDecoration(
                    labelText: 'Dirección',
                    labelStyle: const TextStyle(
                      color: textoSuave,
                    ),

                    prefixIcon: const Icon(
                      Icons.location_on_outlined,
                      color: cafePrincipal,
                    ),

                    filled: true,
                    fillColor: Colors.white,

                    border: OutlineInputBorder(
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
                  ),
                ),

                const SizedBox(height: 25),

                // ==================================================
                // GUARDAR
                // ==================================================

                SizedBox(
                  width: double.infinity,
                  height: 50,

                  child: ElevatedButton(
                    onPressed: _guardando
                        ? null
                        : () {
                      _guardarPerfil(
                        modalContext,
                      );
                    },

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

                    child: _guardando
                        ? const SizedBox(
                      width: 22,
                      height: 22,
                      child:
                      CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                        : const Text(
                      'GUARDAR CAMBIOS',
                      style: TextStyle(
                        fontWeight:
                        FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ============================================================
  // GUARDAR PERFIL
  // ============================================================

  Future<void> _guardarPerfil(
      BuildContext modalContext,
      ) async {
    final nombre =
    _nombreController.text.trim();

    final telefono =
    _telefonoController.text.trim();

    final direccion =
    _direccionController.text.trim();

    final correo =
    _correoController.text.trim();

    if (nombre.isEmpty) {
      _mostrarMensaje(
        'El nombre es obligatorio',
      );
      return;
    }

    if (correo.isEmpty) {
      _mostrarMensaje(
        'No se encontró el correo del usuario',
      );
      return;
    }

    setState(() {
      _guardando = true;
    });

    try {
      await _perfilService.guardarPerfilCompleto(
        correo: correo,
        nombre: nombre,
        telefono: telefono,
        direccion: direccion,
      );

      // ✅ Refrescar los datos en pantalla
      await _cargarPerfil();

      if (!mounted) return;

      Navigator.pop(modalContext);

      setState(() {
        _guardando = false;
      });

      _mostrarMensaje(
        'Perfil actualizado correctamente',
      );
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _guardando = false;
      });

      _mostrarMensaje(
        'Error al actualizar perfil: $e',
      );
    }
  }

  // ============================================================
  // MENSAJE
  // ============================================================

  void _mostrarMensaje(String mensaje) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: cafePrincipal,
        content: Text(
          mensaje,
          style: const TextStyle(
            color: Colors.white,
          ),
        ),
        duration:
        const Duration(seconds: 3),
      ),
    );
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: crema,

      // ========================================================
      // APP BAR
      // ========================================================

      appBar: AppBar(
        backgroundColor: cafePrincipal,
        elevation: 0,

        // FLECHA → CATÁLOGO
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
                const CatalogoScreen(),
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

      // ========================================================
      // CUERPO
      // ========================================================

      body: SafeArea(
        child: _cargando
            ? const Center(
          child: CircularProgressIndicator(
            color: cafePrincipal,
          ),
        )
            : SingleChildScrollView(
          child: Padding(
            padding:
            const EdgeInsets.symmetric(
              horizontal: 20,
            ),

            child: Column(
              children: [

                const SizedBox(height: 35),

                // ==========================================
                // FOTO / ICONO
                // ==========================================

                Container(
                  width: 125,
                  height: 125,

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
                            .withValues(
                          alpha: 0.12,
                        ),
                        blurRadius: 10,
                        offset:
                        const Offset(0, 4),
                      ),
                    ],
                  ),

                  child: const Icon(
                    Icons.person_outline,
                    size: 70,
                    color: cafePrincipal,
                  ),
                ),

                const SizedBox(height: 25),

                // ==========================================
                // NOMBRE
                // ==========================================

                Text(
                  _nombreController.text.isEmpty
                      ? 'Usuario'
                      : _nombreController.text,

                  textAlign:
                  TextAlign.center,

                  style: const TextStyle(
                    fontSize: 21,
                    fontWeight:
                    FontWeight.bold,
                    color: cafePrincipal,
                  ),
                ),

                const SizedBox(height: 8),

                // ==========================================
                // CORREO
                // ==========================================

                Text(
                  _correoController.text,

                  textAlign:
                  TextAlign.center,

                  style: const TextStyle(
                    fontSize: 14,
                    color: textoSuave,
                  ),
                ),

                const SizedBox(height: 30),

                // ==========================================
                // INFORMACIÓN
                // ==========================================

                _datoPerfil(
                  Icons.phone_outlined,
                  'Teléfono',
                  _telefonoController
                      .text
                      .isEmpty
                      ? 'Sin teléfono'
                      : _telefonoController
                      .text,
                ),

                const SizedBox(height: 12),

                if (_direccionController
                    .text
                    .isNotEmpty)
                  _datoPerfil(
                    Icons.location_on_outlined,
                    'Dirección',
                    _direccionController.text,
                  ),

                const SizedBox(height: 30),

                // ==========================================
                // BOTÓN EDITAR
                // ==========================================

                SizedBox(
                  width: 260,
                  height: 50,

                  child: ElevatedButton(
                    onPressed:
                    _mostrarEditarPerfil,

                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                      cafePrincipal,

                      foregroundColor:
                      Colors.white,

                      elevation: 2,

                      shape:
                      RoundedRectangleBorder(
                        borderRadius:
                        BorderRadius.circular(
                          10,
                        ),
                      ),
                    ),

                    child: const Row(
                      mainAxisAlignment:
                      MainAxisAlignment.center,

                      children: [
                        Icon(
                          Icons.edit_outlined,
                          size: 20,
                        ),

                        SizedBox(width: 8),

                        Text(
                          'EDITAR PERFIL',

                          style: TextStyle(
                            fontSize: 15,
                            fontWeight:
                            FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ============================================================
  // TARJETA DE DATO
  // ============================================================

  Widget _datoPerfil(
      IconData icono,
      String titulo,
      String valor,
      ) {
    return Container(
      width: double.infinity,

      padding: const EdgeInsets.all(15),

      decoration: BoxDecoration(
        color: cremaClaro,

        borderRadius:
        BorderRadius.circular(12),

        border: Border.all(
          color: dorado.withValues(
            alpha: 0.35,
          ),
        ),
      ),

      child: Row(
        children: [

          Container(
            width: 45,
            height: 45,

            decoration: BoxDecoration(
              color: crema,
              borderRadius:
              BorderRadius.circular(10),
            ),

            child: Icon(
              icono,
              color: cafePrincipal,
              size: 23,
            ),
          ),

          const SizedBox(width: 14),

          Expanded(
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,

              children: [

                Text(
                  titulo,
                  style: const TextStyle(
                    fontSize: 12,
                    color: textoSuave,
                  ),
                ),

                const SizedBox(height: 3),

                Text(
                  valor,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight:
                    FontWeight.w600,
                    color: textoOscuro,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}