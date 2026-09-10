import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/producto.dart';
import '../providers/carrito_provider.dart';
import '../services/producto_service.dart';
import '../services/auth_service.dart';

import 'carrito_screen.dart';
import 'historial_screen.dart';
import 'login_screen.dart';
import 'mapa_screen.dart';
import 'perfil_screen.dart';
import 'resenas_screen.dart';
import 'pqrs_screen.dart';
import 'detalle_producto_screen.dart';

// ============================================================
// COLORES BUITRÓN COFFEE
// ============================================================

const Color cafePrincipal = Color(0xFF4E342E);
const Color cafeClaro = Color(0xFF795548);
const Color crema = Color(0xFFF5EFE6);
const Color cremaClaro = Color(0xFFFFFCF7);
const Color dorado = Color(0xFFC8A45D);
const Color textoOscuro = Color(0xFF3A2925);
const Color textoSuave = Color(0xFF756860);

// ============================================================
// CATÁLOGO
// ============================================================

class CatalogoScreen extends StatefulWidget {
  const CatalogoScreen({super.key});

  @override
  State<CatalogoScreen> createState() => _CatalogoScreenState();
}

// ============================================================
// ESTADO DEL CATÁLOGO
// ============================================================

class _CatalogoScreenState extends State<CatalogoScreen> {
  final TextEditingController _buscarController =
  TextEditingController();

  Timer? _debounce;

  List<Producto> _productos = [];
  List<Producto> _productosFiltrados = [];

  bool _cargando = true;
  String _error = '';

  String _categoriaSeleccionada = 'Todos';

  // ==========================================================
  // INIT
  // ==========================================================

  @override
  void initState() {
    super.initState();
    _cargarProductos();
  }

  // ==========================================================
  // DISPOSE
  // ==========================================================

  @override
  void dispose() {
    _buscarController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  // ==========================================================
  // CARGAR PRODUCTOS
  // ==========================================================

  Future<void> _cargarProductos() async {
    if (!mounted) return;

    setState(() {
      _cargando = true;
      _error = '';
    });

    try {
      final productos = await ProductoService.obtenerTodos();

      if (!mounted) return;

      setState(() {
        _productos = productos;
        _cargando = false;
      });

      _filtrarProductos();
    } catch (e) {
      if (!mounted) return;

      debugPrint('Error cargando productos: $e');

      setState(() {
        _cargando = false;
        _error = 'No se pudieron cargar los productos';
      });
    }
  }

  // ==========================================================
  // BUSCAR
  // ==========================================================

  void _onBuscar(String texto) {
    if (mounted) {
      setState(() {});
    }

    _debounce?.cancel();

    _debounce = Timer(
      const Duration(milliseconds: 350),
          () {
        _filtrarProductos();
      },
    );
  }

  // ==========================================================
  // FILTRAR PRODUCTOS
  // ==========================================================

  void _filtrarProductos() {
    final texto = _buscarController.text.trim().toLowerCase();

    List<Producto> resultado = List<Producto>.from(_productos);

    // ----------------------------------------------------------
    // FILTRO POR TEXTO
    // ----------------------------------------------------------

    if (texto.isNotEmpty) {
      resultado = resultado.where((producto) {
        final nombre = producto.nombre.toLowerCase();

        final descripcion =
        (producto.descripcion ?? '').toLowerCase();

        final categoria =
        producto.categoria.toLowerCase();

        return nombre.contains(texto) ||
            descripcion.contains(texto) ||
            categoria.contains(texto);
      }).toList();
    }

    // ----------------------------------------------------------
    // FILTRO POR CATEGORÍA
    // ----------------------------------------------------------

    if (_categoriaSeleccionada != 'Todos') {
      resultado = resultado.where((producto) {
        return producto.categoria.toLowerCase() ==
            _categoriaSeleccionada.toLowerCase();
      }).toList();
    }

    if (!mounted) return;

    setState(() {
      _productosFiltrados = resultado;
    });
  }

  // ==========================================================
  // IMAGEN DEL PRODUCTO
  // ==========================================================

  Widget _mostrarImagen(Producto producto) {
    // ----------------------------------------------------------
    // SI NO TIENE IMAGEN
    // ----------------------------------------------------------

    if (producto.imagen == null ||
        producto.imagen!.trim().isEmpty) {
      return _imagenLocalFallback(producto);
    }

    final String nombreImagen =
    producto.imagen!.trim();

    // ----------------------------------------------------------
    // SI ES UNA URL
    // ----------------------------------------------------------

    if (nombreImagen.startsWith('http://') ||
        nombreImagen.startsWith('https://')) {
      return Image.network(
        nombreImagen,
        width: double.infinity,
        height: double.infinity,
        fit: BoxFit.cover,

        loadingBuilder:
            (context, child, loadingProgress) {
          if (loadingProgress == null) {
            return child;
          }

          return Container(
            color: crema,
            child: const Center(
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: cafePrincipal,
              ),
            ),
          );
        },

        errorBuilder:
            (context, error, stackTrace) {
          debugPrint(
            '❌ Error cargando URL: $nombreImagen',
          );

          return _imagenLocalFallback(producto);
        },
      );
    }

    // ----------------------------------------------------------
    // IMAGEN LOCAL
    // ----------------------------------------------------------

    final String ruta = nombreImagen.startsWith('assets/')
        ? nombreImagen
        : 'assets/$nombreImagen';

    debugPrint(
      '🖼️ Cargando imagen local: $ruta',
    );

    return Image.asset(
      ruta,
      width: double.infinity,
      height: double.infinity,
      fit: BoxFit.cover,

      errorBuilder:
          (context, error, stackTrace) {
        debugPrint(
          '❌ No se encontró la imagen: $ruta',
        );

        return _imagenLocalFallback(producto);
      },
    );
  }

