import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'catalogo_screen.dart';

class ComprobantePagoScreen extends StatelessWidget {
  final Map<String, dynamic> pedido;
  final List<dynamic> items;

  const ComprobantePagoScreen({
    super.key,
    required this.pedido,
    required this.items,
  });

  static const Color cafePrincipal = Color(0xFF4E342E);
  static const Color crema = Color(0xFFF5EFE6);
  static const Color dorado = Color(0xFFC8A45D);
  static const Color textoOscuro = Color(0xFF3A2925);

  @override
  Widget build(BuildContext context) {
    final String fecha = pedido['fecha'] != null 
        ? DateFormat('dd/MM/yyyy HH:mm').format(DateTime.parse(pedido['fecha']))
        : 'Reciente';

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('COMPROBANTE DE PAGO', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        backgroundColor: cafePrincipal,
        foregroundColor: Colors.white,
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (_) => const CatalogoScreen()),
              (route) => false,
            ),
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // Icono de éxito
            const Icon(Icons.check_circle, color: Colors.green, size: 80),
            const SizedBox(height: 16),
            const Text(
              '¡Gracias por tu compra!',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: cafePrincipal),
            ),
            Text(
              'Pedido: ${pedido['id']}', // ✅ Nombre del pedido más claro
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: dorado),
            ),
            const Text(
              'Tu pedido ha sido registrado con éxito.',
              style: TextStyle(color: Colors.grey),
            ),
            
            const SizedBox(height: 32),
            
            // Factura
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: crema.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: dorado.withValues(alpha: 0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('No. Pedido:', style: TextStyle(fontWeight: FontWeight.bold)),
                      Text('#${pedido['id']}', style: const TextStyle(fontWeight: FontWeight.bold, color: dorado)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  _filaDetalle('Fecha', fecha),
                  _filaDetalle('Método', pedido['metodo_pago'] ?? 'En línea'),
                  const Divider(height: 30),
                  
                  const Text('PRODUCTOS', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: cafePrincipal)),
                  const SizedBox(height: 12),
                  
                  ...items.map((item) {
                    final prod = item['id_producto'] ?? item['producto']; // ✅ Soporta ambos mapeos
                    final String nombreProd = (prod?['nombre'] ?? prod?['nombre_producto'] ?? prod?['producto'] ?? 'Producto').toString();

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(child: Text('${item['cantidad']} x $nombreProd', style: const TextStyle(fontSize: 14))),
                          Text('\$${((item['cantidad'] ?? 0) * (item['precio_unitario'] ?? 0)).toStringAsFixed(0)}'),
                        ],
                      ),
                    );
                  }),
                  
                  const Divider(height: 30),
                  
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('TOTAL PAGADO', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      Text('\$${pedido['total'] ?? '0'}', 
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: cafePrincipal)),
                    ],
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 40),
            
            // Botones de acción
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (_) => const CatalogoScreen()),
                    (route) => false,
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: cafePrincipal,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('VOLVER AL INICIO', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _filaDetalle(String label, String valor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.black54)),
          Text(valor, style: const TextStyle(fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}
