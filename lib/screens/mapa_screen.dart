import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import 'catalogo_screen.dart';

class MapaScreen extends StatefulWidget {
  const MapaScreen({super.key});

  @override
  State<MapaScreen> createState() => _MapaScreenState();
}

class _MapaScreenState extends State<MapaScreen> {
  // ============================================================
  // PALETA DE COLORES BUITRÓN COFFEE
  // ============================================================

  static const Color cafePrincipal = Color(0xFF4E342E);
  static const Color cafeClaro = Color(0xFF795548);
  static const Color crema = Color(0xFFF5EFE6);
  static const Color cremaClaro = Color(0xFFFFFCF7);
  static const Color dorado = Color(0xFFC8A45D);
  static const Color textoOscuro = Color(0xFF3A2925);
  static const Color textoSuave = Color(0xFF756860);

  // ============================================================
  // UBICACIÓN DE LA EMPRESA
  // ============================================================

  final LatLng _ubicacionEmpresa = const LatLng(
    1.8539,
    -76.0507,
  );

  // ============================================================
  // REGRESAR AL CATÁLOGO
  // ============================================================

  void _volverAlCatalogo() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => const CatalogoScreen(),
      ),
    );
  }

  // ============================================================
  // INTERFAZ
  // ============================================================

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
        child: Column(
          children: [
            // ==================================================
            // ENCABEZADO
            // ==================================================

            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 16,
              ),
              decoration: const BoxDecoration(
                color: cremaClaro,
                border: Border(
                  bottom: BorderSide(
                    color: Color(0xFFE2D7C9),
                    width: 1,
                  ),
                ),
              ),
              child: Column(
                children: [
                  const Icon(
                    Icons.location_on,
                    color: dorado,
                    size: 30,
                  ),

                  const SizedBox(height: 5),

                  const Text(
                    'MAPA',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: cafePrincipal,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1,
                    ),
                  ),

                  const SizedBox(height: 5),

                  Text(
                    'Encuentra nuestra ubicación en Pitalito, Huila.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: textoSuave,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),

            // ==================================================
            // INFORMACIÓN DE UBICACIÓN
            // ==================================================

            Container(
              width: double.infinity,
              margin: const EdgeInsets.fromLTRB(
                14,
                12,
                14,
                12,
              ),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: cremaClaro,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: const Color(0xFFE2D7C9),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: crema,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.storefront,
                      color: cafePrincipal,
                      size: 26,
                    ),
                  ),

                  const SizedBox(width: 12),

                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Buitrón Coffee',
                          style: TextStyle(
                            color: textoOscuro,
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 3),
                        Text(
                          'Pitalito, Huila, Colombia',
                          style: TextStyle(
                            color: textoSuave,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const Icon(
                    Icons.location_pin,
                    color: dorado,
                    size: 27,
                  ),
                ],
              ),
            ),

            // ==================================================
            // MAPA
            // ==================================================

            Expanded(
              child: Container(
                margin: const EdgeInsets.fromLTRB(
                  14,
                  0,
                  14,
                  14,
                ),
                clipBehavior: Clip.antiAlias,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: const Color(0xFFD8C9B8),
                    width: 1,
                  ),
                ),
                child: FlutterMap(
                  options: MapOptions(
                    initialCenter: _ubicacionEmpresa,
                    initialZoom: 14,
                  ),

                  children: [
                    // ==========================================
                    // MAPA OPEN STREET MAP
                    // ==========================================

                    TileLayer(
                      urlTemplate:
                      'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName:
                      'com.example.buitron_coffee',
                    ),

                    // ==========================================
                    // MARCADOR
                    // ==========================================

                    MarkerLayer(
                      markers: [
                        Marker(
                          point: _ubicacionEmpresa,
                          width: 150,
                          height: 85,

                          child: const Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.location_on,
                                color: cafePrincipal,
                                size: 45,
                              ),

                              SizedBox(height: 2),

                              DecoratedBox(
                                decoration: BoxDecoration(
                                  color: cremaClaro,
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(8),
                                  ),
                                ),
                                child: Padding(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  child: Text(
                                    'Buitrón Coffee',
                                    style: TextStyle(
                                      color: textoOscuro,
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}