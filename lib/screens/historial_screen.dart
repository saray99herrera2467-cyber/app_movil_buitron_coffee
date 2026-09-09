import 'package:flutter/material.dart';
import '../models/pedido.dart';
import '../models/producto.dart';

class HistorialScreen extends StatelessWidget {
  const HistorialScreen({super.key});

  @override
<<<<<<< Updated upstream
=======
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
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: cremaClaro,
        title: const Text('¿Eliminar pedido?', style: TextStyle(color: cafePrincipal)),
        content: const Text('Esta acción no se puede deshacer.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('CANCELAR', style: TextStyle(color: cafeClaro)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
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
            const SnackBar(content: Text('Error al eliminar el pedido'), backgroundColor: Colors.redAccent),
          );
        }
      }
    }
  }

  // ==========================================================
  // BUILD
  // ==========================================================

  @override
>>>>>>> Stashed changes
  Widget build(BuildContext context) {
    final colorRojo = const Color(0xFF9B1C2C);
    final colorFondo = const Color(0xFF2B0F0F);

    final List<Pedido> pedidos = [
      Pedido(
        id: '001',
        productos: [
          Producto(id: 'p1', nombre: 'Bourbon Rosado', descripcion: '100% Café especial', precio: 80000, imagen: '', categoria: ''),
        ],
        fecha: DateTime.now().subtract(const Duration(days: 5)),
        total: 80000,
        estado: 'Entregado',
      ),
<<<<<<< Updated upstream
      Pedido(
        id: '002',
        productos: [
          Producto(id: 'p2', nombre: 'Café Buitrón', descripcion: '100% Café especial', precio: 60000, imagen: '', categoria: ''),
        ],
        fecha: DateTime.now().subtract(const Duration(days: 2)),
        total: 60000,
        estado: 'En camino',
=======

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
            );
          },
        ),
>>>>>>> Stashed changes
      ),
    ];

    return Scaffold(
      backgroundColor: colorFondo,
      appBar: AppBar(
        title: const Text('Historial de Pedidos', style: TextStyle(color: Colors.white)),
        backgroundColor: colorRojo,
      ),
<<<<<<< Updated upstream
      body: ListView.builder(
=======
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

  const _PedidoCard({
    required this.pedido,
    required this.formatearFecha,
    required this.estadoPedido,
    required this.colorEstado,
    required this.onEliminar,
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
>>>>>>> Stashed changes
        padding: const EdgeInsets.all(16),
        itemCount: pedidos.length,
        itemBuilder: (ctx, i) {
          final pedido = pedidos[i];
          return Card(
            color: Colors.white10,
            margin: const EdgeInsets.only(bottom: 12),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Pedido #${pedido.id}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      Text('${pedido.fecha.day}/${pedido.fecha.month}/${pedido.fecha.year}', style: const TextStyle(color: Colors.white60)),
                    ],
                  ),
                  const Divider(color: Colors.white24),
                  ...pedido.productos.map((prod) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          color: Colors.brown[200],
                          child: const Icon(Icons.coffee, size: 20, color: Colors.brown),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(prod.nombre, style: const TextStyle(color: Colors.white)),
                              Text(prod.descripcion, style: const TextStyle(color: Colors.white60, fontSize: 12)),
                            ],
                          ),
                        ),
                        Text('\$${prod.precio.toStringAsFixed(0)}', style: const TextStyle(color: Colors.amber)),
                      ],
                    ),
<<<<<<< Updated upstream
                  )),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                        decoration: BoxDecoration(
                          color: colorRojo,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(pedido.estado, style: const TextStyle(color: Colors.white, fontSize: 12)),
=======

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

                IconButton(
                  onPressed: onEliminar,
                  icon: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 20),
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
>>>>>>> Stashed changes
                      ),
                      Text('Total: \$${pedido.total.toStringAsFixed(0)}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}