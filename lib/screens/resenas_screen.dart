import 'package:flutter/material.dart';
import 'catalogo_screen.dart';

class ResenasScreen extends StatefulWidget {
  const ResenasScreen({super.key});

  @override
  State<ResenasScreen> createState() => _ResenasScreenState();
}

class _ResenasScreenState extends State<ResenasScreen> {
  int _calificacion = 0;

  final TextEditingController _comentarioController =
  TextEditingController();

  // ==========================================================
  // COLORES
  // ==========================================================

  static const Color colorPrimario = Color(0xFF4E342E);
  static const Color colorFondo = Color(0xFFF5EFE6);
  static const Color colorDorado = Color(0xFFC8A45D);
  static const Color colorCafeClaro = Color(0xFFD7CCC8);

  // ==========================================================
  // REGRESAR AL CATÁLOGO
  // ==========================================================

  void _volverAlCatalogo() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => const CatalogoScreen(),
      ),
    );
  }

  // ==========================================================
  // ENVIAR RESEÑA
  // ==========================================================

  void _enviarResena() {
    if (_calificacion == 0 ||
        _comentarioController.text.trim().isEmpty) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          '¡Reseña enviada con éxito!',
        ),
        backgroundColor: colorPrimario,
        behavior: SnackBarBehavior.floating,
      ),
    );

    setState(() {
      _calificacion = 0;
      _comentarioController.clear();
    });
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
              // PRODUCTO
              // ==================================================

              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(15),
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
                child: Row(
                  children: [

                    // Imagen / icono del café
                    Container(
                      width: 75,
                      height: 75,
                      decoration: BoxDecoration(
                        color: colorCafeClaro,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.coffee,
                        size: 42,
                        color: colorPrimario,
                      ),
                    ),

                    const SizedBox(width: 15),

                    const Expanded(
                      child: Column(
                        crossAxisAlignment:
                        CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Café Bourbon Rosado',
                            style: TextStyle(
                              color: colorPrimario,
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                            ),
                          ),

                          SizedBox(height: 6),

                          Text(
                            'Califica este producto y cuéntanos tu experiencia.',
                            style: TextStyle(
                              color: Colors.black54,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 25),

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
                      _comentarioController.text
                          .trim()
                          .isNotEmpty
                      ? _enviarResena
                      : null,

                  child: const Row(
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