import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'pagos_perfil.dart';
import '../login_page.dart';
import '../homepage_usu.dart';
import 'TckMes.dart';
import 'configuracion.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'img_dist.dart';



class PerfilPage extends StatefulWidget {
  final dynamic responseData;

  PerfilPage({required this.responseData});

  @override
  _PerfilPageState createState() => _PerfilPageState();
}

class GestionarPage extends StatefulWidget {
  final Map<String, TextEditingController> controllers;

  GestionarPage({required this.controllers});

  @override
  _GestionarPageState createState() => _GestionarPageState();
}

class _GestionarPageState extends State<GestionarPage> {
  bool _editable = false;

  void _confirmEdit() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.black, // Fondo negro
          title: Text(
            'Confirmar Edición',
            style: TextStyle(color: Colors.white), // Texto blanco
          ),
          content: Text(
            '¿Estás seguro que deseas editar tu información comercial?',
            style: TextStyle(color: Colors.white), // Texto blanco
          ),
          actions: <Widget>[
            TextButton(
              child: Text(
                'No',
                style: TextStyle(color: Colors.white), // Texto blanco
              ),
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).pop(); // Regresar a la página principal
              },
            ),
            TextButton(
              child: Text(
                'Sí',
                style: TextStyle(color: Colors.white), // Texto blanco
              ),
              onPressed: () {
                setState(() {
                  _editable = true;
                });
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Información Comercial',
            style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        iconTheme: IconThemeData(color: Colors.black),
      ),
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: [
            ...widget.controllers.entries.map((entry) {
              return Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: TextField(
                  controller: entry.value,
                  enabled: _editable,
                  style: TextStyle(color: Colors.black),
                  decoration: InputDecoration(
                    labelText: entry.key,
                    labelStyle: TextStyle(color: Colors.black),
                    border: OutlineInputBorder(),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.black),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.black),
                    ),
                  ),
                ),
              );
            }).toList(),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _editable
                  ? () {
                      // Aquí puedes agregar la lógica para guardar los cambios
                    }
                  : _confirmEdit,
              child: Text(_editable ? 'GUARDAR CAMBIOS' : 'EDITAR',
                  style: TextStyle(color: Colors.white)),
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(horizontal: 50, vertical: 20),
                backgroundColor: Colors.black,
              ),
            ),
            SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}

class _PerfilPageState extends State<PerfilPage> {
  String _nombreUsuario = '...';
  String _instancia = '...';
  String _rango = '...';
  String _id = '...';
  String _limiteCredito = '...';
  String _giro = '...';
  String _diasCredito = '...';
  String _razonSocial = '...';
  String _calle = '...';
  String _colonia = '...';
  String _codigoPostal = '...';
  String _estado = '...';
  String _frecuencia = '...';
  String _edoCredito = '...';
  String _rfc = '...';
  String _tipoFac = '...';
  String _ruta = '...';
  String _imagen = "";
  int _selectedIndex = 1;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  late GoogleMapController mapController;
  final Set<Marker> _markers = {};
  LatLng? _center;
  String? _userId;

