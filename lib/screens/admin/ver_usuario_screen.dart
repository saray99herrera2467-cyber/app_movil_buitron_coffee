import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../services/api_service.dart';

class VerUsuariosScreen extends StatefulWidget {
  const VerUsuariosScreen({super.key});

  @override
  State<VerUsuariosScreen> createState() => _VerUsuariosScreenState();
}

class _VerUsuariosScreenState extends State<VerUsuariosScreen> {
  // ==========================================================
  // COLORES BUITRÓN COFFEE
  // ==========================================================
  static const Color cafePrincipal = Color(0xFF4E342E);
  static const Color cafeClaro = Color(0xFF795548);
  static const Color crema = Color(0xFFF5EFE6);
  static const Color cremaClaro = Color(0xFFFFFCF7);
  static const Color dorado = Color(0xFFC8A45D);
  static const Color textoOscuro = Color(0xFF3A2925);
  static const Color textoSuave = Color(0xFF756860);

  List<dynamic> _usuarios = [];
  bool _cargando = true;
  String? _error;
  String _filtro = 'todos'; // todos, admin, usuario

  @override
  void initState() {
    super.initState();
    _obtenerUsuarios();
  }

  Future<void> _obtenerUsuarios() async {
    setState(() {
      _cargando = true;
      _error = null;
    });
    try {
      final res = await ApiService.supabase
          .from(ApiService.tablaUsuarios)
          .select()
          .order('id', ascending: true);

      setState(() {
        _usuarios = res as List<dynamic>;
        _cargando = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Error al cargar los usuarios: $e';
        _cargando = false;
      });
    }
  }

  List<dynamic> get _usuariosFiltrados {
    if (_filtro == 'admin') {
      return _usuarios.where((u) => u['id_rol'] == 2).toList();
    } else if (_filtro == 'usuario') {
      return _usuarios.where((u) => u['id_rol'] == 1).toList();
    }
    return _usuarios;
  }

  int _contarRol(int rol) => _usuarios.where((u) => u['id_rol'] == rol).length;

  Color _colorRol(int? rol) {
    return rol == 2 ? dorado : cafeClaro;
  }

  String _textoRol(int? rol) {
    return rol == 2 ? 'Administrador' : 'Usuario';
  }

  Widget _estadisticaCard(String numero, String label, Color color) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: cremaClaro,
          borderRadius: BorderRadius.circular(10),
          border: Border(top: BorderSide(color: color, width: 3)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Text(numero, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: color)),
            const SizedBox(height: 4),
            Text(label, style: const TextStyle(fontSize: 11, color: textoSuave), textAlign: TextAlign.center),
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
        selectedColor: cafePrincipal,
        backgroundColor: cremaClaro,
        labelStyle: TextStyle(color: activo ? Colors.white : textoOscuro),
        onSelected: (_) => setState(() => _filtro = valor),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final totalAdmin = _contarRol(2);
    final totalUsuario = _contarRol(1);

    return Scaffold(
      backgroundColor: crema,
      appBar: AppBar(
        backgroundColor: cafePrincipal,
        foregroundColor: Colors.white,
        title: const Text('GESTIÓN DE USUARIOS', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        centerTitle: true,
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _obtenerUsuarios),
        ],
      ),
      body: _cargando
          ? const Center(child: CircularProgressIndicator(color: cafePrincipal))
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
              padding: const EdgeInsets.fromLTRB(12, 16, 12, 0),
              child: Row(
                children: [
                  _estadisticaCard('$totalAdmin', 'Admins', dorado),
                  _estadisticaCard('$totalUsuario', 'Usuarios', cafeClaro),
                  _estadisticaCard('${_usuarios.length}', 'Total', cafePrincipal),
                ],
              ),
            ),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
              child: Row(
                children: [
                  _chipFiltro('Todos', 'todos'),
                  _chipFiltro('Administradores', 'admin'),
                  _chipFiltro('Usuarios', 'usuario'),
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
                  final rol = usuario['id_rol'] as int?;
                  return Card(
                    color: cremaClaro,
                    margin: const EdgeInsets.only(bottom: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 2,
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
                                  '${usuario['nombre_usuario'] ?? ''} ${usuario['apellido'] ?? ''}',
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: cafePrincipal),
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: _colorRol(rol).withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  _textoRol(rol),
                                  style: TextStyle(color: _colorRol(rol), fontSize: 11, fontWeight: FontWeight.bold),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          _infoRow(Icons.mail_outline, usuario['correo'] ?? ''),
                          _infoRow(Icons.phone_outlined, usuario['telefono'] ?? 'Sin teléfono'),
                          _infoRow(Icons.location_on_outlined, usuario['direccion'] ?? 'Sin dirección'),
                          _infoRow(Icons.badge_outlined, 'Doc: ${usuario['documento'] ?? ''}'),
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

  Widget _infoRow(IconData icono, String texto) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Icon(icono, size: 16, color: dorado),
          const SizedBox(width: 8),
          Expanded(child: Text(texto, style: const TextStyle(fontSize: 13, color: textoOscuro))),
        ],
      ),
    );
  }
}
