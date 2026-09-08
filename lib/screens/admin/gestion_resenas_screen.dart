import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class GestionResenasScreen extends StatefulWidget {
  const GestionResenasScreen({super.key});

  @override
  State<GestionResenasScreen> createState() => _GestionResenasScreenState();
}

class _GestionResenasScreenState extends State<GestionResenasScreen> {
  static const String _baseUrl = 'http://localhost:3001/api/resenas';
  final colorRojo = const Color(0xFF9B1C2C);
  final colorFondo = const Color(0xFFF8F5F2);

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

  Future<String?> _token() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  Future<void> _obtenerResenas() async {
    setState(() {
      _cargando = true;
      _error = null;
    });
    try {
      final token = await _token();
      final res = await http.get(
        Uri.parse('$_baseUrl/admin'),
        headers: {'Authorization': 'Bearer $token'},
      );
      if (res.statusCode == 200) {
        setState(() {
          _resenas = jsonDecode(res.body);
          _cargando = false;
        });
      } else {
        setState(() {
          _error = 'Error al cargar las reseñas';
          _cargando = false;
        });
      }
    } catch (_) {
      setState(() {
        _error = 'Error al cargar las reseñas';
        _cargando = false;
      });
    }
  }

  Future<void> _actualizarEstado(int id, String estado) async {
    try {
      final token = await _token();
      final res = await http.patch(
        Uri.parse('$_baseUrl/admin/$id'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({'estado': estado}),
      );
      if (res.statusCode == 200) {
        setState(() {
          _exito = estado == 'aprobada'
              ? 'Reseña aprobada correctamente'
              : 'Reseña rechazada correctamente';
        });
        await _obtenerResenas();
        Future.delayed(const Duration(seconds: 3), () {
          if (mounted) setState(() => _exito = null);
        });
      } else {
        setState(() => _error = 'Error al actualizar la reseña');
      }
    } catch (_) {
      setState(() => _error = 'Error al actualizar la reseña');
    }
  }

  List<dynamic> get _resenasFiltradas {
    if (_filtro == 'todas') return _resenas;
    return _resenas.where((r) => r['estado'] == _filtro).toList();
  }

  int _contar(String estado) => _resenas.where((r) => r['estado'] == estado).length;

  Widget _chipFiltro(String label, String valor, int? conteo) {
    final activo = _filtro == valor;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(conteo != null ? '$label ($conteo)' : label),
        selected: activo,
        selectedColor: colorRojo,
        labelStyle: TextStyle(color: activo ? Colors.white : Colors.black87),
        onSelected: (_) => setState(() => _filtro = valor),
      ),
    );
  }

  Widget _estrellas(int calificacion) {
    return Row(
      children: List.generate(5, (i) {
        return Icon(
          i < calificacion ? Icons.star : Icons.star_border,
          size: 18,
          color: Colors.amber,
        );
      }),
    );
  }

  Color _colorEstado(String estado) {
    switch (estado) {
      case 'aprobada':
        return Colors.green;
      case 'rechazada':
        return Colors.red;
      default:
        return Colors.orange;
    }
  }

  String _textoEstado(String estado) {
    switch (estado) {
      case 'aprobada':
        return 'Aprobada';
      case 'rechazada':
        return 'Rechazada';
      default:
        return 'Pendiente';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: colorFondo,
      appBar: AppBar(
        backgroundColor: colorRojo,
        foregroundColor: Colors.white,
        title: const Text('Gestión de Reseñas'),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _obtenerResenas),
        ],
      ),
      body: _cargando
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
        onRefresh: _obtenerResenas,
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
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
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
                padding: const EdgeInsets.all(12),
                itemCount: _resenasFiltradas.length,
                itemBuilder: (context, index) {
                  final resena = _resenasFiltradas[index];
                  final estado = resena['estado'] as String? ?? 'pendiente';
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
                              Expanded(
                                child: Text(
                                  resena['producto_nombre'] ?? '',
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: _colorEstado(estado).withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  _textoEstado(estado),
                                  style: TextStyle(color: _colorEstado(estado), fontSize: 12, fontWeight: FontWeight.w600),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              const Icon(Icons.person, size: 16, color: Colors.black54),
                              const SizedBox(width: 4),
                              Text(resena['nombre_usuario'] ?? '', style: const TextStyle(color: Colors.black54, fontSize: 13)),
                            ],
                          ),
                          const SizedBox(height: 6),
                          _estrellas(resena['calificacion'] ?? 0),
                          const SizedBox(height: 6),
                          Text(resena['comentario'] ?? '', style: const TextStyle(fontSize: 14)),
                          const SizedBox(height: 6),
                          Text(
                            '📅 ${resena['fecha'] ?? ''}',
                            style: const TextStyle(fontSize: 12, color: Colors.black45),
                          ),
                          if (estado == 'pendiente') ...[
                            const SizedBox(height: 10),
                            Row(
                              children: [
                                Expanded(
                                  child: ElevatedButton.icon(
                                    style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                                    onPressed: () => _actualizarEstado(resena['id'], 'aprobada'),
                                    icon: const Icon(Icons.check, size: 18, color: Colors.white),
                                    label: const Text('Aprobar', style: TextStyle(color: Colors.white)),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: ElevatedButton.icon(
                                    style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                                    onPressed: () => _actualizarEstado(resena['id'], 'rechazada'),
                                    icon: const Icon(Icons.close, size: 18, color: Colors.white),
                                    label: const Text('Rechazar', style: TextStyle(color: Colors.white)),
                                  ),
                                ),
                              ],
                            ),
                          ],
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