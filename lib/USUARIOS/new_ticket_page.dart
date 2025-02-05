import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:google_fonts/google_fonts.dart';
import 'package:PRETTYCORE/homepage_usu.dart';
import 'TckMes.dart';
import 'configuracion.dart';

class NewTicketPage extends StatefulWidget {
  final Function(String) onTicketRegistered;
  final String userId;
  final Map<String, dynamic> responseData;  // Añadir responseData

  NewTicketPage({Key? key, required this.onTicketRegistered, required this.userId, required this.responseData})
      : super(key: key);

  @override
  _NewTicketPageState createState() => _NewTicketPageState();
}

class _NewTicketPageState extends State<NewTicketPage> {
  final TextEditingController _descriptionController = TextEditingController();
  String? _selectedOption;
  String _nombreId = '';
  String? _ticketId;

  final String apiUrl = "http://ecore.ath.cx:8091/api/FlutterTck";
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _nombreId = widget.userId;
  }

  void _registerTicket() {
    final String description = _descriptionController.text;

    if (_selectedOption != null && description.isNotEmpty) {
      String ticket = 'Instancia: $_selectedOption\nDescripción: $description';
      widget.onTicketRegistered(ticket);
      _sendTicketToAPI(_selectedOption!, description);
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, seleccione una instancia y complete la descripción')),
      );
    }
  }

  Future<void> _sendTicketToAPI(String instance, String description) async {
    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'INST_CODIGO_K': instance,
          'APPUSR_CODIGO_K': _nombreId,
          'APPTCK_DESARROLLO': description,
        }),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        _ticketId = responseData['tickets'][0]['apptcK_CODIGO_K'].toString();

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Ticket registrado con éxito! ID: $_ticketId'),
            action: SnackBarAction(
              label: 'Ver Detalles',
              onPressed: () {
                if (_ticketId != null && _ticketId!.isNotEmpty) {
                  _showTicketDetailsDialog(_ticketId!);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('No se pudo obtener el ID del ticket')),
                  );
                }
              },
            ),
          ),
        );
      } else {
        debugPrint('Error al registrar el ticket: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error de conexión: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error de conexión')),
      );
    }
  }

  void _showTicketDetailsDialog(String ticketId) {
    if (ticketId.isNotEmpty) {
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('Detalles del Ticket'),
            content: Text('El ID de tu ticket es: $ticketId'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('Cerrar'),
              ),
            ],
          );
        },
      );
    } else {
      debugPrint('El ID del ticket no es válido para mostrar los detalles');
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    if (_selectedIndex == 0) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => HomePageUsu(responseData: widget.responseData)),
      );
    } else if (_selectedIndex == 1) {
      final id = widget.responseData['usuarios'][0]['id'].toString();
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => TckMes(responseData: widget.responseData, id: id)),
      );
    } else if (_selectedIndex == 2) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => ConfiguracionUsu(responseData: widget.responseData)),
      );
    }
  }

@override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(
      title: const Text(''),
      backgroundColor: Colors.black, // Para mantener el color negro en el AppBar
    ),
    body: Stack(
      children: [
        Container(
          color: Colors.white, // Cambié de Colors.black a Colors.white
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Usuario ID: $_nombreId',
                style: GoogleFonts.leagueSpartan(
                  color: Colors.black, // Cambié el color a negro
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
              const SizedBox(height: 16),
              DropdownButton<String>(
                value: _selectedOption,
                hint: const Text('Solicita', style: TextStyle(color: Colors.black)), // Cambié el color a negro
                dropdownColor: Colors.grey[200], // Cambié el color del dropdown a un gris claro
                items: const [
                  DropdownMenuItem<String>(value: 'Crédito', child: Text('Crédito', style: TextStyle(color: Colors.black))),
                  DropdownMenuItem<String>(value: 'Envase', child: Text('Envase', style: TextStyle(color: Colors.black))),
                  DropdownMenuItem<String>(value: 'Enfriador', child: Text('Enfriador', style: TextStyle(color: Colors.black))),
                  DropdownMenuItem<String>(value: 'Cambio de Frecuencia', child: Text('Cambio de Frecuencia', style: TextStyle(color: Colors.black))),
                  DropdownMenuItem<String>(value: 'Inmobiliario', child: Text('Inmobiliario', style: TextStyle(color: Colors.black))),
                  DropdownMenuItem<String>(value: 'Visia Supervisor', child: Text('Visia Supervisor', style: TextStyle(color: Colors.black))),
                  DropdownMenuItem<String>(value: 'Llamada Supervisor', child: Text('Llamada Supervisor', style: TextStyle(color: Colors.black))),
                  DropdownMenuItem<String>(value: 'Facturación', child: Text('Facturación', style: TextStyle(color: Colors.black))),
                ],
                onChanged: (value) {
                  setState(() {
                    _selectedOption = value;
                  });
                },
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Descripción',
                  labelStyle: TextStyle(color: Colors.black), // Cambié el color de la etiqueta a negro
                  enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.grey)),
                ),
                style: const TextStyle(color: Colors.black), // Cambié el color del texto a negro
                maxLines: 5,
                maxLength: 20,
              ),
              const SizedBox(height: 20),
              Center(
                child: ElevatedButton(
                  onPressed: _registerTicket,
                  child: const Text('Registrar Ticket'),
                  style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.purple, // El color del botón es púrpura
                  ),
                ),
              ),
            ],
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