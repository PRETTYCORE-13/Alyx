import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'login_page.dart';
import 'USUARIOS/configuracion.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'USUARIOS/TckMes.dart';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../homepage_usu.dart';
import 'USUARIOS/COMPONENTES/img_dist.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class HomePageUsu extends StatefulWidget {
  final dynamic responseData;

  HomePageUsu({required this.responseData});

  @override
  _HomePageUsuState createState() => _HomePageUsuState();
}

class _HomePageUsuState extends State<HomePageUsu> {
  String _promocionales = "";
  String _nombreUsuario = '...';
  String _instancia = '...';
  String _rango = '...';
  String _id = '...';
  String _limiteCredito = '...';
  String _giro = '';
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
  String _cajas = '...';
  String _ventas = '...';
  String _promociones = '...';
  String _imagen = ""; // Para almacenar la imagen base64
  int _selectedIndex = 1; // Índice seleccionado para el BottomNavigationBar

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final double buttonWidth = 200.0;
   
  @override
  void initState() {
    super.initState();
    _checkAndShowAd();
    _loadUserData();
    _fetchAd(); // Llama a la función para obtener los datos de la promoción
  }

  bool _isAdShown = false; // Agregar un control para saber si ya se mostró el anuncio.

  Future<void> _checkAndShowAd() async {
    await _fetchAd();
    if (_promocionales.isNotEmpty && !_isAdShown) {
      setState(() {
        _isAdShown = true; // Marcar que el anuncio ya ha sido mostrado.
      });
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showAdDialog();
      });
    }
  }

  Future<void> _fetchAd() async {
    try {
      final String Id = widget.responseData['usuarios'][0]['id'].toString();
      final String apiUrl = 'http://ecore.ath.cx:8091/api/Flutter/Promocionales/$Id';
      print('Solicitando datos a: $apiUrl');

      final response = await http.get(Uri.parse(apiUrl));
      print('Código de respuesta: ${response.statusCode}');
      print('Respuesta completa: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print('Datos decodificados: $data');

        // Verifica si la clave 'promocionales' contiene datos
        if (data['promocionales'] != null && data['promocionales'].isNotEmpty) {
          var promocional = data['promocionales'][0]['promocionales'];  // Accede a la imagen base64
          if (promocional != null && promocional.isNotEmpty) {
            setState(() {
              _promocionales = promocional;
            });
            print('Imagen base64 obtenida: ${_promocionales.substring(0, _promocionales.length > 50 ? 50 : _promocionales.length)}...');
          } else {
            print('No se encontró una imagen base64 en la respuesta de promocionales');
          }
        } else {
          print('No se encontró ningún promocional en la respuesta');
        }
      } else {
        print('Error en la solicitud: Código ${response.statusCode}');
      }
    } catch (e) {
      print("Error al obtener el anuncio: $e");
    }
  }

  void _showAdDialog() {
    if (_promocionales.isEmpty) {
      print("No hay imagen promocional para mostrar");
      return;
    }

    print("Mostrando diálogo de anuncio");
    Uint8List? imageBytes;
    try {
      imageBytes = base64Decode(_promocionales);
    } catch (e) {
      print("Error al decodificar la imagen base64: $e");
      return;
    }

    showDialog(
      context: context,
      barrierDismissible: false, // No se puede cerrar tocando fuera del diálogo.
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.transparent, // Fondo transparente
          insetPadding: EdgeInsets.zero, // Eliminar el padding por defecto
          child: Stack(
            children: [
              // Imagen que ocupa todo el ancho de la pantalla
              Container(
                width: MediaQuery.of(context).size.width, // Ancho completo
                child: Image.memory(
                  imageBytes!,
                  fit: BoxFit.cover, // Ajustar la imagen para cubrir todo el espacio
                ),
              ),
              // Botón de cerrar (ícono de tache) con un contenedor blanco
              Positioned(
                top: 20, // Posición desde la parte superior
                right: 20, // Posición desde la derecha
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white, // Fondo blanco
                    borderRadius: BorderRadius.circular(20), // Borde redondeado
                  ),
                  child: IconButton(
                    icon: Icon(Icons.close, color: const Color.fromARGB(255, 111, 17, 129), size: 30), // Ícono de tache
                    onPressed: () {
                      Navigator.of(context).pop(); // Cerrar el diálogo
                      setState(() {
                        _isAdShown = false; // Permite mostrar el anuncio nuevamente si fuera necesario
                      });
                    },
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final lastUpdated = prefs.getInt('lastUpdated') ?? 0;
    final now = DateTime.now().millisecondsSinceEpoch;
    final cacheDuration = 60 * 60 * 1000; // 60 minutos en milisegundos

    if (now - lastUpdated < cacheDuration) {
      // Si los datos están en caché y no han expirado, úsalos
      setState(() {
        _nombreUsuario = prefs.getString('nombreUsuario') ?? '...';
        _instancia = prefs.getString('instancia') ?? '...';
        _rango = prefs.getString('rango') ?? '...';
        _id = prefs.getString('id') ?? '...';
        _limiteCredito = prefs.getString('limiteCredito') ?? '...';
        _giro = prefs.getString('giro') ?? '...';
        _diasCredito = prefs.getString('diasCredito') ?? '...';
        _razonSocial = prefs.getString('razonSocial') ?? '...';
        _calle = prefs.getString('calle') ?? '...';
        _colonia = prefs.getString('colonia') ?? '...';
        _codigoPostal = prefs.getString('codigoPostal') ?? '...';
        _estado = prefs.getString('estado') ?? '...';
        _frecuencia = prefs.getString('frecuencia') ?? '...';
        _edoCredito = prefs.getString('edoCredito') ?? '...';
        _rfc = prefs.getString('rfc') ?? '...';
        _tipoFac = prefs.getString('tipoFac') ?? '...';
        _ruta = prefs.getString('ruta') ?? '...';
        _cajas = prefs.getString('cajas') ?? '...';
        _ventas = prefs.getString('ventas') ?? '...';
        _promociones = prefs.getString('promociones') ?? '...';
        _imagen = prefs.getString('imagen') ?? '';
      });
      return;
    }

    // Si los datos no están en caché o han expirado, obtén nuevos datos de la API
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
        _cajas = 'Error: Datos no proporcionados';
        _promociones = 'Error: Datos no proporcionados';
        _ventas = 'Error: Datos no proporcionados';
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
            _imagen = user['imagen'] ?? ''; // Cargar la imagen base64
            _cajas = user['cajas'] ?? 'Cajas no disponible';
            _ventas = user['ventas'] ?? 'Ventas no disponible';
            _promociones = user['promociones'] ?? 'Promociones no disponible';
          });

          // Guardar los datos en caché
          await prefs.setInt('lastUpdated', now);
          await prefs.setString('nombreUsuario', _nombreUsuario);
          await prefs.setString('instancia', _instancia);
          await prefs.setString('rango', _rango);
          await prefs.setString('id', _id);
          await prefs.setString('limiteCredito', _limiteCredito);
          await prefs.setString('giro', _giro);
          await prefs.setString('diasCredito', _diasCredito);
          await prefs.setString('razonSocial', _razonSocial);
          await prefs.setString('calle', _calle);
          await prefs.setString('colonia', _colonia);
          await prefs.setString('codigoPostal', _codigoPostal);
          await prefs.setString('estado', _estado);
          await prefs.setString('frecuencia', _frecuencia);
          await prefs.setString('edoCredito', _edoCredito);
          await prefs.setString('rfc', _rfc);
          await prefs.setString('tipoFac', _tipoFac);
          await prefs.setString('ruta', _ruta);
          await prefs.setString('cajas', _cajas);
          await prefs.setString('ventas', _ventas);
          await prefs.setString('promociones', _promociones);
          await prefs.setString('imagen', _imagen);
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
        _cajas = 'Error de conexión';
        _ventas = 'Error de conexión';
        _promociones = 'Error de conexión';
      });
    }
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      File imageFile = File(image.path);
      List<int> imageBytes = await imageFile.readAsBytes();
      String base64Image = base64Encode(imageBytes);

      setState(() {
        _imagen = base64Image; // Guardamos la imagen en la variable
      });

      _uploadImage(base64Image);
    }
  }

  Future<void> _uploadImage(String base64Image) async {
    final String apiUrl = 'http://ecore.ath.cx:8091/api/Flutter/Imagen';

    final Map<String, dynamic> requestBody = {
      "id": _id, // ID del usuario
      "imagen": base64Image
    };

    try {
      final response = await http.put(
        Uri.parse(apiUrl),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(requestBody),
      );

      if (response.statusCode == 200) {
        print("Imagen actualizada correctamente");
      } else {
        print("Error al subir la imagen: ${response.statusCode}");
      }
    } catch (e) {
      print("Excepción al subir la imagen: $e");
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

  @override
  Widget build(BuildContext context) {
    Uint8List? bytes;
    if (_imagen.isNotEmpty) {
      try {
        bytes = base64Decode(_imagen); // Decodificas la imagen base64
      } catch (e) {
        print('Error al decodificar la imagen base64: $e');
        bytes = null;
      }
    }

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // Sección superior con fondo gris curvado
          Stack(
            children: [
              // Fondo gris curvado
              Container(
                height: 400,
                decoration: const BoxDecoration(
                  color: Color(0xFFE0E0E0),
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(220),
                    bottomRight: Radius.circular(220),
                  ),
                ),
              ),
              FloatingBubble(
                  id: _id), // Colócalo aquí fuera de la jerarquía normal

              // Contenido dentro del fondo curvado
              Column(
                children: [
                  const SizedBox(height: 50),

                  // Aquí mostramos la imagen con CircleImage
                  const SizedBox(height: 10),
                  Center(
                    child: Stack(
                      children: [
                        Container(
                          height: 180,
                          width: 180,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black26,
                                blurRadius: 8,
                                offset: Offset(0, 4),
                              ),
                            ],
                          ),
                          child: bytes != null
                              ? ClipOval(
                                  child: Image.memory(
                                    bytes!,
                                    fit: BoxFit.cover,
                                  ),
                                )
                              : Icon(
                                  Icons.person,
                                  size: 60,
                                  color: Colors.grey,
                                ),
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: InkWell(
                            onTap:
                                _pickImage, // Llamamos al método para seleccionar imagen
                            child: CircleAvatar(
                              backgroundColor:
                                  const Color.fromARGB(255, 141, 141, 141),
                              radius: 20,
                              child: Icon(
                                Icons.edit,
                                color: Colors.white,
                                size: 18,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  // Título principal
                  Container(
                    padding: const EdgeInsets.symmetric(
                      vertical: 5,
                      horizontal: 15,
                    ),
                    color: const Color.fromARGB(255, 150, 149, 149),
                    child: Text(
                      _nombreUsuario,
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white,
                        fontWeight:
                            FontWeight.bold, // Poner el texto en negrita
                      ),
                    ),
                  ),
                  const SizedBox(height: 5),
                  // Subtítulo o número
                  Container(
                    padding: const EdgeInsets.symmetric(
                      vertical: 5,
                      horizontal: 15,
                    ),
                    color: Colors.black,
                    child: Text(
                      _ruta,
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white,
                        fontWeight:
                            FontWeight.bold, // Poner el texto en negrita
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          // Espacio entre la sección superior y la inferior
          const SizedBox(height: 20),
          // Sección inferior con las estadísticas
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    // Primera columna
                    Column(
                      children: [
                        Text(
                          _cajas,
                          style: TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text("CAJAS\nCOMPRADAS",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[700],
                            )),
                      ],
                    ),
                    // Segunda columna
                    Column(
                      children: [
                        Text(
                          _promociones,
                          style: TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text("PROMOCIONES",
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[700],
                            )),
                      ],
                    ),
                    // Tercera columna
                    Column(
                      children: [
                        Text(
                          _ventas,
                          style: TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text("VENTAS",
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[700],
                            )),
                      ],
                    ),
                  ],
                ),

                // Iconos en la parte inferior
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment
                        .start, // Alinea los elementos hacia arriba
                    children: [
                      // Espacio entre las estadísticas y los íconos
                      const SizedBox(
                          height: 50), // Ajusta la altura según lo necesites
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.phone_iphone,
                              size: 40, color: Colors.black),
                          const SizedBox(
                              width:
                                  50), // Incrementa este valor para más separación
                          Icon(Icons.military_tech,
                              size: 40, color: Colors.amber),
                          const SizedBox(
                              width:
                                  50), // Incrementa este valor para más separación
                          Icon(Icons.circle, size: 40, color: Colors.purple),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: Stack(
        alignment: Alignment.bottomCenter,
        clipBehavior:
            Clip.none, // Permite que el botón flotante sobresalga del menú
        children: [
          BottomAppBar(
            shape: const CircularNotchedRectangle(),
            notchMargin: 10,
            color: Colors.black,
            child: Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: 16.0), // Margen lateral para separar botones
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  IconButton(
                    iconSize: 50, // Tamaño más grande para el botón
                    icon: Icon(Icons.monetization_on, color: Colors.white),
                    onPressed: () => _onItemTapped(0),
                  ),
                  IconButton(
                    iconSize: 50, // Tamaño más grande para el botón
                    icon: Icon(Icons.menu, color: Colors.white),
                    onPressed: () => _onItemTapped(2),
                  ),
                ],
              ),
            ),
          ),
          // Imagen sobresaliendo hacia arriba y en primer plano
          Positioned(
            bottom: MediaQuery.of(context).orientation == Orientation.portrait
                ? -10
                : 40, // Ajusta la posición según orientación
            child: Container(
              height: 85, // Tamaño del contenedor circular
              width: 85,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color.fromARGB(
                    0, 0, 0, 0), // Fondo negro del contenedor
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 10,
                    offset: Offset(0, 4), // Sombra hacia abajo
                  ),
                ],
              ),
              child: ClipOval(
                child: Image.asset(
                  'IMG/ALIENx.png',
                  fit: BoxFit.cover,
                  height: 70,
                  width: 70,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
