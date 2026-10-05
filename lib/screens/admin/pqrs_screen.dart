import 'package:flutter/material.dart';
import '../../services/pqrs_service.dart';

class AdminPqrsScreen extends StatefulWidget {
  const AdminPqrsScreen({super.key});

  @override
  State<AdminPqrsScreen> createState() => _AdminPqrsScreenState();
}

class _AdminPqrsScreenState extends State<AdminPqrsScreen> {
  // ✅ PALETA NARANJA CÁLIDO
  static const Color cafePrincipal = Color(0xFFF9A15E);
  static const Color cafeClaro = Color(0xFFFF7043);
  static const Color crema = Color(0xFFFFFBF2);
  static const Color cremaClaro = Color(0xFFFFFFFF);
  static const Color dorado = Color(0xFFFFAB40);
  static const Color textoSuave = Color(0xFF7D6E66);

  String filtroEstado = 'todos';
  String busqueda = '';
  bool _cargando = true;
  List<Map<String, dynamic>> pqrs = [];

  final TextEditingController _buscarController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _cargarPqrs();
  }

  @override
  void dispose() {
    _buscarController.dispose();
    super.dispose();
  }

  Future<void> _cargarPqrs() async {
    setState(() => _cargando = true);
    try {
      final res = await PqrsService.obtenerTodas();
      if (!mounted) return;
      setState(() {
        pqrs = List<Map<String, dynamic>>.from(res);
        _cargando = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _cargando = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al cargar PQRS: $e')),
      );
    }
  }

  Future<void> _actualizarRespuesta(
      String codigoRef, String nuevoEstado, String respuesta) async {
    try {
      await PqrsService.actualizarRespuesta(codigoRef, nuevoEstado, respuesta);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('PQRS actualizada')),
      );
      await _cargarPqrs();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al actualizar: $e')),
      );
    }
  }

  List<Map<String, dynamic>> get pqrsFiltradas {
    return pqrs.where((item) {
      final coincideEstado = filtroEstado == 'todos' ||
          item['estado'].toString().toLowerCase() == filtroEstado.toLowerCase();

      final texto = busqueda.toLowerCase();

      final coincideBusqueda =
          (item['nombre'] ?? '').toString().toLowerCase().contains(texto) ||
              (item['descripcion'] ?? '').toString().toLowerCase().contains(texto) ||
              (item['codigo_referencia'] ?? '').toString().toLowerCase().contains(texto);

      return coincideEstado && coincideBusqueda;
    }).toList();
  }

  Color colorEstado(String estado) {
    switch (estado.toLowerCase()) {
      case 'pendiente':
        return Colors.orange;
      case 'en proceso':
        return Colors.blue;
      case 'respondido':
        return Colors.teal;
      case 'resuelta':
        return Colors.green;
      case 'cerrada':
        return Colors.grey;
      default:
        return Colors.grey;
    }
  }

  IconData iconoEstado(String estado) {
    switch (estado.toLowerCase()) {
      case 'pendiente':
        return Icons.pending_actions;
      case 'en proceso':
        return Icons.autorenew;
      case 'respondido':
        return Icons.mark_email_read;
      case 'resuelta':
        return Icons.check_circle;
      case 'cerrada':
        return Icons.lock_outline;
      default:
        return Icons.help_outline;
    }
  }

  Future<void> mostrarDetalle(Map<String, dynamic> pqrsItem) async {
    // El diálogo maneja su propio controller y devuelve el resultado.
    final resultado = await showDialog<Map<String, String>>(
      context: context,
      builder: (_) => _DetalleDialog(pqrsItem: pqrsItem),
    );

    if (resultado != null && mounted) {
      await _actualizarRespuesta(
        pqrsItem['codigo_referencia'],
        resultado['estado']!,
        resultado['respuesta']!,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final lista = pqrsFiltradas;

    return Scaffold(
      backgroundColor: crema,
      appBar: AppBar(
        title: const Text('GESTIÓN DE PQRS',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        backgroundColor: cafePrincipal,
        foregroundColor: Colors.white,
        centerTitle: true,
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _cargarPqrs),
        ],
      ),
      body: _cargando
          ? const Center(child: CircularProgressIndicator(color: cafePrincipal))
          : Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // BUSCADOR
            TextField(
              controller: _buscarController,
              decoration: InputDecoration(
                hintText: 'Buscar por nombre o radicado...',
                prefixIcon: const Icon(Icons.search, color: cafePrincipal),
                filled: true,
                fillColor: cremaClaro,
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none),
                focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide:
                    const BorderSide(color: Color(0xFFFF7043), width: 2)),
              ),
              onChanged: (valor) => setState(() => busqueda = valor),
            ),
            const SizedBox(height: 15),
            // FILTRO
            DropdownButtonFormField<String>(
              initialValue: filtroEstado,
              decoration: InputDecoration(
                labelText: 'Filtrar por estado',
                filled: true,
                fillColor: cremaClaro,
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none),
              ),
              items: const [
                DropdownMenuItem(value: 'todos', child: Text('Todos')),
                DropdownMenuItem(value: 'pendiente', child: Text('Pendientes')),
                DropdownMenuItem(value: 'en proceso', child: Text('En proceso')),
                DropdownMenuItem(value: 'respondido', child: Text('Respondidas')),
                DropdownMenuItem(value: 'resuelta', child: Text('Resueltas')),
                DropdownMenuItem(value: 'cerrada', child: Text('Cerradas')),
              ],
              onChanged: (valor) => setState(() => filtroEstado = valor!),
            ),
            const SizedBox(height: 20),
            Text('${lista.length} PQRS encontradas',
                style: const TextStyle(
                    fontWeight: FontWeight.bold, color: cafePrincipal)),
            const SizedBox(height: 10),
            Expanded(
              child: RefreshIndicator(
                onRefresh: _cargarPqrs,
                color: cafePrincipal,
                child: lista.isEmpty
                    ? ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  children: const [
                    SizedBox(height: 80),
                    Center(child: Text('No hay PQRS para mostrar')),
                  ],
                )
                    : ListView.builder(
                  physics: const AlwaysScrollableScrollPhysics(),
                  itemCount: lista.length,
                  itemBuilder: (context, index) {
                    final item = lista[index];
                    final estadoActual = item['estado'] ?? 'pendiente';
                    final color = colorEstado(estadoActual);
                    return Card(
                      color: cremaClaro,
                      margin: const EdgeInsets.only(bottom: 12),
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(15),
                        title: Text(item['asunto'] ?? 'Sin asunto',
                            style: const TextStyle(
                                fontWeight: FontWeight.bold)),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(item['nombre'] ?? '',
                                style: const TextStyle(color: textoSuave)),
                            const SizedBox(height: 4),
                            Text('Ref: ${item['codigo_referencia'] ?? ''}',
                                style: const TextStyle(fontSize: 12)),
                          ],
                        ),
                        trailing: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                              color: color.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(20)),
                          child: Text(estadoActual.toString().toUpperCase(),
                              style: TextStyle(
                                  color: color,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 11)),
                        ),
                        onTap: () => mostrarDetalle(item),
                      ),
                    );
                  },
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
// DIÁLOGO DE DETALLE (maneja su propio controller)
// ============================================================
class _DetalleDialog extends StatefulWidget {
  final Map<String, dynamic> pqrsItem;