  final Map<String, TextEditingController> _controllers = {};

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _loadUserId().then((_) {
      fetchCoordinates();
    });
  }

  @override
  void dispose() {
    _controllers.forEach((key, controller) {
      controller.dispose();
    });
    super.dispose();
  }

  Future<void> _loadUserId() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _userId = prefs.getString('username');
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
      print('Respuesta del API: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final geoubicacion = data['geoubicacion'];
        if (geoubicacion != null && geoubicacion.isNotEmpty) {
          final location = geoubicacion[0];
          final double mapX = double.parse(location['map_X']);
          final double mapY = double.parse(location['map_Y']);

          setState(() {
            _center = LatLng(mapY, mapX);
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
      print('Error: $e');
    }
  }

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  void _loadUserData() async {
    if (widget.responseData == null ||
        widget.responseData['usuarios'] == null ||
        widget.responseData['usuarios'].isEmpty) {
      setState(() {
        _nombreUsuario = 'Error: Datos no proporcionados';
        _instancia = 'Error: Datos no proporcionados';
        _rango = 'Error: Datos no proporcionados';
        _id = 'Error: Datos no proporcionados';
        _limiteCredito = 'Error: Datos no proporcionados';
        _giro = 'Error: Datos no proporcionados';
        _diasCredito = 'Error: Datos no proporcionados';
        _razonSocial = 'Error: Datos no proporcionados';
        _calle = 'Error: Datos no proporcionados';
        _colonia = 'Error: Datos no proporcionados';
        _codigoPostal = 'Error: Datos no proporcionados';
        _estado = 'Error: Datos no proporcionados';
        _frecuencia = 'Error: Datos no proporcionados';
        _edoCredito = 'Error: Datos no proporcionados';
        _rfc = 'Error: Datos no proporcionados';
        _tipoFac = 'Error: Datos no proporcionados';
        _ruta = 'Error: Datos no proporcionados';
      });
      print('Error: widget.responseData no contiene usuarios válidos');
      return;
    }

    final String userId = widget.responseData['usuarios'][0]['id'].toString();
    final String apiUrl = 'http://ecore.ath.cx:8091/api/Flutter/$userId';
    print('Solicitando datos a: $apiUrl');

    try {
      final response = await http.get(Uri.parse(apiUrl));
      print('Respuesta del API: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['usuarios'] != null && data['usuarios'].isNotEmpty) {
          var user = data['usuarios'][0];
          setState(() {
            _nombreUsuario = user['razon_Social'] ?? 'Nombre no disponible';
            _instancia = user['instancia'] ?? 'Instancia no disponible';
            _rango = user['rango'] ?? 'Rango no disponible';
            _id = user['id']?.toString() ?? 'ID no disponible';
            _limiteCredito = user['limiteCredito']?.toString() ??
                'limiteCredito no disponible';
            _diasCredito =
                user['diasCredito']?.toString() ?? 'diasCredito no disponible';
            _razonSocial = user['razon_Social'] ?? 'Razón Social no disponible';
            _calle = user['calle'] ?? 'Calle no disponible';
            _colonia = user['colonia'] ?? 'Colonia no disponible';
            _codigoPostal =
                user['codigoPostal'] ?? 'Código Postal no disponible';
            _estado = user['estado'] ?? 'Estado no disponible';
            _frecuencia = user['frecuencia'] ?? 'Frecuencia no disponible';
            _giro = user['giro'] ?? 'Giro no disponible';
            _edoCredito =
                user['edoCredito'] ?? 'Estado de Crédito no disponible';
            _rfc = user['rfc'] ?? 'RFC no disponible';
            _tipoFac = user['tipoFac'] ?? 'Tipo de Factura no disponible';
            _ruta = user['ruta'] ?? 'Ruta no disponible';
            _imagen = user['imagen'] ?? '';
          });

          _controllers['Calle'] = TextEditingController(text: _calle);
          _controllers['Colonia'] = TextEditingController(text: _colonia);
          _controllers['Código Postal'] =
              TextEditingController(text: _codigoPostal);
          _controllers['Estado'] = TextEditingController(text: _estado);
        } else {
          print('Usuarios no disponibles en la respuesta');
        }
      } else {
        print('Error en la respuesta: ${response.statusCode}');
      }
    } catch (e) {
      print('Excepción: $e');
      setState(() {
        _nombreUsuario = 'Error de conexión';
        _instancia = 'Error de conexión';
        _rango = 'Error de conexión';
        _id = 'Error de conexión';
        _limiteCredito = 'Error de conexión';
        _giro = 'Error de conexión';
        _diasCredito = 'Error de conexión';
        _razonSocial = 'Error de conexión';
        _calle = 'Error de conexión';
        _colonia = 'Error de conexión';
        _codigoPostal = 'Error de conexión';
        _estado = 'Error de conexión';
        _frecuencia = 'Error de conexión';
        _edoCredito = 'Error de conexión';
        _rfc = 'Error de conexión';
        _ruta = 'Error de conexión';
        _tipoFac = 'Error de conexión';
      });
    }
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

  Future<void> _saveChanges() async {
    // Aquí puedes implementar la lógica para guardar los cambios en el API
    final Map<String, String> updatedData = {};
    _controllers.forEach((key, controller) {
      updatedData[key] = controller.text;
    });

    // Ejemplo de solicitud HTTP para actualizar los datos en el servidor
    // final response = await http.put(
    //   Uri.parse('URL_DEL_API'),
    //   body: json.encode(updatedData),
    //   headers: {'Content-Type': 'application/json'},
    // );

    // if (response.statusCode == 200) {
    //   ScaffoldMessenger.of(context).showSnackBar(
    //     SnackBar(content: Text('Cambios guardados exitosamente')),
    //   );
    // } else {
    //   ScaffoldMessenger.of(context).showSnackBar(
    //     SnackBar(content: Text('Error al guardar los cambios')),
    //   );
    // }
  }

  @override
  Widget build(BuildContext context) {
    Uint8List? bytes;
    if (_imagen.isNotEmpty) {
      try {
        bytes = base64Decode(_imagen);
      } catch (e) {
        print('Error al decodificar la imagen base64: $e');
        bytes = null;
      }
    }

    // Concatenar las variables
    String direccionCompleta = '$_calle, $_colonia, $_codigoPostal, $_estado';

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(''),
        actions: [
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            if (bytes != null)
              Container(
                margin: EdgeInsets.all(10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: MediaQuery.of(context).size.width *
                          0.25, // 25% del ancho de la pantalla
                      height: MediaQuery.of(context).size.width *
                          0.25, // 25% del ancho de la pantalla
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        image: DecorationImage(
                          fit: BoxFit.cover,
                          image: MemoryImage(bytes),
                        ),
                      ),
                    ),

                    SizedBox(width: 20),
                    Text(
                      _nombreUsuario,
                      style: TextStyle(
                        fontSize: MediaQuery.of(context).size.width *
                            0.05, // 5% del ancho de la pantalla
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            SizedBox(height: 20),
            Container(
              margin: EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Mi información',
                    style: TextStyle(
                      fontSize: MediaQuery.of(context).size.width *
                          0.05, // 5% del ancho de la pantalla
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 20),
            Container(
              margin: EdgeInsets.symmetric(horizontal: 20),
              padding: EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: Colors.grey[300],
                border: Border.all(
                  color: Colors.grey,
                  width: 0,
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: Text(
                  direccionCompleta, // Aquí se muestra la dirección concatenada
                  style: TextStyle(
                    fontSize: 14, // Tamaño de fuente fijo a 18
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            SizedBox(height: 20),
            // Aquí comienza la integración de los 10 contenedores
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    children: [
                      _buildInfoContainer('Instancia', _instancia),
                      _buildInfoContainer('Rango', _rango),
                      _buildInfoContainer('Límite de Crédito', _limiteCredito),
                      _buildInfoContainer('Días de Crédito', _diasCredito),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    children: [
                      _buildInfoContainer('Gíro', _giro),
                      _buildInfoContainer('Frecuencia', _frecuencia),
                      _buildInfoContainer('Estado de Crédito', _edoCredito),
                      _buildInfoContainer('Ruta', _ruta),
                    ],
                  ),
                ),
              ],
            ),
            // Aquí termina la integración de los 10 contenedores
            SizedBox(height: 40),
            if (_center != null)
              Container(
                height: MediaQuery.of(context).size.height *
                    0.3, // 30% del alto de la pantalla
                child: GoogleMap(
                  onMapCreated: _onMapCreated,
                  initialCameraPosition: CameraPosition(
                    target: _center!,
                    zoom: 20.0,
                  ),
                  markers: _markers,
                ),
              ),
          ],
        ),
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
                    iconSize: MediaQuery.of(context).size.width *
                        0.1, // 10% del ancho de la pantalla
                    icon: Icon(Icons.monetization_on, color: Colors.white),
                    onPressed: () => _onItemTapped(0),
                  ),
                  IconButton(
                    iconSize: MediaQuery.of(context).size.width *
                        0.1, // 10% del ancho de la pantalla
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
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        HomePageUsu(responseData: widget.responseData),
                  ),
                );
              },
              child: Container(
                height: MediaQuery.of(context).size.width *
                    0.2, // 20% del ancho de la pantalla
                width: MediaQuery.of(context).size.width *
                    0.2, // 20% del ancho de la pantalla
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
                  child: Image.asset(
                    'IMG/ALIENx.png',
                    fit: BoxFit.cover,
                    height: MediaQuery.of(context).size.width *
                        0.15, // 15% del ancho de la pantalla
                    width: MediaQuery.of(context).size.width *
                        0.15, // 15% del ancho de la pantalla
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

// Método para construir los contenedores de información con tamaño relativo
  Widget _buildInfoContainer(String label, String value) {
    return FractionallySizedBox(
      widthFactor: 0.9, // 90% del ancho disponible
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        padding: EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 5,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: MediaQuery.of(context).size.width *
                    0.04, // 4% del ancho de la pantalla
                fontWeight: FontWeight.bold,
                color: Colors.grey[600],
              ),
            ),
            SizedBox(height: 5),
            Text(
              value,
              style: TextStyle(
                fontSize: MediaQuery.of(context).size.width *
                    0.045, // 4.5% del ancho de la pantalla
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
