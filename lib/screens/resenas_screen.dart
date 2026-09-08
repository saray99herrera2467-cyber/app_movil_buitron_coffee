import 'package:flutter/material.dart';
import 'catalogo_screen.dart';
import '../models/producto.dart';
import '../models/resena.dart';
import '../services/producto_service.dart';
import '../services/resena_service.dart';
import '../services/auth_service.dart';

class ResenasScreen extends StatefulWidget {
  const ResenasScreen({super.key});

  @override
  State<ResenasScreen> createState() => _ResenasScreenState();
}

class _ResenasScreenState extends State<ResenasScreen> {
  int _calificacion = 0;
  final TextEditingController _comentarioController = TextEditingController();

  List<Producto> _productos = [];
  Producto? _productoSeleccionado;
  List<ResenaModel> _resenasExistentes = [];
  bool _cargandoProductos = true;
  bool _cargandoResenas = false;
  bool _enviando = false;

  // ==========================================================
  // COLORES
  // ==========================================================

  static const Color colorPrimario = Color(0xFF4E342E);
  static const Color colorFondo = Color(0xFFF5EFE6);
  static const Color colorDorado = Color(0xFFC8A45D);

  // ==========================================================
  // REGRESAR AL CATÁLOGO
  // ==========================================================

  @override
  void initState() {
    super.initState();
    _cargarProductos();
  }

  Future<void> _cargarProductos() async {
    try {
      final productos = await ProductoService.obtenerTodos();
      if (!mounted) return;
      setState(() {
        _productos = productos;
        _cargandoProductos = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _cargandoProductos = false);
    }
  }

  Future<void> _cargarResenas(int productoId) async {
    setState(() => _cargandoResenas = true);
    try {
      final resenas = await ResenaService.obtenerResenasAprobadasPorProducto(productoId);
      if (!mounted) return;
      setState(() {
        _resenasExistentes = resenas;
        _cargandoResenas = false;
      });
    } catch (e) {
      if (mounted) setState(() => _cargandoResenas = false);
    }
  }

  // ==========================================================
  // ENVIAR RESEÑA REAL A SUPABASE
  // ==========================================================

  Future<void> _enviarResena() async {
    if (_calificacion == 0 ||
        _productoSeleccionado == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, selecciona un producto y una calificación')),
      );
      return;
    }

    setState(() => _enviando = true);

    try {
      final int? usuarioId = await AuthService.obtenerIdSesion();
      
      if (usuarioId == null) {
        throw Exception('Sesión expirada. Por favor, inicia sesión de nuevo.');
      }

      // Obtener el nombre del usuario para la columna nombre_usuario
      final usuarioData = await AuthService.obtenerUsuario(usuarioId);
      final String nombreUsuario = usuarioData['nombre_usuario'] ?? 'Cliente Buitrón';

      final nuevaResena = ResenaModel(
        productoId: _productoSeleccionado!.id,
        usuarioId: usuarioId,
        nombreUsuario: nombreUsuario,
        calificacion: _calificacion,
        comentario: _comentarioController.text.trim().isEmpty 
            ? null 
            : _comentarioController.text.trim(),
        estado: 'pendiente',
      );

      await ResenaService.agregarResena(nuevaResena);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('¡Reseña enviada! El administrador la revisará pronto.'),
          backgroundColor: colorPrimario,
          behavior: SnackBarBehavior.floating,
        ),
      );

