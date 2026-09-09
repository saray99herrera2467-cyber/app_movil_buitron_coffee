// lib/screens/pse_datos_screen.dart
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../services/pse_service.dart';
import '../services/pagos_service.dart';

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
  final String? bancoPreseleccionado; // 👈 NUEVO

  const PseDatosScreen({
    super.key,
    required this.total,
    required this.items,
    required this.correo,
    required this.nombreCompleto,
    required this.telefono,
    required this.direccion,
    this.bancoPreseleccionado, // 👈 NUEVO
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
    _bancoSeleccionado = widget.bancoPreseleccionado; // 👈 NUEVO
  }

  Future<void> _pagarConPse() async {
    if (_bancoSeleccionado == null || _docController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('❌ Selecciona un banco e ingresa tu documento')),
      );
      return;
    }

    setState(() => _procesando = true);

    try {
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
      if (pedido == null) throw Exception('No se pudo crear el pedido');

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

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => _PseWebView(url: urlBanco),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('❌ Error: $e')),
      );
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

    return Scaffold(
      backgroundColor: crema,
      appBar: AppBar(
        backgroundColor: cafePrincipal,
        centerTitle: true,
        title: const Text('DATOS DE PAGO', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        leading: IconButton(icon: const Icon(Icons.arrow_back, color: Colors.white), onPressed: () => Navigator.pop(context)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Selecciona tu banco', style: TextStyle(fontWeight: FontWeight.bold, color: cafePrincipal)),
            const SizedBox(height: 10),
            DropdownButtonFormField<String>(
              value: _bancoSeleccionado,
              decoration: InputDecoration(
                filled: true,
                fillColor: cremaClaro,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              ),
              items: bancos
                  .map((b) => DropdownMenuItem(value: b.codigo, child: Text(b.nombre)))
                  .toList(),
              onChanged: (v) => setState(() => _bancoSeleccionado = v),
            ),
            const SizedBox(height: 20),

            const Text('Tipo de persona', style: TextStyle(fontWeight: FontWeight.bold, color: cafePrincipal)),
            Row(
              children: [
                Expanded(
                  child: RadioListTile<String>(
                    value: '0',
                    groupValue: _tipoPersona,
                    title: const Text('Natural'),
                    onChanged: (v) => setState(() => _tipoPersona = v!),
                  ),
                ),
                Expanded(
                  child: RadioListTile<String>(
                    value: '1',
                    groupValue: _tipoPersona,
                    title: const Text('Jurídica'),
                    onChanged: (v) => setState(() => _tipoPersona = v!),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),

            Row(
              children: [
                Expanded(
                  flex: 1,
                  child: DropdownButtonFormField<String>(
                    value: _tipoDocumento,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: cremaClaro,
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
                const SizedBox(width: 10),
                Expanded(
                  flex: 2,
                  child: TextField(
                    controller: _docController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'Número de documento',
                      filled: true,
                      fillColor: cremaClaro,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                    ),
                  ),
                ),
              ],
            ),

            const Spacer(),

            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _procesando ? null : _pagarConPse,
                style: ElevatedButton.styleFrom(
                  backgroundColor: cafePrincipal,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: _procesando
                    ? const CircularProgressIndicator(color: Colors.white)
                    : Text('PAGAR \$${widget.total.toStringAsFixed(0)}',
                    style: const TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
          ],
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
      ),
      body: WebViewWidget(controller: _controller),
    );
  }
}