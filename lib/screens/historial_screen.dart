import 'package:flutter/material.dart';
import '../services/historial_service.dart';
import 'catalogo_screen.dart';
import 'carrito_screen.dart';
import 'perfil_screen.dart';
import 'login_screen.dart';

class HistorialScreen extends StatefulWidget {
  const HistorialScreen({super.key});

  @override
  State<HistorialScreen> createState() => _HistorialScreenState();
}

class _HistorialScreenState extends State<HistorialScreen> {
  List<dynamic> _pedidos = [];
  bool _cargando = true;

  @override
  void initState() {
    super.initState();
    _cargarPedidos();
  }

  Future<void> _cargarPedidos() async {
    setState(() => _cargando = true);
    final lista = await HistorialService.obtenerPedidosUsuario();
    setState(() {
      _pedidos = lista;
      _cargando = false;
    });
  }

  // Formatear fecha
  String _formatearFecha(String fecha) {
    try {
      final DateTime fechaHora = DateTime.parse(fecha);
      return '${fechaHora.day}/${fechaHora.month}/${fechaHora.year}  •  ${fechaHora.hour.toString().padLeft(2,'0')}:${fechaHora.minute.toString().padLeft(2,'0')}';
    } catch (_) {
      return fecha;
    }
  }

  // Traducir estado
  String _estadoPedido(String? estado) {
    switch (estado?.toLowerCase()) {
      case 'pendiente': return '⏳ Pendiente';
      case 'pagado': return '✅ Pagado';
      case 'enviado': return '🚀 Enviado';
      case 'entregado': return '☕ Entregado';
      default: return estado ?? 'Desconocido';
    }
  }

