import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

// ============================================================
// CONFIGURACIÓN DE LA API
// ============================================================

class ApiConfig {
  static const String baseUrl = 'http://10.0.2.2:3000';
}

// ============================================================
// MODELO DE PRODUCTO
// ============================================================

class Producto {
  final int id;
  final String nombre;
  final String descripcion;
  final double precio;
  final String imagen;

  Producto({
    required this.id,
    required this.nombre,
    required this.descripcion,
    required this.precio,
    required this.imagen,
  });

  factory Producto.fromJson(Map<String, dynamic> json) {
    return Producto(
      id: json['id'] is int
          ? json['id']
          : int.tryParse('${json['id']}') ?? 0,

      nombre: json['nombre'] ?? '',

      descripcion: json['descripcion'] ?? '',

      precio: double.tryParse(
        '${json['precio']}',
      ) ??
          0.0,

      imagen: json['imagen'] ?? '',
    );
  }
}

// ============================================================
// SERVICIO DE PRODUCTOS
// ============================================================

class ProductoService {
  static Future<List<Producto>> obtenerTodos() async {
    final response = await http.get(
      Uri.parse(
        '${ApiConfig.baseUrl}/productos',
      ),
    );

    if (response.statusCode == 200) {
      final List<dynamic> data =
      jsonDecode(response.body);

      return data
          .map(
            (json) => Producto.fromJson(json),
      )
          .toList();
    } else {
      throw Exception(
        'Error al cargar productos (${response.statusCode})',
      );
    }
  }

  static Future<List<Producto>> buscar(
      String query,
      ) async {
    final uri = Uri.parse(
      '${ApiConfig.baseUrl}/productos/buscar',
    ).replace(
      queryParameters: {
        'q': query,
      },
    );

    final response = await http.get(uri);

    if (response.statusCode == 200) {
      final List<dynamic> data =
      jsonDecode(response.body);

      return data
          .map(
            (json) => Producto.fromJson(json),
      )
          .toList();
    } else {
      throw Exception(
        'Error al buscar productos (${response.statusCode})',
      );
    }
  }
}

// ============================================================
// PANTALLA DEL CATÁLOGO
// ============================================================

class CatalogoScreen extends StatefulWidget {
  const CatalogoScreen({
    super.key,
  });

  @override
  State<CatalogoScreen> createState() =>
      _CatalogoScreenState();
}

