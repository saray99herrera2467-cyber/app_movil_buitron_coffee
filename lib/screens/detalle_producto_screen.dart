import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/producto.dart';
import '../models/resena.dart';
import '../providers/carrito_provider.dart';
import '../services/resena_service.dart';

class DetalleProductoScreen extends StatefulWidget {
  final Producto producto;

  const DetalleProductoScreen({super.key, required this.producto});

  @override
  State<DetalleProductoScreen> createState() => _DetalleProductoScreenState();
}

class _DetalleProductoScreenState extends State<DetalleProductoScreen> {
  List<ResenaModel> _resenas = [];
  bool _cargandoResenas = true;

  static const Color cafePrincipal = Color(0xFF4E342E);
  static const Color crema = Color(0xFFF5EFE6);
  static const Color dorado = Color(0xFFC8A45D);
  static const Color textoOscuro = Color(0xFF3A2925);
  static const Color textoSuave = Color(0xFF756860);

  @override
  void initState() {
    super.initState();
    _cargarResenas();
  }

  Future<void> _cargarResenas() async {
    try {
      final resenas = await ResenaService.obtenerResenasAprobadasPorProducto(widget.producto.id);
      if (mounted) {
        setState(() {
          _resenas = resenas;
          _cargandoResenas = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _cargandoResenas = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: crema,
      body: CustomScrollView(
        slivers: [
          // APP BAR CON IMAGEN
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            backgroundColor: cafePrincipal,
            flexibleSpace: FlexibleSpaceBar(
              background: _mostrarImagen(widget.producto),
            ),
          ),

          // CONTENIDO
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Categoría y Precio
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: cafePrincipal.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          widget.producto.categoria.toUpperCase(),
                          style: const TextStyle(color: cafePrincipal, fontWeight: FontWeight.bold, fontSize: 12),
                        ),
                      ),
                      Text(
                        '\$${widget.producto.precio.toStringAsFixed(0)}',
                        style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: cafePrincipal),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Nombre
                  Text(
                    widget.producto.nombre,
                    style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: textoOscuro),
                  ),

                  const SizedBox(height: 8),

                  // Stock disponible
                  Row(
                    children: [
                      Icon(Icons.inventory_2_outlined, size: 16, color: widget.producto.stock > 0 ? Colors.green : Colors.red),
                      const SizedBox(width: 6),
                      Text(
                        widget.producto.stock > 0 
                          ? 'Stock disponible: ${widget.producto.stock} unidades' 
                          : 'Agotado',
                        style: TextStyle(
                          color: widget.producto.stock > 0 ? Colors.green : Colors.red,
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  // Descripción
                  Text(
                    widget.producto.descripcion ?? 'No hay descripción disponible para este café.',
                    style: const TextStyle(fontSize: 16, color: textoSuave, height: 1.5),
                  ),

                  const SizedBox(height: 32),

                  // Sección de Reseñas
                  const Text(
                    'RESEÑAS DE LA COMUNIDAD',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: cafePrincipal, letterSpacing: 1),
                  ),

                  const SizedBox(height: 16),

                  if (_cargandoResenas)
                    const Center(child: CircularProgressIndicator(color: cafePrincipal))
                  else if (_resenas.isEmpty)
                    const Text('Aún no hay reseñas para este producto.', style: TextStyle(color: textoSuave))
                  else
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _resenas.length,
                      itemBuilder: (context, index) {
                        final r = _resenas[index];
                        return _buildResenaCard(r);
                      },
                    ),

                  const SizedBox(height: 100), // Espacio para el botón flotante
                ],
              ),
            ),
          ),
        ],
      ),
      bottomSheet: Container(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 85), // ✅ Elevamos los botones sustancialmente (85px)
        decoration: const BoxDecoration(
          color: Colors.white,
          boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, -5))],
        ),
        child: SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton(
            onPressed: () async {
              final messenger = ScaffoldMessenger.of(context);
              final error = await context.read<CarritoProvider>().agregarProducto(widget.producto);
              if (error != null) {
                messenger.showSnackBar(
                  SnackBar(backgroundColor: Colors.redAccent, content: Text(error)),
                );
              } else {
                messenger.showSnackBar(
                  SnackBar(content: Text('${widget.producto.nombre} agregado')),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: cafePrincipal,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('AGREGAR AL CARRITO', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          ),
        ),
      ),
    );
  }

  Widget _buildResenaCard(ResenaModel r) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 0,
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  r.usuario?['nombre_usuario'] ?? r.nombreUsuario ?? 'Cliente',
                  style: const TextStyle(fontWeight: FontWeight.bold, color: textoOscuro),
                ),
                Row(
                  children: List.generate(5, (i) => Icon(
                    i < r.calificacion ? Icons.star : Icons.star_border,
                    size: 16,
                    color: dorado,
                  )),
                ),
              ],
            ),
            if (r.comentario != null && r.comentario!.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(r.comentario!, style: const TextStyle(color: textoSuave, fontSize: 14)),
            ],
          ],
        ),
      ),
    );
  }

  Widget _mostrarImagen(Producto p) {
    if (p.imagen == null || p.imagen!.isEmpty) {
      return Image.asset('assets/cafe1.png', fit: BoxFit.cover);
    }
    if (p.imagen!.startsWith('http')) {
      return Image.network(p.imagen!, fit: BoxFit.cover);
    }
    final String ruta = p.imagen!.startsWith('assets/') ? p.imagen! : 'assets/${p.imagen}';
    return Image.asset(ruta, fit: BoxFit.cover, errorBuilder: (context, error, stackTrace) => Image.asset('assets/cafe1.png', fit: BoxFit.cover));
  }
}
