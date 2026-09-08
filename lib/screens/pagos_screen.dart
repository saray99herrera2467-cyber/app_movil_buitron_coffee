import 'package:flutter/material.dart';
import 'catalogo_screen.dart';

class PagosScreen extends StatefulWidget {
  const PagosScreen({super.key});

  @override
  State<PagosScreen> createState() => _PagosScreenState();
}

class _PagosScreenState extends State<PagosScreen> {

  // ==========================================================
  // COLORES BUITRÓN COFFEE
  // ==========================================================

  static const Color cafePrincipal = Color(0xFF4E342E);
  static const Color cafeClaro = Color(0xFF795548);
  static const Color crema = Color(0xFFF5EFE6);
  static const Color cremaClaro = Color(0xFFFFFCF7);
  static const Color dorado = Color(0xFFC8A45D);
  static const Color textoOscuro = Color(0xFF3A2925);
  static const Color textoSuave = Color(0xFF756860);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: crema,

      // ========================================================
      // APP BAR
      // ========================================================

      appBar: AppBar(
        backgroundColor: cafePrincipal,
        elevation: 0,

        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            color: Colors.white,
          ),

          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => const CatalogoScreen(),
              ),
            );
          },
        ),

        title: const Text(
          'BUITRÓN COFFEE',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
            letterSpacing: 1,
          ),
        ),

        centerTitle: true,
      ),

      // ========================================================
      // CUERPO
      // ========================================================

      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),

          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,

            children: [

              const SizedBox(height: 25),

              // ==================================================
              // TÍTULO
              // ==================================================

              const Text(
                'Pagos',

                style: TextStyle(
                  color: cafePrincipal,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 6),

              const Text(
                'Selecciona tu método de pago',

                style: TextStyle(
                  color: textoSuave,
                  fontSize: 14,
                ),
              ),

              const SizedBox(height: 30),

              // ==================================================
              // MÉTODO NEQUI
              // ==================================================

              Center(
                child: Column(
                  children: [

                    Container(
                      width: 90,
                      height: 90,

                      decoration: BoxDecoration(
                        color: cafePrincipal,
                        shape: BoxShape.circle,

                        border: Border.all(
                          color: dorado,
                          width: 3,
                        ),
                      ),

                      child: const Icon(
                        Icons.account_balance_wallet_outlined,
                        color: Colors.white,
                        size: 42,
                      ),
                    ),

                    const SizedBox(height: 10),

                    const Text(
                      'Nequi',

                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: cafePrincipal,
                      ),
                    ),

                    const SizedBox(height: 4),

                    const Text(
                      'Pago mediante transferencia',
                      style: TextStyle(
                        fontSize: 13,
                        color: textoSuave,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 35),

              // ==================================================
              // NÚMERO TELEFÓNICO
              // ==================================================

              const Text(
                'Ingrese su número',

                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: textoOscuro,
                ),
              ),

              const SizedBox(height: 8),

              TextField(
                keyboardType: TextInputType.phone,

                decoration: InputDecoration(
                  hintText:
                  'Número telefónico empresa\n3052456845',

                  hintStyle: const TextStyle(
                    fontSize: 13,
                    color: textoSuave,
                  ),

                  prefixIcon: const Icon(
                    Icons.phone_outlined,
                    color: cafePrincipal,
                  ),

                  filled: true,

                  fillColor: cremaClaro,

                  border: OutlineInputBorder(
                    borderRadius:
                    BorderRadius.circular(10),

                    borderSide: BorderSide.none,
                  ),

                  enabledBorder: OutlineInputBorder(
                    borderRadius:
                    BorderRadius.circular(10),

                    borderSide: BorderSide.none,
                  ),

                  focusedBorder: OutlineInputBorder(
                    borderRadius:
                    BorderRadius.circular(10),

                    borderSide: const BorderSide(
                      color: dorado,
                      width: 2,
                    ),
                  ),

                  contentPadding:
                  const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 15,
                  ),
                ),

                style: const TextStyle(
                  fontSize: 14,
                  color: textoOscuro,
                ),
              ),

              const Spacer(),

              // ==================================================
              // BOTÓN CONFIRMAR
              // ==================================================

              Center(
                child: SizedBox(
                  width: 260,
                  height: 50,

                  child: ElevatedButton(
                    onPressed: () {},

                    style: ElevatedButton.styleFrom(
                      backgroundColor: cafePrincipal,

                      foregroundColor: Colors.white,

                      elevation: 2,

                      shape:
                      RoundedRectangleBorder(
                        borderRadius:
                        BorderRadius.circular(10),
                      ),
                    ),

                    child: const Text(
                      'CONFIRMAR',

                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}