import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart'; // Importa el paquete
import 'TckMes.dart';
import 'package:PRETTYCORE/homepage_usu.dart';
import 'configuracion.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MapScreen extends StatefulWidget {
  final Map<String, dynamic> responseData;
  MapScreen({required this.responseData}); // Añade este constructor

  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  late GoogleMapController mapController;

  final Set<Marker> _markers = {}; // Conjunto para almacenar los marcadores
  LatLng? _center; // Coordenadas del centro
  String? _userId; // Variable para almacenar el ID del usuario
  int _selectedIndex = 0; // Índice para la navegación inferior

  @override
  void initState() {
    super.initState();
    _loadUserId().then((_) {
      fetchCoordinates(); // Llamar a la función para obtener coordenadas después de cargar el ID
    });
  }

  Future<void> _loadUserId() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _userId = prefs.getString(
          'username'); // Obtén el ID del usuario desde SharedPreferences
    });
  }

  Future<void> fetchCoordinates() async {
    if (_userId == null) {
      print('ID de usuario no disponible');
      return;
    }

    final String apiUrl = 'http://ecore.ath.cx:8091/api/Flutter/GEO/$_userId';

    try {
      final response = await http.get(Uri.parse(apiUrl));
      print('Respuesta del API: ${response.body}'); // Verifica la respuesta

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        // Accede a los datos dentro de la lista "geoubicacion"
        final geoubicacion = data['geoubicacion'];
        if (geoubicacion != null && geoubicacion.isNotEmpty) {
          final location = geoubicacion[0]; // Accede al primer elemento
          final double mapX = double.parse(location['map_X']);
          final double mapY = double.parse(location['map_Y']);

          setState(() {
            _center = LatLng(mapY, mapX); // Actualiza el centro del mapa
            _markers.add(
              Marker(
                markerId: MarkerId('location_marker'),
                position: _center!,
                infoWindow: InfoWindow(
                  title: 'Ubicación',
                  snippet: 'Mi tienda',
                ),
              ),
            );
          });
        } else {
          print('No se encontraron ubicaciones en la respuesta.');
        }
      } else {
        throw Exception('Error al cargar datos');
      }
    } catch (e) {
      print('Error: $e'); // Manejo de errores
    }
  }

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    if (index == 0) {
      final id = widget.responseData['usuarios'][0]['id'].toString();
      Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => TckMes(
                  responseData: widget.responseData,
                  id: id,
                )),
      );
    } else if (index == 2) {
      Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => ConfiguracionUsu(
                  responseData: widget.responseData,
                )),
      );
    } else if (index == 1) {
      Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) =>
                HomePageUsu(responseData: widget.responseData)),
      );
    }
  }

@override
Widget build(BuildContext context) {
  return Scaffold(
    backgroundColor: Colors.white, // Fondo blanco para todo el Scaffold
    body: _center == null // Verifica si _center ha sido inicializado
        ? Center(
            child: CircularProgressIndicator(),
          )
        : Column(
            children: [
              Container(
                height: MediaQuery.of(context).size.height /
                    2, // Ocupa la mitad de la pantalla-
                child: GoogleMap(
                  onMapCreated: _onMapCreated,
                  initialCameraPosition: CameraPosition(
                    target: _center!,
                    zoom: 20.0, // Ajusta el valor de zoom aquí
                  ),
                  markers:
                      _markers, // Pasar el conjunto de marcadores al mapa
                ),
              ),
              SizedBox(height: 150), // Margen de 30
              Container(
                width: 300, // Ancho del botón
                height: 50, // Alto del botón (igual que el ancho para hacerlo cuadrado)
                child: ElevatedButton(
                  onPressed: () {
                    // Aquí puedes agregar la lógica para actualizar la geoubicación
                    fetchCoordinates();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        Colors.black, // Color de fondo del botón (opcional)
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.zero, // Sin bordes redondeados
                    ),
                  ),
                  child: Text(
                    'Actualizar Geoubicación',
                    style: TextStyle(
                      color: Colors.white, // Color del texto en blanco
                      fontSize: 20, // Tamaño del texto a 24
                    ),
                  ),
                ),
              ),
            ],
          ),
      bottomNavigationBar: Stack(
        alignment: Alignment.bottomCenter,
        clipBehavior: Clip.none,
        children: [
          BottomAppBar(
            shape: const CircularNotchedRectangle(),
            notchMargin: 10,
            color: Colors.black,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  IconButton(
                    iconSize: 50,
                    icon: Icon(Icons.monetization_on, color: Colors.white),
                    onPressed: () => _onItemTapped(0),
                  ),
                  IconButton(
                    iconSize: 50,
                    icon: Icon(Icons.menu, color: Colors.white),
                    onPressed: () => _onItemTapped(2),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            bottom: MediaQuery.of(context).orientation == Orientation.portrait
                ? -10
                : 40,
            child: GestureDetector(
              onTap: () => _onItemTapped(1),
              child: Container(
                height: 85,
                width: 85,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.black,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 10,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: ClipOval(
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Image.asset(
                        'IMG/ALIENx.png',
                        fit: BoxFit.cover,
                        height: 100,
                        width: 100,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
