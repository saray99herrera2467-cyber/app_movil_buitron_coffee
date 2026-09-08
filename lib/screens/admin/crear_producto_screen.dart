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
  final _imagenCtrl = TextEditingController();
  final _categoriaCtrl = TextEditingController();

  bool _estado = true;
  bool _guardando = false;

  @override
  void dispose() {
    _nombreCtrl.dispose();
    _descripcionCtrl.dispose();
    _precioCtrl.dispose();
    _imagenCtrl.dispose();
    _categoriaCtrl.dispose();
    super.dispose();
  }

  Future<void> _guardarProducto() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _guardando = true);

    final nuevoProducto = Producto(
      id: 0, // Supabase asigna el id automáticamente
      nombre: _nombreCtrl.text.trim(),
      descripcion: _descripcionCtrl.text.trim().isEmpty
          ? null
          : _descripcionCtrl.text.trim(),
      precio: double.parse(_precioCtrl.text.trim()),
      imagen:
      _imagenCtrl.text.trim().isEmpty ? null : _imagenCtrl.text.trim(),
      categoria: _categoriaCtrl.text.trim(),
      estado: _estado,
    );

    final provider = context.read<ProductoAdminProvider>();
    final exito = await provider.crearProducto(nuevoProducto);

    if (!mounted) return;
    setState(() => _guardando = false);

    if (exito) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Producto creado correctamente')),
      );
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(provider.error ?? 'Error al crear el producto')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Crear Producto')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _nombreCtrl,
                decoration: const InputDecoration(
                  labelText: 'Nombre del producto',
                  border: OutlineInputBorder(),
                ),
                validator: (value) => (value == null || value.trim().isEmpty)
                    ? 'El nombre es obligatorio'
                    : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descripcionCtrl,
                decoration: const InputDecoration(
                  labelText: 'Descripción (opcional)',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _precioCtrl,
                decoration: const InputDecoration(
                  labelText: 'Precio',
                  border: OutlineInputBorder(),
                  prefixText: '\$ ',
                ),
                keyboardType:
                const TextInputType.numberWithOptions(decimal: true),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'El precio es obligatorio';
                  }
                  final n = double.tryParse(value.trim());
                  if (n == null || n <= 0) {
                    return 'Ingresa un precio válido';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _categoriaCtrl,
                decoration: const InputDecoration(
                  labelText: 'Categoría',
                  border: OutlineInputBorder(),
                ),
                validator: (value) => (value == null || value.trim().isEmpty)
                    ? 'La categoría es obligatoria'
                    : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _imagenCtrl,
                decoration: const InputDecoration(
                  labelText: 'URL de la imagen (opcional)',
                  border: OutlineInputBorder(),
                ),
                onChanged: (_) => setState(() {}),
              ),
              if (_imagenCtrl.text.trim().isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 12, bottom: 4),
                  child: Image.network(
                    _imagenCtrl.text.trim(),
                    height: 120,
                    errorBuilder: (_, _, _) =>
                    const Text('No se pudo cargar la imagen'),
                  ),
                ),
              const SizedBox(height: 16),
              SwitchListTile(
                title: const Text('Producto activo'),
                value: _estado,
                onChanged: (value) => setState(() => _estado = value),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _guardando ? null : _guardarProducto,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: _guardando
                    ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
                    : const Text('Guardar Producto'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}