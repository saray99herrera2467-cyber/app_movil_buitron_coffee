import 'package:flutter/material.dart';
import '../../services/pqrs_service.dart';

class AdminPqrsScreen extends StatefulWidget {
  const AdminPqrsScreen({super.key});

  @override
  State<AdminPqrsScreen> createState() => _AdminPqrsScreenState();
}

class _AdminPqrsScreenState extends State<AdminPqrsScreen> {
  static const Color cafePrincipal = Color(0xFF4E342E);
  static const Color cafeClaro = Color(0xFF795548);
  static const Color crema = Color(0xFFF5EFE6);
  static const Color cremaClaro = Color(0xFFFFFCF7);
  static const Color dorado = Color(0xFFC8A45D);
  static const Color textoSuave = Color(0xFF756860);

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
      if (mounted) {
        setState(() => _cargando = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al cargar PQRS: $e')),
        );
      }
    }
  }

  Future<void> _actualizarRespuesta(String codigoRef, String nuevoEstado, String respuesta) async {
    try {
      await PqrsService.actualizarRespuesta(codigoRef, nuevoEstado, respuesta);
      await _cargarPqrs();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al actualizar: $e')),
        );
      }
    }
  }

  @override
  void dispose() {
    _buscarController.dispose();
    super.dispose();
  }

  List<Map<String, dynamic>> get pqrsFiltradas {
    return pqrs.where((item) {
      final coincideEstado = filtroEstado == 'todos' ||
          item['estado'].toString() == filtroEstado;

      final texto = busqueda.toLowerCase();

      final coincideBusqueda =
          (item['nombre'] ?? '').toString().toLowerCase().contains(texto) ||
          (item['descripcion'] ?? '').toString().toLowerCase().contains(texto) ||
          (item['codigo_referencia'] ?? '').toString().toLowerCase().contains(texto);

      return coincideEstado && coincideBusqueda;
    }).toList();
  }

  Color colorEstado(String estado) {
    switch (estado.toUpperCase()) {
      case 'PENDIENTE': return Colors.orange;
      case 'EN PROCESO': return Colors.blue;
      case 'RESUELTA': return Colors.green;
      default: return Colors.grey;
    }
  }

  IconData iconoEstado(String estado) {
    switch (estado.toUpperCase()) {
      case 'PENDIENTE': return Icons.pending_actions;
      case 'EN PROCESO': return Icons.autorenew;
      case 'RESUELTA': return Icons.check_circle;
      default: return Icons.help_outline;
    }
  }

  void mostrarDetalle(Map<String, dynamic> pqrsItem) {
    String estadoActual = pqrsItem['estado'] ?? 'Pendiente';
    final TextEditingController respuestaCtrl = TextEditingController(text: pqrsItem['respuesta'] ?? '');

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: cremaClaro,
              title: Row(
                children: [
                  const Icon(Icons.assignment, color: cafePrincipal),
                  const SizedBox(width: 10),
                  Expanded(child: Text('Radicado: ${pqrsItem['codigo_referencia']}', style: const TextStyle(fontSize: 14))),
                ],
              ),
              content: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(pqrsItem['nombre'] ?? 'Sin nombre', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: cafePrincipal)),
                    const SizedBox(height: 4),
                    Text(pqrsItem['email'] ?? '', style: const TextStyle(fontSize: 13, color: textoSuave)),
                    const SizedBox(height: 15),
                    const Text('Descripción:', style: TextStyle(fontWeight: FontWeight.bold)),
                    Text(pqrsItem['descripcion'] ?? ''),
                    const SizedBox(height: 20),
                    const Text('Cambiar Estado:', style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
    DropdownButtonFormField<String>(
      initialValue: ['PENDIENTE', 'EN PROCESO', 'RESUELTA'].contains(estadoActual.toUpperCase()) 
          ? estadoActual.toUpperCase() 
          : 'PENDIENTE',
      decoration: const InputDecoration(border: OutlineInputBorder()),
      items: const [
        DropdownMenuItem(value: 'PENDIENTE', child: Text('Pendiente')),
        DropdownMenuItem(value: 'EN PROCESO', child: Text('En proceso')),
        DropdownMenuItem(value: 'RESUELTA', child: Text('Resuelta')),
      ],
      onChanged: (valor) {
        if (valor != null) {
          setDialogState(() {
            estadoActual = valor;
          });
        }
      },
    ),
                    const SizedBox(height: 20),
                    const Text('Respuesta del Administrador:', style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    TextField(
                      controller: respuestaCtrl,
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
                  onPressed: () {
                    respuestaCtrl.dispose();
                    Navigator.pop(context);
                  }, 
                  child: const Text('Cerrar', style: TextStyle(color: cafeClaro))
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: cafePrincipal, foregroundColor: Colors.white),
                  onPressed: () {
                    _actualizarRespuesta(
                      pqrsItem['codigo_referencia'], 
                      estadoActual, 
                      respuestaCtrl.text.trim()
                    );
                    respuestaCtrl.dispose();
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('PQRS actualizada')));
                  },
                  child: const Text('Guardar'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final lista = pqrsFiltradas;

    return Scaffold(
      backgroundColor: crema,
      appBar: AppBar(
        title: const Text('GESTIÓN DE PQRS', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
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
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: dorado, width: 2)),
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
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                    ),
                    items: const [
                      DropdownMenuItem(value: 'todos', child: Text('Todos')),
                      DropdownMenuItem(value: 'Pendiente', child: Text('Pendientes')),
                      DropdownMenuItem(value: 'En proceso', child: Text('En proceso')),
                      DropdownMenuItem(value: 'Resuelta', child: Text('Resueltas')),
                    ],
                    onChanged: (valor) => setState(() => filtroEstado = valor!),
                  ),
                  const SizedBox(height: 20),
                  Text('${lista.length} PQRS encontradas', style: const TextStyle(fontWeight: FontWeight.bold, color: cafePrincipal)),
                  const SizedBox(height: 10),
                  Expanded(
                    child: RefreshIndicator(
                      onRefresh: _cargarPqrs,
                      color: cafePrincipal,
                      child: lista.isEmpty
                          ? const Center(child: Text('No hay PQRS para mostrar'))
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
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                  child: ListTile(
                                    contentPadding: const EdgeInsets.all(15),
                                    title: Text(item['asunto'] ?? 'Sin asunto', style: const TextStyle(fontWeight: FontWeight.bold)),
                                    subtitle: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(item['nombre'] ?? '', style: const TextStyle(color: textoSuave)),
                                        const SizedBox(height: 4),
                                        Text('Ref: ${item['codigo_referencia'] ?? ''}', style: const TextStyle(fontSize: 12)),
                                      ],
                                    ),
                                    trailing: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                      decoration: BoxDecoration(color: color.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(20)),
                                      child: Text(estadoActual.toUpperCase(), style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 11)),
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