  @override
  Widget build(BuildContext context) {
<<<<<<< Updated upstream
    return Scaffold(
      backgroundColor: const Color(0xFFF8F5F2),

      // ✅ MENÚ LATERAL IGUAL QUE EN TODAS LAS PANTALLAS
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(color: Color(0xFF9E0000)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.coffee, color: Colors.white, size: 40),
                  SizedBox(height: 10),
                  Text('Buitrón Coffee',
                      style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                  Text('Historial de Pedidos', style: TextStyle(color: Colors.white70, fontSize: 14)),
=======
    final colorRojo = const Color(0xFF9B1C2C);
    final colorFondo = const Color(0xFF2B0F0F);

    final List<Pedido> pedidos = [
      Pedido(
        id: '001',
        productos: [
          Producto(
            id: 1,
            nombre: 'Bourbon Rosado',
            descripcion: '100% Café especial',
            precio: 80000,
            imagen: '',
            categoria: 'Café',
            estado: true,
          ),
        ],
        fecha: DateTime.now().subtract(const Duration(days: 5)),
        total: 80000,
        estado: 'Entregado',
      ),

      Pedido(
        id: '002',
        productos: [
          Producto(
            id: 2,
            nombre: 'Café Buitrón',
            descripcion: '100% Café especial',
            precio: 60000,
            imagen: '',
            categoria: 'Café',
            estado: true,
          ),
        ],
        fecha: DateTime.now().subtract(const Duration(days: 2)),
        total: 60000,
        estado: 'En camino',
      ),
    ];

    return Scaffold(
      backgroundColor: colorFondo,

      appBar: AppBar(
        title: const Text(
          'Historial de Pedidos',
          style: TextStyle(
            color: Colors.white,
          ),
        ),
        backgroundColor: colorRojo,
        iconTheme: const IconThemeData(
          color: Colors.white,
        ),
      ),

      body: ListView.builder(
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

                  // ==============================
                  // PEDIDO Y FECHA
                  // ==============================

                  Row(
                    mainAxisAlignment:
                    MainAxisAlignment.spaceBetween,

                    children: [
                      Text(
                        'Pedido #${pedido.id}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      Text(
                        '${pedido.fecha.day}/${pedido.fecha.month}/${pedido.fecha.year}',
                        style: const TextStyle(
                          color: Colors.white60,
                        ),
                      ),
                    ],
                  ),

                  const Divider(
                    color: Colors.white24,
                  ),

                  // ==============================
                  // PRODUCTOS
                  // ==============================

                  ...pedido.productos.map(
                        (prod) => Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: 4,
                      ),

                      child: Row(
                        children: [

                          // Imagen / icono
                          Container(
                            width: 40,
                            height: 40,

                            decoration: BoxDecoration(
                              color: Colors.brown[200],
                              borderRadius:
                              BorderRadius.circular(6),
                            ),

                            child: const Icon(
                              Icons.coffee,
                              size: 20,
                              color: Colors.brown,
                            ),
                          ),

                          const SizedBox(width: 10),

                          // Información del producto
                          Expanded(
                            child: Column(
                              crossAxisAlignment:
                              CrossAxisAlignment.start,

                              children: [
                                Text(
                                  prod.nombre,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),

                                Text(
                                  prod.descripcion ?? '',
                                  style: const TextStyle(
                                    color: Colors.white60,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // Precio
                          Text(
                            '\$${prod.precio.toStringAsFixed(0)}',

                            style: const TextStyle(
                              color: Colors.amber,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 8),

                  // ==============================
                  // ESTADO Y TOTAL
                  // ==============================

                  Row(
                    mainAxisAlignment:
                    MainAxisAlignment.spaceBetween,

                    children: [

                      // Estado
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),

                        decoration: BoxDecoration(
                          color: colorRojo,
                          borderRadius:
                          BorderRadius.circular(4),
                        ),

                        child: Text(
                          pedido.estado,

                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                          ),
                        ),
                      ),

                      // Total
                      Text(
                        'Total: \$${pedido.total.toStringAsFixed(0)}',

                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
>>>>>>> Stashed changes
                ],
              ),
            ),
            ListTile(
              leading: const Icon(Icons.home, color: Color(0xFF9E0000)),
              title: const Text('Catálogo'),
              onTap: () {
                Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const CatalogoScreen()));
              },
            ),
            ListTile(
              leading: const Icon(Icons.shopping_cart, color: Color(0xFF9E0000)),
              title: const Text('Carrito'),
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const CarritoScreen()));
              },
            ),
            ListTile(
              leading: const Icon(Icons.person, color: Color(0xFF9E0000)),
              title: const Text('Mi Perfil'),
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const PerfilScreen()));
              },
            ),
            ListTile(
              leading: const Icon(Icons.history, color: Color(0xFF9E0000)),
              title: const Text('Historial'),
              selected: true,
              selectedTileColor: const Color(0xFF9E0000).withValues(alpha: 0.1),
              onTap: () => Navigator.pop(context),
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: const Text('Cerrar Sesión', style: TextStyle(color: Colors.red)),
              onTap: () {
                Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => const LoginScreen()), (_) => false);
              },
            ),
          ],
        ),
      ),

      // ✅ BARRA SUPERIOR
      appBar: AppBar(
        backgroundColor: const Color(0xFF9E0000),
        foregroundColor: Colors.white,
        title: const Text('HISTORIAL DE PEDIDOS', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _cargarPedidos,
          ),
        ],
      ),

      // ✅ CONTENIDO
      body: _cargando
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF9E0000)))
          : _pedidos.isEmpty
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.shopping_bag_outlined, size: 80, color: Colors.grey.shade300),
            const SizedBox(height: 16),
            const Text('No tienes pedidos aún', style: TextStyle(fontSize: 18, color: Colors.grey)),
            const SizedBox(height: 8),
            const Text('Tus compras aparecerán aquí', style: TextStyle(fontSize: 14, color: Colors.grey)),
            const SizedBox(height: 24),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF9E0000), foregroundColor: Colors.white),
              onPressed: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const CatalogoScreen())),
              child: const Text('Ver Catálogo'),
            ),
          ],
        ),
      )
          : RefreshIndicator(
        onRefresh: _cargarPedidos,
        child: ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: _pedidos.length,
          itemBuilder: (context, index) {
            final pedido = _pedidos[index];
            return Card(
              elevation: 3,
              margin: const EdgeInsets.only(bottom: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Pedido #${pedido['id']}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF9E0000))),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFF9E0000).withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(_estadoPedido(pedido['estado']), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text('📅 Fecha: ${_formatearFecha(pedido['fecha'])}', style: const TextStyle(fontSize: 14, color: Colors.black54)),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Subtotal: \$${pedido['subtotal'] ?? '0.00'}', style: const TextStyle(fontSize: 14)),
                        Text('Total: \$${pedido['total'] ?? '0.00'}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF9E0000))),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}