class _CatalogoScreenState
    extends State<CatalogoScreen> {

  final TextEditingController _buscadorController =
  TextEditingController();

  List<Producto> _productos = [];

  bool _cargando = true;

  String? _error;

  Timer? _debounce;

  int _navIndex = 1;

  static const Color rojo =
  Color(0xFF8B1E1E);

  // ==========================================================
  // INICIO
  // ==========================================================

  @override
  void initState() {
    super.initState();

    _cargarProductos();
  }

  // ==========================================================
  // CARGAR PRODUCTOS
  // ==========================================================

  Future<void> _cargarProductos() async {
    setState(() {
      _cargando = true;
      _error = null;
    });

    try {
      final productos =
      await ProductoService.obtenerTodos();

      setState(() {
        _productos = productos;
        _cargando = false;
      });
    } catch (e) {
      setState(() {
        _error =
        'No se pudo conectar con el servidor.';

        _cargando = false;
      });
    }
  }

  // ==========================================================
  // BUSCADOR
  // ==========================================================

  void _onBuscar(String texto) {
    if (_debounce?.isActive ?? false) {
      _debounce!.cancel();
    }

    _debounce = Timer(
      const Duration(
        milliseconds: 400,
      ),
          () async {
        await _buscarTexto(texto);
      },
    );
  }

  Future<void> _buscarTexto(
      String texto,
      ) async {

    if (texto.trim().isEmpty) {
      await _cargarProductos();
      return;
    }

    setState(() {
      _cargando = true;
      _error = null;
    });

    try {
      final resultados =
      await ProductoService.buscar(texto);

      setState(() {
        _productos = resultados;
        _cargando = false;
      });
    } catch (e) {
      setState(() {
        _error =
        'No se pudo conectar con el servidor.';

        _cargando = false;
      });
    }
  }

  // ==========================================================
  // SELECCIONAR CATEGORÍA
  // ==========================================================

  void _seleccionarCategoria(
      String categoria,
      ) {
    _buscadorController.text =
        categoria;

    _buscadorController.selection =
        TextSelection.fromPosition(
          TextPosition(
            offset:
            _buscadorController.text.length,
          ),
        );

    _buscarTexto(categoria);
  }

  // ==========================================================
  // LIBERAR CONTROLADORES
  // ==========================================================

  @override
  void dispose() {
    _buscadorController.dispose();

    _debounce?.cancel();

    super.dispose();
  }

  // ==========================================================
  // INTERFAZ
  // ==========================================================

  @override
  Widget build(
      BuildContext context,
      ) {
    return Scaffold(

      // ======================================================
      // MENÚ LATERAL
      // ======================================================

      drawer: _construirMenuLateral(),

      // ======================================================
      // BARRA SUPERIOR
      // ======================================================

      appBar: AppBar(
        backgroundColor: rojo,

        centerTitle: true,

        elevation: 0,

        title: const Text(
          'CATALOGO',

          style: TextStyle(
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
          ),
        ),
      ),

      // ======================================================
      // CONTENIDO
      // ======================================================

      body: Column(
        children: [

          const SizedBox(
            height: 16,
          ),

          _construirBotonesCategoria(),

          const SizedBox(
            height: 20,
          ),

          _construirBuscador(),

          Expanded(
            child:
            _construirContenido(),
          ),
        ],
      ),

      // ======================================================
      // BARRA INFERIOR
      // ======================================================

      bottomNavigationBar:
      _construirBottomNav(),
    );
  }

  // ==========================================================
  // MENÚ LATERAL
  // ==========================================================

  Widget _construirMenuLateral() {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,

        children: [

          // ==================================================
          // ENCABEZADO
          // ==================================================

          DrawerHeader(
            decoration: const BoxDecoration(
              color: rojo,
            ),

            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,

              children: const [

                Icon(
                  Icons.local_cafe,
                  color: Colors.white,
                  size: 48,
                ),

                SizedBox(
                  height: 10,
                ),

                Text(
                  'BUITRON COFFEE',

                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight:
                    FontWeight.bold,
                  ),
                ),

                SizedBox(
                  height: 5,
                ),

                Text(
                  'Menú principal',

                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),

          // ==================================================
          // CATÁLOGO
          // ==================================================

          ListTile(
            leading: const Icon(
              Icons.home_outlined,
              color: rojo,
            ),

            title: const Text(
              'Catálogo',
            ),

            onTap: () {
              Navigator.pop(
                context,
              );
            },
          ),

          // ==================================================
          // PERFIL
          // ==================================================

          ListTile(
            leading: const Icon(
              Icons.person_outline,
              color: rojo,
            ),

            title: const Text(
              'Mi perfil',
            ),

            onTap: () {
              Navigator.pop(
                context,
              );

              _mostrarMensaje(
                'Vista de perfil',
              );
            },
          ),

          // ==================================================
          // CARRITO
          // ==================================================

          ListTile(
            leading: const Icon(
              Icons.shopping_cart_outlined,
              color: rojo,
            ),

            title: const Text(
              'Carrito',
            ),

            onTap: () {
              Navigator.pop(
                context,
              );

              _mostrarMensaje(
                'Vista del carrito',
              );
            },
          ),

          // ==================================================
          // HISTORIAL
          // ==================================================

          ListTile(
            leading: const Icon(
              Icons.history,
              color: rojo,
            ),

            title: const Text(
              'Historial de compras',
            ),

            onTap: () {
              Navigator.pop(
                context,
              );

              _mostrarMensaje(
                'Historial de compras',
              );
            },
          ),

          // ==================================================
          // MAPA
          // ==================================================

          ListTile(
            leading: const Icon(
              Icons.location_on_outlined,
              color: rojo,
            ),

            title: const Text(
              'Ubicación',
            ),

            onTap: () {
              Navigator.pop(
                context,
              );

              _mostrarMensaje(
                'Vista de ubicación',
              );
            },
          ),

          // ==================================================
          // PAGOS
          // ==================================================

          ListTile(
            leading: const Icon(
              Icons.payment_outlined,
              color: rojo,
            ),

            title: const Text(
              'Métodos de pago',
            ),

            onTap: () {
              Navigator.pop(
                context,
              );

              _mostrarMensaje(
                'Vista de métodos de pago',
              );
            },
          ),

          const Divider(),

          // ==================================================
          // CERRAR SESIÓN
          // ==================================================

          ListTile(
            leading: const Icon(
              Icons.logout,
              color: Colors.red,
            ),

            title: const Text(
              'Cerrar sesión',

              style: TextStyle(
                color: Colors.red,
                fontWeight:
                FontWeight.bold,
              ),
            ),

            onTap: () {
              Navigator.pop(
                context,
              );

              Navigator.pushNamedAndRemoveUntil(
                context,
                '/',
                    (route) => false,
              );
            },
          ),
        ],
      ),
    );
  }

  // ==========================================================
  // MENSAJE TEMPORAL
  // ==========================================================

  void _mostrarMensaje(
      String mensaje,
      ) {
    ScaffoldMessenger.of(context)
        .showSnackBar(
      SnackBar(
        content: Text(
          mensaje,
        ),
      ),
    );
  }

  // ==========================================================
  // BOTONES DE CATEGORÍA
  // ==========================================================

  Widget _construirBotonesCategoria() {
    return Row(
      mainAxisAlignment:
      MainAxisAlignment.center,

      children: [

        _CategoriaBoton(
          texto: 'Molido',

          imagenAsset: null,

          icono: Icons.coffee,

          onTap: () =>
              _seleccionarCategoria(
                'Molido',
              ),
        ),

        const SizedBox(
          width: 24,
        ),

        _CategoriaBoton(
          texto: 'Grano',

          imagenAsset: null,

          icono: Icons.grain,

          onTap: () =>
              _seleccionarCategoria(
                'Grano',
              ),
        ),
      ],
    );
  }

  // ==========================================================
  // BUSCADOR
  // ==========================================================

  Widget _construirBuscador() {
    return Padding(
      padding:
      const EdgeInsets.symmetric(
        horizontal: 16,
      ),

      child: TextField(
        controller:
        _buscadorController,

        onChanged: _onBuscar,

        decoration:
        InputDecoration(
          hintText: 'Buscar producto',

          filled: true,

          fillColor:
          const Color(0xFFF6EAE8),

          suffixIcon:
          const Icon(
            Icons.search,
            color: Colors.black54,
          ),

          contentPadding:
          const EdgeInsets.symmetric(
            vertical: 0,
          ),

          border:
          OutlineInputBorder(
            borderRadius:
            BorderRadius.circular(
              24,
            ),

            borderSide:
            BorderSide.none,
          ),
        ),
      ),
    );
  }

  // ==========================================================
  // CONTENIDO
  // ==========================================================

  Widget _construirContenido() {

    if (_cargando) {
      return const Center(
        child:
        CircularProgressIndicator(),
      );
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisSize:
          MainAxisSize.min,

          children: [

            Text(
              _error!,

              style:
              const TextStyle(
                color: Colors.red,
              ),
            ),

            const SizedBox(
              height: 8,
            ),

            ElevatedButton(
              onPressed:
              _cargarProductos,

              child:
              const Text(
                'Reintentar',
              ),
            ),
          ],
        ),
      );
    }

    if (_productos.isEmpty) {
      return const Center(
        child: Text(
          'No se encontraron productos',

          style: TextStyle(
            color: Colors.grey,
          ),
        ),
      );
    }

    return ListView.builder(
      padding:
      const EdgeInsets.fromLTRB(
        16,
        12,
        16,
        12,
      ),

      itemCount:
      _productos.length,

      itemBuilder:
          (context, index) {

        return ProductoCard(
          producto:
          _productos[index],
        );
      },
    );
  }

  // ==========================================================
  // BARRA INFERIOR
  // ==========================================================

  Widget _construirBottomNav() {
    return BottomNavigationBar(

      currentIndex:
      _navIndex,

      onTap: (i) {
        setState(() {
          _navIndex = i;
        });
      },

      type:
      BottomNavigationBarType.fixed,

      selectedItemColor:
      rojo,

      unselectedItemColor:
      Colors.black54,

      showSelectedLabels:
      false,

      showUnselectedLabels:
      false,

      items: const [

        BottomNavigationBarItem(
          icon:
          Icon(
            Icons.person_outline,
          ),
          label: 'Perfil',
        ),

        BottomNavigationBarItem(
          icon:
          Icon(
            Icons.home_outlined,
          ),
          label: 'Inicio',
        ),

        BottomNavigationBarItem(
          icon:
          Icon(
            Icons.shopping_cart_outlined,
          ),
          label: 'Carrito',
        ),
      ],
    );
  }
}

