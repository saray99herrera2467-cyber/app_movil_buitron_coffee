import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class MapaScreen extends StatefulWidget {
  const MapaScreen({super.key});

  @override
  State<MapaScreen> createState() => _MapaScreenState();
}

class _MapaScreenState extends State<MapaScreen> {
  int _navIndex = 1;

  // Coordenadas aproximadas de Pitalito, Huila
  final LatLng _ubicacionEmpresa = const LatLng(
    1.8539,
    -76.0507,
  );

  @override
  Widget build(BuildContext context) {
    const rojo = Color(0xFF8B1E1E);

    return Scaffold(
      backgroundColor: Colors.white,

      appBar: AppBar(
        leading: const BackButton(color: Colors.white),
        backgroundColor: rojo,
        elevation: 0,
      ),

      body: SafeArea(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 10),
              color: rojo,
              child: const Text(
                'Mapa',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 7),
              child: const Text(
                'La empresa Buitrón Coffee está ubicada en Pitalito, Huila.',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ),

            Expanded(
              child: FlutterMap(
                options: MapOptions(
                  initialCenter: _ubicacionEmpresa,
                  initialZoom: 14,
                ),
                children: [
                  TileLayer(
                    urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    userAgentPackageName: 'com.example.buitron_coffee',
                  ),
                  MarkerLayer(
                    markers: [
                      Marker(
                        point: _ubicacionEmpresa,
                        width: 55,
                        height: 65,
                        child: Column(
                          children: const [
                            Icon(Icons.location_on, color: rojo, size: 42),
                            Text(
                              'Buitrón Coffee',
                              style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),

      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _navIndex,
        onTap: (index) {
          if (index == 3) Navigator.pop(context);
          setState(() => _navIndex = index);
        },
        type: BottomNavigationBarType.fixed,
        selectedItemColor: rojo,
        unselectedItemColor: Colors.black54,
        showSelectedLabels: false,
        showUnselectedLabels: false,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.assignment_outlined), label: 'Pedidos'),
          BottomNavigationBarItem(icon: Icon(Icons.location_on_outlined), label: 'Mapa'),
          BottomNavigationBarItem(icon: Icon(Icons.menu_book_outlined), label: 'Catálogo'),
          BottomNavigationBarItem(icon: Icon(Icons.home_outlined), label: 'Inicio'),
        ],
      ),
    );
  }
}