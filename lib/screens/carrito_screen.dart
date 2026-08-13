import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/carrito_provider.dart';

class CarritoScreen extends StatelessWidget {
  const CarritoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final carrito = Provider.of<CarritoProvider>(context);
    final colorRojo = const Color(0xFF9B1C2C);
    final colorFondo = const Color(0xFF2B0F0F);

    return Scaffold(
      backgroundColor: colorFondo,
      appBar: AppBar(
        title: const Text('Carrito', style: TextStyle(color: Colors.white)),
        backgroundColor: colorRojo,
      ),
      body: carrito.items.isEmpty
          ? const Center(child: Text('Tu carrito está vacío', style: TextStyle(color: Colors.white)))
          : Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: carrito.items.length,
              itemBuilder: (ctx, i) {
                final prod = carrito.items[i];
                final cant = carrito.cantidades[prod.id] ?? 1;
                return Card(
                  color: Colors.white10,
                  child: ListTile(
                    leading: Container(
                      width: 50,
                      height: 50,
                      color: Colors.brown[200],
                      child: const Icon(Icons.coffee, color: Colors.brown),
                    ),
                    title: Text(prod.nombre, style: const TextStyle(color: Colors.white)),
                    subtitle: Text('\$${prod.precio.toStringAsFixed(0)}', style: const TextStyle(color: Colors.amber)),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.remove, color: Colors.white),
                          onPressed: () => carrito.cambiarCantidad(prod.id, cant - 1),
                        ),
                        Text('$cant', style: const TextStyle(color: Colors.white)),
                        IconButton(
                          icon: const Icon(Icons.add, color: Colors.white),
                          onPressed: () => carrito.cambiarCantidad(prod.id, cant + 1),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.black26,
            child: Column(
              children: [
                Text('Subtotal: \$${carrito.subtotal.toStringAsFixed(0)}', style: const TextStyle(color: Colors.white)),
                Text('Envío: \$${carrito.costoEnvio.toStringAsFixed(0)}', style: const TextStyle(color: Colors.white)),
                Text('TOTAL: \$${carrito.total.toStringAsFixed(0)}', style: const TextStyle(color: Colors.amber, fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 10),
                const Text('Pago en línea', style: TextStyle(color: Colors.white70)),
                const SizedBox(height: 15),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.grey),
                        onPressed: () => carrito.limpiarCarrito(),
                        child: const Text('Cancelar pedido', style: TextStyle(color: Colors.white)),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(backgroundColor: colorRojo),
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Procediendo al pago...'))
                          );
                        },
                        child: const Text('Finalizar su compra', style: TextStyle(color: Colors.white)),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}