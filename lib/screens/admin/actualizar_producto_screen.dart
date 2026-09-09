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
  // ==========================================================
  // COLORES BUITRÓN COFFEE
  // ==========================================================
  static const Color cafePrincipal = Color(0xFF4E342E);
  static const Color cafeClaro = Color(0xFF795548);
  static const Color crema = Color(0xFFF5EFE6);
  static const Color cremaClaro = Color(0xFFFFFCF7);
  static const Color dorado = Color(0xFFC8A45D);
  static const Color textoSuave = Color(0xFF756860);

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
      backgroundColor: crema,
      appBar: AppBar(
        title: const Text('GESTIÓN DE PRODUCTOS', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        backgroundColor: cafePrincipal,
        foregroundColor: Colors.white,
        centerTitle: true,
      ),
      body: Consumer<ProductoAdminProvider>(
        builder: (context, provider, _) {
          if (provider.cargando && provider.productos.isEmpty) {
            return const Center(child: CircularProgressIndicator(color: cafePrincipal));
          }

          if (provider.error != null && provider.productos.isEmpty) {
            return Center(child: Text(provider.error!, style: const TextStyle(color: Colors.red)));
          }

          if (provider.productos.isEmpty) {
            return const Center(child: Text('No hay productos registrados', style: TextStyle(color: textoSuave)));
          }

          return RefreshIndicator(
            onRefresh: provider.cargarProductos,
            color: cafePrincipal,
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 15),
              itemCount: provider.productos.length,
              itemBuilder: (context, index) {
                final producto = provider.productos[index];
                return Card(
                  color: cremaClaro,
                  elevation: 2,
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(12),
                    leading: Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(color: crema, borderRadius: BorderRadius.circular(10)),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: _construirImagen(producto),
                      ),
                    ),
                    title: Text(producto.nombre, style: const TextStyle(fontWeight: FontWeight.bold, color: cafePrincipal)),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 4),
                        Text('\$${producto.precio.toStringAsFixed(0)} · ${producto.categoria}', style: const TextStyle(color: textoSuave, fontWeight: FontWeight.w500)),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Container(
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                color: producto.estado ? Colors.green : Colors.red,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text(producto.estado ? 'Activo' : 'Inactivo', style: TextStyle(fontSize: 12, color: producto.estado ? Colors.green : Colors.red)),
                          ],
                        ),
                      ],
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit, color: dorado),
                          onPressed: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => EditarProductoScreen(producto: producto),
                            ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: cafeClaro),
                          onPressed: () => _confirmarEliminar(context, provider, producto),
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

  Widget _construirImagen(Producto producto) {
    if (producto.imagen == null || producto.imagen!.isEmpty) {
      return _imagenFallback();
    }

    final img = producto.imagen!.trim();

    if (img.startsWith('http')) {
      return Image.network(
        img,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _imagenFallback(),
      );
    }

    if (img.startsWith('assets/')) {
      return Image.asset(
        img,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _imagenFallback(),
      );
    }

    return Image.asset(
      'assets/$img',
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => _imagenFallback(),
    );
  }

  Widget _imagenFallback() {
    return const Icon(Icons.coffee, color: cafePrincipal, size: 30);
  }

  void _confirmarEliminar(BuildContext context, ProductoAdminProvider provider, Producto producto) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: cremaClaro,
        title: const Text('Eliminar producto', style: TextStyle(color: cafePrincipal)),
        content: Text('¿Seguro que deseas eliminar "${producto.nombre}"?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar', style: TextStyle(color: cafeClaro))),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              provider.eliminarProducto(producto.id);
            },
            child: const Text('Eliminar', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
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
  late final TextEditingController _stockCtrl; // ✅ Definido correctamente
  late final TextEditingController _imagenCtrl;
  late final TextEditingController _categoriaCtrl;
  late bool _estado;

  bool _guardando = false;

  // Colores repetidos para simplicidad
  static const Color cafePrincipal = Color(0xFF4E342E);
  static const Color crema = Color(0xFFF5EFE6);
  static const Color cremaClaro = Color(0xFFFFFCF7);
  static const Color dorado = Color(0xFFC8A45D);

  @override
  void initState() {
    super.initState();
    final p = widget.producto;
    _nombreCtrl = TextEditingController(text: p.nombre);
    _descripcionCtrl = TextEditingController(text: p.descripcion ?? '');
    _precioCtrl = TextEditingController(text: p.precio.toString());
    _stockCtrl = TextEditingController(text: p.stock.toString());
    _imagenCtrl = TextEditingController(text: p.imagen ?? '');
    _categoriaCtrl = TextEditingController(text: p.categoria);
    _estado = p.estado;
  }

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

  Future<void> _guardarCambios() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _guardando = true);

    final actualizado = widget.producto.copyWith(
      nombre: _nombreCtrl.text.trim(),
      descripcion: _descripcionCtrl.text.trim().isEmpty ? null : _descripcionCtrl.text.trim(),
      precio: double.parse(_precioCtrl.text.trim()),
      imagen: _imagenCtrl.text.trim().isEmpty ? null : _imagenCtrl.text.trim(),
      categoria: _categoriaCtrl.text.trim(),
      estado: _estado,
    );

    final provider = context.read<ProductoAdminProvider>();
    final exito = await provider.actualizarProducto(actualizado);

    if (!mounted) return;
    setState(() => _guardando = false);

    if (exito) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(backgroundColor: Colors.green, content: Text('Producto actualizado correctamente')),
      );
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.red, 
          content: Text(provider.error ?? 'Error al actualizar'),
          duration: const Duration(seconds: 5),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: crema,
      appBar: AppBar(
        title: const Text('EDITAR PRODUCTO', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
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
              _campoTexto(controller: _categoriaCtrl, label: 'Categoría', icono: Icons.category),
              const SizedBox(height: 16),
              _campoTexto(controller: _imagenCtrl, label: 'URL o nombre de la imagen', icono: Icons.image),
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
                  onPressed: _guardando ? null : _guardarCambios,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: cafePrincipal,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: _guardando
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('GUARDAR CAMBIOS', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
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
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: tipo,
      decoration: InputDecoration(
        labelText: label,
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
    );
  }
}
