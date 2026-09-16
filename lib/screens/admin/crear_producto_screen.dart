import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/producto.dart';
import '../../providers/producto_admin_provider.dart';

class CrearProductoScreen extends StatefulWidget {
  const CrearProductoScreen({super.key});

  @override
  State<CrearProductoScreen> createState() => _CrearProductoScreenState();
}

class _CrearProductoScreenState extends State<CrearProductoScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nombreCtrl = TextEditingController();
  final _descripcionCtrl = TextEditingController();
  final _precioCtrl = TextEditingController();
  final _stockCtrl = TextEditingController(text: '0');
  final _imagenCtrl = TextEditingController();
  final _categoriaCtrl = TextEditingController();

  bool _estado = true;
  bool _guardando = false;

  // ✅ PALETA NARANJA CÁLIDO
  static const Color naranjaPrincipal = Color(0xFFF9A15E);
  static const Color cafeClaro = Color(0xFFFF7043);
  static const Color cremaFondo = Color(0xFFFFFBF2);
  static const Color dorado = Color(0xFFFFAB40);

  @override
  void dispose() {
    _nombreCtrl.dispose();
    _descripcionCtrl.dispose();
    _precioCtrl.dispose();
    _stockCtrl.dispose();
    _imagenCtrl.dispose();
    _categoriaCtrl.dispose();
    super.dispose();
  }

  Future<void> _guardarProducto() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _guardando = true);

    try {
      final nuevoProducto = Producto(
        id: 0, 
        nombre: _nombreCtrl.text.trim(),
        descripcion: _descripcionCtrl.text.trim().isEmpty ? null : _descripcionCtrl.text.trim(),
        precio: double.parse(_precioCtrl.text.trim()),
        stock: int.tryParse(_stockCtrl.text.trim()) ?? 0, 
        imagen: _imagenCtrl.text.trim().isEmpty ? null : _imagenCtrl.text.trim(),
        categoria: _categoriaCtrl.text.trim(),
        estado: _estado,
      );

      final provider = context.read<ProductoAdminProvider>();
      final exito = await provider.crearProducto(nuevoProducto);

      if (!mounted) return;
      setState(() => _guardando = false);

      if (exito) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(backgroundColor: Colors.green, content: Text('Producto creado correctamente')),
        );
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(backgroundColor: Colors.red, content: Text(provider.error ?? 'Error al crear el producto')),
        );
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _guardando = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(backgroundColor: Colors.red, content: Text('Error: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: cremaFondo,
      appBar: AppBar(
        title: const Text('CREAR PRODUCTO', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, letterSpacing: 1)),
        backgroundColor: naranjaPrincipal,
        foregroundColor: Colors.white,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              const SizedBox(height: 10),
              _campoTexto(controller: _nombreCtrl, label: 'Nombre del producto', icono: Icons.coffee),
              const SizedBox(height: 16),
              _campoTexto(controller: _descripcionCtrl, label: 'Descripción (opcional)', icono: Icons.description, maxLines: 3),
              const SizedBox(height: 16),
              _campoTexto(
                controller: _precioCtrl, 
                label: 'Precio', 
                icono: Icons.attach_money,
                tipo: const TextInputType.numberWithOptions(decimal: true),
                prefix: '\$ ',
              ),
              const SizedBox(height: 16),
              _campoTexto(
                controller: _stockCtrl, 
                label: 'Stock disponible', 
                icono: Icons.inventory_2_outlined,
                tipo: TextInputType.number,
              ),
              const SizedBox(height: 16),
              _campoTexto(controller: _categoriaCtrl, label: 'Categoría (Grano / Molido)', icono: Icons.category),
              const SizedBox(height: 16),
              _campoTexto(
                controller: _imagenCtrl, 
                label: 'URL de la imagen', 
                icono: Icons.image,
                hint: 'Ej: cafe1.png',
              ),
              
              if (_imagenCtrl.text.trim().isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 15),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(15),
                    child: _construirImagenPreview(_imagenCtrl.text.trim()),
                  ),
                ),

              const SizedBox(height: 16),
              SwitchListTile(
                title: const Text('Producto activo', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF2D2D2D))),
                value: _estado,
                activeColor: dorado,
                onChanged: (value) => setState(() => _estado = value),
              ),
              
              const SizedBox(height: 30),
              InkWell(
                onTap: _guardando ? null : _guardarProducto,
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  height: 55,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(colors: [naranjaPrincipal, cafeClaro]),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(color: naranjaPrincipal.withValues(alpha: 0.3), blurRadius: 10, offset: const Offset(0, 4))
                    ],
                  ),
                  alignment: Alignment.center,
                  child: _guardando
                      ? const CircularProgressIndicator(color: Colors.white, strokeWidth: 2)
                      : const Text('GUARDAR PRODUCTO', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16, letterSpacing: 1)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _campoTexto({
    required TextEditingController controller,
    required String label,
    required IconData icono,
    int maxLines = 1,
    TextInputType tipo = TextInputType.text,
    String? prefix,
    String? hint,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: tipo,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixText: prefix,
        prefixIcon: Icon(icono, color: naranjaPrincipal),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: cafeClaro, width: 2)),
      ),
      validator: (value) => (value == null || value.trim().isEmpty && label != 'Descripción (opcional)')
          ? 'Este campo es obligatorio'
          : null,
      onChanged: label == 'URL de la imagen' ? (_) => setState(() {}) : null,
    );
  }

  Widget _construirImagenPreview(String url) {
    if (url.startsWith('http')) {
      return Image.network(
        url,
        height: 150,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _imagenError(),
      );
    }
    return Image.asset(
      'assets/$url',
      height: 150,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => _imagenError(),
    );
  }

  Widget _imagenError() {
    return Container(
      height: 150,
      color: Colors.grey.shade200,
      child: const Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.broken_image, color: Colors.grey, size: 40),
          Text('Vista previa no disponible', style: TextStyle(fontSize: 12)),
        ],
      ),
    );
  }
}
