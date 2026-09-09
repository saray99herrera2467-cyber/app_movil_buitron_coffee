import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/auth_service.dart';
import 'pagos_screen.dart';
const Color cafePrincipal = Color(0xFF4E342E);
const Color crema = Color(0xFFF5EFE6);
const Color cremaClaro = Color(0xFFFFFCF7);
const Color dorado = Color(0xFFC8A45D);

class PagoDatosScreen extends StatefulWidget {
  final double total;
  final List<Map<String, dynamic>> items;

  const PagoDatosScreen({
    super.key,
    required this.total,
    required this.items,
  });

  @override
  State<PagoDatosScreen> createState() => _PagoDatosScreenState();
}

class _PagoDatosScreenState extends State<PagoDatosScreen> {
  final _correoController = TextEditingController();
  final _nombreController = TextEditingController();
  final _telefonoController = TextEditingController();
  final _direccionController = TextEditingController();
  bool _cargando = true;

  @override
  void initState() {
    super.initState();
    _cargarDatos();
  }

  Future<void> _cargarDatos() async {
    final correo = await AuthService.obtenerCorreoSesion();
    if (correo != null) {
      _correoController.text = correo;

      try {
        final datos = await Supabase.instance.client
            .from('usuario')
            .select()
            .eq('correo', correo)
            .maybeSingle();

        if (datos != null) {
          setState(() {
            _nombreController.text = '${datos['nombre_usuario'] ?? ''} ${datos['apellido'] ?? ''}'.trim();
            _telefonoController.text = datos['telefono'] ?? '';
            _direccionController.text = datos['direccion'] ?? '';
          });
        }
      } catch (_) {}
    }
    setState(() => _cargando = false);
  }

  void _continuar() {
    if (_correoController.text.trim().isEmpty ||
        _nombreController.text.trim().isEmpty ||
        _direccionController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('❌ Completa todos los datos')),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PagosScreen(
          total: widget.total,
          items: widget.items,
          correo: _correoController.text.trim(),
          nombreCompleto: _nombreController.text.trim(),
          telefono: _telefonoController.text.trim(),
          direccion: _direccionController.text.trim(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: crema,
      appBar: AppBar(
        backgroundColor: cafePrincipal,
        centerTitle: true,
        title: const Text('DATOS DE ENVÍO', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
        leading: IconButton(icon: const Icon(Icons.arrow_back, color: Colors.white), onPressed: () => Navigator.pop(context)),
      ),
      body: _cargando
          ? const Center(child: CircularProgressIndicator(color: cafePrincipal))
          : SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Ingresa tu correo electrónico', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: cafePrincipal)),
            const SizedBox(height: 6),
            const Text('Utilizaremos tus datos para procesar el envío de tu pedido.', style: TextStyle(fontSize: 12, color: Colors.grey)),
            const SizedBox(height: 20),

            _campoTexto(
              controller: _correoController,
              label: 'Correo electrónico',
              icono: Icons.email_outlined,
              habilitado: false,
            ),
            const SizedBox(height: 24),

            const Text('Tus datos personales', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: cafePrincipal)),
            const SizedBox(height: 16),
            _campoTexto(
              controller: _nombreController,
              label: 'Nombre completo',
              icono: Icons.person_outline,
            ),
            const SizedBox(height: 16),
            _campoTexto(
              controller: _telefonoController,
              label: 'Teléfono',
              icono: Icons.phone_outlined,
              tipo: TextInputType.phone,
            ),
            const SizedBox(height: 24),

            const Text('Lugar de entrega', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: cafePrincipal)),
            const SizedBox(height: 16),
            _campoTexto(
              controller: _direccionController,
              label: 'Dirección completa',
              icono: Icons.location_on_outlined,
              maxLines: 2,
            ),
            const SizedBox(height: 35),

            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _continuar,
                style: ElevatedButton.styleFrom(
                  backgroundColor: cafePrincipal,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 2,
                ),
                child: const Text('CONTINUAR AL PAGO', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, letterSpacing: 1)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _campoTexto({
    required TextEditingController controller,
    required String label,
    required IconData icono,
    bool habilitado = true,
    int maxLines = 1,
    TextInputType tipo = TextInputType.text,
  }) {
    return TextField(
      controller: controller,
      enabled: habilitado,
      maxLines: maxLines,
      keyboardType: tipo,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icono, color: cafePrincipal),
        filled: true,
        fillColor: habilitado ? cremaClaro : const Color(0xFFE9E3DC),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: dorado, width: 2)),
      ),
    );
  }
}
