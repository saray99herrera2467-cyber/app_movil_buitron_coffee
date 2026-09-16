import 'package:flutter/material.dart';
import '../../services/pedido_service.dart';

class GestionPedidosScreen extends StatefulWidget {
  const GestionPedidosScreen({super.key});

  @override
  State<GestionPedidosScreen> createState() => _GestionPedidosScreenState();
}

class _GestionPedidosScreenState extends State<GestionPedidosScreen> {
  // ✅ PALETA NARANJA CÁLIDO
  static const Color naranjaPrincipal = Color(0xFFF9A15E);
  static const Color cremaFondo = Color(0xFFFFFBF2);
  static const Color naranjaIntenso = Color(0xFFFF7043);
  static const Color textoOscuro = Color(0xFF2D2D2D);

  List<dynamic> _pedidos = [];
  bool _cargando = true;

  @override
  void initState() {
    super.initState();
    _cargarPedidos();
  }

  Future<void> _cargarPedidos() async {
    setState(() => _cargando = true);
    try {
      final res = await PedidoService.obtenerTodosAdmin();
      if (!mounted) return;
      setState(() { _pedidos = res; _cargando = false; });
    } catch (e) {
      if (mounted) setState(() => _cargando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: cremaFondo,
      appBar: AppBar(
        backgroundColor: naranjaPrincipal,
        foregroundColor: Colors.white,
        title: const Text('GESTIÓN DE PEDIDOS', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        centerTitle: true,
        actions: [IconButton(icon: const Icon(Icons.refresh), onPressed: _cargarPedidos)],
      ),
      body: _cargando 
          ? const Center(child: CircularProgressIndicator(color: naranjaPrincipal))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _pedidos.length,
              itemBuilder: (context, index) {
                final p = _pedidos[index];
                final String estado = (p['estado'] ?? 'PENDIENTE').toString().toUpperCase();
                return Card(
                  color: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  margin: const EdgeInsets.only(bottom: 16),
                  elevation: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('PEDIDO #${p['id']}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(color: naranjaIntenso.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
                              child: Text(estado, style: const TextStyle(color: naranjaIntenso, fontSize: 11, fontWeight: FontWeight.bold)),
                            ),
                          ],
                        ),
                        const Divider(height: 24),
                        Text('Cliente: ${p['usuario']?['nombre_usuario'] ?? 'N/A'}', style: const TextStyle(fontWeight: FontWeight.w600, color: textoOscuro)),
                        Text('Total: \$${p['total']}', style: const TextStyle(color: naranjaPrincipal, fontWeight: FontWeight.bold, fontSize: 18)),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: ElevatedButton(
                                onPressed: () => _actualizarEstado(p['id'], 'ENTREGADO'),
                                style: ElevatedButton.styleFrom(backgroundColor: naranjaPrincipal),
                                child: const Text('MARCAR ENTREGADO', style: TextStyle(fontSize: 10, color: Colors.white)),
                              ),
                            ),
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

  Future<void> _actualizarEstado(int id, String nuevo) async {
    try {
      await PedidoService.actualizarEstado(id, nuevo);
      _cargarPedidos();
    } catch (_) {}
  }
}