  // ==========================================================
  // IMAGEN DE RESPALDO
  // ==========================================================

  Widget _imagenLocalFallback(Producto producto) {
    final String nombre =
    producto.nombre.toLowerCase().trim();

    String path = 'assets/cafe1.png';

    // ----------------------------------------------------------
    // PRODUCTOS ESPECIALES
    // ----------------------------------------------------------

    if (nombre.contains('especial')) {
      path = 'assets/cafe2.png';
    }

    // ----------------------------------------------------------
    // PRODUCTOS PREMIUM
    // ----------------------------------------------------------

    else if (nombre.contains('premium') ||
        nombre.contains('buitron')) {
      path = 'assets/cafe3.png';
    }

    // ----------------------------------------------------------
    // PRODUCTOS MOLIDOS
    // ----------------------------------------------------------

    else if (nombre.contains('molido')) {
      path = 'assets/cafe1.png';
    }

    // ----------------------------------------------------------
    // PRODUCTOS TOSTADOS
    // ----------------------------------------------------------

    else if (nombre.contains('tostado') ||
        nombre.contains('tradicional')) {
      path = 'assets/cafe1.png';
    }

    // ----------------------------------------------------------
    // FALLBACK POR ID
    // ----------------------------------------------------------

    else {
      final int id =
      producto.id > 0
          ? producto.id
          : producto.nombre.length;

      final int resto = id % 3;

      if (resto == 0) {
        path = 'assets/cafe1.png';
      } else if (resto == 1) {
        path = 'assets/cafe2.png';
      } else {
        path = 'assets/cafe3.png';
      }
    }

    return Image.asset(
      path,
      width: double.infinity,
      height: double.infinity,
      fit: BoxFit.cover,

      errorBuilder:
          (context, error, stackTrace) {
        return Container(
          color: crema,
          child: const Center(
            child: Icon(
              Icons.coffee,
              color: cafePrincipal,
              size: 40,
            ),
          ),
        );
      },
    );
  }

  // ==========================================================
  // AGREGAR AL CARRITO
  // ==========================================================