  const _DetalleDialog({required this.pqrsItem});

  @override
  State<_DetalleDialog> createState() => _DetalleDialogState();
}

class _DetalleDialogState extends State<_DetalleDialog> {
  static const Color cafePrincipal = Color(0xFFF9A15E);
  static const Color cremaClaro = Color(0xFFFFFFFF);
  static const Color textoSuave = Color(0xFF7D6E66);

  static const List<String> _estados = [
    'pendiente',
    'en proceso',
    'respondido',
    'resuelta',
    'cerrada',
  ];

  late String _estadoOriginal;
  late String _estadoActual;
  late String _respuestaOriginal;
  late final TextEditingController _respuestaCtrl;

  @override
  void initState() {
    super.initState();
    final estado = (widget.pqrsItem['estado'] ?? 'pendiente').toString().toLowerCase();
    _estadoOriginal = _estados.contains(estado) ? estado : 'pendiente';
    _estadoActual = _estadoOriginal;
    _respuestaOriginal = (widget.pqrsItem['respuesta'] ?? '').toString();
    _respuestaCtrl = TextEditingController(text: _respuestaOriginal);
  }

  /// Si el admin escribió una respuesta nueva y no cambió el estado a mano,
  /// el estado pasa automáticamente a "respondido".
  String _calcularEstadoFinal(String respuesta) {
    final hayRespuestaNueva =
        respuesta.isNotEmpty && respuesta != _respuestaOriginal.trim();
    final estadoCambiadoManual = _estadoActual != _estadoOriginal;

    if (hayRespuestaNueva && !estadoCambiadoManual) {
      return 'respondido';
    }
    return _estadoActual;
  }

