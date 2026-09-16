import 'package:flutter/material.dart';
import '../../services/auth_service.dart';

class VerUsuariosScreen extends StatefulWidget {
  const VerUsuariosScreen({super.key});

  @override
  State<VerUsuariosScreen> createState() => _VerUsuariosScreenState();
}

class _VerUsuariosScreenState extends State<VerUsuariosScreen> {
  // ✅ PALETA NARANJA CÁLIDO
  static const Color naranjaPrincipal = Color(0xFFF9A15E);
  static const Color crema = Color(0xFFFFFBF2);
  static const Color naranjaIntenso = Color(0xFFFF7043);
  static const Color textoOscuro = Color(0xFF2D2D2D);
  static const Color textoSuave = Color(0xFF7D6E66);

  List<dynamic> _usuarios = [];
  bool _cargando = true;
  String? _error;
  String _filtro = 'todos';

  @override
  void initState() {
    super.initState();
    _obtenerUsuarios();
  }

  Future<void> _obtenerUsuarios() async {
    setState(() { _cargando = true; _error = null; });
    try {
      final res = await AuthService.obtenerTodosUsuarios();
      setState(() { _usuarios = res; _cargando = false; });
    } catch (e) {
      setState(() { _error = 'Error al cargar usuarios: $e'; _cargando = false; });
    }
  }

  List<dynamic> get _usuariosFiltrados {
    if (_filtro == 'admin') return _usuarios.where((u) => u['id_rol'] == 2).toList();
    if (_filtro == 'usuario') return _usuarios.where((u) => u['id_rol'] == 1).toList();
    return _usuarios;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: crema,
      appBar: AppBar(
        backgroundColor: naranjaPrincipal,
        foregroundColor: Colors.white,
        title: const Text('GESTIÓN DE USUARIOS', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        centerTitle: true,
        actions: [IconButton(icon: const Icon(Icons.refresh), onPressed: _obtenerUsuarios)],
      ),
      body: _cargando 
          ? const Center(child: CircularProgressIndicator(color: naranjaPrincipal))
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      _chipFiltro('Todos', 'todos'),
                      _chipFiltro('Admins', 'admin'),
                      _chipFiltro('Clientes', 'usuario'),
                    ],
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: _usuariosFiltrados.length,
                    itemBuilder: (context, index) {
                      final u = _usuariosFiltrados[index];
                      final bool esAdmin = u['id_rol'] == 2;
                      return Card(
                        color: Colors.white,
                        elevation: 1,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                        margin: const EdgeInsets.only(bottom: 12),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: esAdmin ? naranjaIntenso : naranjaPrincipal.withValues(alpha: 0.1),
                            child: Icon(esAdmin ? Icons.admin_panel_settings : Icons.person, color: esAdmin ? Colors.white : naranjaPrincipal),
                          ),
                          title: Text('${u['nombre_usuario'] ?? ''} ${u['apellido'] ?? ''}', style: const TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Text(u['correo'] ?? ''),
                          trailing: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(color: (esAdmin ? naranjaIntenso : Colors.grey).withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
                            child: Text(esAdmin ? 'ADMIN' : 'CLIENTE', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: esAdmin ? naranjaIntenso : Colors.grey)),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
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
        selectedColor: naranjaPrincipal,
        onSelected: (_) => setState(() => _filtro = valor),
        labelStyle: TextStyle(color: activo ? Colors.white : textoOscuro, fontSize: 12),
      ),
    );
  }
}
