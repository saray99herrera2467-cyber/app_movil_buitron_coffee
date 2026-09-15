import 'package:flutter/material.dart';
import '../../services/resena_service.dart';

class GestionResenasScreen extends StatefulWidget {
  const GestionResenasScreen({super.key});

  @override
  State<GestionResenasScreen> createState() => _GestionResenasScreenState();
}

class _GestionResenasScreenState extends State<GestionResenasScreen> {
  static const Color cafePrincipal = Color(0xFF4E342E);
  static const Color cafeClaro = Color(0xFF795548);
  static const Color crema = Color(0xFFF5EFE6);
  static const Color cremaClaro = Color(0xFFFFFCF7);
  static const Color dorado = Color(0xFFC8A45D);
  static const Color textoOscuro = Color(0xFF3A2925);
  static const Color textoSuave = Color(0xFF756860);

  List<dynamic> _resenas = [];
  bool _cargando = true;
  String? _error;
  String? _exito;
  String _filtro = 'todas';

  @override
  void initState() {
    super.initState();
    _obtenerResenas();
  }

  Future<void> _obtenerResenas() async {
    setState(() {
      _cargando = true;
      _error = null;
    });
    try {
      final res = await ResenaService.obtenerTodasAdmin();
      if (!mounted) return;
      setState(() {
        _resenas = res;
        _cargando = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = 'Error al cargar las reseñas: $e';
        _cargando = false;
      });
    }
  }

  Future<void> _actualizarEstado(int id, String estado) async {
    try {
      await ResenaService.actualizarEstado(id, estado);
      if (!mounted) return;
      setState(() {
        _exito = estado == 'aprobada'
            ? 'Reseña aprobada correctamente'
            : 'Reseña rechazada correctamente';
      });
      await _obtenerResenas();
      Future.delayed(const Duration(seconds: 3), () {
        if (mounted) setState(() => _exito = null);
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = 'Error al actualizar: $e');
    }
  }

  List<dynamic> get _resenasFiltradas {
    if (_filtro == 'todas') return _resenas;
    return _resenas.where((r) => r['estado'].toString().toLowerCase() == _filtro).toList();
  }

  int _contar(String estado) => _resenas.where((r) => r['estado'].toString().toLowerCase() == estado.toLowerCase()).length;

  Widget _chipFiltro(String label, String valor, int? conteo) {
    final activo = _filtro == valor;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(conteo != null ? '$label ($conteo)' : label),
        selected: activo,
        selectedColor: cafePrincipal,
        backgroundColor: cremaClaro,
        labelStyle: TextStyle(color: activo ? Colors.white : textoOscuro),
        onSelected: (_) => setState(() => _filtro = valor),
      ),
    );
  }

  Widget _estrellas(int calificacion) {
    return Row(
      children: List.generate(5, (i) {
        return Icon(
          i < calificacion ? Icons.star : Icons.star_border,
          size: 20,
          color: dorado,
        );
      }),
    );
  }

  Color _colorEstado(String estado) {
    switch (estado.toLowerCase()) {
      case 'aprobada':
        return Colors.green;
      case 'rechazada':
        return Colors.red;
      default:
        return Colors.orange;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: crema,
      appBar: AppBar(
        backgroundColor: cafePrincipal,
        foregroundColor: Colors.white,
        title: const Text('GESTIÓN DE RESEÑAS', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        centerTitle: true,
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _obtenerResenas),
        ],
      ),
      body: _cargando
          ? const Center(child: CircularProgressIndicator(color: cafePrincipal))
          : RefreshIndicator(
        onRefresh: _obtenerResenas,
        child: Column(
          children: [
            if (_error != null)
              Container(width: double.infinity, color: Colors.red.shade100, padding: const EdgeInsets.all(10), child: Text(_error!, style: const TextStyle(color: Colors.red))),
            if (_exito != null)
              Container(width: double.infinity, color: Colors.green.shade100, padding: const EdgeInsets.all(10), child: Text(_exito!, style: const TextStyle(color: Colors.green))),
            
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
              child: Row(
                children: [
                  _chipFiltro('Todas', 'todas', _resenas.length),
                  _chipFiltro('Pendientes', 'pendiente', _contar('pendiente')),
                  _chipFiltro('Aprobadas', 'aprobada', _contar('aprobada')),
                  _chipFiltro('Rechazadas', 'rechazada', _contar('rechazada')),
                ],
              ),
            ),
            
            Expanded(
              child: _resenasFiltradas.isEmpty
                  ? const Center(child: Text('No hay reseñas para mostrar'))
                  : ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                itemCount: _resenasFiltradas.length,
                itemBuilder: (context, index) {
                  final resena = _resenasFiltradas[index];
                  final estado = resena['estado'] as String? ?? 'pendiente';
                  
                  final rawProducto = resena['producto'];
                  final producto = rawProducto is List && rawProducto.isNotEmpty 
                      ? rawProducto[0] 
                      : (rawProducto is Map ? rawProducto : null);
                      
                  final rawUsuario = resena['usuario'];
                  final usuario = rawUsuario is List && rawUsuario.isNotEmpty 
                      ? rawUsuario[0] 
                      : (rawUsuario is Map ? rawUsuario : null);

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
                              Expanded(
                                child: Text(
                                  producto?['nombre_producto'] ?? producto?['nombre'] ?? 'Producto no encontrado',
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: cafePrincipal),
                                ),
                              ),
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
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              const Icon(Icons.person, size: 16, color: dorado),
                              const SizedBox(width: 6),
                              Text(
                                usuario?['nombre_usuario'] ?? resena['nombre_usuario'] ?? 'Anónimo', 
                                style: const TextStyle(color: textoSuave, fontSize: 13, fontWeight: FontWeight.bold)
                              ),
                            ],
                          ),
                          const Divider(height: 25),
                          _estrellas(resena['calificacion'] ?? 0),
                          const SizedBox(height: 10),
                          Text(resena['comentario'] ?? 'Sin comentario', style: const TextStyle(fontSize: 14, color: textoOscuro)),
                          const SizedBox(height: 15),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '📅 ${resena['fecha'] ?? ''}',
                                style: const TextStyle(fontSize: 12, color: cafeClaro),
                              ),
                              if (estado.toLowerCase() == 'pendiente')
                                Row(
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.check_circle, color: Colors.green, size: 30),
                                      onPressed: () => _actualizarEstado(resena['id'], 'aprobada'),
                                      tooltip: 'Aprobar',
                                    ),
                                    const SizedBox(width: 8),
                                    IconButton(
                                      icon: const Icon(Icons.cancel, color: Colors.red, size: 30),
                                      onPressed: () => _actualizarEstado(resena['id'], 'rechazada'),
                                      tooltip: 'Rechazar',
                                    ),
                                  ],
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
