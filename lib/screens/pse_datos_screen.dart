// lib/screens/pse_datos_screen.dart
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../services/pse_service.dart';
import '../services/pedido_service.dart';

const Color cafePrincipal = Color(0xFF4E342E);
const Color crema = Color(0xFFF5EFE6);
const Color cremaClaro = Color(0xFFFFFCF7);
const Color dorado = Color(0xFFC8A45D);

class PseDatosScreen extends StatefulWidget {
  final double total;
  final List<Map<String, dynamic>> items;
  final String correo;
  final String nombreCompleto;
  final String telefono;
  final String direccion;
  final String? bancoPreseleccionado;

  const PseDatosScreen({
    super.key,
    required this.total,
    required this.items,
    required this.correo,
    required this.nombreCompleto,
    required this.telefono,
    required this.direccion,
    this.bancoPreseleccionado,
  });

  @override
  State<PseDatosScreen> createState() => _PseDatosScreenState();
}

class _PseDatosScreenState extends State<PseDatosScreen> {
  final _docController = TextEditingController();
  String? _bancoSeleccionado;
  String _tipoDocumento = 'CC';
  String _tipoPersona = '0'; // natural
  bool _procesando = false;

  @override
  void initState() {
    super.initState();
    _bancoSeleccionado = widget.bancoPreseleccionado;
  }

  Future<void> _pagarConPse() async {
    if (_bancoSeleccionado == null || _docController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('❌ Selecciona un banco e ingresa tu documento'),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() => _procesando = true);

    try {
      // 1. Crear el pedido en Supabase
      final pedido = await PedidoService.crearPedido(
        correo: widget.correo,
        nombreCompleto: widget.nombreCompleto,
        telefono: widget.telefono,
        direccion: widget.direccion,
        metodoPago: _bancoSeleccionado == '1060'
            ? 'Nequi'
            : _bancoSeleccionado == '1801'
            ? 'Daviplata'
            : 'PSE',
        numeroPago: null,
        subtotal: widget.total,
        total: widget.total,
        items: widget.items,
      );

      if (pedido == null) throw Exception('No se pudo crear el pedido en la base de datos');

      // 2. Iniciar pago en ePayco
      final resultado = await PseService.crearPagoPse(
        banco: _bancoSeleccionado!,
        tipoDocumento: _tipoDocumento,
        numeroDocumento: _docController.text.trim(),
        tipoPersona: _tipoPersona,
        nombreCompleto: widget.nombreCompleto,
        correo: widget.correo,
        telefono: widget.telefono,
        direccion: widget.direccion,
        total: widget.total,
        idPedido: pedido['id'],
      );

      final urlBanco = resultado['data']?['urlbanco'] ?? resultado['urlbanco'];

      if (urlBanco == null) {
        throw Exception('ePayco no devolvió la URL del banco: $resultado');
      }

      if (!mounted) return;

      // 3. Abrir pasarela en WebView
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => _PseWebView(url: urlBanco),
        ),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Error al procesar: ${e.toString().replaceFirst('Exception: ', '')}'),
            backgroundColor: Colors.redAccent,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _procesando = false);
    }
  }

  @override
  void dispose() {
    _docController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bancos = PseService.obtenerBancos();

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: crema,
        appBar: AppBar(
          backgroundColor: cafePrincipal,
          centerTitle: true,
          title: const Text('DATOS DE PAGO',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.pop(context)),
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Selecciona tu banco',
                    style: TextStyle(fontWeight: FontWeight.bold, color: cafePrincipal, fontSize: 16)),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  initialValue: _bancoSeleccionado,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: cremaClaro,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                  ),
                  items: bancos
                      .map((b) => DropdownMenuItem(value: b.codigo, child: Text(b.nombre)))
                      .toList(),
                  onChanged: (v) => setState(() => _bancoSeleccionado = v),
                ),
                const SizedBox(height: 24),

                const Text('Tipo de persona',
                    style: TextStyle(fontWeight: FontWeight.bold, color: cafePrincipal, fontSize: 16)),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: RadioListTile<String>(
                        value: '0',
                        groupValue: _tipoPersona,
                        title: const Text('Natural', style: TextStyle(fontSize: 14)),
                        onChanged: (v) => setState(() => _tipoPersona = v!),
                        activeColor: cafePrincipal,
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                    Expanded(
                      child: RadioListTile<String>(
                        value: '1',
                        groupValue: _tipoPersona,
                        title: const Text('Jurídica', style: TextStyle(fontSize: 14)),
                        onChanged: (v) => setState(() => _tipoPersona = v!),
                        activeColor: cafePrincipal,
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                const Text('Identificación',
                    style: TextStyle(fontWeight: FontWeight.bold, color: cafePrincipal, fontSize: 16)),
                const SizedBox(height: 12),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 1,
                      child: DropdownButtonFormField<String>(
                        initialValue: _tipoDocumento,
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: cremaClaro,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                        ),
                        items: const [
                          DropdownMenuItem(value: 'CC', child: Text('CC')),
                          DropdownMenuItem(value: 'CE', child: Text('CE')),
                          DropdownMenuItem(value: 'NIT', child: Text('NIT')),
                        ],
                        onChanged: (v) => setState(() => _tipoDocumento = v!),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 2,
                      child: TextField(
                        controller: _docController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          hintText: 'Número de documento',
                          filled: true,
                          fillColor: cremaClaro,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: dorado, width: 2),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 40),

                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: _procesando ? null : _pagarConPse,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: cafePrincipal,
                      foregroundColor: Colors.white,
                      elevation: 2,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: _procesando
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                          )
                        : Text('PAGAR \$${widget.total.toStringAsFixed(0)}',
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, letterSpacing: 1)),
                  ),
                ),
                const SizedBox(height: 20),
                const Center(
                  child: Text(
                    'Tu pago es procesado de forma segura por ePayco',
                    style: TextStyle(fontSize: 12, color: Colors.black54),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _PseWebView extends StatefulWidget {
  final String url;
  const _PseWebView({required this.url});

  @override
  State<_PseWebView> createState() => _PseWebViewState();
}

class _PseWebViewState extends State<_PseWebView> {
  late final WebViewController _controller;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..loadRequest(Uri.parse(widget.url));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: cafePrincipal,
        title: const Text('Confirmación bancaria', style: TextStyle(color: Colors.white)),
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: WebViewWidget(controller: _controller),
    );
  }
}
