import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class VerUsuariosScreen extends StatefulWidget {
  const VerUsuariosScreen({super.key});

  @override
  State<VerUsuariosScreen> createState() => _VerUsuariosScreenState();
}

class _VerUsuariosScreenState extends State<VerUsuariosScreen> {
  static const String _baseUrl = 'http://localhost:3001/api/auth/usuarios';
  final colorRojo = const Color(0xFF9B1C2C);
  final colorFondo = const Color(0xFFF8F5F2);

  List<dynamic> _usuarios = [];
  bool _cargando = true;
  String? _error;
  String _filtro = 'todos'; // todos, admin, usuario, proveedor

  @override
  void initState() {
    super.initState();
    _obtenerUsuarios();
  }

  Future<String?> _token() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  Future<void> _obtenerUsuarios() async {
    setState(() {
      _cargando = true;
      _error = null;
    });
    try {
      final token = await _token();
      final res = await http.get(
        Uri.parse(_baseUrl),
        headers: {'Authorization': 'Bearer $token'},
      );
      if (res.statusCode == 200) {
        setState(() {
          _usuarios = jsonDecode(res.body);
          _cargando = false;
        });
      } else {
        setState(() {
          _error = 'Error al cargar los usuarios';
          _cargando = false;
        });
      }
    } catch (_) {
      setState(() {
        _error = 'Error al cargar los usuarios';
        _cargando = false;
      });
    }
  }

  List<dynamic> get _usuariosFiltrados {
    switch (_filtro) {
      case 'admin':
        return _usuarios.where((u) => u['ID_Rol'] == 1).toList();
      case 'usuario':
        return _usuarios.where((u) => u['ID_Rol'] == 2).toList();
      case 'proveedor':
        return _usuarios.where((u) => u['ID_Rol'] == 3).toList();
      default:
        return _usuarios;
    }
  }

  int _contarRol(int rol) => _usuarios.where((u) => u['ID_Rol'] == rol).length;

  Color _colorRol(int? rol) {
    switch (rol) {
      case 1:
        return const Color(0xFF9B1C2C);
      case 2:
        return Colors.blue;
      case 3:
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  String _textoRol(int? rol) {
    switch (rol) {
      case 1:
        return 'Administrador';
      case 2:
        return 'Usuario';
      case 3:
        return 'Proveedor';
      default:
        return '${rol ?? ''}';
    }
  }

  Widget _estadisticaCard(String numero, String label, Color color) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border(top: BorderSide(color: color, width: 3)),
        ),
        child: Column(
          children: [
            Text(numero, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: color)),
            const SizedBox(height: 4),
            Text(label, style: const TextStyle(fontSize: 11, color: Colors.black54), textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }

  Widget _chipFiltro(String label, String valor) {
    final activo = _filtro == valor;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(label),
        selected: activo,
        selectedColor: colorRojo,
        labelStyle: TextStyle(color: activo ? Colors.white : Colors.black87),
        onSelected: (_) => setState(() => _filtro = valor),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final totalAdmin = _contarRol(1);
    final totalUsuario = _contarRol(2);
    final totalProveedor = _contarRol(3);

    return Scaffold(
      backgroundColor: colorFondo,
      appBar: AppBar(
        backgroundColor: colorRojo,
        foregroundColor: Colors.white,
        title: const Text('Lista de Usuarios'),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _obtenerUsuarios),
        ],
      ),
      body: _cargando
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
        onRefresh: _obtenerUsuarios,
        child: Column(
          children: [
            if (_error != null)
              Container(
                width: double.infinity,
                color: Colors.red.shade100,
                padding: const EdgeInsets.all(10),
                child: Text(_error!, style: const TextStyle(color: Colors.red)),
              ),
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 12, 8, 0),
              child: Row(
                children: [
                  _estadisticaCard('$totalAdmin', 'Administradores', colorRojo),
                  _estadisticaCard('$totalUsuario', 'Usuarios', Colors.blue),
                  _estadisticaCard('$totalProveedor', 'Proveedores', Colors.green),
                  _estadisticaCard('${_usuarios.length}', 'Total', Colors.black87),
                ],
              ),
            ),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              child: Row(
                children: [
                  _chipFiltro('Todos', 'todos'),
                  _chipFiltro('Administradores', 'admin'),
                  _chipFiltro('Usuarios', 'usuario'),
                  _chipFiltro('Proveedores', 'proveedor'),
                ],
              ),
            ),
            Expanded(
              child: _usuariosFiltrados.isEmpty
                  ? const Center(child: Text('No hay usuarios para mostrar'))
                  : ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                itemCount: _usuariosFiltrados.length,
                itemBuilder: (context, index) {
                  final usuario = _usuariosFiltrados[index];
                  final rol = usuario['ID_Rol'] as int?;
                  return Card(
                    margin: const EdgeInsets.only(bottom: 10),
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
                                  '${usuario['Nombre_usuario'] ?? ''} ${usuario['Apellido'] ?? ''}',
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: _colorRol(rol).withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  _textoRol(rol),
                                  style: TextStyle(color: _colorRol(rol), fontSize: 12, fontWeight: FontWeight.w600),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              const Icon(Icons.badge_outlined, size: 16, color: Colors.black45),
                              const SizedBox(width: 6),
                              Text('ID: ${usuario['ID_Usuario'] ?? ''}', style: const TextStyle(fontSize: 13, color: Colors.black54)),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              const Icon(Icons.mail_outline, size: 16, color: Colors.black45),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(usuario['Correo'] ?? '', style: const TextStyle(fontSize: 13, color: Colors.black54)),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              const Icon(Icons.description_outlined, size: 16, color: Colors.black45),
                              const SizedBox(width: 6),
                              Text('Doc: ${usuario['Documento'] ?? ''}', style: const TextStyle(fontSize: 13, color: Colors.black54)),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              const Icon(Icons.phone_outlined, size: 16, color: Colors.black45),
                              const SizedBox(width: 6),
                              Text(usuario['Telefono'] ?? '', style: const TextStyle(fontSize: 13, color: Colors.black54)),
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