import 'package:flutter/material.dart';

import '../services/historial_service.dart';
import 'catalogo_screen.dart';

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
// HISTORIAL SCREEN
// ============================================================

class HistorialScreen extends StatefulWidget {
  const HistorialScreen({super.key});

  @override
  State<HistorialScreen> createState() => _HistorialScreenState();
}

// ============================================================
// ESTADO
// ============================================================

class _HistorialScreenState extends State<HistorialScreen> {
  List<dynamic> _pedidos = [];
  bool _cargando = true;

  // ==========================================================
  // INIT
  // ==========================================================

  @override
  void initState() {
    super.initState();
    _cargarPedidos();
  }

  // ==========================================================
  // CARGAR PEDIDOS
  // ==========================================================

  Future<void> _cargarPedidos() async {
    if (mounted) {
      setState(() {
        _cargando = true;
      });
    }

    try {
      final lista =
      await HistorialService.obtenerPedidosUsuario();

      if (!mounted) return;

      setState(() {
        _pedidos = lista;
        _cargando = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _pedidos = [];
        _cargando = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: cafePrincipal,
          content: Text(
            'No se pudieron cargar los pedidos',
            style: TextStyle(
              color: Colors.white,
            ),
          ),
        ),
      );
    }
  }

  // ==========================================================
  // VOLVER AL CATÁLOGO
  // ==========================================================

