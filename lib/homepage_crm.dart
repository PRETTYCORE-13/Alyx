import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'login_page.dart';
import 'ECORE/tickets_page0.dart';
import 'ECORE/new_ticket_page0.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomePageCRM extends StatefulWidget {
  final dynamic responseData;

  HomePageCRM({required this.responseData});

  @override
  _HomePageCRMState createState() => _HomePageCRMState();
}

class _HomePageCRMState extends State<HomePageCRM> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  String _welcomeMessage = 'Cargando...';
  List<String> tickets = [];
  String? _ticketId;
  late List<Widget> _pages;
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();

    if (widget.responseData != null &&
        widget.responseData['usuarios'] != null &&
        widget.responseData['usuarios'].isNotEmpty) {
      var user = widget.responseData['usuarios'][0];
      _welcomeMessage = 'Bienvenido, ${user['nombre']}';
    } else {
      _welcomeMessage = 'Error al cargar los datos';
    }

    _pages = [
      _buildWelcomePage(),
      TicketsPage(tickets: tickets),
      _buildLogoutPage(), // Página temporal para Logout
    ];
  }

  Widget _buildWelcomePage() {
    return Container(
      color: Colors.white,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              _welcomeMessage,
              style: GoogleFonts.leagueSpartan(
                fontWeight: FontWeight.bold,
                color: Colors.black,
                fontSize: 24,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _navigateToNewTicketPage,
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF690769),
              ),
              child: Text(
                'CRM',
                style: GoogleFonts.leagueSpartan(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLogoutPage() {
    return Center(
      child: CircularProgressIndicator(), // Cargando antes de cerrar sesión
    );
  }

  void _navigateToNewTicketPage() {
    if (widget.responseData['usuarios'] != null &&
        widget.responseData['usuarios'].isNotEmpty) {
      var userId = widget.responseData['usuarios'][0]['id'];

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => NewTicketPage(
            userId: userId,
            onTicketRegistered: (ticket) {
              setState(() {
                tickets.add(ticket);
                _pages[1] = TicketsPage(tickets: tickets);
              });
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Ticket registrado exitosamente.'),
                  backgroundColor: Colors.green,
                ),
              );
            },
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al obtener datos del usuario.')),
      );
    }
  }

  void _onItemTapped(int index) {
    if (index == 2) { 
      setState(() {
        _selectedIndex = index; // Muestra la página temporal de Logout
      });
      _logout();
    } else {
      setState(() {
        _selectedIndex = index;
      });
    }
  }

  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear(); // Limpia todos los datos

    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LoginPage()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      body: Column(
        children: [
          Container(
            height: 50,
            color: Colors.black,
          ),
          Expanded(
            child: _pages[_selectedIndex],
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
            icon: Icon(Icons.logout, color: Colors.white),
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
