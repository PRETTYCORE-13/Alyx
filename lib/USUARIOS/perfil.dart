import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'tickets_page.dart';
import 'new_ticket_page.dart';
import 'configuracion.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'TckMes.dart';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'pagos_perfil.dart';
import '../login_page.dart';
import '../homepage_usu.dart';

class PerfilPage extends StatefulWidget {
  final dynamic responseData;

PerfilPage({required this.responseData});

  @override
  _PerfilPageState createState() => _PerfilPageState();
}

class _PerfilPageState extends State<PerfilPage> {
  String _nombreUsuario = 'Cargando...';
  String _instancia = 'Cargando...';
  String _rango = 'Cargando...';
  String _id = 'Cargando...';
  String _limiteCredito = 'Cargando...';
  String _giro = 'Cargando';
  String _diasCredito = 'Cargando...';
  String _razonSocial = 'Cargando...';
  String _calle = 'Cargando...';
  String _colonia = 'Cargando...';
  String _codigoPostal = 'Cargando...';
  String _estado = 'Cargando...';
  String _frecuencia = 'Cargando...';
  String _edoCredito = 'Cargando...';
  String _rfc = 'Cargando...';
  String _tipoFac = 'Cargando...';
  String _ruta = 'Cargando...';
  String _imagen = ""; // Para almacenar la imagen base64
  int _selectedIndex = 1; // Índice seleccionado para el BottomNavigationBar
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  final double buttonWidth = 200.0;

  @override
  void initState() {
    super.initState();
    _loadUserData();
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

    final String Id = widget.responseData['usuarios'][0]['id'].toString();
    final String apiUrl = 'http://ecore.ath.cx:8091/api/Flutter/$Id';
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
            _limiteCredito = user['limiteCredito']?.toString() ?? 'limiteCredito no disponible';
            _diasCredito = user['diasCredito']?.toString() ?? 'diasCredito no disponible';
            _razonSocial = user['razon_Social'] ?? 'Razón Social no disponible';
            _calle = user['calle'] ?? 'Calle no disponible';
            _colonia = user['colonia'] ?? 'Colonia no disponible';
            _codigoPostal = user['codigoPostal'] ?? 'Código Postal no disponible';
            _estado = user['estado'] ?? 'Estado no disponible';
            _frecuencia = user['frecuencia'] ?? 'Frecuencia no disponible';
            _giro = user['giro'] ?? 'Giro no disponible';
            _edoCredito = user['edoCredito'] ?? 'Estado de Crédito no disponible';
            _rfc = user['rfc'] ?? 'RFC no disponible';
            _tipoFac = user['tipoFac'] ?? 'Tipo de Factura no disponible';
            _ruta = user['ruta'] ?? 'Ruta no disponible';
            _imagen = user['imagen'] ?? ''; // Cargar la imagen base64
          });
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

// Aquí, extraemos el id y lo pasamos a la página TckMes
void _onItemTapped(int index) {
  setState(() {
    _selectedIndex = index;
  });

  if (_selectedIndex == 0) {
    // Página principal
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => HomePageUsu(responseData: widget.responseData),
      ),
    );
  } else if (_selectedIndex == 1) {
    // Página de tickets o lista
    final id = widget.responseData['usuarios'][0]['id'].toString();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TckMes(responseData: widget.responseData, id: id, // Pasar el userId aquí
        ),
      ),
    );
  } else if (_selectedIndex == 2) {
    // Página de configuración
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => ConfiguracionUsu(responseData: widget.responseData)),
    );
  }
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

  return Scaffold(
    key: _scaffoldKey,
    backgroundColor: Colors.white, // Fondo blanco para toda la página
    body: Stack(
      children: [
        Column(
          children: [
            Container(
              height: 50,
              color: const Color.fromARGB(255, 0, 0, 0), // Cambiado a blanco
            ),
            Expanded(
              child: Column(
                children: [
                  SizedBox(height: 60),
                  // Nombre de usuario, centrado
                  Text(
                    _nombreUsuario,
                    style: GoogleFonts.leagueSpartan(
                      color: Colors.black,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(30.0),
                        child: Container(
                          width: 160,
                          height: 160,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2),
                          ),
                          child: ClipOval(
                            child: bytes != null
                                ? Image.memory(
                                    bytes,
                                    fit: BoxFit.cover,
                                  )
                                : Icon(Icons.account_circle, size: 80),
                          ),
                        ),
                      ),
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'VENDEDOR',
                              style: GoogleFonts.leagueSpartan(
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                                fontSize: 20,
                              ),
                            ),
                            Container(
                              width: 140, // Ajustar el tamaño
                              height: 40,
                              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              decoration: BoxDecoration(
                                color: Colors.transparent,
                                borderRadius: BorderRadius.circular(25),
                                border: Border.all(
                                  color: Color(0xFF690769),
                                  width: 4.0,
                                ),
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                _ruta,
                                style: GoogleFonts.leagueSpartan(
                                  color: Colors.black,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            SizedBox(height: 15), // Ajustar el espacio
                            Container(
                              width: 140, // Ajustar el tamaño del contenedor
                              height: 40,
                              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              decoration: BoxDecoration(
                                color: Color(0xFF690769),
                                borderRadius: BorderRadius.circular(25),
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                _giro,
                                style: GoogleFonts.leagueSpartan(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            SizedBox(height: 15), // Ajustar el espacio
                            Container(
                              width: 140, // Ajustar el tamaño
                              height: 40,
                              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              decoration: BoxDecoration(
                                color: Colors.black,
                                borderRadius: BorderRadius.circular(25),
                                border: Border.all(
                                  color: Color.fromARGB(0, 105, 7, 105),
                                  width: 4.0,
                                ),
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                _rango,
                                style: GoogleFonts.leagueSpartan(
                                  color: Colors.white, // Texto blanco
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
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
          ],
        ),
        Align(
          alignment: Alignment.bottomCenter,
          child: Container(
            margin: EdgeInsets.symmetric(horizontal: 25),
            height: 450,
            decoration: BoxDecoration(
              color: Colors.white, // Fondo blanco
              border: Border.all(
                width: 2.0,
              ),
              borderRadius: BorderRadius.circular(30.0),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(25.0),
              child: PagosPerfilPage(
                diasCredito: _diasCredito,
                razonSocial: _razonSocial,
                calle: _calle,
                colonia: _colonia,
                codigoPostal: _codigoPostal,
                estado: _estado,
                frecuencia: _frecuencia,
                edoCredito: _edoCredito,
                rfc: _rfc,
                tipoFac: _tipoFac,
              ),
            ),
            
          ),
        ),
        Positioned(
          top: 10,
          left: MediaQuery.of(context).size.width / 2 - 40,
          child: Image.asset(
            'IMG/ALIENx.png',
            height: 80,
          ),
        ),
      ],
    ),
    bottomNavigationBar: BottomNavigationBar(
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home, color: Colors.white),
          label: '',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.list, color: Colors.white),
          label: '',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.settings, color: Colors.white),
          label: '',
        ),
      ],
      currentIndex: _selectedIndex,
      selectedItemColor: Colors.purple,
      onTap: _onItemTapped,
      iconSize: 30.0,
      showSelectedLabels: false,
      showUnselectedLabels: false,
      backgroundColor: Colors.black,
    ),
  );
}
}