  Future<void> _agregarAlCarrito(Producto producto) async {
    final messenger = ScaffoldMessenger.of(context);
    final error = await context.read<CarritoProvider>().agregarProducto(producto);

    if (error != null) {
      messenger.hideCurrentSnackBar();
      messenger.showSnackBar(
        SnackBar(
          backgroundColor: Colors.redAccent,
          content: Text(
            error,
            style: const TextStyle(color: Colors.white),
          ),
          duration: const Duration(seconds: 2),
        ),
      );
      return;
    }

    messenger.hideCurrentSnackBar();

    messenger.showSnackBar(
      SnackBar(
        backgroundColor: cafePrincipal,

        content: Text(
          '${producto.nombre} agregado al carrito',
          style: const TextStyle(
            color: Colors.white,
          ),
        ),

        duration: const Duration(
          seconds: 2,
        ),

        action: SnackBarAction(
          label: 'VER',
          textColor: dorado,

          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) =>
                const CarritoScreen(),
              ),
            );
          },
        ),
      ),
    );
  }

  // ==========================================================
  // NAVEGACIÓN
  // ==========================================================

  void _irA(Widget pantalla) {
    Navigator.pop(context);

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => pantalla,
      ),
    );
  }

  // ==========================================================
  // DRAWER
  // ==========================================================

  Widget _crearDrawer() {
    return Drawer(
      width:
      MediaQuery.of(context).size.width * 0.78,

      backgroundColor: cremaClaro,

      child: Column(
        children: [
          // ==================================================
          // CABECERA
          // ==================================================

          Container(
            width: double.infinity,
            padding: const EdgeInsets.only(
              top: 55,
              bottom: 30,
              left: 25,
              right: 25,
            ),
            decoration: const BoxDecoration(
              color: cafePrincipal,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ✅ Logo mejorado
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: cremaClaro,
                    border: Border.all(color: dorado, width: 3),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: ClipOval(
                    child: Padding(
                      padding: const EdgeInsets.all(8),
                      child: Image.asset(
                        'assets/login.png',
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => const Icon(Icons.coffee, color: cafePrincipal, size: 40),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 15),
                const Text(
                  'BUITRÓN COFFEE',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 23,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 5),
                const Text(
                  'Café colombiano',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),

          // ==================================================
          // OPCIONES
          // ==================================================

          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,

              children: [
                // =================================================
                // CATÁLOGO
                // =================================================

                ListTile(
                  leading: const Icon(
                    Icons.storefront,
                    color: cafePrincipal,
                  ),

                  title: const Text(
                    'Catálogo',
                    style: TextStyle(
                      color: textoOscuro,
                    ),
                  ),

                  onTap: () {
                    Navigator.pop(context);
                  },
                ),

                // =================================================
                // CARRITO
                // =================================================

                ListTile(
                  leading: const Icon(
                    Icons.shopping_cart,
                    color: cafePrincipal,
                  ),

                  title: const Text(
                    'Carrito',
                    style: TextStyle(
                      color: textoOscuro,
                    ),
                  ),

                  onTap: () {
                    _irA(
                      const CarritoScreen(),
                    );
                  },
                ),

                // =================================================
                // PERFIL
                // =================================================

                ListTile(
                  leading: const Icon(
                    Icons.person,
                    color: cafePrincipal,
                  ),

                  title: const Text(
                    'Mi perfil',
                    style: TextStyle(
                      color: textoOscuro,
                    ),
                  ),

                  onTap: () {
                    _irA(
                      const PerfilScreen(),
                    );
                  },
                ),

                // =================================================
                // HISTORIAL
                // =================================================

                ListTile(
                  leading: const Icon(
                    Icons.history,
                    color: cafePrincipal,
                  ),

                  title: const Text(
                    'Historial de compras',
                    style: TextStyle(
                      color: textoOscuro,
                    ),
                  ),

                  onTap: () {
                    _irA(
                      const HistorialScreen(),
                    );
                  },
                ),

                // =================================================
                // UBICACIÓN
                // =================================================

                ListTile(
                  leading: const Icon(
                    Icons.location_on,
                    color: cafePrincipal,
                  ),

                  title: const Text(
                    'Ubicación',
                    style: TextStyle(
                      color: textoOscuro,
                    ),
                  ),

                  onTap: () {
                    _irA(
                      const MapaScreen(),
                    );
                  },
                ),

                // =================================================
                // PAGOS
                // =================================================

                // =================================================
                // RESEÑAS
                // =================================================

                ListTile(
                  leading: const Icon(
                    Icons.star,
                    color: dorado,
                  ),

                  title: const Text(
                    'Reseñas',
                    style: TextStyle(
                      color: textoOscuro,
                    ),
                  ),

                  onTap: () {
                    _irA(
                      const ResenasScreen(),
                    );
                  },
                ),

                // =================================================
                // PQRS
                // =================================================

                ListTile(
                  leading: const Icon(
                    Icons.help_outline,
                    color: cafePrincipal,
                  ),

                  title: const Text(
                    'PQRS',
                    style: TextStyle(
                      color: textoOscuro,
                    ),
                  ),

                  onTap: () {
                    _irA(
                      const PqrsScreen(),
                    );
                  },
                ),

                const Divider(
                  color: cafeClaro,
                ),

                // =================================================
                // CERRAR SESIÓN
                // =================================================

                ListTile(
                  leading: const Icon(
                    Icons.logout,
                    color: cafeClaro,
                  ),

                  title: const Text(
                    'Cerrar sesión',
                    style: TextStyle(
                      color: cafeClaro,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  onTap: () async {
                    // ✅ Al cerrar sesión solo limpiamos la memoria local del carrito
                    // No vaciamos la base de datos
                    context.read<CarritoProvider>().limpiarCarritoLocal();
                    
                    await AuthService.logout();

                    if (!mounted) return;

                    Navigator.pushAndRemoveUntil(
                      context,

                      MaterialPageRoute(
                        builder: (_) =>
                        const LoginPage(),
                      ),

                          (route) => false,
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================================
  // BUILD
  // ==========================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: crema,

      // ======================================================
      // DRAWER
      // ======================================================

      drawer: _crearDrawer(),

      // ======================================================
      // APP BAR
      // ======================================================

      appBar: AppBar(
        backgroundColor: cafePrincipal,

        foregroundColor: Colors.white,

        elevation: 0,

        centerTitle: true,

        title: const Text(
          'CATÁLOGO',

          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            letterSpacing: 1,
          ),
        ),

        actions: [
          Consumer<CarritoProvider>(
            builder: (
                context,
                carrito,
                child,
                ) {
              return Stack(
                clipBehavior: Clip.none,

                children: [
                  IconButton(
                    icon: const Icon(
                      Icons.shopping_cart_outlined,
                      size: 27,
                      color: Colors.white,
                    ),

                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                          const CarritoScreen(),
                        ),
                      );
                    },
                  ),

                  // =================================================
                  // CONTADOR
                  // =================================================

                  if (carrito.cantidadTotal > 0)
                    Positioned(
                      right: 2,
                      top: 3,

                      child: Container(
                        padding:
                        const EdgeInsets.all(5),

                        decoration:
                        const BoxDecoration(
                          color: dorado,
                          shape: BoxShape.circle,
                        ),

                        child: Text(
                          '${carrito.cantidadTotal}',

                          style:
                          const TextStyle(
                            color: textoOscuro,
                            fontSize: 10,
                            fontWeight:
                            FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
        ],
      ),

      // ======================================================
      // BODY
      // ======================================================

      body: Column(
        children: [
          // ====================================================
          // BUSCADOR
          // ====================================================

          Padding(
            padding: const EdgeInsets.fromLTRB(
              14,
              15,
              14,
              8,
            ),

            child: TextField(
              controller: _buscarController,

              onChanged: _onBuscar,

              decoration: InputDecoration(
                hintText: 'Buscar café...',

                hintStyle: const TextStyle(
                  color: textoSuave,
                ),

                prefixIcon: const Icon(
                  Icons.search,
                  color: cafePrincipal,
                ),

                suffixIcon:
                _buscarController.text.isNotEmpty
                    ? IconButton(
                  icon: const Icon(
                    Icons.clear,
                    color: cafePrincipal,
                  ),

                  onPressed: () {
                    _buscarController
                        .clear();

                    _filtrarProductos();

                    setState(() {});
                  },
                )
                    : null,

                filled: true,

                fillColor: cremaClaro,

                border: OutlineInputBorder(
                  borderRadius:
                  BorderRadius.circular(14),

                  borderSide: BorderSide.none,
                ),

                focusedBorder:
                OutlineInputBorder(
                  borderRadius:
                  BorderRadius.circular(14),

                  borderSide:
                  const BorderSide(
                    color: cafePrincipal,
                    width: 1.5,
                  ),
                ),
              ),
            ),
          ),

          // ====================================================
          // CATEGORÍAS
          // ====================================================

          SizedBox(
            height: 50,

            child: ListView(
              scrollDirection:
              Axis.horizontal,

              padding:
              const EdgeInsets.symmetric(
                horizontal: 14,
              ),

              children: [
                _categoria(
                  'Todos',
                  _categoriaSeleccionada ==
                      'Todos',
                ),

                _categoria(
                  'Molido',
                  _categoriaSeleccionada ==
                      'Molido',
                ),

                _categoria(
                  'Grano',
                  _categoriaSeleccionada ==
                      'Grano',
                ),

                _categoria(
                  'Tostado',
                  _categoriaSeleccionada ==
                      'Tostado',
                ),
              ],
            ),
          ),

          // ====================================================
          // CONTENIDO
          // ====================================================

          Expanded(
            child: _cargando
                ? const Center(
              child:
              CircularProgressIndicator(
                color: cafePrincipal,
              ),
            )

                : _error.isNotEmpty
                ? Center(
              child: Column(
                mainAxisAlignment:
                MainAxisAlignment
                    .center,

                children: [
                  const Icon(
                    Icons.error_outline,
                    size: 50,
                    color: cafeClaro,
                  ),

                  const SizedBox(
                    height: 10,
                  ),

                  Text(
                    _error,

                    textAlign:
                    TextAlign.center,

                    style:
                    const TextStyle(
                      color:
                      textoOscuro,
                    ),
                  ),

                  const SizedBox(
                    height: 15,
                  ),

                  ElevatedButton(
                    onPressed:
                    _cargarProductos,

                    style:
                    ElevatedButton
                        .styleFrom(
                      backgroundColor:
                      cafePrincipal,

                      foregroundColor:
                      Colors.white,
                    ),

                    child:
                    const Text(
                      'REINTENTAR',
                    ),
                  ),
                ],
              ),
            )

                : _productosFiltrados.isEmpty
                ? const Center(
              child: Text(
                'No se encontraron productos',

                style:
                TextStyle(
                  color:
                  textoSuave,
                  fontSize: 16,
                ),
              ),
            )

                : GridView.builder(
              padding:
              const EdgeInsets
                  .all(14),

              gridDelegate:
              const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,

                crossAxisSpacing:
                12,

                mainAxisSpacing:
                14,

                childAspectRatio:
                0.75,
              ),

              itemCount:
              _productosFiltrados
                  .length,

              itemBuilder:
                  (
                  context,
                  index,
                  ) {
                final producto =
                _productosFiltrados[
                index];

                return ProductoCard(
                  producto:
                  producto,

                  imagenWidget:
                  _mostrarImagen(
                    producto,
                  ),

                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => DetalleProductoScreen(producto: producto),
                      ),
                    );
                  },

                  onAgregar: () {
                    _agregarAlCarrito(
                      producto,
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================================
  // BOTÓN DE CATEGORÍA
  // ==========================================================

  Widget _categoria(
      String nombre,
      bool seleccionado,
      ) {
    return Padding(
      padding: const EdgeInsets.only(
        right: 8,
        top: 5,
        bottom: 5,
      ),

      child: ChoiceChip(
        label: Text(nombre),

        selected: seleccionado,

        selectedColor: cafePrincipal,

        backgroundColor: cremaClaro,

        side: BorderSide(
          color: seleccionado
              ? cafePrincipal
              : cafeClaro,
        ),

        labelStyle: TextStyle(
          color: seleccionado
              ? Colors.white
              : textoOscuro,

          fontWeight: FontWeight.w600,
        ),

        onSelected: (_) {
          setState(() {
            _categoriaSeleccionada =
                nombre;
          });

          _filtrarProductos();
        },
      ),
    );
  }
}

// ============================================================
// PRODUCT CARD
// ============================================================

class ProductoCard extends StatelessWidget {
  final Producto producto;
  final Widget imagenWidget;
  final VoidCallback onAgregar;
  final VoidCallback onTap;

  const ProductoCard({
    super.key,

    required this.producto,

    required this.imagenWidget,

    required this.onAgregar,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(15),
      child: Card(
        color: cremaClaro,

      elevation: 3,

      margin: EdgeInsets.zero,

      shadowColor:
      Colors.black.withValues(
        alpha: 0.10,
      ),

      shape:
      RoundedRectangleBorder(
        borderRadius:
        BorderRadius.circular(15),
      ),

      child: Padding(
        padding:
        const EdgeInsets.all(10),

        child: Column(
          crossAxisAlignment:
          CrossAxisAlignment.start,

          children: [
            // =================================================
            // IMAGEN
            // =================================================

            Expanded(
              flex: 5,

              child: Container(
                width: double.infinity,

                decoration:
                BoxDecoration(
                  color: crema,

                  borderRadius:
                  BorderRadius.circular(
                    12,
                  ),
                ),

                child: ClipRRect(
                  borderRadius:
                  BorderRadius.circular(
                    12,
                  ),

                  child: imagenWidget,
                ),
              ),
            ),

            const SizedBox(
              height: 8,
            ),

            // =================================================
            // NOMBRE
            // =================================================

            Text(
              producto.nombre.isEmpty
                  ? 'Sin nombre'
                  : producto.nombre,

              maxLines: 1,

              overflow:
              TextOverflow.ellipsis,

              style: const TextStyle(
                fontSize: 16,
                fontWeight:
                FontWeight.bold,
                color: textoOscuro,
              ),
            ),

            const SizedBox(
              height: 4,
            ),

            // =================================================
            // DESCRIPCIÓN
            // =================================================

            if (producto.descripcion !=
                null &&
                producto.descripcion!
                    .isNotEmpty)
              Text(
                producto.descripcion!,

                maxLines: 2,

                overflow:
                TextOverflow.ellipsis,

                style:
                const TextStyle(
                  fontSize: 12,
                  color: textoSuave,
                ),
              ),

            const Spacer(),

            // =================================================
            // PRECIO
            // =================================================

            Text(
              '\$${producto.precio.toStringAsFixed(0)}',

              style:
              const TextStyle(
                fontSize: 17,
                fontWeight:
                FontWeight.bold,
                color: cafePrincipal,
              ),
            ),

            const SizedBox(height: 4),

            // STOCK
            Text(
              producto.stock > 0 ? 'Stock: ${producto.stock}' : 'Agotado',
              style: TextStyle(
                fontSize: 11,
                color: producto.stock > 0 ? Colors.green : Colors.red,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(
              height: 4,
            ),

            // =================================================
            // BOTÓN AGREGAR
            // =================================================

            SizedBox(
              width: double.infinity,

              child: ElevatedButton(
                onPressed: onAgregar,

                style:
                ElevatedButton.styleFrom(
                  backgroundColor:
                  cafePrincipal,

                  foregroundColor:
                  Colors.white,

                  padding:
                  const EdgeInsets
                      .symmetric(
                    vertical: 10,
                  ),

                  shape:
                  RoundedRectangleBorder(
                    borderRadius:
                    BorderRadius.circular(
                      10,
                    ),
                  ),
                ),

                child: const Text(
                  'AGREGAR',

                  style: TextStyle(
                    fontWeight:
                    FontWeight.bold,

                    fontSize: 12,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      ),
    );
  }
}
