import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'pagos_screen.dart';

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
    final usuario = Supabase.instance.client.auth.currentUser;
    if (usuario != null) {
      _correoController.text = usuario.email ?? '';

      // Cargar datos desde la tabla usuario
      try {
        final datos = await Supabase.instance.client
            .from('usuario')
            .select()
            .eq('correo', usuario.email!)
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
        builder: (_) => PagoMetodoScreen(
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
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: const Color(0xFF9B1C2C),
        title: const Text('PAGO', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        leading: IconButton(icon: const Icon(Icons.arrow_back, color: Colors.white), onPressed: () => Navigator.pop(context)),
      ),
      body: _cargando
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF9B1C2C)))
          : SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Ingresa tu correo electrónico', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),
            const Text('Al ingresar utilizaremos tus datos para mejorar tu experiencia en nuestro sitio.', style: TextStyle(fontSize: 12, color: Colors.grey)),
            const SizedBox(height: 16),

            // 📧 CORREO
            TextField(
              controller: _correoController,
              decoration: InputDecoration(
                labelText: 'Correo',
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
            const SizedBox(height: 24),

            // 👤 NOMBRE
            const Text('Tus datos', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            TextField(
              controller: _nombreController,
              decoration: InputDecoration(
                labelText: 'Nombre completo',
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _telefonoController,
              keyboardType: TextInputType.phone,
              decoration: InputDecoration(
                labelText: 'Teléfono',
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
            const SizedBox(height: 24),

            // 🏠 DIRECCIÓN
            const Text('Dirección de envío', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            TextField(
              controller: _direccionController,
              maxLines: 2,
              decoration: InputDecoration(
                labelText: 'Dirección completa',
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
            const SizedBox(height: 32),

            // ✅ BOTÓN
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _continuar,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF9B1C2C),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: const Text('Continuar', style: TextStyle(fontSize: 16, color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}