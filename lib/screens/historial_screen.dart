import 'package:flutter/material.dart';

import '../services/historial_service.dart';
import 'catalogo_screen.dart';
import 'comprobante_pago_screen.dart';

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

  Future<void> _eliminarPedido(int idPedido) async {
    final bool? confirmar = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: cremaClaro,
        title: const Text('¿Eliminar del historial?', style: TextStyle(color: cafePrincipal)),
        content: const Text('Esta acción borrará el registro del pedido permanentemente.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('CANCELAR', style: TextStyle(color: cafeClaro)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('ELIMINAR', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );

    if (confirmar == true) {
      setState(() => _cargando = true);
      final exito = await HistorialService.eliminarPedido(idPedido);
      
      if (mounted) {
        if (exito) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Pedido eliminado correctamente')),
          );
          _cargarPedidos();
        } else {
          setState(() => _cargando = false);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('No se pudo eliminar el pedido'), backgroundColor: Colors.redAccent),
          );
        }
      }
    }
  }

  Future<void> _mostrarDetallePedido(int idPedido, dynamic pedido) async {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: cremaClaro,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      builder: (ctx) {
        return FutureBuilder<List<dynamic>>(
          future: HistorialService.obtenerDetallePedido(idPedido),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const SizedBox(height: 300, child: Center(child: CircularProgressIndicator(color: cafePrincipal)));
            }
            if (snapshot.hasError || !snapshot.hasData) {
              return const SizedBox(height: 200, child: Center(child: Text('No se pudo cargar el detalle')));
            }

            final items = snapshot.data!;
            return Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(width: 40, height: 5, decoration: BoxDecoration(color: cafeClaro, borderRadius: BorderRadius.circular(10))),
                  ),
                  const SizedBox(height: 20),
                  Text('Detalle del Pedido #$idPedido', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: cafePrincipal)),
                  const SizedBox(height: 10),
                  Text('Fecha: ${_formatearFecha(pedido['fecha'])}', style: const TextStyle(color: textoSuave, fontSize: 14)),
                  const SizedBox(height: 20),
                  
                  // LINEA DE TIEMPO (SEGUIMIENTO)
                  _LineaTiempoSeguimiento(estado: pedido['estado']?.toString() ?? 'Pendiente'),
                  
                  const SizedBox(height: 20),
                  
                  if (pedido['numero_guia'] != null && pedido['numero_guia'].toString().isNotEmpty) ...[
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(color: Colors.green.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('INFORMACIÓN DE ENVÍO', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.green)),
                          const SizedBox(height: 4),
                          Text('Transportadora: ${pedido['transportadora'] ?? 'N/A'}', style: const TextStyle(fontSize: 13)),
                          Text('Número de Guía: ${pedido['numero_guia']}', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                  ],

                  const Divider(height: 30, color: dorado),
                  
                  Flexible(
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: items.length,
                      itemBuilder: (context, i) {
                        final item = items[i];
                        final prod = item['id_producto']; // ✅ Cambiado de 'producto' a 'id_producto'
                        final String nombreProd = (prod?['nombre'] ?? prod?['nombre_producto'] ?? prod?['producto'] ?? 'Producto').toString();
                        
                        return ListTile(
                          contentPadding: EdgeInsets.zero,
                          title: Text(nombreProd, style: const TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Text('${item['cantidad']} x \$${item['precio_unitario'] ?? '0'}'),
                          trailing: Text('\$${((item['cantidad'] ?? 0) * (item['precio_unitario'] ?? 0)).toStringAsFixed(0)}', 
                              style: const TextStyle(fontWeight: FontWeight.bold, color: cafePrincipal)),
                        );
                      },
                    ),
                  ),
                  const Divider(height: 30, color: dorado),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('TOTAL', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: textoOscuro)),
                      Text('\$${pedido['total'] ?? '0.00'}', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: cafePrincipal)),
                    ],
                  ),
                  const SizedBox(height: 30),
                  
                  // Botón para ver comprobante
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: OutlinedButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ComprobantePagoScreen(
                              pedido: Map<String, dynamic>.from(pedido),
                              items: items,
                            ),
                          ),
                        );
                      },
                      icon: const Icon(Icons.receipt_long),
                      label: const Text('VER COMPROBANTE / FACTURA', style: TextStyle(fontWeight: FontWeight.bold)),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: cafePrincipal,
                        side: const BorderSide(color: cafePrincipal),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                ],
              ),
            );
          },
        );
      },
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
              formatearFecha: _formatearFecha,
              estadoPedido: _estadoPedido,
              colorEstado: _colorEstado,
              onEliminar: () => _eliminarPedido(pedido['id']),
              onTap: () => _mostrarDetallePedido(pedido['id'], pedido),
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
  final VoidCallback onEliminar;
  final VoidCallback onTap;

  const _PedidoCard({
    required this.pedido,
    required this.formatearFecha,
    required this.estadoPedido,
    required this.colorEstado,
    required this.onEliminar,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final String estado =
        pedido['estado']?.toString() ??
            'Desconocido';

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Card(
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

                const SizedBox(width: 8),

                IconButton(
                  onPressed: onEliminar,
                  icon: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 22),
                  tooltip: 'Eliminar pedido',
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
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
      ),
    );
  }
}

// ============================================================
// WIDGET LINEA DE TIEMPO (SEGUIMIENTO)
// ============================================================

class _LineaTiempoSeguimiento extends StatelessWidget {
  final String estado;

  const _LineaTiempoSeguimiento({required this.estado});

  int get _pasoActual {
    switch (estado.toUpperCase()) {
      case 'PENDIENTE': return 0;
      case 'PAGADO': return 1;
      case 'ENVIADO': return 2;
      case 'ENTREGADO': return 3;
      case 'CANCELADO': return -1;
      default: return 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_pasoActual == -1) {
      return Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(color: Colors.red.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)),
        child: const Row(
          children: [
            Icon(Icons.cancel, color: Colors.red),
            SizedBox(width: 10),
            Text('Este pedido ha sido CANCELADO', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
          ],
        ),
      );
    }

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _paso(0, 'Recibido', Icons.receipt_long),
            _linea(0),
            _paso(1, 'Pagado', Icons.payments_outlined),
            _linea(1),
            _paso(2, 'En camino', Icons.local_shipping_outlined),
            _linea(2),
            _paso(3, 'Entregado', Icons.coffee),
          ],
        ),
      ],
    );
  }

  Widget _paso(int index, String titulo, IconData icono) {
    final bool completado = index <= _pasoActual;
    final Color color = completado ? dorado : Colors.grey.shade300;

    return Expanded(
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: completado ? color.withValues(alpha: 0.1) : Colors.transparent,
              shape: BoxShape.circle,
              border: Border.all(color: color, width: 2),
            ),
            child: Icon(icono, size: 20, color: color),
          ),
          const SizedBox(height: 6),
          Text(
            titulo,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 10,
              fontWeight: completado ? FontWeight.bold : FontWeight.normal,
              color: completado ? cafePrincipal : Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _linea(int index) {
    final bool completado = index < _pasoActual;
    return Container(
      width: 20,
      height: 2,
      margin: const EdgeInsets.only(bottom: 22), // Alineado con los iconos
      color: completado ? dorado : Colors.grey.shade300,
    );
  }
}
