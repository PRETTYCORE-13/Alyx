import 'package:PRETTYCORE/homepage_usu.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../login_page.dart';
import '../homepage_usu.dart';
import 'tickets_page.dart';
import 'new_ticket_page.dart';

class TicketsPageIni extends StatefulWidget {
  @override
  _TicketsPageIniState createState() => _TicketsPageIniState();
}

class _TicketsPageIniState extends State<TicketsPageIni> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final String userId = '12345'; // Ejemplo de userId, cámbialo según lo necesites

  void _logout() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LoginPage()),
    );
  }

  void _openDrawer() {
    _scaffoldKey.currentState?.openDrawer();
  }

  void _showNotifications() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('No tienes notificaciones nuevas.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final double buttonWidth = 250;

    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Padding(
          padding: EdgeInsets.only(right: 10.0),
          child: Image.asset(
            'IMG/ALIENx.png',
            height: 50,
          ),
        ),
        backgroundColor: Colors.black,
        leading: IconButton(
          icon: const Icon(Icons.menu, color: Colors.white),
          iconSize: 40,
          onPressed: _openDrawer,
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications, color: Colors.white),
            iconSize: 40,
            onPressed: _showNotifications,
          ),
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            iconSize: 40,
            onPressed: _logout,
          ),
        ],
      ),
      drawer: Drawer(
        child: Container(
          color: Colors.black,
          child: ListView(
            padding: EdgeInsets.zero,
            children: <Widget>[
              DrawerHeader(
                decoration: BoxDecoration(
                  color: Colors.black,
                ),
                child: Text(
                  'PRETTYCORE',
                  style: GoogleFonts.leagueSpartan(
                    color: Colors.white,
                    fontSize: 24,
                  ),
                ),
              ),
              ListTile(
                title: Text(
                  'PERFIL',
                  style: GoogleFonts.leagueSpartan(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => HomePageUsu(responseData: []),
                    ),
                  );
                },
              ),
              // Otras opciones del Drawer...
            ],
          ),
        ),
      ),
      body: Container(
        color: Colors.white,
        width: double.infinity,
        height: double.infinity,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min, // Cambia el tamaño del eje principal para ajustarse al contenido
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                child: Text(
                  '¿CÓMO PODEMOS AYUDARTE EL DÍA DE HOY?',
                  style: GoogleFonts.leagueSpartan(
                    color: Colors.black,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              SizedBox(height: 32),
              SizedBox(
                width: buttonWidth,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF690769),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                  ),
                  onPressed: () {
                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      backgroundColor: Colors.transparent,
                      builder: (BuildContext context) {
                        return Container(
                          height: MediaQuery.of(context).size.height * 0.9, // Ajusta la altura del modal
                          decoration: BoxDecoration(
                            color: Colors.black,
                            borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
                          ),
                          child: NewTicketPage(
                            onTicketRegistered: (ticket) {
                              // Maneja el ticket registrado aquí, si es necesario
                              print(ticket);
                              Navigator.pop(context); // Cierra el modal después de registrar el ticket
                            },
                            userId: userId,  // Aquí pasas el userId
                            responseData: {
                              // Asegúrate de proporcionar el responseData esperado aquí
                              'usuarios': [
                                {'id': '12345'}
                              ]
                            }, // Agregar el responseData como se esperaba en NewTicketPage
                          ),
                        );
                      },
                    );
                  },
                  child: Text(
                    'ALTA DE TICKET',
                    style: GoogleFonts.leagueSpartan(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 16),
              SizedBox(
                width: buttonWidth,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => TicketsPage(tickets: []),
                      ),
                    );
                  },
                  child: Text(
                    'VER TICKETS',
                    style: GoogleFonts.leagueSpartan(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
