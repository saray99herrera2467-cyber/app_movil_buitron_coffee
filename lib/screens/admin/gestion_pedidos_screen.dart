import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class GestionPedidosScreen extends StatefulWidget {
  const GestionPedidosScreen({super.key});

  @override
  State<GestionPedidosScreen> createState() => _GestionPedidosScreenState();
}

class _GestionPedidosScreenState extends State<GestionPedidosScreen> {
  static const String _baseUrl = 'http://localhost:3001/api/pedidos';
  final colorRojo = const Color(0xFF9B1C2C);
  final colorFondo = const Color(0xFFF8F5F2);

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

  Future<String?> _token() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  Future<void> _cargarPedidos() async {
    setState(() {
      _cargando = true;
      _error = null;
    });
    try {
      final token = await _token();
      final res = await http.get(
        Uri.parse('$_baseUrl/admin/todos'),
        headers: {'Authorization': 'Bearer $token'},
      );
      if (res.statusCode == 200) {
        final lista = jsonDecode(res.body) as List;
        setState(() {
          _pedidos = lista;
          _aplicarFiltros();
          _cargando = false;
        });
      } else {
        setState(() {
          _error = 'Error al cargar los pedidos';
          _cargando = false;
        });
      }
    } catch (_) {
      setState(() {
        _error = 'Error al cargar los pedidos';
        _cargando = false;
      });
    }
  }

  void _aplicarFiltros() {
    var filtrados = List<dynamic>.from(_pedidos);
    if (_filtroEstado != 'todos') {
      filtrados = filtrados.where((p) => p['Estado'] == _filtroEstado).toList();
    }
    if (_busqueda.trim().isNotEmpty) {
      final q = _busqueda.toLowerCase();
      filtrados = filtrados.where((p) {
        final nombre = (p['Nombre_usuario'] ?? '').toString().toLowerCase();
        final apellido = (p['Apellido'] ?? '').toString().toLowerCase();
        final correo = (p['Correo'] ?? '').toString().toLowerCase();
        return nombre.contains(q) || apellido.contains(q) || correo.contains(q);
      }).toList();
    }
    _pedidosFiltrados = filtrados;
  }

