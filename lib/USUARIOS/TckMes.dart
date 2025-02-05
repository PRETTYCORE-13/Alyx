import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'tickets_page.dart';
import 'new_ticket_page.dart';
import 'configuracion.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'TckMes.dart';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'pagos_perfil.dart';
import '../login_page.dart';
import '../homepage_usu.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TckMes App',
      theme: ThemeData(
        textTheme: TextTheme(
          bodyLarge: TextStyle(color: Colors.black), // Para texto grande
          bodyMedium: TextStyle(
              color:
                  Colors.black), // Para texto de tamaño medio (antes bodyText1)
          bodySmall: TextStyle(
              color: Colors.black), // Para texto pequeño (antes bodyText2)
          titleLarge: TextStyle(
              color:
                  Colors.black), // Para encabezados grandes (antes headline6)
        ),
      ),
      home: TckMes(
        responseData: {}, // Coloca datos simulados o reales
        id: '123', // Id de usuario de prueba
      ),
    );
  }
}

class TckMes extends StatefulWidget {
  final dynamic responseData;
  final String id;

  TckMes({required this.responseData, required this.id});

  @override
  _TckMesState createState() => _TckMesState();
}

class _TckMesState extends State<TckMes> {
  int _selectedIndex = 0;
  List<dynamic> ventas = [];
  // Agrega la declaración de _scaffoldKey aquí
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    fetchVentasData(widget.id);
  }

  Future<void> fetchVentasData(String id) async {
    final url = 'http://ecore.ath.cx:8091/api/FlutterVtas/$id';

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        // Aquí se imprime la respuesta completa
        print('Respuesta del API: $data');

        setState(() {
          ventas = data['ventas'];
        });
      } else {
        throw Exception('Failed to load ventas');
      }
    } catch (e) {
      print('Error al cargar los datos: $e');
    }
  }

  void _showVentaDetails(String id, folio) async {
    final url = 'http://ecore.ath.cx:8091/api/FlutterVtas/folio';

    final Map<String, dynamic> body = {
      'id': id,
      'folio': folio,
    };

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode(body),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        // Imprimir la respuesta completa de la consulta
        print('Respuesta de la API (Detalles de la venta): $data');
        TableRow _buildTableRow(String label, String value) {
          return TableRow(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  label,
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  value,
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          );
        }

        // Aquí se construye el contenido del modal con GridView
showDialog(
  context: context,
  builder: (BuildContext context) {
    final ventas = data['venta']; // Obtener todos los elementos de la lista 'venta'
    return AlertDialog(
      backgroundColor: Colors.black,
      insetPadding: EdgeInsets.symmetric(horizontal: 20),
      contentPadding: EdgeInsets.all(10),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      title: Text(
        'Detalles de las Ventas',
        style: TextStyle(color: Colors.white),
      ),
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Encabezados fijos que aparecen una sola vez
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    'Estado',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Expanded(
                  child: Text(
                    'Fecha de Venta',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Expanded(
                  child: Text(
                    'Fecha de Entrega',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 10),
            Divider(color: Colors.white, thickness: 1),

            // Fila con los valores de Estado, Fecha de Venta y Fecha de Entrega
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    '${ventas.isNotEmpty ? ventas[0]['estado'] ?? 'No disponible' : 'No disponible'}',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
                Expanded(
                  child: Text(
                    '${ventas.isNotEmpty ? ventas[0]['fechaVenta'] ?? 'No disponible' : 'No disponible'}',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
                Expanded(
                  child: Text(
                    '${ventas.isNotEmpty ? ventas[0]['fechaEntrega'] ?? 'No disponible' : 'No disponible'}',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
            SizedBox(height: 10),
            Divider(color: Colors.white, thickness: 1),

            // Encabezado de "Cantidad", "Costo", "Subtotal" que debe aparecer solo una vez
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    'Cantidad',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Expanded(
                  child: Text(
                    'Costo',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Expanded(
                  child: Text(
                    'Subtotal',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 10),
            Divider(color: Colors.white, thickness: 1),

            // Datos de cada venta
            ...ventas.map((venta) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Descripción del producto
                  Text(
                    '${venta['descProd'] ?? 'No disponible'}',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 5), // Espaciado entre la descripción y los detalles

                  // Fila con los valores de Cantidad, Costo y Subtotal
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          '${venta['cantidad'] ?? 'No disponible'}',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                      Expanded(
                        child: Text(
                          '${venta['costo'] ?? 'No disponible'}',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                      Expanded(
                        child: Text(
                          '${venta['subtotal'] ?? 'No disponible'}',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 10), // Espaciado entre cada producto
                ],
              );
            }).toList(),

            // Espaciado adicional
            SizedBox(height: 20),

            // Aquí agregamos el campo DESCUENTOS
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    'DESCUENTOS:',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Expanded(
                  child: Text(
                    '${ventas.isNotEmpty ? ventas[0]['descuentos'] ?? 'No disponible' : 'No disponible'}',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
            SizedBox(height: 10), // Espaciado adicional

            // Aquí agregamos el campo TOTAL
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    'TOTAL:',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Expanded(
                  child: Text(
                    '${ventas.isNotEmpty ? ventas[0]['total'] ?? 'No disponible' : 'No disponible'}',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
            SizedBox(height: 20), // Espaciado adicional

            // Espacio para el QR
            if (ventas.isNotEmpty && ventas[0]['qr'] != null && ventas[0]['qr'] != 'null') ...[
              Center(
                child: Image.memory(
                  base64Decode(ventas[0]['qr']),
                  width: 120,
                  height: 120,
                ),
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: Text('Cerrar', style: TextStyle(color: Colors.white)),
        ),
      ],
    );
  },
);















        print('Detalles de la venta: $data');
      } else {
        throw Exception('Failed to load detalles de venta');
      }
    } catch (e) {
      print('Error al cargar los detalles: $e');
    }
  }

Widget _buildVentasList() {
  if (ventas.isEmpty) {
    return Center(child: CircularProgressIndicator());
  } else {
    return Column(
      children: [
        // Encabezados de las columnas
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Center( // Centrar el texto
                child: Text(
                  'Folio',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ),
            ),
            Expanded(
              child: Center( // Centrar el texto
                child: Text(
                  'Total',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ),
            ),
            Expanded(
              child: Center( // Centrar el texto
                child: Text(
                  'Fecha',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ),
            ),
          ],
        ),
        Divider(color: Colors.black, thickness: 1), // Línea divisoria

        // Lista de ventas
        Expanded(
          child: ListView.builder(
            itemCount: ventas.length,
            itemBuilder: (context, index) {
              final venta = ventas[index];
              return ListTile(
                title: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Center( // Centrar el texto
                        child: Text(
                          '${venta['folio']}',
                          style: TextStyle(color: Colors.black),
                        ),
                      ),
                    ),
                    Expanded(
                      child: Center( // Centrar el texto
                        child: Text(
                          '${venta['total']}',
                          style: TextStyle(color: Colors.black),
                        ),
                      ),
                    ),
                    Expanded(
                      child: Center( // Centrar el texto
                        child: Text(
                          '${venta['fechaVenta']}',
                          style: TextStyle(color: Colors.black),
                        ),
                      ),
                    ),
                  ],
                ),
                onTap: () {
                  // Llamar a la función para mostrar los detalles de la venta
                  _showVentaDetails(widget.id, venta['folio'].toString());
                },
              );
            },
          ),
        ),
      ],
    );
  }
}
  void _onItemTapped(int index) {
    if (index == _selectedIndex) {
      return; // No hace nada si ya estamos en la página seleccionada
    }

    setState(() {
      _selectedIndex = index;
    });

    if (_selectedIndex == 2) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => ConfiguracionUsu(
              responseData: widget.responseData), // Configuración
        ),
      );
    } else if (_selectedIndex == 0) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) =>
              TckMes(responseData: widget.responseData, id: widget.id),
        ),
      );
    } else if (_selectedIndex == 1) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) =>
              HomePageUsu(responseData: widget.responseData), // HomePageUsu
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Colors.white, // Fondo blanco para toda la página
      body: Stack(
        children: [
          // Contenido desplazable
          // Usamos un ListView.builder, que ya es desplazable por sí mismo
          Container(
            width: double.infinity,
            height: MediaQuery.of(context).size.height,
            child: Column(
              children: [
                SizedBox(height: 50), // Espacio para la barra superior
                Expanded(
                  child: _buildVentasList(), // Lista de ventas desplazable
                ),
              ],
            ),
          ),

          // Contenido principal de la página (anterior Center eliminado)
          Center(
            child: Text(
              ' ${_selectedIndex == 0 ? '' : _selectedIndex == 1 ? 'HomePageUsu' : 'Configuración'}',
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
