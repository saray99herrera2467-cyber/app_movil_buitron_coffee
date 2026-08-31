import 'package:flutter/material.dart';

class ResenasScreen extends StatefulWidget {
  const ResenasScreen({super.key});

  @override
  State<ResenasScreen> createState() => _ResenasScreenState();
}

class _ResenasScreenState extends State<ResenasScreen> {
  int _calificacion = 0;
  final _comentarioController = TextEditingController();
  final colorRojo = const Color(0xFF9B1C2C);
  final colorFondo = const Color(0xFF2B0F0F);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: colorFondo,
      appBar: AppBar(
        title: const Text('Reseñas y Calificaciones', style: TextStyle(color: Colors.white)),
        backgroundColor: colorRojo,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 70,
                  height: 70,
                  color: Colors.brown[200],
                  child: const Icon(Icons.coffee, size: 40, color: Colors.brown),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    'Café Bourbon Rosado',
                    style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 25),
            const Text('¿Cómo calificarías este café?', style: TextStyle(color: Colors.white)),
            const SizedBox(height: 10),
            Row(
              children: List.generate(5, (index) {
                return IconButton(
                  icon: Icon(
                    index < _calificacion ? Icons.star : Icons.star_border,
                    color: Colors.amber,
                    size: 35,
                  ),
                  onPressed: () => setState(() => _calificacion = index + 1),
                );
              }),
            ),
            const SizedBox(height: 25),
            const Text('Escribe tu reseña:', style: TextStyle(color: Colors.white)),
            const SizedBox(height: 8),
            TextField(
              controller: _comentarioController,
              maxLines: 4,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Escribe aquí...',
                hintStyle: const TextStyle(color: Colors.white54),
                filled: true,
                fillColor: Colors.white10,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
            const SizedBox(height: 25),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: colorRojo,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                ),
                onPressed: _calificacion > 0 && _comentarioController.text.isNotEmpty
                    ? () {
                  ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('¡Reseña enviada con éxito!'))
                  );
                  setState(() {
                    _calificacion = 0;
                    _comentarioController.clear();
                  });
                }
                    : null,
                child: const Text('Enviar', style: TextStyle(fontSize: 16, color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}