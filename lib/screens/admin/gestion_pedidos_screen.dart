import 'package:flutter/material.dart';
import '../../services/pedido_service.dart';

class GestionPedidosScreen extends StatefulWidget {
  const GestionPedidosScreen({super.key});

  @override
  State<GestionPedidosScreen> createState() => _GestionPedidosScreenState();
}

class _GestionPedidosScreenState extends State<GestionPedidosScreen> {
  static const Color cafePrincipal = Color(0xFF4E342E);
  static const Color cafeClaro = Color(0xFF795548);
  static const Color crema = Color(0xFFF5EFE6);
  static const Color cremaClaro = Color(0xFFFFFCF7);
  static const Color dorado = Color(0xFFC8A45D);
  static const Color textoOscuro = Color(0xFF3A2925);
  static const Color textoSuave = Color(0xFF756860);

  List<dynamic> _pedidos = [];
  List<dynamic> _pedidosFiltrados = [];
  bool _cargando = true;
  String? _error;
  String? _exito;
  String _filtroEstado = 'todos';
  String _busqueda = '';

  @override
  void initState() {
    super.initState();
    _cargarPedidos();
  }

  Future<void> _cargarPedidos() async {
    setState(() {
      _cargando = true;
      _error = null;
    });
    try {
      final res = await PedidoService.obtenerTodosAdmin();
      if (!mounted) return;
      setState(() {
        _pedidos = res;
        _aplicarFiltros();
        _cargando = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = 'Error al cargar los pedidos: $e';
        _cargando = false;
      });
    }
  }

  void _aplicarFiltros() {
    var filtrados = List<dynamic>.from(_pedidos);
    if (_filtroEstado != 'todos') {
      filtrados = filtrados.where((p) => p['estado'].toString().toLowerCase() == _filtroEstado.toLowerCase()).toList();
    }
    if (_busqueda.trim().isNotEmpty) {
      final q = _busqueda.toLowerCase();
      filtrados = filtrados.where((p) {
        final usuario = p['usuario'];
        if (usuario == null) return false;
        final nombre = (usuario['nombre_usuario'] ?? '').toString().toLowerCase();
        final correo = (usuario['correo'] ?? '').toString().toLowerCase();
        return nombre.contains(q) || correo.contains(q);
      }).toList();
    }
    setState(() {
      _pedidosFiltrados = filtrados;
    });
  }

