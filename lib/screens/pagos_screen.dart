import 'package:flutter/material.dart';

class PagosScreen extends StatefulWidget {
  const PagosScreen({super.key});

  @override
  State<PagosScreen> createState() => _PagosScreenState();
}

class _PagosScreenState extends State<PagosScreen> {
  static const Color _colorPrimario = Color(0xFF8B1E1E);
  static const Color _colorFondo = Color(0xFFF9F6F6);
  static const Color _colorNequi = Color(0xFFFF4D6D);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _colorFondo,

      appBar: AppBar(
        leading: const BackButton(color: Colors.white),
        backgroundColor: _colorPrimario,
        elevation: 0,
      ),

      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 12),
              color: _colorPrimario,
              child: const Text(
                'Pagos',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            const Padding(
              padding: EdgeInsets.all(10),
              child: Text(
                'Pagos',
                style: TextStyle(
                  color: _colorPrimario,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),

            const SizedBox(height: 20),

            Center(
              child: Column(
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: _colorNequi,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.credit_card,
                      color: Colors.white,
                      size: 36,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Nequi',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 35),

            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'Ingrese su número',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.black54,
                ),
              ),
            ),

            const SizedBox(height: 6),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: TextField(
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                  hintText: 'Número telefónico empresa\n3052456845',
                  hintStyle: const TextStyle(fontSize: 13, color: Colors.black45),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(4),
                    borderSide: const BorderSide(color: Colors.black12),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(4),
                    borderSide: const BorderSide(color: Colors.black12),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 14,
                  ),
                ),
                style: const TextStyle(fontSize: 14),
              ),
            ),

            const Spacer(),

            Center(
              child: SizedBox(
                width: 260,
                child: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _colorPrimario,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                  child: const Text(
                    'CONFIRMAR',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}