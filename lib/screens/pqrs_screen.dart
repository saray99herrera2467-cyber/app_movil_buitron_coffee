import 'package:flutter/material.dart';
import 'catalogo_screen.dart';

// ============================================================
// PALETA DE COLORES
// ============================================================

const Color kFondoApp = Color(0xFFF5EFE6);
const Color kCafePrincipal = Color(0xFF4E342E);
const Color kCafeClaro = Color(0xFF795548);
const Color kDorado = Color(0xFFC8A45D);
const Color kCrema = Color(0xFFFFFCF7);
const Color kInput = Color(0xFFEDE5D9);
const Color kTextoOscuro = Color(0xFF3A2925);
const Color kTextoSuave = Color(0xFF756860);

// ============================================================
// MODELO PQRS
// ============================================================

enum TipoPqrs {
  peticion,
  queja,
  reclamo,
  sugerencia,
}

extension TipoPqrsX on TipoPqrs {
  String get etiqueta {
    switch (this) {
      case TipoPqrs.peticion:
        return 'Petición';

      case TipoPqrs.queja:
        return 'Queja';

      case TipoPqrs.reclamo:
        return 'Reclamo';

      case TipoPqrs.sugerencia:
        return 'Sugerencia';
    }
  }

  IconData get icono {
    switch (this) {
      case TipoPqrs.peticion:
        return Icons.description_outlined;

      case TipoPqrs.queja:
        return Icons.report_problem_outlined;

      case TipoPqrs.reclamo:
        return Icons.gavel_outlined;

      case TipoPqrs.sugerencia:
        return Icons.lightbulb_outline;
    }
  }
}

// ============================================================
// MODELO RADICADO
// ============================================================

class Radicado {
  final String numero;
  final String fecha;
  final int diasHabiles;

  Radicado({
    required this.numero,
    required this.fecha,
    this.diasHabiles = 15,
  });
}

// ============================================================
// PANTALLA PQRS
// ============================================================

class PqrsScreen extends StatefulWidget {
  const PqrsScreen({super.key});

  @override
  State<PqrsScreen> createState() => _PqrsScreenState();
}

class _PqrsScreenState extends State<PqrsScreen> {
  TipoPqrs _tipo = TipoPqrs.peticion;

  final TextEditingController _nombreCtrl =
  TextEditingController();

  final TextEditingController _correoCtrl =
  TextEditingController();

  final TextEditingController _telefonoCtrl =
  TextEditingController();

  final TextEditingController _asuntoCtrl =
  TextEditingController();

  final TextEditingController _descripcionCtrl =
  TextEditingController();

  bool _aceptaTratamientoDatos = false;
  bool _mostrarError = false;

  Radicado? _radicado;

  // ==========================================================
  // REGRESAR AL CATÁLOGO
  // ==========================================================

