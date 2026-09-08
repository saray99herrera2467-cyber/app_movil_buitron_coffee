import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/carrito_provider.dart';
import 'catalogo_screen.dart';

// ============================================================
// COLORES DE BUITRÓN COFFEE
// ============================================================

const Color cafePrincipal = Color(0xFF4E342E);
const Color cafeClaro = Color(0xFF795548);
const Color crema = Color(0xFFF5EFE6);
const Color cremaClaro = Color(0xFFFFFCF7);
const Color dorado = Color(0xFFC8A45D);
const Color textoOscuro = Color(0xFF3A2925);
const Color textoSuave = Color(0xFF756860);

// ============================================================
// CARRITO
// ============================================================

class CarritoScreen extends StatelessWidget {
  const CarritoScreen({super.key});

  // ----------------------------------------------------------
  // VOLVER AL CATÁLOGO
  // ----------------------------------------------------------

  void _volverCatalogo(BuildContext context) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => const CatalogoScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final carrito = Provider.of<CarritoProvider>(context);

    return Scaffold(
      backgroundColor: crema,

      // ======================================================
      // APP BAR
      // ======================================================

      appBar: AppBar(
        backgroundColor: cafePrincipal,
        elevation: 0,

        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            color: Colors.white,
          ),
          tooltip: 'Volver al catálogo',
          onPressed: () => _volverCatalogo(context),
        ),

