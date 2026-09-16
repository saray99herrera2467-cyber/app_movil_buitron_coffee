import 'package:flutter/material.dart';
import '../../services/resena_service.dart';

class GestionResenasScreen extends StatefulWidget {
  const GestionResenasScreen({super.key});

  @override
  State<GestionResenasScreen> createState() => _GestionResenasScreenState();
}

class _GestionResenasScreenState extends State<GestionResenasScreen> {
  // ✅ PALETA NARANJA CÁLIDO
  static const Color naranjaPrincipal = Color(0xFFF9A15E);
  static const Color crema = Color(0xFFFFFBF2);
  static const Color naranjaIntenso = Color(0xFFFF7043);
  static const Color textoOscuro = Color(0xFF2D2D2D);
  static const Color textoSuave = Color(0xFF7D6E66);

  List<dynamic> _resenas = [];
  bool _cargando = true;

  @override
  void initState() {
    super.initState();
    _cargarResenas();
  }

  Future<void> _cargarResenas() async {
    setState(() => _cargando = true);
    try {
      final res = await ResenaService.obtenerTodasAdmin();
      setState(() { _resenas = res; _cargando = false; });
    } catch (e) {
      setState(() => _cargando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: crema,
      appBar: AppBar(
        backgroundColor: naranjaPrincipal,
        foregroundColor: Colors.white,
        title: const Text('GESTIÓN DE RESEÑAS', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        centerTitle: true,
      ),
      body: _cargando 
          ? const Center(child: CircularProgressIndicator(color: naranjaPrincipal))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _resenas.length,
              itemBuilder: (context, index) {
                final r = _resenas[index];
                final bool pendiente = r['estado'] == 'pendiente';
                return Card(
                  color: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  margin: const EdgeInsets.only(bottom: 12),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(r['usuario']?['nombre_usuario'] ?? 'Cliente', style: const TextStyle(fontWeight: FontWeight.bold)),
                            Text('⭐ ${r['calificacion']}', style: const TextStyle(color: naranjaIntenso, fontWeight: FontWeight.bold)),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(r['comentario'] ?? 'Sin comentario', style: const TextStyle(color: textoSuave, fontSize: 14)),
                        if (pendiente) ...[
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: ElevatedButton(
                                  onPressed: () => _aprobar(r['id']),
                                  style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                                  child: const Text('APROBAR', style: TextStyle(color: Colors.white)),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: ElevatedButton(
                                  onPressed: () => _rechazar(r['id']),
                                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                                  child: const Text('RECHAZAR', style: TextStyle(color: Colors.white)),
                                ),
                              ),
                            ],
                          )
                        ],
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }

  Future<void> _aprobar(int id) async {
    try { await ResenaService.actualizarEstado(id, 'aprobada'); _cargarResenas(); } catch (_) {}
  }

  Future<void> _rechazar(int id) async {
    try { await ResenaService.actualizarEstado(id, 'rechazada'); _cargarResenas(); } catch (_) {}
  }
}