  void _volverCatalogo() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => const CatalogoScreen(),
      ),
    );
  }

  // ==========================================================
  // FORMATEAR FECHA
  // ==========================================================

  String _formatearFecha(String fecha) {
    try {
      final DateTime fechaHora =
      DateTime.parse(fecha);

      return '${fechaHora.day}/${fechaHora.month}/${fechaHora.year}  •  '
          '${fechaHora.hour.toString().padLeft(2, '0')}:'
          '${fechaHora.minute.toString().padLeft(2, '0')}';
    } catch (_) {
      return fecha;
    }
  }

  // ==========================================================
  // TRADUCIR ESTADO
  // ==========================================================

  String _estadoPedido(String? estado) {
    switch (estado?.toUpperCase()) {
      case 'PENDIENTE':
        return '⏳ Pendiente';

      case 'PAGADO':
        return '✓ Pagado';

      case 'ENVIADO':
        return '🚚 Enviado';

      case 'ENTREGADO':
        return '☕ Entregado';

      case 'CANCELADO':
        return '❌ Cancelado';

      default:
        return estado ?? 'Desconocido';
    }
  }

  // ==========================================================
  // COLOR DEL ESTADO
  // ==========================================================

  Color _colorEstado(String? estado) {
    switch (estado?.toUpperCase()) {
      case 'ENTREGADO':
        return const Color(0xFF5D4037);

      case 'ENVIADO':
        return cafeClaro;

      case 'PAGADO':
        return dorado;

      case 'PENDIENTE':
        return const Color(0xFF8D6E63);

      case 'CANCELADO':
        return Colors.red;

      default:
        return textoSuave;
    }
  }

  // ==========================================================
  // BUILD
  // ==========================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: crema,

      // ======================================================
      // APP BAR
      // ======================================================

      appBar: AppBar(
        backgroundColor: cafePrincipal,
        foregroundColor: Colors.white,
        elevation: 0,

        // -----------------------------------------------
        // FLECHA PARA VOLVER AL CATÁLOGO
        // -----------------------------------------------

        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            color: Colors.white,
          ),
          tooltip: 'Volver al catálogo',
          onPressed: _volverCatalogo,
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

        // -----------------------------------------------
        // ACTUALIZAR
        // -----------------------------------------------

        actions: [
          IconButton(
            icon: const Icon(
              Icons.refresh,
              color: Colors.white,
            ),
            tooltip: 'Actualizar',
            onPressed: _cargarPedidos,
          ),
        ],
      ),

      // ======================================================
      // CONTENIDO
      // ======================================================

      body: _cargando
          ? const Center(
        child: CircularProgressIndicator(
          color: cafePrincipal,
        ),
      )
          : _pedidos.isEmpty
          ? _historialVacio()
          : RefreshIndicator(
        color: cafePrincipal,
        backgroundColor: cremaClaro,
        onRefresh: _cargarPedidos,
        child: ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: _pedidos.length,
          itemBuilder: (context, index) {
            final pedido = _pedidos[index];

            return _PedidoCard(
              pedido: pedido,
              formatearFecha:
              _formatearFecha,
              estadoPedido:
              _estadoPedido,
              colorEstado:
              _colorEstado,
            );
          },
        ),
      ),
    );
  }

  // ==========================================================
  // HISTORIAL VACÍO
  // ==========================================================

  Widget _historialVacio() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(30),
        child: Column(
          mainAxisAlignment:
          MainAxisAlignment.center,
          children: [
            // -----------------------------------------------
            // ICONO
            // -----------------------------------------------

            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: cremaClaro,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(
                      alpha: 0.08,
                    ),
                    blurRadius: 12,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: const Icon(
                Icons.receipt_long_outlined,
                size: 50,
                color: cafePrincipal,
              ),
            ),

            const SizedBox(height: 25),

            // -----------------------------------------------
            // TÍTULO
            // -----------------------------------------------

            const Text(
              'NO TIENES PEDIDOS AÚN',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: textoOscuro,
                fontSize: 21,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 10),

            // -----------------------------------------------
            // DESCRIPCIÓN
            // -----------------------------------------------

            const Text(
              'Tus compras aparecerán aquí '
                  'cuando realices tu primer pedido.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: textoSuave,
                fontSize: 14,
                height: 1.5,
              ),
            ),

            const SizedBox(height: 25),

            // -----------------------------------------------
            // BOTÓN CATÁLOGO
            // -----------------------------------------------

            ElevatedButton.icon(
              onPressed: _volverCatalogo,

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
                foregroundColor: Colors.white,

                padding:
                const EdgeInsets.symmetric(
                  horizontal: 25,
                  vertical: 14,
                ),

                shape:
                RoundedRectangleBorder(
                  borderRadius:
                  BorderRadius.circular(12),
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
// TARJETA DEL PEDIDO
// ============================================================

class _PedidoCard extends StatelessWidget {
  final dynamic pedido;
  final String Function(String) formatearFecha;
  final String Function(String?) estadoPedido;
  final Color Function(String?) colorEstado;

  const _PedidoCard({
    required this.pedido,
    required this.formatearFecha,
    required this.estadoPedido,
    required this.colorEstado,
  });

  @override
  Widget build(BuildContext context) {
    final String estado =
        pedido['estado']?.toString() ??
            'Desconocido';

    return Card(
      color: cremaClaro,
      elevation: 3,

      margin: const EdgeInsets.only(
        bottom: 16,
      ),

      shadowColor: Colors.black.withValues(
        alpha: 0.10,
      ),

      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),

      child: Padding(
        padding: const EdgeInsets.all(16),

        child: Column(
          crossAxisAlignment:
          CrossAxisAlignment.start,

          children: [
            // ==================================================
            // PEDIDO Y ESTADO
            // ==================================================

            Row(
              mainAxisAlignment:
              MainAxisAlignment.spaceBetween,

              crossAxisAlignment:
              CrossAxisAlignment.start,

              children: [
                // --------------------------------------------
                // NÚMERO DE PEDIDO
                // --------------------------------------------

                Expanded(
                  child: Row(
                    children: [
                      Container(
                        width: 42,
                        height: 42,

                        decoration:
                        BoxDecoration(
                          color: crema,
                          borderRadius:
                          BorderRadius.circular(
                            12,
                          ),
                        ),

                        child: const Icon(
                          Icons.receipt_long,
                          color: cafePrincipal,
                          size: 23,
                        ),
                      ),

                      const SizedBox(width: 10),

                      Expanded(
                        child: Text(
                          'Pedido #${pedido['id']}',
                          overflow:
                          TextOverflow.ellipsis,

                          style:
                          const TextStyle(
                            fontSize: 16,
                            fontWeight:
                            FontWeight.bold,
                            color:
                            textoOscuro,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 8),

                // --------------------------------------------
                // ESTADO
                // --------------------------------------------

                Container(
                  padding:
                  const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),

                  decoration:
                  BoxDecoration(
                    color: colorEstado(
                      estado,
                    ).withValues(
                      alpha: 0.12,
                    ),

                    borderRadius:
                    BorderRadius.circular(
                      20,
                    ),
                  ),

                  child: Text(
                    estadoPedido(estado),

                    style: TextStyle(
                      fontSize: 11,
                      fontWeight:
                      FontWeight.w600,
                      color:
                      colorEstado(estado),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 14),

            // ==================================================
            // FECHA
            // ==================================================

            Container(
              width: double.infinity,

              padding:
              const EdgeInsets.all(11),

              decoration:
              BoxDecoration(
                color: crema,
                borderRadius:
                BorderRadius.circular(10),
              ),

              child: Row(
                children: [
                  const Icon(
                    Icons.calendar_today_outlined,
                    size: 17,
                    color: cafeClaro,
                  ),

                  const SizedBox(width: 8),

                  Expanded(
                    child: Text(
                      formatearFecha(
                        pedido['fecha']
                            ?.toString() ??
                            '',
                      ),

                      style:
                      const TextStyle(
                        fontSize: 13,
                        color:
                        textoSuave,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 14),

            // ==================================================
            // PRECIOS
            // ==================================================

            Row(
              mainAxisAlignment:
              MainAxisAlignment.spaceBetween,
              children: [
                // --------------------------------------------
                // SUBTOTAL
                // --------------------------------------------

                Column(
                  crossAxisAlignment:
                  CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Subtotal',
                      style: TextStyle(
                        fontSize: 12,
                        color: textoSuave,
                      ),
                    ),

                    const SizedBox(height: 3),

                    Text(
                      '\$${pedido['subtotal'] ?? '0.00'}',

                      style:
                      const TextStyle(
                        fontSize: 15,
                        fontWeight:
                        FontWeight.w600,
                        color:
                        textoOscuro,
                      ),
                    ),
                  ],
                ),

                // --------------------------------------------
                // TOTAL
                // --------------------------------------------

                Column(
                  crossAxisAlignment:
                  CrossAxisAlignment.end,
                  children: [
                    const Text(
                      'TOTAL',
                      style: TextStyle(
                        fontSize: 12,
                        color: textoSuave,
                      ),
                    ),

                    const SizedBox(height: 3),

                    Text(
                      '\$${pedido['total'] ?? '0.00'}',

                      style:
                      const TextStyle(
                        fontSize: 19,
                        fontWeight:
                        FontWeight.bold,
                        color:
                        cafePrincipal,
                      ),
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 14),

            // ==================================================
            // LÍNEA DECORATIVA
            // ==================================================

            Container(
              width: double.infinity,
              height: 1,
              color: cafeClaro.withValues(
                alpha: 0.15,
              ),
            ),
          ],
        ),
      ),
    );
  }
}