      setState(() {
        _calificacion = 0;
        _comentarioController.clear();
        _productoSeleccionado = null;
        _enviando = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _enviando = false);
      
      String errorMsg = e.toString().replaceFirst('Exception: ', '');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $errorMsg'), 
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _volverAlCatalogo() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => const CatalogoScreen(),
      ),
    );
  }

  @override
  void dispose() {
    _comentarioController.dispose();
    super.dispose();
  }

  // ==========================================================
  // PANTALLA
  // ==========================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: colorFondo,

      // ========================================================
      // APP BAR
      // ========================================================

      appBar: AppBar(
        backgroundColor: colorPrimario,
        elevation: 3,

        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            color: Colors.white,
            size: 26,
          ),
          onPressed: _volverAlCatalogo,
        ),

        centerTitle: true,

        title: const Text(
          'BUITRÓN COFFEE',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
            letterSpacing: 1,
          ),
        ),
      ),

      // ========================================================
      // CONTENIDO
      // ========================================================

      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              // ==================================================
              // ENCABEZADO
              // ==================================================

              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  vertical: 18,
                  horizontal: 15,
                ),
                decoration: BoxDecoration(
                  color: colorPrimario,
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 6,
                      offset: Offset(0, 3),
                    ),
                  ],
                ),
                child: const Column(
                  children: [
                    Icon(
                      Icons.rate_review_outlined,
                      color: colorDorado,
                      size: 38,
                    ),

                    SizedBox(height: 8),

                    Text(
                      'RESEÑAS Y CALIFICACIONES',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1,
                      ),
                    ),

                    SizedBox(height: 5),

                    Text(
                      'Comparte tu experiencia con nuestro café',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 25),

              // ==================================================
              // SELECCIONAR PRODUCTO
              // ==================================================

              const Text(
                'Selecciona el café que deseas calificar',
                style: TextStyle(
                  color: colorPrimario,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 10),

              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 15),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 5,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: _cargandoProductos
                    ? const Padding(
                  padding: EdgeInsets.all(20),
                  child: Center(child: CircularProgressIndicator(color: colorPrimario)),
                )
                    : DropdownButtonHideUnderline(
                  child: DropdownButton<Producto>(
                    value: _productoSeleccionado,
                    hint: const Text('Elige un producto...'),
                    isExpanded: true,
                    items: _productos.map((producto) {
                      return DropdownMenuItem<Producto>(
                        value: producto,
                        child: Text(producto.nombre, style: const TextStyle(color: colorPrimario)),
                      );
                    }).toList(),
                    onChanged: (val) {
                      setState(() {
                        _productoSeleccionado = val;
                        _resenasExistentes = [];
                      });
                      if (val != null) {
                        _cargarResenas(val.id);
                      }
                    },
                  ),
                ),
              ),

              if (_productoSeleccionado != null) ...[
                const SizedBox(height: 15),
                Center(
                  child: Text(
                    'Calificando: ${_productoSeleccionado!.nombre}',
                    style: const TextStyle(color: colorDorado, fontWeight: FontWeight.bold, fontSize: 13),
                  ),
                ),
              ],

              const SizedBox(height: 25),

              // ==================================================
              // LISTA DE RESEÑAS EXISTENTES
              // ==================================================

              if (_productoSeleccionado != null) ...[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Reseñas de la comunidad',
                      style: TextStyle(
                        color: colorPrimario,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (_cargandoResenas)
                      const SizedBox(
                        width: 15,
                        height: 15,
                        child: CircularProgressIndicator(strokeWidth: 2, color: colorDorado),
                      ),
                  ],
                ),
                const SizedBox(height: 10),
                if (!_cargandoResenas && _resenasExistentes.isEmpty)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 20),
                      child: Text(
                        'Aún no hay reseñas aprobadas para este café.',
                        style: TextStyle(color: Colors.black45, fontSize: 13),
                      ),
                    ),
                  )
                else
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _resenasExistentes.length,
                    itemBuilder: (context, index) {
                      final r = _resenasExistentes[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        color: Colors.white,
                        elevation: 1,
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    r.usuario?['nombre_usuario'] ?? 'Cliente Buitrón',
                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: colorPrimario),
                                  ),
                                  Row(
                                    children: List.generate(
                                      5,
                                      (i) => Icon(
                                        i < r.calificacion ? Icons.star : Icons.star_border,
                                        size: 14,
                                        color: colorDorado,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              Text(
                                r.comentario ?? '',
                                style: const TextStyle(fontSize: 13, color: Colors.black87),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                const SizedBox(height: 20),
                const Divider(),
                const SizedBox(height: 10),
              ],

              // ==================================================
              // CALIFICACIÓN
              // ==================================================

              const Text(
                '¿Cómo calificarías este café?',
                style: TextStyle(
                  color: colorPrimario,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 10),

              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  vertical: 15,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 4,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  children: [

                    Row(
                      mainAxisAlignment:
                      MainAxisAlignment.center,
                      children: List.generate(
                        5,
                            (index) {
                          return IconButton(
                            icon: Icon(
                              index < _calificacion
                                  ? Icons.star
                                  : Icons.star_border,
                              color: colorDorado,
                              size: 38,
                            ),
                            onPressed: () {
                              setState(() {
                                _calificacion = index + 1;
                              });
                            },
                          );
                        },
                      ),
                    ),

                    if (_calificacion > 0)
                      Text(
                        _textoCalificacion(),
                        style: const TextStyle(
                          color: colorPrimario,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                  ],
                ),
              ),

              const SizedBox(height: 25),

              // ==================================================
              // COMENTARIO
              // ==================================================

              const Text(
                'Escribe tu reseña',
                style: TextStyle(
                  color: colorPrimario,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 10),

              TextField(
                controller: _comentarioController,
                maxLines: 5,
                style: const TextStyle(
                  color: colorPrimario,
                  fontSize: 14,
                ),
                decoration: InputDecoration(
                  hintText:
                  'Cuéntanos qué te pareció el café...',
                  hintStyle: const TextStyle(
                    color: Colors.black38,
                    fontSize: 13,
                  ),
                  filled: true,
                  fillColor: Colors.white,

                  contentPadding:
                  const EdgeInsets.all(15),

                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),

                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                      color: Colors.black12,
                    ),
                  ),

                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                      color: colorDorado,
                      width: 2,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 25),

              // ==================================================
              // BOTÓN ENVIAR
              // ==================================================

              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colorPrimario,
                    foregroundColor: Colors.white,
                    elevation: 3,

                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),

                  onPressed:
                  _calificacion > 0 &&
                      _productoSeleccionado != null &&
                      !_enviando
                      ? _enviarResena
                      : null,

                  child: _enviando
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Row(
                    mainAxisAlignment:
                    MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.send_outlined,
                        size: 20,
                      ),

                      SizedBox(width: 8),

                      Text(
                        'Enviar reseña',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // ==================================================
              // MENSAJE INFERIOR
              // ==================================================

              Center(
                child: Row(
                  mainAxisAlignment:
                  MainAxisAlignment.center,
                  children: const [
                    Icon(
                      Icons.coffee_outlined,
                      color: colorDorado,
                      size: 18,
                    ),

                    SizedBox(width: 6),

                    Text(
                      'Gracias por elegir Buitrón Coffee',
                      style: TextStyle(
                        color: Colors.black54,
                        fontSize: 12,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }

  // ==========================================================
  // TEXTO SEGÚN CALIFICACIÓN
  // ==========================================================

  String _textoCalificacion() {
    switch (_calificacion) {
      case 1:
        return 'Muy malo';
      case 2:
        return 'Malo';
      case 3:
        return 'Regular';
      case 4:
        return 'Muy bueno';
      case 5:
        return '¡Excelente!';
      default:
        return '';
    }
  }
}