  Future<void> _actualizarEstado(int pedidoId, String nuevoEstado) async {
    try {
      final token = await _token();
      final res = await http.patch(
        Uri.parse('$_baseUrl/admin/estado/$pedidoId'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({'estado': nuevoEstado}),
      );
      if (res.statusCode == 200) {
        setState(() => _exito = 'Pedido #$pedidoId actualizado a $nuevoEstado');
        await _cargarPedidos();
        Future.delayed(const Duration(seconds: 3), () {
          if (mounted) setState(() => _exito = null);
        });
      } else {
        setState(() => _error = 'Error al actualizar el estado');
      }
    } catch (_) {
      setState(() => _error = 'Error al actualizar el estado');
    }
  }

  Future<void> _confirmarCambioEstado(int pedidoId, String nuevoEstado) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Confirmar cambio'),
        content: Text('¿Cambiar estado del pedido #$pedidoId a "$nuevoEstado"?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancelar')),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Confirmar')),
        ],
      ),
    );
    if (confirmar == true) {
      _actualizarEstado(pedidoId, nuevoEstado);
    }
  }

  Future<void> _verDetalle(int pedidoId) async {
    try {
      final token = await _token();
      final res = await http.get(
        Uri.parse('$_baseUrl/admin/detalle/$pedidoId'),
        headers: {'Authorization': 'Bearer $token'},
      );
      if (res.statusCode == 200) {
        final detalle = jsonDecode(res.body) as List;
        if (!mounted) return;
        _mostrarDetalle(pedidoId, detalle);
      } else {
        _mostrarError('Error al cargar el detalle del pedido');
      }
    } catch (_) {
      _mostrarError('Error al cargar el detalle del pedido');
    }
  }

  void _mostrarError(String mensaje) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(mensaje)));
  }

  void _mostrarDetalle(int pedidoId, List<dynamic> items) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (ctx) {
        return DraggableScrollableSheet(
          initialChildSize: 0.6,
          maxChildSize: 0.9,
          expand: false,
          builder: (context, scrollController) {
            return Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Detalle del pedido #${pedidoId.toString().padLeft(6, '0')}',
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(ctx)),
                    ],
                  ),
                  const Divider(),
                  Expanded(
                    child: ListView.builder(
                      controller: scrollController,
                      itemCount: items.length,
                      itemBuilder: (context, i) {
                        final item = items[i];
                        final cantidad = item['Cantidad'] ?? 0;
                        final precio = (item['PrecioUnitario'] ?? 0) as num;
                        final subtotal = cantidad * precio;
                        return ListTile(
                          leading: Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(color: Colors.brown[200], borderRadius: BorderRadius.circular(6)),
                            child: const Icon(Icons.coffee, color: Colors.brown),
                          ),
                          title: Text(item['Nombre_producto'] ?? ''),
                          subtitle: Text('$cantidad x \$${precio.toStringAsFixed(0)}'),
                          trailing: Text('\$${subtotal.toStringAsFixed(0)}', style: const TextStyle(fontWeight: FontWeight.bold)),
                        );
                      },
                    ),
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

  String _tiempoRestante(String? fechaLimite) {
    if (fechaLimite == null) return 'No definida';
    final limite = DateTime.tryParse(fechaLimite);
    if (limite == null) return 'No definida';
    final diff = limite.difference(DateTime.now());
    if (diff.isNegative) return '⏰ Vencido';
    final horas = diff.inHours;
    final dias = diff.inDays;
    if (dias > 0) return '$dias día(s) restante(s)';
    if (horas > 0) return '$horas hora(s) restante(s)';
    return 'Menos de 1 hora';
  }

  Color _colorEstado(String estado) {
    switch (estado) {
      case 'Entregado':
        return Colors.green;
      case 'Cancelado':
        return Colors.red;
      default:
        return Colors.orange;
    }
  }

  Widget _chipFiltro(String label, String valor, int conteo) {
    final activo = _filtroEstado == valor;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text('$label ($conteo)'),
        selected: activo,
        selectedColor: colorRojo,
        labelStyle: TextStyle(color: activo ? Colors.white : Colors.black87),
        onSelected: (_) => setState(() {
          _filtroEstado = valor;
          _aplicarFiltros();
        }),
      ),
    );
  }

  int _contar(String estado) => _pedidos.where((p) => p['Estado'] == estado).length;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: colorFondo,
      appBar: AppBar(
        backgroundColor: colorRojo,
        foregroundColor: Colors.white,
        title: const Text('Gestión de Pedidos'),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _cargarPedidos),
        ],
      ),
      body: _cargando
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
        onRefresh: _cargarPedidos,
        child: Column(
          children: [
            if (_error != null)
              Container(
                width: double.infinity,
                color: Colors.red.shade100,
                padding: const EdgeInsets.all(10),
                child: Text(_error!, style: const TextStyle(color: Colors.red)),
              ),
            if (_exito != null)
              Container(
                width: double.infinity,
                color: Colors.green.shade100,
                padding: const EdgeInsets.all(10),
                child: Text(_exito!, style: const TextStyle(color: Colors.green)),
              ),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 0),
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Buscar por usuario, apellido o correo',
                  prefixIcon: const Icon(Icons.search),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                ),
                onChanged: (v) => setState(() {
                  _busqueda = v;
                  _aplicarFiltros();
                }),
              ),
            ),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              child: Row(
                children: [
                  _chipFiltro('Todos', 'todos', _pedidos.length),
                  _chipFiltro('Pendientes', 'Pendiente', _contar('Pendiente')),
                  _chipFiltro('Entregados', 'Entregado', _contar('Entregado')),
                  _chipFiltro('Cancelados', 'Cancelado', _contar('Cancelado')),
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
                  final estado = pedido['Estado'] as String? ?? 'Pendiente';
                  final id = pedido['ID_Pedido'] as int;
                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    child: Padding(
                      padding: const EdgeInsets.all(14),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Pedido #${id.toString().padLeft(6, '0')}',
                                  style: TextStyle(fontWeight: FontWeight.bold, color: colorRojo)),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: _colorEstado(estado).withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(estado, style: TextStyle(color: _colorEstado(estado), fontSize: 12, fontWeight: FontWeight.w600)),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text('${pedido['Nombre_usuario'] ?? ''} ${pedido['Apellido'] ?? ''}',
                              style: const TextStyle(fontWeight: FontWeight.w500)),
                          Text(pedido['Correo'] ?? '', style: const TextStyle(fontSize: 12, color: Colors.black54)),
                          const SizedBox(height: 6),
                          Text('📅 ${_formatearFecha(pedido['Fecha'])}', style: const TextStyle(fontSize: 12, color: Colors.black54)),
                          Text(_tiempoRestante(pedido['Fecha_Limite']),
                              style: TextStyle(
                                fontSize: 12,
                                color: DateTime.tryParse(pedido['Fecha_Limite'] ?? '')?.isBefore(DateTime.now()) == true
                                    ? Colors.red
                                    : Colors.black54,
                              )),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('${pedido['CantidadProductos'] ?? 0} artículos', style: const TextStyle(fontSize: 13)),
                              Text('\$${(pedido['Total'] ?? 0).toString()}',
                                  style: TextStyle(fontWeight: FontWeight.bold, color: colorRojo)),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              Expanded(
                                child: DropdownButtonFormField<String>(
                                  initialValue: estado,
                                  decoration: const InputDecoration(
                                    isDense: true,
                                    contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                    border: OutlineInputBorder(),
                                  ),
                                  items: const [
                                    DropdownMenuItem(value: 'Pendiente', child: Text('📋 Pendiente')),
                                    DropdownMenuItem(value: 'Entregado', child: Text('✅ Entregado')),
                                    DropdownMenuItem(value: 'Cancelado', child: Text('❌ Cancelado')),
                                  ],
                                  onChanged: (nuevo) {
                                    if (nuevo != null && nuevo != estado) {
                                      _confirmarCambioEstado(id, nuevo);
                                    }
                                  },
                                ),
                              ),
                              const SizedBox(width: 8),
                              OutlinedButton(
                                onPressed: () => _verDetalle(id),
                                child: const Text('Ver detalle'),
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