// ============================================================
// BOTÓN DE CATEGORÍA
// ============================================================

class _CategoriaBoton
    extends StatelessWidget {

  final String texto;

  final String? imagenAsset;

  final IconData icono;

  final VoidCallback onTap;

  const _CategoriaBoton({
    required this.texto,
    required this.imagenAsset,
    required this.icono,
    required this.onTap,
  });

  @override
  Widget build(
      BuildContext context,
      ) {
    return GestureDetector(

      onTap: onTap,

      child: Column(
        mainAxisSize:
        MainAxisSize.min,

        children: [

          CircleAvatar(
            radius: 32,

            backgroundColor:
            const Color(
              0xFFF6EAE8,
            ),

            backgroundImage:
            imagenAsset != null
                ? AssetImage(
              imagenAsset!,
            )
                : null,

            child:
            imagenAsset == null
                ? Icon(
              icono,

              color:
              const Color(
                0xFF8B1E1E,
              ),

              size: 28,
            )
                : null,
          ),

          const SizedBox(
            height: 8,
          ),

          Text(
            texto,

            style:
            const TextStyle(
              fontSize: 14,
              fontWeight:
              FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// TARJETA DE PRODUCTO
// ============================================================

class ProductoCard
    extends StatelessWidget {

  final Producto producto;

  const ProductoCard({
    super.key,
    required this.producto,
  });

  // ==========================================================
  // FORMATO DEL PRECIO
  // ==========================================================

  String _formatearPrecio(
      double precio,
      ) {
    final texto =
    precio.toStringAsFixed(0);

    final buffer =
    StringBuffer();

    for (
    int i = 0;
    i < texto.length;
    i++
    ) {
      final posicionDesdeFinal =
          texto.length - i;

      buffer.write(
        texto[i],
      );

      if (
      posicionDesdeFinal > 1 &&
          posicionDesdeFinal % 3 == 1) {
        buffer.write('.');
      }
    }

    return '\$$buffer';
  }

  // ==========================================================
  // TARJETA
  // ==========================================================

  @override
  Widget build(
      BuildContext context,
      ) {
    return Padding(

      padding:
      const EdgeInsets.only(
        bottom: 16,
      ),

      child: Row(
        crossAxisAlignment:
        CrossAxisAlignment.start,

        children: [

          // ==================================================
          // IMAGEN
          // ==================================================

          ClipRRect(
            borderRadius:
            BorderRadius.circular(
              8,
            ),

            child:
            producto.imagen.isNotEmpty
                ? Image.network(
              producto.imagen,

              width: 60,
              height: 78,

              fit:
              BoxFit.cover,

              loadingBuilder:
                  (
                  context,
                  child,
                  progress,
                  ) {
                if (progress ==
                    null) {
                  return child;
                }

                return const SizedBox(
                  width: 60,
                  height: 78,

                  child: Center(
                    child:
                    CircularProgressIndicator(
                      strokeWidth:
                      2,
                    ),
                  ),
                );
              },

              errorBuilder:
                  (
                  context,
                  error,
                  stackTrace,
                  ) {
                return Container(
                  width: 60,
                  height: 78,

                  color:
                  Colors.grey[300],

                  child:
                  const Icon(
                    Icons.coffee,

                    color:
                    Colors.brown,

                    size: 28,
                  ),
                );
              },
            )
                : Container(
              width: 60,
              height: 78,

              color:
              Colors.grey[300],

              child:
              const Icon(
                Icons.coffee,

                color:
                Colors.brown,

                size: 28,
              ),
            ),
          ),

          const SizedBox(
            width: 14,
          ),

          // ==================================================
          // INFORMACIÓN
          // ==================================================

          Expanded(
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,

              children: [

                Text(
                  producto.nombre,

                  style:
                  const TextStyle(
                    fontWeight:
                    FontWeight.bold,

                    fontSize: 15,
                  ),
                ),

                const SizedBox(
                  height: 4,
                ),

                Text(
                  producto.descripcion,

                  style: TextStyle(
                    color:
                    Colors.grey[700],

                    fontSize: 13,
                  ),
                ),

                const SizedBox(
                  height: 6,
                ),

                Text(
                  _formatearPrecio(
                    producto.precio,
                  ),

                  style:
                  const TextStyle(
                    fontWeight:
                    FontWeight.bold,

                    fontSize: 14,

                    color:
                    Color(0xFF8B1E1E),
                  ),
                ),

                const SizedBox(
                  height: 10,
                ),

                // ==================================================
                // AGREGAR AL CARRITO
                // ==================================================

                SizedBox(
                  width:
                  double.infinity,

                  child:
                  ElevatedButton.icon(

                    onPressed: () {

                      ScaffoldMessenger
                          .of(context)
                          .showSnackBar(
                        SnackBar(
                          content:
                          Text(
                            '${producto.nombre} agregado al carrito',
                          ),

                          duration:
                          const Duration(
                            seconds: 2,
                          ),
                        ),
                      );
                    },

                    icon:
                    const Icon(
                      Icons.shopping_cart,
                    ),

                    label:
                    const Text(
                      'Agregar al carrito',
                    ),

                    style:
                    ElevatedButton.styleFrom(
                      backgroundColor:
                      const Color(
                        0xFF8B1E1E,
                      ),

                      foregroundColor:
                      Colors.white,

                      padding:
                      const EdgeInsets
                          .symmetric(
                        vertical: 12,
                      ),

                      shape:
                      RoundedRectangleBorder(
                        borderRadius:
                        BorderRadius
                            .circular(
                          10,
                        ),
                      ),
                    ),
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