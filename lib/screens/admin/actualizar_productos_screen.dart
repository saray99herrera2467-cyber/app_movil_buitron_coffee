import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/producto.dart';
import '../../providers/producto_admin_provider.dart';

class ActualizarProductoScreen extends StatefulWidget {
  const ActualizarProductoScreen({super.key});

  @override
  State<ActualizarProductoScreen> createState() =>
      _ActualizarProductoScreenState();
}

class _ActualizarProductoScreenState extends State<ActualizarProductoScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProductoAdminProvider>().cargarProductos();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Actualizar Productos')),
      body: Consumer<ProductoAdminProvider>(
        builder: (context, provider, _) {
          if (provider.cargando && provider.productos.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.error != null && provider.productos.isEmpty) {
            return Center(child: Text(provider.error!));
          }

          if (provider.productos.isEmpty) {
            return const Center(child: Text('No hay productos registrados'));
          }

          return RefreshIndicator(
            onRefresh: provider.cargarProductos,
            child: ListView.builder(
              itemCount: provider.productos.length,
              itemBuilder: (context, index) {
                final producto = provider.productos[index];
                return Card(
                  margin:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  child: ListTile(
                    leading: producto.imagen != null
                        ? ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: Image.network(
                        producto.imagen!,
                        width: 50,
                        height: 50,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) =>
                        const Icon(Icons.image_not_supported),
                      ),
                    )
                        : const Icon(Icons.inventory_2, size: 36),
                    title: Text(producto.nombre),
                    subtitle: Text(
                      '\$${producto.precio.toStringAsFixed(2)} · ${producto.categoria}',
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Switch(
                          value: producto.estado,
                          onChanged: (_) => provider.cambiarEstado(producto),
                        ),
                        IconButton(
                          icon: const Icon(Icons.edit, color: Colors.blue),
                          onPressed: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  EditarProductoScreen(producto: producto),
                            ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () =>
                              _confirmarEliminar(context, provider, producto),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }

  void _confirmarEliminar(BuildContext context, ProductoAdminProvider provider,
      Producto producto) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Eliminar producto'),
        content: Text('¿Seguro que deseas eliminar "${producto.nombre}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              provider.eliminarProducto(producto.id);
            },
            child:
            const Text('Eliminar', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}

// -----------------------------------------------------------------------
// FORMULARIO DE EDICIÓN
// -----------------------------------------------------------------------

class EditarProductoScreen extends StatefulWidget {
  final Producto producto;

  const EditarProductoScreen({super.key, required this.producto});

  @override
  State<EditarProductoScreen> createState() => _EditarProductoScreenState();
}

class _EditarProductoScreenState extends State<EditarProductoScreen> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _nombreCtrl;
  late final TextEditingController _descripcionCtrl;
  late final TextEditingController _precioCtrl;
  late final TextEditingController _imagenCtrl;
  late final TextEditingController _categoriaCtrl;
  late bool _estado;

  bool _guardando = false;

  @override
  void initState() {
    super.initState();
    final p = widget.producto;
    _nombreCtrl = TextEditingController(text: p.nombre);
    _descripcionCtrl = TextEditingController(text: p.descripcion ?? '');
    _precioCtrl = TextEditingController(text: p.precio.toString());
    _imagenCtrl = TextEditingController(text: p.imagen ?? '');
    _categoriaCtrl = TextEditingController(text: p.categoria);
    _estado = p.estado;
  }

  @override
  void dispose() {
    _nombreCtrl.dispose();
    _descripcionCtrl.dispose();
    _precioCtrl.dispose();
    _imagenCtrl.dispose();
    _categoriaCtrl.dispose();
    super.dispose();
  }

  Future<void> _guardarCambios() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _guardando = true);

    final actualizado = widget.producto.copyWith(
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
    final exito = await provider.actualizarProducto(actualizado);

    if (!mounted) return;
    setState(() => _guardando = false);

    if (exito) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Producto actualizado correctamente')),
      );
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(provider.error ?? 'Error al actualizar')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Editar Producto')),
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
              ),
              const SizedBox(height: 16),
              SwitchListTile(
                title: const Text('Producto activo'),
                value: _estado,
                onChanged: (value) => setState(() => _estado = value),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _guardando ? null : _guardarCambios,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: _guardando
                    ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
                    : const Text('Guardar Cambios'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}