  void _volverAlCatalogo() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => const CatalogoScreen(),
      ),
    );
  }

  // ==========================================================
  // DISPOSE
  // ==========================================================

  @override
  void dispose() {
    _nombreCtrl.dispose();
    _correoCtrl.dispose();
    _telefonoCtrl.dispose();
    _asuntoCtrl.dispose();
    _descripcionCtrl.dispose();

    super.dispose();
  }

  // ==========================================================
  // VALIDAR CAMPOS
  // ==========================================================

  bool get _camposCompletos =>
      _nombreCtrl.text.trim().isNotEmpty &&
          _correoCtrl.text.trim().isNotEmpty &&
          _asuntoCtrl.text.trim().isNotEmpty &&
          _descripcionCtrl.text.trim().isNotEmpty;

  // ==========================================================
  // GENERAR RADICADO
  // ==========================================================

  Radicado _generarRadicado() {
    final ahora = DateTime.now();

    final anio = ahora.year;

    final numero =
        100000 +
            (ahora.millisecondsSinceEpoch % 900000);

    const meses = [
      'enero',
      'febrero',
      'marzo',
      'abril',
      'mayo',
      'junio',
      'julio',
      'agosto',
      'septiembre',
      'octubre',
      'noviembre',
      'diciembre',
    ];

    final fecha =
        '${ahora.day} de '
        '${meses[ahora.month - 1]} de '
        '${ahora.year}, '
        '${ahora.hour.toString().padLeft(2, '0')}:'
        '${ahora.minute.toString().padLeft(2, '0')}';

    return Radicado(
      numero: 'PQRS-$anio-$numero',
      fecha: fecha,
    );
  }

  // ==========================================================
  // ENVIAR PQRS
  // ==========================================================

  void _enviar() {
    if (!_camposCompletos ||
        !_aceptaTratamientoDatos) {
      setState(() {
        _mostrarError = true;
      });

      return;
    }

    setState(() {
      _mostrarError = false;
      _radicado = _generarRadicado();
    });
  }

  // ==========================================================
  // REINICIAR
  // ==========================================================

  void _reiniciar() {
    setState(() {
      _nombreCtrl.clear();
      _correoCtrl.clear();
      _telefonoCtrl.clear();
      _asuntoCtrl.clear();
      _descripcionCtrl.clear();

      _tipo = TipoPqrs.peticion;

      _aceptaTratamientoDatos = false;
      _mostrarError = false;

      _radicado = null;
    });
  }

  // ==========================================================
  // BUILD
  // ==========================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kFondoApp,

      // ========================================================
      // APP BAR
      // ========================================================

      appBar: AppBar(
        backgroundColor: kCafePrincipal,
        foregroundColor: Colors.white,
        elevation: 3,

        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            color: Colors.white,
            size: 26,
          ),
          onPressed: _volverAlCatalogo,
        ),

        centerTitle: true,

        title: const Text(
          'BUITRÓN COFFEE',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
            letterSpacing: 1,
          ),
        ),
      ),

      // ========================================================
      // CONTENIDO
      // ========================================================

      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(18),

          child: Column(
            children: [
              // ==================================================
              // ENCABEZADO
              // ==================================================

              Container(
                width: double.infinity,

                padding: const EdgeInsets.symmetric(
                  vertical: 20,
                  horizontal: 15,
                ),

                decoration: BoxDecoration(
                  color: kCafePrincipal,

                  borderRadius:
                  BorderRadius.circular(18),

                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 7,
                      offset: Offset(0, 3),
                    ),
                  ],
                ),

                child: const Column(
                  children: [
                    Icon(
                      Icons.forum_outlined,
                      color: kDorado,
                      size: 40,
                    ),

                    SizedBox(height: 8),

                    Text(
                      'PQRS',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1,
                      ),
                    ),

                    SizedBox(height: 5),

                    Text(
                      'Peticiones, quejas, reclamos y sugerencias',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // ==================================================
              // CONTENEDOR PRINCIPAL
              // ==================================================

              Container(
                width: double.infinity,

                padding: const EdgeInsets.all(18),

                decoration: BoxDecoration(
                  color: kCrema,

                  borderRadius:
                  BorderRadius.circular(18),

                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 6,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),

                child: _radicado == null
                    ? _buildFormulario()
                    : _buildComprobante(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ============================================================
  // FORMULARIO
  // ============================================================

  Widget _buildFormulario() {
    return Column(
      crossAxisAlignment:
      CrossAxisAlignment.stretch,

      children: [
        const Text(
          'Cuéntanos qué pasó',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: kTextoOscuro,
            fontWeight: FontWeight.bold,
            fontSize: 17,
          ),
        ),

        const SizedBox(height: 5),

        const Text(
          'Selecciona el tipo de solicitud que deseas realizar.',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: kTextoSuave,
            fontSize: 12,
          ),
        ),

        const SizedBox(height: 20),

        // ======================================================
        // TIPO DE PQRS
        // ======================================================

        _SelectorTipo(
          seleccionado: _tipo,
          onSeleccionar: (tipo) {
            setState(() {
              _tipo = tipo;
            });
          },
        ),

        const SizedBox(height: 20),

        // ======================================================
        // NOMBRE
        // ======================================================

        _CampoEtiquetado(
          label: 'Nombre',
          controller: _nombreCtrl,
        ),

        const SizedBox(height: 13),

        // ======================================================
        // CORREO
        // ======================================================

        _CampoEtiquetado(
          label: 'Correo',
          controller: _correoCtrl,
          keyboardType:
          TextInputType.emailAddress,
        ),

        const SizedBox(height: 13),

        // ======================================================
        // TELÉFONO
        // ======================================================

        _CampoEtiquetado(
          label: 'Teléfono',
          controller: _telefonoCtrl,
          keyboardType:
          TextInputType.phone,
        ),

        const SizedBox(height: 13),

        // ======================================================
        // ASUNTO
        // ======================================================

        _CampoEtiquetado(
          label: 'Asunto',
          controller: _asuntoCtrl,
        ),

        const SizedBox(height: 13),

        // ======================================================
        // DESCRIPCIÓN
        // ======================================================

        _CampoEtiquetado(
          label: 'Descripción',
          controller: _descripcionCtrl,
          lineas: 4,
        ),

        const SizedBox(height: 15),

        // ======================================================
        // TRATAMIENTO DE DATOS
        // ======================================================

        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 5,
            vertical: 4,
          ),

          decoration: BoxDecoration(
            color: kInput,
            borderRadius:
            BorderRadius.circular(12),
          ),

          child: Row(
            crossAxisAlignment:
            CrossAxisAlignment.start,

            children: [
              Checkbox(
                value: _aceptaTratamientoDatos,

                activeColor: kCafePrincipal,

                onChanged: (valor) {
                  setState(() {
                    _aceptaTratamientoDatos =
                        valor ?? false;
                  });
                },
              ),

              const Expanded(
                child: Padding(
                  padding: EdgeInsets.only(
                    top: 12,
                    right: 5,
                  ),

                  child: Text(
                    'Autorizo el tratamiento de mis datos personales para dar trámite a esta solicitud.',

                    style: TextStyle(
                      color: kTextoSuave,
                      fontSize: 11,
                      height: 1.3,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),

        // ======================================================
        // MENSAJE DE ERROR
        // ======================================================

        if (_mostrarError)
          const Padding(
            padding: EdgeInsets.only(
              top: 10,
            ),

            child: Text(
              'Completa todos los campos obligatorios y acepta el tratamiento de datos.',

              style: TextStyle(
                color: Colors.red,
                fontSize: 11,
              ),
            ),
          ),

        const SizedBox(height: 20),

        // ======================================================
        // BOTÓN
        // ======================================================

        _BotonPrincipal(
          texto: 'Enviar solicitud',
          onPressed: _enviar,
        ),
      ],
    );
  }

  // ============================================================
  // COMPROBANTE
  // ============================================================

  Widget _buildComprobante() {
    return Column(
      crossAxisAlignment:
      CrossAxisAlignment.stretch,

      children: [
        const Icon(
          Icons.check_circle_outline,
          color: kDorado,
          size: 55,
        ),

        const SizedBox(height: 10),

        const Text(
          '¡Solicitud enviada!',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: kCafePrincipal,
            fontSize: 19,
            fontWeight: FontWeight.bold,
          ),
        ),

        const SizedBox(height: 5),

        const Text(
          'Tu solicitud ha sido registrada correctamente.',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: kTextoSuave,
            fontSize: 12,
          ),
        ),

        const SizedBox(height: 20),

        _ComprobanteRadicado(
          tipo: _tipo,
          nombre: _nombreCtrl.text,
          correo: _correoCtrl.text,
          asunto: _asuntoCtrl.text,
          radicado: _radicado!,
        ),

        const SizedBox(height: 20),

        _BotonPrincipal(
          texto: 'Radicar otra solicitud',
          onPressed: _reiniciar,
        ),
      ],
    );
  }
}

// ============================================================
// SELECTOR DE TIPO
// ============================================================

class _SelectorTipo extends StatelessWidget {
  final TipoPqrs seleccionado;
  final ValueChanged<TipoPqrs> onSeleccionar;

  const _SelectorTipo({
    required this.seleccionado,
    required this.onSeleccionar,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: TipoPqrs.values.map((tipo) {
        final bool activo =
            tipo == seleccionado;

        return Expanded(
          child: Padding(
            padding:
            const EdgeInsets.symmetric(
              horizontal: 3,
            ),

            child: InkWell(
              onTap: () {
                onSeleccionar(tipo);
              },

              borderRadius:
              BorderRadius.circular(12),

              child: AnimatedContainer(
                duration:
                const Duration(
                  milliseconds: 200,
                ),

                padding:
                const EdgeInsets.symmetric(
                  vertical: 12,
                  horizontal: 3,
                ),

                decoration: BoxDecoration(
                  color: activo
                      ? kCafePrincipal
                      : kInput,

                  borderRadius:
                  BorderRadius.circular(12),

                  border: Border.all(
                    color: activo
                        ? kDorado
                        : Colors.transparent,
                  ),
                ),

                child: Column(
                  children: [
                    Icon(
                      tipo.icono,
                      size: 19,

                      color: activo
                          ? kDorado
                          : kTextoOscuro,
                    ),

                    const SizedBox(height: 5),

                    Text(
                      tipo.etiqueta,
                      textAlign:
                      TextAlign.center,

                      style: TextStyle(
                        fontSize: 10,
                        fontWeight:
                        FontWeight.bold,

                        color: activo
                            ? Colors.white
                            : kTextoOscuro,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

// ============================================================
// CAMPO
// ============================================================

class _CampoEtiquetado extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final TextInputType keyboardType;
  final int lineas;

  const _CampoEtiquetado({
    required this.label,
    required this.controller,
    this.keyboardType =
        TextInputType.text,
    this.lineas = 1,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment:
      CrossAxisAlignment.start,

      children: [
        Text(
          label,

          style: const TextStyle(
            color: kTextoOscuro,
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),

        const SizedBox(height: 6),

        TextField(
          controller: controller,

          keyboardType: keyboardType,

          minLines: lineas,

          maxLines:
          lineas == 1
              ? 1
              : lineas + 1,

          style: const TextStyle(
            color: kTextoOscuro,
            fontSize: 13,
          ),

          decoration: InputDecoration(
            filled: true,

            fillColor: kInput,

            hintText:
            'Ingresa tu ${label.toLowerCase()}',

            hintStyle:
            const TextStyle(
              color: kTextoSuave,
              fontSize: 12,
            ),

            contentPadding:
            const EdgeInsets.symmetric(
              horizontal: 15,
              vertical: 12,
            ),

            border: OutlineInputBorder(
              borderRadius:
              BorderRadius.circular(
                lineas == 1
                    ? 24
                    : 14,
              ),

              borderSide:
              BorderSide.none,
            ),

            focusedBorder:
            OutlineInputBorder(
              borderRadius:
              BorderRadius.circular(
                lineas == 1
                    ? 24
                    : 14,
              ),

              borderSide:
              const BorderSide(
                color: kDorado,
                width: 2,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ============================================================
// BOTÓN PRINCIPAL
// ============================================================

class _BotonPrincipal
    extends StatelessWidget {
  final String texto;
  final VoidCallback onPressed;

  const _BotonPrincipal({
    required this.texto,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 50,

      child: ElevatedButton(
        onPressed: onPressed,

        style: ElevatedButton.styleFrom(
          backgroundColor:
          kCafePrincipal,

          foregroundColor:
          Colors.white,

          elevation: 3,

          shape:
          RoundedRectangleBorder(
            borderRadius:
            BorderRadius.circular(25),
          ),
        ),

        child: Text(
          texto,

          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}

// ============================================================
// COMPROBANTE
// ============================================================

class _ComprobanteRadicado
    extends StatelessWidget {
  final TipoPqrs tipo;
  final String nombre;
  final String correo;
  final String asunto;
  final Radicado radicado;

  const _ComprobanteRadicado({
    required this.tipo,
    required this.nombre,
    required this.correo,
    required this.asunto,
    required this.radicado,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding:
      const EdgeInsets.all(16),

      decoration: BoxDecoration(
        color: kInput,

        borderRadius:
        BorderRadius.circular(14),

        border: Border.all(
          color: kDorado,
          width: 1,
        ),
      ),

      child: Column(
        crossAxisAlignment:
        CrossAxisAlignment.start,

        children: [
          Row(
            children: [
              const Icon(
                Icons.check_circle,
                color: kCafePrincipal,
                size: 22,
              ),

              const SizedBox(width: 8),

              Expanded(
                child: Text(
                  'Tu ${tipo.etiqueta.toLowerCase()} fue radicada',

                  style:
                  const TextStyle(
                    color: kTextoOscuro,
                    fontWeight:
                    FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          _fila(
            'N° de radicado',
            radicado.numero,
          ),

          _fila(
            'Fecha',
            radicado.fecha,
          ),

          _fila(
            'Nombre',
            nombre,
          ),

          _fila(
            'Correo',
            correo,
          ),

          _fila(
            'Asunto',
            asunto,
          ),

          const SizedBox(height: 10),

          const Text(
            'Recibirás respuesta en máximo 15 días hábiles al correo registrado.',

            style: TextStyle(
              color: kTextoSuave,
              fontSize: 11,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================================
  // FILA
  // ==========================================================

  Widget _fila(
      String etiqueta,
      String valor,
      ) {
    return Padding(
      padding:
      const EdgeInsets.symmetric(
        vertical: 4,
      ),

      child: Row(
        mainAxisAlignment:
        MainAxisAlignment.spaceBetween,

        children: [
          Text(
            etiqueta,

            style:
            const TextStyle(
              color: kTextoSuave,
              fontSize: 11,
            ),
          ),

          const SizedBox(width: 10),

          Flexible(
            child: Text(
              valor.trim().isEmpty
                  ? '—'
                  : valor,

              textAlign:
              TextAlign.end,

              style:
              const TextStyle(
                color: kTextoOscuro,
                fontSize: 11,
                fontWeight:
                FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}