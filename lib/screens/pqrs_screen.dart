import 'package:flutter/material.dart';

// ============================================================
// PALETA DE COLORES
// ============================================================

const Color kFondoApp = Color(0xFF1F0606);
const Color kRojoHeader = Color(0xFF8E0B09);
const Color kRojoHeaderClaro = Color(0xFFA1121C);
const Color kCrema = Color(0xFFF8F6F3);
const Color kInputGris = Color(0xFFE2E0DC);
const Color kTextoOscuro = Color(0xFF3A1414);
const Color kTextoSuave = Color(0xFF7A6B63);

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
  // ==========================================================
  // VARIABLES
  // ==========================================================

  TipoPqrs _tipo = TipoPqrs.peticion;

  final _nombreCtrl = TextEditingController();
  final _correoCtrl = TextEditingController();
  final _telefonoCtrl = TextEditingController();
  final _asuntoCtrl = TextEditingController();
  final _descripcionCtrl = TextEditingController();

  bool _aceptaTratamientoDatos = false;
  bool _mostrarError = false;

  Radicado? _radicado;

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
    final anio = DateTime.now().year;

    final numero =
        100000 + (DateTime.now().millisecondsSinceEpoch % 900000);

    final ahora = DateTime.now();

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
        '${ahora.day} de ${meses[ahora.month - 1]} de ${ahora.year}, '
        '${ahora.hour.toString().padLeft(2, '0')}:'
        '${ahora.minute.toString().padLeft(2, '0')}';

    return Radicado(
      numero: 'PQRS-$anio-$numero',
      fecha: fecha,
    );
  }

  // ============================================================
  // ENVIAR PQRS
  // ============================================================

  void _enviar() {
    if (!_camposCompletos || !_aceptaTratamientoDatos) {
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

  // ============================================================
  // REINICIAR FORMULARIO
  // ============================================================

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

  // ============================================================
  // ELEMENTO DEL MENÚ LATERAL
  // ============================================================

  Widget _itemMenu({
    required IconData icon,
    required String texto,
    required BuildContext contexto,
    String? ruta,
    bool esSalir = false,
  }) {
    return ListTile(
      leading: Icon(
        icon,
        color: esSalir
            ? kRojoHeader
            : const Color(0xFF5A4A42),
        size: 22,
      ),

      title: Text(
        texto,
        style: TextStyle(
          fontSize: 15,
          color: esSalir
              ? kRojoHeader
              : const Color(0xFF2D2D2D),
          fontWeight: FontWeight.w500,
        ),
      ),

      onTap: () {
        // Cerrar el menú
        Navigator.pop(contexto);

        // Navegar
        if (ruta != null) {
          Navigator.pushNamed(contexto, ruta);
        }

        // Cerrar sesión
        if (esSalir) {
          Navigator.pushReplacementNamed(
            contexto,
            '/',
          );
        }
      },
    );
  }

  // ============================================================
  // BUILD PRINCIPAL
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kFondoApp,

      // ========================================================
      // MENÚ LATERAL
      // ========================================================

      drawer: Drawer(
        width: 280,

        child: Column(
          children: [
            // --------------------------------------------------
            // CABECERA DEL MENÚ
            // --------------------------------------------------

            Container(
              width: double.infinity,

              padding: const EdgeInsets.only(
                top: 48,
                bottom: 24,
                left: 20,
              ),

              color: kRojoHeader,

              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,

                children: const [
                  Text(
                    'BUITRÓN COFFEE',

                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1,
                    ),
                  ),

                  SizedBox(height: 4),

                  Text(
                    'Menú principal',

                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),

            // --------------------------------------------------
            // OPCIONES DEL MENÚ
            // --------------------------------------------------

            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(
                  vertical: 8,
                ),

                children: [
                  // CATÁLOGO
                  _itemMenu(
                    icon: Icons.home,
                    texto: 'Catálogo',
                    contexto: context,
                    ruta: '/catalogo',
                  ),

                  // PERFIL
                  _itemMenu(
                    icon: Icons.person,
                    texto: 'Mi perfil',
                    contexto: context,
                    ruta: '/perfil',
                  ),

                  // CARRITO
                  _itemMenu(
                    icon: Icons.shopping_cart,
                    texto: 'Carrito',
                    contexto: context,
                    ruta: '/carrito',
                  ),

                  // HISTORIAL
                  _itemMenu(
                    icon: Icons.history,
                    texto: 'Historial de compras',
                    contexto: context,
                    ruta: '/historial',
                  ),

                  // UBICACIÓN
                  _itemMenu(
                    icon: Icons.location_on,
                    texto: 'Ubicación',
                    contexto: context,
                    ruta: '/mapa',
                  ),

                  // PAGOS
                  _itemMenu(
                    icon: Icons.money,
                    texto: 'Pagos',
                    contexto: context,
                    ruta: '/pagos',
                  ),

                  // RESEÑAS
                  _itemMenu(
                    icon: Icons.reviews_rounded,
                    texto: 'Reseñas',
                    contexto: context,
                    ruta: '/resenas',
                  ),

                  // PQRS
                  _itemMenu(
                    icon: Icons.feedback_outlined,
                    texto: 'PQRS',
                    contexto: context,
                    ruta: '/pqrs',
                  ),

                  const Divider(
                    height: 1,
                    indent: 20,
                    endIndent: 20,
                  ),

                  // CERRAR SESIÓN
                  _itemMenu(
                    icon: Icons.logout,
                    texto: 'Cerrar sesión',
                    contexto: context,
                    esSalir: true,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),

      // ========================================================
      // APP BAR
      // ========================================================

      appBar: AppBar(
        backgroundColor: kRojoHeader,
        foregroundColor: Colors.white,
        elevation: 0,

        title: const Text(
          'PQRS',

          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 15,
            letterSpacing: 0.5,
          ),
        ),

        actions: [
          // BOTÓN CARRITO
          IconButton(
            icon: const Icon(
              Icons.shopping_cart,
            ),

            onPressed: () {
              Navigator.pushNamed(
                context,
                '/carrito',
              );
            },
          ),
        ],
      ),

      // ========================================================
      // CONTENIDO
      // ========================================================

      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),

          child: Align(
            alignment: Alignment.topCenter,

            child: SingleChildScrollView(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(18),

                child: Container(
                  width: double.infinity,
                  color: kCrema,

                  child: Column(
                    crossAxisAlignment:
                    CrossAxisAlignment.stretch,

                    children: [
                      // HEADER INTERNO
                      _Header(
                        mostrandoComprobante:
                        _radicado != null,
                      ),

                      Padding(
                        padding:
                        const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 18,
                        ),

                        child: _radicado == null
                            ? _buildFormulario()
                            : _buildComprobante(),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ============================================================
  // FORMULARIO PQRS
  // ============================================================

  Widget _buildFormulario() {
    return Column(
      crossAxisAlignment:
      CrossAxisAlignment.stretch,

      children: [
        // ------------------------------------------------------
        // ICONO
        // ------------------------------------------------------

        Center(
          child: Container(
            width: 74,
            height: 74,

            decoration: BoxDecoration(
              shape: BoxShape.circle,

              color: kCrema,

              border: Border.all(
                color: kRojoHeader,
                width: 1,
              ),
            ),

            child: const Icon(
              Icons.forum_outlined,
              color: kRojoHeader,
              size: 34,
            ),
          ),
        ),

        const SizedBox(height: 8),

        // ------------------------------------------------------
        // TITULO
        // ------------------------------------------------------

        const Text(
          'Cuéntanos qué pasó',

          textAlign: TextAlign.center,

          style: TextStyle(
            color: kTextoOscuro,
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),

        const Text(
          'Peticiones, quejas, reclamos y sugerencias',

          textAlign: TextAlign.center,

          style: TextStyle(
            color: kTextoSuave,
            fontSize: 11,
          ),
        ),

        const SizedBox(height: 18),

        // ------------------------------------------------------
        // TIPO DE PQRS
        // ------------------------------------------------------

        _SelectorTipo(
          seleccionado: _tipo,

          onSeleccionar: (t) {
            setState(() {
              _tipo = t;
            });
          },
        ),

        const SizedBox(height: 18),

        // ------------------------------------------------------
        // NOMBRE
        // ------------------------------------------------------

        _CampoEtiquetado(
          label: 'Nombre',
          controller: _nombreCtrl,
        ),

        const SizedBox(height: 12),

        // ------------------------------------------------------
        // CORREO
        // ------------------------------------------------------

        _CampoEtiquetado(
          label: 'Correo',
          controller: _correoCtrl,
          keyboardType:
          TextInputType.emailAddress,
        ),

        const SizedBox(height: 12),

        // ------------------------------------------------------
        // TELÉFONO
        // ------------------------------------------------------

        _CampoEtiquetado(
          label: 'Teléfono',
          controller: _telefonoCtrl,
          keyboardType:
          TextInputType.phone,
        ),

        const SizedBox(height: 12),

        // ------------------------------------------------------
        // ASUNTO
        // ------------------------------------------------------

        _CampoEtiquetado(
          label: 'Asunto',
          controller: _asuntoCtrl,
        ),

        const SizedBox(height: 12),

        // ------------------------------------------------------
        // DESCRIPCIÓN
        // ------------------------------------------------------

        _CampoEtiquetado(
          label: 'Descripción',
          controller: _descripcionCtrl,
          lineas: 4,
        ),

        const SizedBox(height: 14),

        // ------------------------------------------------------
        // AUTORIZACIÓN
        // ------------------------------------------------------

        InkWell(
          onTap: () {
            setState(() {
              _aceptaTratamientoDatos =
              !_aceptaTratamientoDatos;
            });
          },

          child: Row(
            crossAxisAlignment:
            CrossAxisAlignment.start,

            children: [
              Checkbox(
                value: _aceptaTratamientoDatos,

                activeColor: kRojoHeader,

                onChanged: (v) {
                  setState(() {
                    _aceptaTratamientoDatos =
                        v ?? false;
                  });
                },
              ),

              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(
                    top: 12,
                    right: 4,
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

        // ------------------------------------------------------
        // ERROR
        // ------------------------------------------------------

        if (_mostrarError)
          const Padding(
            padding: EdgeInsets.only(top: 8),

            child: Text(
              'Completa nombre, correo, asunto y descripción, y acepta el tratamiento de datos.',

              style: TextStyle(
                color: kRojoHeaderClaro,
                fontSize: 11,
              ),
            ),
          ),

        const SizedBox(height: 18),

        // ------------------------------------------------------
        // BOTÓN ENVIAR
        // ------------------------------------------------------

        _BotonPrincipal(
          texto: 'Enviar solicitud',
          onPressed: _enviar,
        ),

        const SizedBox(height: 6),
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
        _ComprobanteRadicado(
          tipo: _tipo,
          nombre: _nombreCtrl.text,
          correo: _correoCtrl.text,
          asunto: _asuntoCtrl.text,
          radicado: _radicado!,
        ),

        const SizedBox(height: 18),

        _BotonPrincipal(
          texto: 'Radicar otra solicitud',
          onPressed: _reiniciar,
        ),

        const SizedBox(height: 6),
      ],
    );
  }
}

// ============================================================
// HEADER INTERNO DE PQRS
// ============================================================

class _Header extends StatelessWidget {
  final bool mostrandoComprobante;

  const _Header({
    required this.mostrandoComprobante,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: kRojoHeader,

      padding: const EdgeInsets.symmetric(
        vertical: 14,
        horizontal: 12,
      ),

      child: Row(
        children: [
          const SizedBox(width: 22),

          Expanded(
            child: Text(
              mostrandoComprobante
                  ? 'SOLICITUD RADICADA'
                  : 'PQRS',

              textAlign: TextAlign.center,

              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 15,
                letterSpacing: 0.5,
              ),
            ),
          ),

          const SizedBox(width: 22),
        ],
      ),
    );
  }
}

// ============================================================
// SELECTOR DE TIPO PQRS
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
        final activo = tipo == seleccionado;

        return Expanded(
          child: Padding(
            padding:
            const EdgeInsets.symmetric(
              horizontal: 4,
            ),

            child: InkWell(
              onTap: () => onSeleccionar(tipo),

              borderRadius:
              BorderRadius.circular(12),

              child: Container(
                padding:
                const EdgeInsets.symmetric(
                  vertical: 10,
                  horizontal: 4,
                ),

                decoration: BoxDecoration(
                  color: activo
                      ? kRojoHeader
                      : kInputGris,

                  borderRadius:
                  BorderRadius.circular(12),
                ),

                child: Column(
                  children: [
                    Icon(
                      tipo.icono,

                      size: 18,

                      color: activo
                          ? Colors.white
                          : kTextoOscuro,
                    ),

                    const SizedBox(height: 4),

                    Text(
                      tipo.etiqueta,

                      textAlign:
                      TextAlign.center,

                      style: TextStyle(
                        fontSize: 10,
                        fontWeight:
                        FontWeight.w600,

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
// CAMPO ETIQUETADO
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
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: kTextoOscuro,
          ),
        ),

        const SizedBox(height: 6),

        TextField(
          controller: controller,
          keyboardType: keyboardType,

          minLines: lineas,

          maxLines:
          lineas == 1 ? 1 : lineas + 2,

          style: const TextStyle(
            fontSize: 13,
            color: kTextoOscuro,
          ),

          decoration: InputDecoration(
            filled: true,

            fillColor: kInputGris,

            hintText:
            'Ingresa tu ${label.toLowerCase()}',

            hintStyle: const TextStyle(
              color: kTextoSuave,
              fontSize: 12,
            ),

            contentPadding:
            const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),

            border: OutlineInputBorder(
              borderRadius:
              BorderRadius.circular(
                lineas == 1 ? 24 : 14,
              ),

              borderSide:
              BorderSide.none,
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

class _BotonPrincipal extends StatelessWidget {
  final String texto;
  final VoidCallback onPressed;

  const _BotonPrincipal({
    required this.texto,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 46,

      child: ElevatedButton(
        onPressed: onPressed,

        style: ElevatedButton.styleFrom(
          backgroundColor: kRojoHeader,
          foregroundColor: Colors.white,

          elevation: 0,

          shape:
          RoundedRectangleBorder(
            borderRadius:
            BorderRadius.circular(24),
          ),
        ),

        child: Text(
          texto,

          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 13,
          ),
        ),
      ),
    );
  }
}

// ============================================================
// COMPROBANTE DEL RADICADO
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
      padding: const EdgeInsets.all(16),

      decoration: BoxDecoration(
        color: kInputGris,

        borderRadius:
        BorderRadius.circular(14),
      ),

      child: Column(
        crossAxisAlignment:
        CrossAxisAlignment.start,

        children: [
          Padding(
            padding:
            const EdgeInsets.only(
              bottom: 10,
            ),

            child: Row(
              children: [
                const Icon(
                  Icons.check_circle,
                  color: kRojoHeader,
                  size: 20,
                ),

                const SizedBox(width: 6),

                Text(
                  'Tu ${tipo.etiqueta.toLowerCase()} fue radicada',

                  style: const TextStyle(
                    color: kTextoOscuro,
                    fontWeight:
                    FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),

          _filaComprobante(
            'N° de radicado',
            radicado.numero,
          ),

          _filaComprobante(
            'Fecha',
            radicado.fecha,
          ),

          _filaComprobante(
            'Nombre',
            nombre,
          ),

          _filaComprobante(
            'Correo',
            correo,
          ),

          _filaComprobante(
            'Asunto',
            asunto,
          ),

          const SizedBox(height: 6),

          Text(
            'Recibirás respuesta en máximo '
                '${radicado.diasHabiles} días hábiles '
                'al correo registrado.',

            style: const TextStyle(
              fontSize: 11,
              color: kTextoSuave,
              height: 1.3,
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================================
  // FILA DEL COMPROBANTE
  // ==========================================================

  Widget _filaComprobante(
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

            style: const TextStyle(
              fontSize: 11,
              color: kTextoSuave,
            ),
          ),

          const SizedBox(width: 12),

          Flexible(
            child: Text(
              valor.trim().isEmpty
                  ? '—'
                  : valor,

              textAlign:
              TextAlign.end,

              style: const TextStyle(
                fontSize: 11,
                fontWeight:
                FontWeight.w600,
                color: kTextoOscuro,
              ),
            ),
          ),
        ],
      ),
    );
  }
}