  @override
  void dispose() {
    // Se destruye cuando el diálogo ya salió completamente del árbol.
    _respuestaCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final item = widget.pqrsItem;

    return AlertDialog(
      backgroundColor: cremaClaro,
      title: Row(
        children: [
          const Icon(Icons.assignment, color: cafePrincipal),
          const SizedBox(width: 10),
          Expanded(
            child: Text('Radicado: ${item['codigo_referencia']}',
                style: const TextStyle(fontSize: 14)),
          ),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(item['nombre'] ?? 'Sin nombre',
                style: const TextStyle(
                    fontSize: 18, fontWeight: FontWeight.bold, color: cafePrincipal)),
            const SizedBox(height: 4),
            Text(item['email'] ?? '',
                style: const TextStyle(fontSize: 13, color: textoSuave)),
            const SizedBox(height: 10),
            Text('Tipo: ${(item['tipo'] ?? '').toString().toUpperCase()}',
                style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFFF7043),
                    fontSize: 12)),
            const SizedBox(height: 15),
            const Text('Descripción:', style: TextStyle(fontWeight: FontWeight.bold)),
            Text(item['descripcion'] ?? ''),
            const SizedBox(height: 20),
            const Text('Cambiar Estado:',
                style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              initialValue: _estadoActual,
              decoration: const InputDecoration(border: OutlineInputBorder()),
              items: const [
                DropdownMenuItem(value: 'pendiente', child: Text('Pendiente')),
                DropdownMenuItem(value: 'en proceso', child: Text('En proceso')),
                DropdownMenuItem(value: 'respondido', child: Text('Respondido')),
                DropdownMenuItem(value: 'resuelta', child: Text('Resuelta')),
                DropdownMenuItem(value: 'cerrada', child: Text('Cerrada')),
              ],
              onChanged: (valor) {
                if (valor != null) {
                  setState(() => _estadoActual = valor);
                }
              },
            ),
            const SizedBox(height: 20),
            const Text('Respuesta del Administrador:',
                style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            TextField(
              controller: _respuestaCtrl,
              maxLines: 4,
              decoration: const InputDecoration(
                hintText: 'Escribe aquí la respuesta...',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cerrar', style: TextStyle(color: cafePrincipal)),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
              backgroundColor: cafePrincipal, foregroundColor: Colors.white),
          onPressed: () {
            final respuesta = _respuestaCtrl.text.trim();
            Navigator.pop(context, {
              'estado': _calcularEstadoFinal(respuesta),
              'respuesta': respuesta,
            });
          },
          child: const Text('Guardar'),
        ),
      ],
    );
  }
}