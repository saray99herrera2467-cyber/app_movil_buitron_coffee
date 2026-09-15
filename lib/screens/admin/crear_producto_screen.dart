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
  final _stockCtrl = TextEditingController(text: '0'); // 👈 NUEVO
  final _imagenCtrl = TextEditingController();
  final _categoriaCtrl = TextEditingController();

  bool _estado = true;
  bool _guardando = false;

  // ==========================================================
  // COLORES BUITRÓN COFFEE
  // ==========================================================
  static const Color cafePrincipal = Color(0xFF4E342E);
  static const Color cafeClaro = Color(0xFF795548);
  static const Color crema = Color(0xFFF5EFE6);
  static const Color cremaClaro = Color(0xFFFFFCF7);
  static const Color dorado = Color(0xFFC8A45D);

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
      backgroundColor: crema,
      appBar: AppBar(
        title: const Text('CREAR PRODUCTO', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        backgroundColor: cafePrincipal,
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
                label: 'Nombre de imagen o URL', 
                icono: Icons.image,
                hint: 'Ej: cafe1.png o URL completa',
              ),
              
              if (_imagenCtrl.text.trim().isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 15),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(15),
                    child: Image.network(
                      _imagenCtrl.text.trim(),
                      height: 150,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        height: 150,
                        color: cremaClaro,
                        child: const Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.broken_image, color: cafeClaro, size: 40),
                            Text('Vista previa no disponible', style: TextStyle(fontSize: 12)),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

              const SizedBox(height: 16),
              SwitchListTile(
                title: const Text('Producto activo', style: TextStyle(fontWeight: FontWeight.bold, color: cafePrincipal)),
                value: _estado,
                activeColor: dorado,
                onChanged: (value) => setState(() => _estado = value),
              ),
              
              const SizedBox(height: 30),
              SizedBox(
                height: 55,
                child: ElevatedButton(
                  onPressed: _guardando ? null : _guardarProducto,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: cafePrincipal,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 3,
                  ),
                  child: _guardando
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('GUARDAR PRODUCTO', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, letterSpacing: 1)),
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
        prefixIcon: Icon(icono, color: dorado),
        filled: true,
        fillColor: cremaClaro,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: dorado, width: 2)),
      ),
      validator: (value) => (value == null || value.trim().isEmpty && label != 'Descripción (opcional)')
          ? 'Este campo es obligatorio'
          : null,
      onChanged: label == 'Nombre de imagen o URL' ? (_) => setState(() {}) : null,
    );
  }
}
