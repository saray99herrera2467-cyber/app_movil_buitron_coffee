import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/carrito_provider.dart';

class CarritoScreen extends StatelessWidget {
  const CarritoScreen({super.key});

  Widget _buildImagenProducto(String? ruta) {
    String rutaFinal = '';
    if (ruta != null && ruta.isNotEmpty) {
      rutaFinal = ruta.startsWith('http') ? ruta : ruta.startsWith('assets/') ? ruta : 'assets/$ruta';
    }
    if (rutaFinal.isEmpty) return const Icon(Icons.coffee, size: 40, color: Color(0xFF9B1C2C));
    return rutaFinal.startsWith('http')
        ? Image.network(rutaFinal, width:50, height:50, fit:BoxFit.contain, errorBuilder: (_,__,___)=>const Icon(Icons.coffee, size:40, color:Color(0xFF9B1C2C)))
        : Image.asset(rutaFinal, width:50, height:50, fit:BoxFit.contain, errorBuilder: (_,__,___)=>const Icon(Icons.coffee, size:40, color:Color(0xFF9B1C2C)));
  }

  @override
  Widget build(BuildContext context) {
    final carrito = Provider.of<CarritoProvider>(context);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF9B1C2C),
        title: const Text('MI PEDIDO', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        leading: IconButton(icon:const Icon(Icons.arrow_back, color:Colors.white), onPressed:()=>Navigator.pop(context)),
      ),
      body: carrito.items.isEmpty
          ? const Center(child: Text('Tu carrito está vacío ☕', style: TextStyle(fontSize: 18, color: Colors.grey)))
          : Column(children: [
        Expanded(child: ListView.builder(padding:const EdgeInsets.all(16), itemCount:carrito.items.length, itemBuilder:(context, index){
          final item = carrito.items[index];
          return Card(margin:const EdgeInsets.only(bottom:12), child:Padding(padding:const EdgeInsets.all(12), child:Row(children:[
            // ✅ IMAGEN A LA IZQUIERDA
            _buildImagenProducto(item.producto.imagen),
            const SizedBox(width:12),
            // ✅ DATOS
            Expanded(child:Column(crossAxisAlignment:CrossAxisAlignment.start, children:[
              Text(item.producto.nombre, style:const TextStyle(fontWeight:FontWeight.bold, fontSize:14)),
              const SizedBox(height:4),
              Text('Cantidad: ${item.cantidad} • \$${item.subtotal.toStringAsFixed(0)}', style:TextStyle(fontSize:12, color:Colors.grey[600])),
            ])),
            // ✅ BOTONES CANTIDAD
            Row(mainAxisSize:MainAxisSize.min, children:[
              IconButton(icon:const Icon(Icons.remove_circle_outline, color:Color(0xFF9B1C2C)), onPressed:()=>carrito.cambiarCantidad(index, item.cantidad-1)),
              IconButton(icon:const Icon(Icons.add_circle_outline, color:Color(0xFF9B1C2C)), onPressed:()=>carrito.cambiarCantidad(index, item.cantidad+1)),
              IconButton(icon:const Icon(Icons.delete, color:Colors.red), onPressed:()=>carrito.eliminarProducto(index)),
            ]),
          ])));
        })),
        // ✅ TOTAL Y BOTÓN
        Container(padding:const EdgeInsets.all(20), decoration:BoxDecoration(color:Colors.white, boxShadow:[BoxShadow(color:Colors.grey.shade200, blurRadius:5)]), child:Column(children:[
          Row(mainAxisAlignment:MainAxisAlignment.spaceBetween, children:[const Text('TOTAL:', style:TextStyle(fontSize:18, fontWeight:FontWeight.bold)), Text('\$${carrito.total.toStringAsFixed(0)}', style:const TextStyle(fontSize:20, color:Color(0xFF9B1C2C), fontWeight:FontWeight.bold))]),
          const SizedBox(height:12),
          SizedBox(width:double.infinity, child:ElevatedButton(style:ElevatedButton.styleFrom(backgroundColor:const Color(0xFF9B1C2C), padding:const EdgeInsets.symmetric(vertical:14)), onPressed:(){ ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content:Text('¡Pedido realizado con éxito! ☕'))); carrito.vaciarCarrito(); Navigator.pop(context); }, child:const Text('CONFIRMAR PEDIDO', style:TextStyle(fontSize:16, color:Colors.white)))),
        ])),
      ]),
    );
  }
}