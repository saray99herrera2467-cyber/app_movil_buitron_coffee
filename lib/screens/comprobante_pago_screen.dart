import 'package:flutter/material.dart';
import 'catalogo_screen.dart';

class ComprobantePagoScreen extends StatelessWidget {
  final Map<String, dynamic> pedido;
  final List<dynamic> items;

  const ComprobantePagoScreen({
    super.key,
    required this.pedido,
    required this.items,
  });

  // ✅ PALETA NARANJA CÁLIDO
  static const Color naranjaPrincipal = Color(0xFFF9A15E);
  static const Color crema = Color(0xFFFFFBF2);
  static const Color naranjaIntenso = Color(0xFFFF7043);
  static const Color textoOscuro = Color(0xFF2D2D2D);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: crema,
      appBar: AppBar(
        backgroundColor: naranjaPrincipal,
        centerTitle: true,
        title: const Text('COMPROBANTE', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const CatalogoScreen())),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const Icon(Icons.check_circle_outline, color: Color(0xFF4CAF50), size: 80),
            const SizedBox(height: 16),
            const Text('¡Pedido Exitoso!', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: naranjaPrincipal)),
            const SizedBox(height: 8),
            Text('N° de Pedido: #${pedido['id']}', style: const TextStyle(fontSize: 16, color: Colors.grey)),
            const SizedBox(height: 32),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 4))],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('RESUMEN DE PRODUCTOS', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF2D2D2D))),
                  const Divider(height: 24),
                  ...items.map((item) {
                    final prod = item['id_producto'];
                    final nombre = (prod?['nombre_producto'] ?? 'Producto').toString();
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('${item['cantidad']}x $nombre', style: const TextStyle(fontSize: 14)),
                          Text('\$${((item['cantidad'] ?? 0) * (item['precio_unitario'] ?? 0)).toStringAsFixed(0)}'),
                        ],
                      ),
                    );
                  }).toList(),
                  const Divider(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('TOTAL PAGADO', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      Text('\$${pedido['total']}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: naranjaIntenso)),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),
            InkWell(
              onTap: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const CatalogoScreen())),
              borderRadius: BorderRadius.circular(12),
              child: Container(
                height: 52,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(colors: [naranjaPrincipal, naranjaIntenso]),
                  borderRadius: BorderRadius.circular(12),
                ),
                alignment: Alignment.center,
                child: const Text('VOLVER AL CATÁLOGO', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
