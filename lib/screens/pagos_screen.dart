import 'package:flutter/material.dart';
import '../services/pagos_service.dart';
import 'catalogo_screen.dart';
import 'pse_datos_screen.dart';

class PagosScreen extends StatefulWidget {
  final double total;
  final List<Map<String, dynamic>> items;
  final String correo;
  final String nombreCompleto;
  final String telefono;
  final String direccion;

  const PagosScreen({
    super.key,
    required this.total,
    required this.items,
    required this.correo,
    required this.nombreCompleto,
    required this.telefono,
    required this.direccion,
  });

  @override
  State<PagosScreen> createState() => _PagosScreenState();
}

class _PagosScreenState extends State<PagosScreen> {
  // 'nequi', 'daviplata' o 'pse'
  String _metodoSeleccionado = 'nequi';

  // Código de banco de ePayco/PSE para cada método fijo
  static const Map<String, String> _codigoBancoPorMetodo = {
    'nequi': '1060',
    'daviplata': '1801',
  };

  // ==========================================================
  // IR AL FORMULARIO DE PAGO (banco/documento)
  // ==========================================================

  void _irAFormularioPago() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PseDatosScreen(
          total: widget.total,
          items: widget.items,
          correo: widget.correo,
          nombreCompleto: widget.nombreCompleto,
          telefono: widget.telefono,
          direccion: widget.direccion,
          // Nequi y Daviplata precargan su código; PSE lo deja libre
          bancoPreseleccionado: _codigoBancoPorMetodo[_metodoSeleccionado],
        ),
      ),
    );
  }

  void _confirmar() {
    _irAFormularioPago();
  }

  String get _textoInfo {
    switch (_metodoSeleccionado) {
      case 'nequi':
        return 'Al continuar completarás tu pago vía Nequi de forma segura.';
      case 'daviplata':
        return 'Al continuar completarás tu pago vía Daviplata de forma segura.';
      default:
        return 'Al continuar podrás elegir tu banco y completar el pago vía PSE de forma segura.';
    }
  }

  String get _textoBoton {
    switch (_metodoSeleccionado) {
      case 'nequi':
        return 'CONTINUAR CON NEQUI';
      case 'daviplata':
        return 'CONTINUAR CON DAVIPLATA';
      default:
        return 'CONTINUAR CON PSE';
    }
  }

  // ==========================================================
  // COLORES BUITRÓN COFFEE
  // ==========================================================

  static const Color cafePrincipal = Color(0xFF4E342E);
  static const Color crema = Color(0xFFF5EFE6);
  static const Color cremaClaro = Color(0xFFFFFCF7);
  static const Color dorado = Color(0xFFC8A45D);
  static const Color textoOscuro = Color(0xFF3A2925);
  static const Color textoSuave = Color(0xFF756860);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: crema,
      appBar: AppBar(
        backgroundColor: cafePrincipal,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const CatalogoScreen()),
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
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 25),
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
                style: TextStyle(color: textoSuave, fontSize: 14),
              ),
              const SizedBox(height: 20),

              // ==================================================
              // SELECTOR DE MÉTODO (3 opciones)
              // ==================================================

              Row(
                children: [
                  Expanded(
                    child: _TarjetaMetodo(
                      titulo: 'Nequi',
                      icono: Icons.account_balance_wallet_outlined,
                      seleccionado: _metodoSeleccionado == 'nequi',
                      onTap: () => setState(() => _metodoSeleccionado = 'nequi'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _TarjetaMetodo(
                      titulo: 'Daviplata',
                      icono: Icons.smartphone_outlined,
                      seleccionado: _metodoSeleccionado == 'daviplata',
                      onTap: () => setState(() => _metodoSeleccionado = 'daviplata'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _TarjetaMetodo(
                      titulo: 'PSE',
                      icono: Icons.account_balance_outlined,
                      seleccionado: _metodoSeleccionado == 'pse',
                      onTap: () => setState(() => _metodoSeleccionado = 'pse'),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 25),

              Center(
                child: Text(
                  'Total a pagar: \$${widget.total.toStringAsFixed(0)}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: dorado,
                  ),
                ),
              ),

              const SizedBox(height: 25),

              // ==================================================
              // INFO SEGÚN MÉTODO
              // ==================================================

              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: cremaClaro,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.info_outline, color: cafePrincipal),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        _textoInfo,
                        style: const TextStyle(fontSize: 13, color: textoSuave),
                      ),
                    ),
                  ],
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
                    onPressed: _confirmar,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: cafePrincipal,
                      foregroundColor: Colors.white,
                      elevation: 2,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    child: Text(
                      _textoBoton,
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, letterSpacing: 0.5),
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

// ============================================================
// TARJETA SELECCIONABLE DE MÉTODO DE PAGO
// ============================================================

class _TarjetaMetodo extends StatelessWidget {
  final String titulo;
  final IconData icono;
  final bool seleccionado;
  final VoidCallback onTap;

  const _TarjetaMetodo({
    required this.titulo,
    required this.icono,
    required this.seleccionado,
    required this.onTap,
  });

  static const Color cafePrincipal = Color(0xFF4E342E);
  static const Color cremaClaro = Color(0xFFFFFCF7);
  static const Color dorado = Color(0xFFC8A45D);
  static const Color textoOscuro = Color(0xFF3A2925);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: cremaClaro,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: seleccionado ? dorado : Colors.transparent,
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(icono, color: cafePrincipal, size: 28),
            const SizedBox(height: 6),
            Text(
              titulo,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: textoOscuro,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }
}