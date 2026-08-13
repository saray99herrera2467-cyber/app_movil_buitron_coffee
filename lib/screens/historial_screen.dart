import 'package:flutter/material.dart';
import '../models/pedido.dart';
import '../models/producto.dart';

class HistorialScreen extends StatelessWidget {
  const HistorialScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colorRojo = const Color(0xFF9B1C2C);
    final colorFondo = const Color(0xFF2B0F0F);

    final List<Pedido> pedidos = [
      Pedido(
        id: '001',
        productos: [
          Producto(id: 'p1', nombre: 'Bourbon Rosado', descripcion: '100% Café especial', precio: 80000, imagen: '', categoria: ''),
        ],
        fecha: DateTime.now().subtract(const Duration(days: 5)),
        total: 80000,
        estado: 'Entregado',
      ),
      Pedido(
        id: '002',
        productos: [
          Producto(id: 'p2', nombre: 'Café Buitrón', descripcion: '100% Café especial', precio: 60000, imagen: '', categoria: ''),
        ],
        fecha: DateTime.now().subtract(const Duration(days: 2)),
        total: 60000,
        estado: 'En camino',
      ),
    ];

    return Scaffold(
      backgroundColor: colorFondo,
      appBar: AppBar(
        title: const Text('Historial de Pedidos', style: TextStyle(color: Colors.white)),
        backgroundColor: colorRojo,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: pedidos.length,
        itemBuilder: (ctx, i) {
          final pedido = pedidos[i];
          return Card(
            color: Colors.white10,
            margin: const EdgeInsets.only(bottom: 12),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Pedido #${pedido.id}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      Text('${pedido.fecha.day}/${pedido.fecha.month}/${pedido.fecha.year}', style: const TextStyle(color: Colors.white60)),
                    ],
                  ),
                  const Divider(color: Colors.white24),
                  ...pedido.productos.map((prod) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          color: Colors.brown[200],
                          child: const Icon(Icons.coffee, size: 20, color: Colors.brown),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(prod.nombre, style: const TextStyle(color: Colors.white)),
                              Text(prod.descripcion, style: const TextStyle(color: Colors.white60, fontSize: 12)),
                            ],
                          ),
                        ),
                        Text('\$${prod.precio.toStringAsFixed(0)}', style: const TextStyle(color: Colors.amber)),
                      ],
                    ),
                  )),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                        decoration: BoxDecoration(
                          color: colorRojo,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(pedido.estado, style: const TextStyle(color: Colors.white, fontSize: 12)),
                      ),
                      Text('Total: \$${pedido.total.toStringAsFixed(0)}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}