        title: const Text(
          'BUITRÓN COFFEE',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            letterSpacing: 1,
          ),
        ),

        centerTitle: true,
      ),

      // ======================================================
      // CUERPO
      // ======================================================

      body: carrito.items.isEmpty
          ? _CarritoVacio(
        onVolver: () => _volverCatalogo(context),
      )
          : Column(
        children: [
          // ----------------------------------------------
          // TÍTULO
          // ----------------------------------------------

          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(
              20,
              20,
              20,
              12,
            ),
            child: const Text(
              'MI CARRITO',
              style: TextStyle(
                color: textoOscuro,
                fontSize: 24,
                fontWeight: FontWeight.bold,
                letterSpacing: 1,
              ),
            ),
          ),

          // ----------------------------------------------
          // PRODUCTOS
          // ----------------------------------------------

          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.fromLTRB(
                16,
                8,
                16,
                16,
              ),
              itemCount: carrito.items.length,
              itemBuilder: (context, index) {
                final producto = carrito.items[index];

                final cantidad =
                    carrito.cantidades[producto.id] ?? 1;

                return _ProductoCarrito(
                  nombre: producto.nombre,
                  precio: producto.precio,
                  cantidad: cantidad,
                  onRestar: () {
                    carrito.cambiarCantidad(
                      producto.id,
                      cantidad - 1,
                    );
                  },
                  onSumar: () {
                    carrito.cambiarCantidad(
                      producto.id,
                      cantidad + 1,
                    );
                  },
                );
              },
            ),
          ),

          // ----------------------------------------------
          // RESUMEN
          // ----------------------------------------------

          _ResumenCompra(
            carrito: carrito,
            onCancelar: () {
              carrito.limpiarCarrito();

              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(
                    'Carrito vaciado correctamente',
                  ),
                ),
              );
            },
            onFinalizar: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(
                    'Procediendo al pago...',
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

// ============================================================
// CARRITO VACÍO
// ============================================================

class _CarritoVacio extends StatelessWidget {
  final VoidCallback onVolver;

  const _CarritoVacio({
    required this.onVolver,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(30),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // ICONO
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: cremaClaro,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    blurRadius: 12,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: const Icon(
                Icons.shopping_cart_outlined,
                size: 50,
                color: cafePrincipal,
              ),
            ),

            const SizedBox(height: 25),

            // TÍTULO
            const Text(
              'CARRITO VACÍO',
              style: TextStyle(
                color: textoOscuro,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 10),

            // INFORMACIÓN
            const Text(
              'Agrega algunos de nuestros cafés favoritos '
                  'desde el catálogo.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: textoSuave,
                fontSize: 15,
                height: 1.5,
              ),
            ),

            const SizedBox(height: 25),

            // BOTÓN
            ElevatedButton.icon(
              onPressed: onVolver,
              icon: const Icon(
                Icons.coffee,
                color: Colors.white,
              ),
              label: const Text(
                'Ver catálogo',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: cafePrincipal,
                padding: const EdgeInsets.symmetric(
                  horizontal: 25,
                  vertical: 14,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// PRODUCTO DEL CARRITO
// ============================================================

class _ProductoCarrito extends StatelessWidget {
  final String nombre;
  final double precio;
  final int cantidad;
  final VoidCallback onRestar;
  final VoidCallback onSumar;

  const _ProductoCarrito({
    required this.nombre,
    required this.precio,
    required this.cantidad,
    required this.onRestar,
    required this.onSumar,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      color: cremaClaro,
      elevation: 2,
      shadowColor: Colors.black.withValues(alpha: 0.08),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            // ==================================================
            // ICONO DEL PRODUCTO
            // ==================================================

            Container(
              width: 70,
              height: 70,
              decoration: BoxDecoration(
                color: crema,
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(
                Icons.coffee,
                size: 38,
                color: cafeClaro,
              ),
            ),

            const SizedBox(width: 14),

            // ==================================================
            // INFORMACIÓN
            // ==================================================

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    nombre,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: textoOscuro,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 6),

                  Text(
                    '\$${precio.toStringAsFixed(0)}',
                    style: const TextStyle(
                      color: cafePrincipal,
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

            // ==================================================
            // CANTIDAD
            // ==================================================

            Container(
              decoration: BoxDecoration(
                color: crema,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    tooltip: 'Restar',
                    visualDensity: VisualDensity.compact,
                    icon: const Icon(
                      Icons.remove,
                      color: cafePrincipal,
                      size: 20,
                    ),
                    onPressed: onRestar,
                  ),

                  Text(
                    '$cantidad',
                    style: const TextStyle(
                      color: textoOscuro,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  IconButton(
                    tooltip: 'Sumar',
                    visualDensity: VisualDensity.compact,
                    icon: const Icon(
                      Icons.add,
                      color: cafePrincipal,
                      size: 20,
                    ),
                    onPressed: onSumar,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// RESUMEN DE COMPRA
// ============================================================

class _ResumenCompra extends StatelessWidget {
  final CarritoProvider carrito;
  final VoidCallback onCancelar;
  final VoidCallback onFinalizar;

  const _ResumenCompra({
    required this.carrito,
    required this.onCancelar,
    required this.onFinalizar,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        color: cremaClaro,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      padding: const EdgeInsets.fromLTRB(
        20,
        18,
        20,
        20,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ==================================================
          // TÍTULO
          // ==================================================

          const Text(
            'RESUMEN DE COMPRA',
            style: TextStyle(
              color: textoOscuro,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 14),

          // ==================================================
          // SUBTOTAL
          // ==================================================

          _FilaPrecio(
            titulo: 'Subtotal',
            precio: carrito.subtotal,
          ),

          const SizedBox(height: 8),

          // ==================================================
          // ENVÍO
          // ==================================================

          _FilaPrecio(
            titulo: 'Envío',
            precio: carrito.costoEnvio,
          ),

          const Divider(
            height: 22,
            color: cafeClaro,
          ),

          // ==================================================
          // TOTAL
          // ==================================================

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'TOTAL',
                style: TextStyle(
                  color: textoOscuro,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                '\$${carrito.total.toStringAsFixed(0)}',
                style: const TextStyle(
                  color: cafePrincipal,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          // ==================================================
          // MÉTODO DE PAGO
          // ==================================================

          Row(
            children: const [
              Icon(
                Icons.credit_card,
                size: 18,
                color: cafeClaro,
              ),
              SizedBox(width: 8),
              Text(
                'Pago en línea',
                style: TextStyle(
                  color: textoSuave,
                  fontSize: 14,
                ),
              ),
            ],
          ),

          const SizedBox(height: 18),

          // ==================================================
          // BOTONES
          // ==================================================

          Row(
            children: [
              // CANCELAR
              Expanded(
                child: OutlinedButton(
                  onPressed: onCancelar,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: cafePrincipal,
                    side: const BorderSide(
                      color: cafePrincipal,
                    ),
                    padding: const EdgeInsets.symmetric(
                      vertical: 14,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'CANCELAR',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),

              const SizedBox(width: 12),

              // FINALIZAR
              Expanded(
                child: ElevatedButton(
                  onPressed: onFinalizar,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: cafePrincipal,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      vertical: 14,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'FINALIZAR',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ============================================================
// FILA DE PRECIO
// ============================================================

class _FilaPrecio extends StatelessWidget {
  final String titulo;
  final double precio;

  const _FilaPrecio({
    required this.titulo,
    required this.precio,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          titulo,
          style: const TextStyle(
            color: textoSuave,
            fontSize: 15,
          ),
        ),
        Text(
          '\$${precio.toStringAsFixed(0)}',
          style: const TextStyle(
            color: textoOscuro,
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}