  Future<void> _actualizarEstado(int pedidoId, String nuevoEstado) async {
    try {
      await PedidoService.actualizarEstado(pedidoId, nuevoEstado);
      if (!mounted) return;
      setState(() => _exito = 'Pedido #$pedidoId actualizado a $nuevoEstado');
      await _cargarPedidos();
      Future.delayed(const Duration(seconds: 3), () {
        if (mounted) setState(() => _exito = null);
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = 'Error al actualizar el estado: $e');
    }
  }

  Future<void> _confirmarCambioEstado(int pedidoId, String nuevoEstado) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: cremaClaro,
        title: const Text('Confirmar cambio', style: TextStyle(color: cafePrincipal)),
        content: Text('¿Cambiar estado del pedido #$pedidoId a "$nuevoEstado"?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancelar', style: TextStyle(color: cafeClaro))),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Confirmar', style: TextStyle(color: cafePrincipal))),
        ],
      ),
    );
    if (confirmar == true) {
      _actualizarEstado(pedidoId, nuevoEstado);
    }
  }

  Future<void> _verDetalle(dynamic pedido) async {
    final int pedidoId = pedido['id'];
    try {
      final res = await PedidoService.obtenerDetalleConProductos(pedidoId);
      if (!mounted) return;
      _mostrarDetalle(pedido, res);
    } catch (e) {
      _mostrarError('Error al cargar el detalle: $e');
    }
  }

  void _mostrarError(String mensaje) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(backgroundColor: Colors.red, content: Text(mensaje)));
  }

  void _mostrarDetalle(dynamic pedido, List<dynamic> items) {
    final int pedidoId = pedido['id'];
    final usuario = pedido['usuario'];
    final TextEditingController guiaCtrl = TextEditingController(text: (pedido['numero_guia'] ?? '').toString());
    final TextEditingController transportadoraCtrl = TextEditingController(text: (pedido['transportadora'] ?? '').toString());

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: cremaClaro,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) {
        return DraggableScrollableSheet(
          initialChildSize: 0.85,
          maxChildSize: 0.95,
          expand: false,
          builder: (context, scrollController) {
            return Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Detalle del Pedido #$pedidoId',
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: cafePrincipal)),
                      IconButton(icon: const Icon(Icons.close, color: cafeClaro), onPressed: () => Navigator.pop(ctx)),
                    ],
                  ),
                  const Divider(color: dorado),
                  
                  const Text('INFORMACIÓN DEL CLIENTE', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: dorado)),
                  const SizedBox(height: 8),
                  Text('Nombre: ${usuario?['nombre_usuario'] ?? 'N/A'} ${usuario?['apellido'] ?? ''}', style: const TextStyle(fontWeight: FontWeight.w600)),
                  Text('Email: ${usuario?['correo'] ?? 'N/A'}'),
                  Text('Teléfono: ${usuario?['telefono'] ?? 'N/A'}'),
                  Text('Dirección: ${usuario?['direccion'] ?? 'N/A'}'),
                  const SizedBox(height: 4),
                  Text('Método de Pago: ${pedido['metodo_pago'] ?? 'No especificado'}', 
                      style: const TextStyle(fontWeight: FontWeight.bold, color: cafePrincipal)),
                  
                  const SizedBox(height: 20),
                  
                  // SECCIÓN DE SEGUIMIENTO
                  const Text('SEGUIMIENTO DE ENVÍO', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: dorado)),
                  const SizedBox(height: 8),
                  TextField(
                    controller: guiaCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Número de Guía', 
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: transportadoraCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Transportadora', 
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    ),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () async {
                        if (guiaCtrl.text.trim().isEmpty || transportadoraCtrl.text.trim().isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('❌ Por favor ingresa el número de guía y la transportadora')),
                          );
                          return;
                        }

                        // Mostrar indicador de carga
                        showDialog(
                          context: context,
                          barrierDismissible: false,
                          builder: (_) => const Center(child: CircularProgressIndicator(color: cafePrincipal)),
                        );

                        try {
                          await PedidoService.actualizarSeguimiento(pedidoId, guiaCtrl.text.trim(), transportadoraCtrl.text.trim());
                          
                          if (mounted) {
                            Navigator.pop(context); // Cerrar indicador de carga
                            Navigator.pop(ctx); // Cerrar panel inferior (bottom sheet) del detalle del pedido
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('✅ Seguimiento guardado y pedido marcado EN CAMINO')),
                            );
                            _cargarPedidos(); // Recargar la lista para reflejar los cambios
                          }
                        } catch (e) {
                          if (mounted) {
                            Navigator.pop(context); // Cerrar indicador de carga en caso de error
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
                          }
                        }
                      }, 
                      style: ElevatedButton.styleFrom(backgroundColor: cafePrincipal, foregroundColor: Colors.white),
                      child: const Text('GUARDAR SEGUIMIENTO'),
                    ),
                  ),

                  const SizedBox(height: 20),
                  const Text('PRODUCTOS', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: dorado)),
                  const SizedBox(height: 8),
                  
                  Expanded(
                    child: ListView.builder(
                      controller: scrollController,
                      itemCount: items.length,
                      itemBuilder: (context, i) {
                        final item = items[i];
                        final producto = item['id_producto'];
                        final String nombreProd = (producto?['nombre_producto'] ?? producto?['nombre'] ?? 'Producto').toString();
                        
                        final cantidad = item['cantidad'] ?? 0;
                        final precio = (item['precio_unitario'] ?? 0) as num;
                        final subtotal = cantidad * precio;
                        return ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(color: crema, borderRadius: BorderRadius.circular(10)),
                            child: const Icon(Icons.coffee, color: cafePrincipal),
                          ),
                          title: Text(nombreProd, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                          subtitle: Text('$cantidad x \$${precio.toStringAsFixed(0)}'),
                          trailing: Text('\$${subtotal.toStringAsFixed(0)}', style: const TextStyle(fontWeight: FontWeight.bold, color: cafePrincipal)),
                        );
                      },
                    ),
                  ),
                  const Divider(color: dorado),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('TOTAL:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      Text('\$${(pedido['total'] ?? 0).toString()}', style: const TextStyle(fontWeight: FontWeight.bold, color: cafePrincipal, fontSize: 20)),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  String _formatearFecha(String? fecha) {
    if (fecha == null) return '';
    try {
      final f = DateTime.parse(fecha);
      return '${f.day}/${f.month}/${f.year} ${f.hour.toString().padLeft(2, '0')}:${f.minute.toString().padLeft(2, '0')}';
    } catch (_) {
      return fecha;
    }
  }

  Color _colorEstado(String estado) {
    switch (estado.toLowerCase()) {
      case 'entregado':
        return Colors.green;
      case 'en camino':
        return Colors.blue;
      case 'cancelado':
        return Colors.red;
      case 'pendiente':
        return Colors.orange;
      default:
        return dorado;
    }
  }

  Widget _chipFiltro(String label, String valor, int conteo) {
    final activo = _filtroEstado == valor;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text('$label ($conteo)'),
        selected: activo,
        selectedColor: cafePrincipal,
        backgroundColor: cremaClaro,
        labelStyle: TextStyle(color: activo ? Colors.white : textoOscuro),
        onSelected: (_) => setState(() {
          _filtroEstado = valor;
          _aplicarFiltros();
        }),
      ),
    );
  }

  int _contar(String estado) => _pedidos.where((p) => p['estado'].toString().toLowerCase() == estado.toLowerCase()).length;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: crema,
      appBar: AppBar(
        backgroundColor: cafePrincipal,
        foregroundColor: Colors.white,
        title: const Text('GESTIÓN DE PEDIDOS', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        centerTitle: true,
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _cargarPedidos),
        ],
      ),
      body: _cargando
          ? const Center(child: CircularProgressIndicator(color: cafePrincipal))
          : RefreshIndicator(
        onRefresh: _cargarPedidos,
        child: Column(
          children: [
            if (_error != null)
              Container(width: double.infinity, color: Colors.red.shade100, padding: const EdgeInsets.all(10), child: Text(_error!, style: const TextStyle(color: Colors.red))),
            if (_exito != null)
              Container(width: double.infinity, color: Colors.green.shade100, padding: const EdgeInsets.all(10), child: Text(_exito!, style: const TextStyle(color: Colors.green))),
            
            Padding(
              padding: const EdgeInsets.all(12),
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Buscar por usuario o correo...',
                  prefixIcon: const Icon(Icons.search, color: cafePrincipal),
                  filled: true,
                  fillColor: cremaClaro,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                  focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: dorado, width: 2)),
                ),
                onChanged: (v) => setState(() {
                  _busqueda = v;
                  _aplicarFiltros();
                }),
              ),
            ),
            
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Row(
                children: [
                  _chipFiltro('Todos', 'todos', _pedidos.length),
                  _chipFiltro('Pendientes', 'pendiente', _contar('pendiente')),
                  _chipFiltro('En Camino', 'en camino', _contar('en camino')),
                  _chipFiltro('Entregados', 'entregado', _contar('entregado')),
                  _chipFiltro('Cancelados', 'cancelado', _contar('cancelado')),
                ],
              ),
            ),
            
            Expanded(
              child: _pedidosFiltrados.isEmpty
                  ? const Center(child: Text('No hay pedidos para mostrar'))
                  : ListView.builder(
                padding: const EdgeInsets.all(12),
                itemCount: _pedidosFiltrados.length,
                itemBuilder: (context, index) {
                  final pedido = _pedidosFiltrados[index];
                  final usuario = pedido['usuario'];
                  final estado = pedido['estado'] as String? ?? 'pendiente';
                  final id = pedido['id'] as int;
                  return Card(
                    color: cremaClaro,
                    margin: const EdgeInsets.only(bottom: 15),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                    elevation: 3,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('PEDIDO #$id', style: const TextStyle(fontWeight: FontWeight.bold, color: cafePrincipal, fontSize: 16)),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: _colorEstado(estado).withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(estado.toUpperCase(), style: TextStyle(color: _colorEstado(estado), fontSize: 11, fontWeight: FontWeight.bold)),
                              ),
                            ],
                          ),
                          const Divider(height: 20),
                          Text('${usuario?['nombre_usuario'] ?? ''} ${usuario?['apellido'] ?? ''}', style: const TextStyle(fontWeight: FontWeight.bold)),
                          Text(usuario?['correo'] ?? '', style: const TextStyle(fontSize: 13, color: textoSuave)),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              const Icon(Icons.calendar_today, size: 14, color: dorado),
                              const SizedBox(width: 6),
                              Text(_formatearFecha(pedido['fecha']), style: const TextStyle(fontSize: 13)),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Total:', style: const TextStyle(fontWeight: FontWeight.bold)),
                              Text('\$${(pedido['total'] ?? 0).toString()}', style: const TextStyle(fontWeight: FontWeight.bold, color: cafePrincipal, fontSize: 18)),
                            ],
                          ),
                          const SizedBox(height: 15),
                          Row(
                            children: [
                              Expanded(
                                child: DropdownButtonFormField<String>(
                                  initialValue: ['pendiente', 'en camino', 'entregado', 'cancelado'].contains(estado.toLowerCase()) ? estado.toLowerCase() : 'pendiente',
                                  decoration: InputDecoration(
                                    isDense: true,
                                    filled: true,
                                    fillColor: crema,
                                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                                  ),
                                  items: const [
                                    DropdownMenuItem(value: 'pendiente', child: Text('Pendiente')),
                                    DropdownMenuItem(value: 'en camino', child: Text('En Camino')),
                                    DropdownMenuItem(value: 'entregado', child: Text('Entregado')),
                                    DropdownMenuItem(value: 'cancelado', child: Text('Cancelado')),
                                  ],
                                  onChanged: (nuevo) {
                                    if (nuevo != null && nuevo.toLowerCase() != estado.toLowerCase()) {
                                      _confirmarCambioEstado(id, nuevo);
                                    }
                                  },
                                ),
                              ),
                              const SizedBox(width: 10),
                              ElevatedButton(
                                onPressed: () => _verDetalle(pedido),
                                style: ElevatedButton.styleFrom(backgroundColor: dorado, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                                child: const Text('DETALLE'),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
