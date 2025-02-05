import 'package:flutter/material.dart';
import 'new_ticket_page.dart';
import 'AutorizacionesUsu.dart';
import 'TckMes.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../login_page.dart';
import '../homepage_usu.dart';
import 'package:PRETTYCORE/USUARIOS/perfil_page.dart';
import 'Geoubicacion.dart';

class ConfiguracionUsu extends StatefulWidget {
  final dynamic responseData;

  ConfiguracionUsu({required this.responseData});

  @override
  _ConfiguracionUsuState createState() => _ConfiguracionUsuState();
}

class _ConfiguracionUsuState extends State<ConfiguracionUsu> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  int _selectedIndex = 2;

  Future<void> _showLogoutConfirmationDialog() async {
    showDialog(
      context: context,
      barrierDismissible: false, // No se puede cerrar tocando fuera del cuadro
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.black, // Color de fondo del modal
          title: Text(
            '¿Estás seguro de que deseas salir?',
            style: TextStyle(
              color: Colors.white, // Color de las letras del título
              fontSize: 22, // Tamaño de la letra del título
            ),
          ),
          actions: <Widget>[
            // Row para separar los botones
            Row(
              mainAxisAlignment:
                  MainAxisAlignment.spaceBetween, // Separar botones
              children: <Widget>[
                TextButton(
                  onPressed: () {
                    Navigator.of(context)
                        .pop(); // Cierra el modal sin hacer logout
                  },
                  style: TextButton.styleFrom(
                    backgroundColor: Colors.white, // Fondo blanco para el botón
                  ),
                  child: Text(
                    'No',
                    style: TextStyle(
                      color: Colors.purple, // Color del texto "No"
                      fontSize: 28, // Tamaño de la letra del botón "No"
                      fontWeight: FontWeight.bold, // Negrita
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    _logout(); // Llama a la función de logout
                    Navigator.of(context)
                        .pop(); // Cierra el modal después de hacer logout
                  },
                  style: TextButton.styleFrom(
                    backgroundColor: Colors.white, // Fondo blanco para el botón
                  ),
                  child: Text(
                    'Sí',
                    style: TextStyle(
                      color: Colors.purple, // Color del texto "Sí"
                      fontSize: 28, // Tamaño de la letra del botón "Sí"
                      fontWeight: FontWeight.bold, // Negrita
                    ),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear(); // Limpia las preferencias compartidas

    // Aquí puedes limpiar cualquier otro estado que tengas en la aplicación
    // Por ejemplo, si tienes un singleton o variables estáticas, reinícialas aquí

    if (mounted) {
      // Navega a la página de login y elimina todas las rutas anteriores
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => LoginPage()),
        (Route<dynamic> route) => false,
      );
    }
  }

  void _onItemTapped(int index) {
    if (_selectedIndex == index) {}

    setState(() {
      _selectedIndex = index;
    });

    if (_selectedIndex == 0) {
      final id = widget.responseData['usuarios'][0]['id'].toString();
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => TckMes(
            responseData: widget.responseData,
            id: id,
          ),
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
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Container(
          width: double.infinity,
          height: MediaQuery.of(context).size.height,
          child: Stack(
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Fila para los botones de Perfil y Geoubicación
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Botón Perfil
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => PerfilPage(
                                  responseData: widget.responseData,
                                ),
                              ),
                            );
                          },
                          child: Container(
                            height: 100,
                            margin: EdgeInsets.all(10),
                            padding: EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Colors.black,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Image.asset(
                                  'IMG/ALIENx.png',
                                  width: 40,
                                  height: 40,
                                ),
                                SizedBox(height: 5),
                                Text(
                                  'PERFIL',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),

// Botón Geoubicación
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    MapScreen(responseData: widget.responseData,), // Asegúrate de que GeoUbiPage esté definida
                              ),
                            );
                          },
                          child: Container(
                            height: 100,
                            margin: EdgeInsets.all(10),
                            padding: EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Colors.black,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.location_on,
                                  color: Colors.white,
                                  size: 40,
                                ),
                                SizedBox(height: 5),
                                Text(
                                  'GEOUBICACIÓN',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  // Botón Salir (Cerrar sesión)
                  GestureDetector(
                    onTap: _showLogoutConfirmationDialog,
                    child: Container(
                      height: 80,
                      margin: EdgeInsets.all(10),
                      padding: EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.black,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Center(
                        child: Icon(
                          Icons.logout,
                          color: Colors.white,
                          size: 50,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
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
