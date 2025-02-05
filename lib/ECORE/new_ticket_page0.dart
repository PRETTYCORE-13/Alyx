import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:google_fonts/google_fonts.dart';

class NewTicketPage extends StatefulWidget {
  final Function(String) onTicketRegistered;
  final String userId;

  NewTicketPage({Key? key, required this.onTicketRegistered, required this.userId}) : super(key: key);

  @override
  _NewTicketPageState createState() => _NewTicketPageState();
}

class _NewTicketPageState extends State<NewTicketPage> {
  final TextEditingController _descriptionController = TextEditingController();
  String? _selectedOption;
  String _nombreId = '';
  String? _ticketId;

  final String apiUrl = "http://ecore.ath.cx:8091/api/FlutterTck";

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
              // Validamos si _ticketId no es null antes de mostrar el diálogo
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
      // Error si la respuesta no es 200
      debugPrint('Error al registrar el ticket: ${response.statusCode}');
    }
  } catch (e) {
    // Error de conexión
    debugPrint('Error de conexión: $e');
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Error de conexión')),
    );
  }
}

void _showTicketDetailsDialog(String ticketId) {
  // Asegurarnos de que el ticketId no sea nulo
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
    // Si el ID no es válido, no hacemos nada
    debugPrint('El ID del ticket no es válido para mostrar los detalles');
  }
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('NUEVO TICKET'),
      ),
      body: Container(
        color: Colors.black,
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Usuario ID: $_nombreId',
              style: GoogleFonts.leagueSpartan(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
            const SizedBox(height: 16),
            DropdownButton<String>(
              value: _selectedOption,
              hint: const Text('Instancia', style: TextStyle(color: Colors.white)),
              dropdownColor: Colors.grey[850],
              items: const [
                DropdownMenuItem<String>(
                  value: 'ECOREPRD00',
                  child: Text('ECOREPRD00', style: TextStyle(color: Colors.white)),
                ),
                DropdownMenuItem<String>(
                  value: 'ECOREPRD01',
                  child: Text('ECOREPRD01', style: TextStyle(color: Colors.white)),
                ),
                DropdownMenuItem<String>(
                  value: 'ECOREPRD02',
                  child: Text('ECOREPRD02', style: const TextStyle(color: Colors.white)),
                ),
                DropdownMenuItem<String>(
                  value: 'ECOREPRD03',
                  child: Text('ECOREPRD03', style: const TextStyle(color: Colors.white)),
                ),
                DropdownMenuItem<String>(
                  value: 'ECOREPRD04',
                  child: Text('ECOREPRD04', style: const TextStyle(color: Colors.white)),
                ),
                DropdownMenuItem<String>(
                  value: 'ECOREPRD05',
                  child: Text('ECOREPRD05', style: const TextStyle(color: Colors.white)),
                ),
                DropdownMenuItem<String>(
                  value: 'ECOREPRD06',
                  child: Text('ECOREPRD06', style: const TextStyle(color: Colors.white)),
                ),
                DropdownMenuItem<String>(
                  value: 'ECOREPRD07',
                  child: Text('ECOREPRD07', style: const TextStyle(color: Colors.white)),
                ),
                DropdownMenuItem<String>(
                  value: 'ECOREPRD08',
                  child: Text('ECOREPRD08', style: const TextStyle(color: Colors.white)),
                ),
                DropdownMenuItem<String>(
                  value: 'ECOREPRD09',
                  child: Text('ECOREPRD09', style: const TextStyle(color: Colors.white)),
                ),
                DropdownMenuItem<String>(
                  value: 'ECOREPRD10',
                  child: Text('ECOREPRD10', style: const TextStyle(color: Colors.white)),
                ),
                DropdownMenuItem<String>(
                  value: 'ECOREPRD11',
                  child: Text('ECOREPRD11', style: const TextStyle(color: Colors.white)),
                ),
                DropdownMenuItem<String>(
                  value: 'ECOREPRD12',
                  child: Text('ECOREPRD12', style: const TextStyle(color: Colors.white)),
                ),
                DropdownMenuItem<String>(
                  value: 'ECOREPRD13',
                  child: Text('ECOREPRD13', style: const TextStyle(color: Colors.white)),
                ),
                DropdownMenuItem<String>(
                  value: 'ECOREPRD14',
                  child: Text('ECOREPRD14', style: const TextStyle(color: Colors.white)),
                ),
                DropdownMenuItem<String>(
                  value: 'ECOREPRD15',
                  child: Text('ECOREPRD15', style: const TextStyle(color: Colors.white)),
                ),
                DropdownMenuItem<String>(
                  value: 'ECOREPRD16',
                  child: Text('ECOREPRD16', style: const TextStyle(color: Colors.white)),
                ),
                DropdownMenuItem<String>(
                  value: 'ECOREPRD17',
                  child: Text('ECOREPRD17', style: const TextStyle(color: Colors.white)),
                ),
                DropdownMenuItem<String>(
                  value: 'ECOREPRD18',
                  child: Text('ECOREPRD18', style: const TextStyle(color: Colors.white)),
                ),
                DropdownMenuItem<String>(
                  value: 'ECOREPRD19',
                  child: Text('ECOREPRD19', style: const TextStyle(color: Colors.white)),
                ),
                DropdownMenuItem<String>(
                  value: 'ECOREPRD21',
                  child: Text('ECOREPRD21', style: const TextStyle(color: Colors.white)),
                ),
                DropdownMenuItem<String>(
                  value: 'ENNOVA00PRD',
                  child: Text('ENNOVA00PRD', style: const TextStyle(color: Colors.white)),
                ),
                DropdownMenuItem<String>(
                  value: 'ENNOVA01',
                  child: Text('ENNOVA01', style: const TextStyle(color: Colors.white)),
                ),
                DropdownMenuItem<String>(
                  value: 'ENNOVA03PRD',
                  child: Text('ENNOVA03PRD', style: const TextStyle(color: Colors.white)),
                ),
                DropdownMenuItem<String>(
                  value: 'ENNOVA04PRD',
                  child: Text('ENNOVA04PRD', style: const TextStyle(color: Colors.white)),
                ),
                DropdownMenuItem<String>(
                  value: 'ENNOVA05PRD',
                  child: Text('ENNOVA05PRD', style: const TextStyle(color: Colors.white)),
                ),
                DropdownMenuItem<String>(
                  value: 'ENNOVA06PRD',
                  child: Text('ENNOVA06PRD', style: const TextStyle(color: Colors.white)),
                ),
                DropdownMenuItem<String>(
                  value: 'ENNOVA08PRD',
                  child: Text('ENNOVA08PRD', style: const TextStyle(color: Colors.white)),
                ),
                DropdownMenuItem<String>(
                  value: 'ENNOVA0PPRD',
                  child: Text('ENNOVA0PPRD', style: const TextStyle(color: Colors.white)),
                ),
                DropdownMenuItem<String>(
                  value: 'ENNOVA11PRD',
                  child: Text('ENNOVA11PRD', style: const TextStyle(color: Colors.white)),
                ),
                DropdownMenuItem<String>(
                  value: 'ENNOVA12PRD',
                  child: Text('ENNOVA12PRD', style: const TextStyle(color: Colors.white)),
                ),
                DropdownMenuItem<String>(
                  value: 'ENNOVA13PRD',
                  child: Text('ENNOVA13PRD', style: const TextStyle(color: Colors.white)),
                ),
                DropdownMenuItem<String>(
                  value: 'ENNOVA14PRD',
                  child: Text('ENNOVA14PRD', style: const TextStyle(color: Colors.white)),
                ),
                DropdownMenuItem<String>(
                  value: 'ENNOVA16PRD',
                  child: Text('ENNOVA16PRD', style: const TextStyle(color: Colors.white)),
                ),
                DropdownMenuItem<String>(
                  value: 'ENNOVA17PRD',
                  child: Text('ENNOVA17PRD', style: const TextStyle(color: Colors.white)),
                ),
                DropdownMenuItem<String>(
                  value: 'ENNOVA18PRD',
                  child: Text('ENNOVA18PRD', style: const TextStyle(color: Colors.white)),
                ),
                DropdownMenuItem<String>(
                  value: 'ENNOVA1PPRD',
                  child: Text('ENNOVA1PPRD', style: const TextStyle(color: Colors.white)),
                ),
                DropdownMenuItem<String>(
                  value: 'ENNOVA20PRD',
                  child: Text('ENNOVA20PRD', style: const TextStyle(color: Colors.white)),
                ),
                DropdownMenuItem<String>(
                  value: 'ENNOVA21PRD',
                  child: Text('ENNOVA21PRD', style: const TextStyle(color: Colors.white)),
                ),
                DropdownMenuItem<String>(
                  value: 'ENNOVA22PRD',
                  child: Text('ENNOVA22PRD', style: const TextStyle(color: Colors.white)),
                ),
                DropdownMenuItem<String>(
                  value: 'ENNOVA23PRD',
                  child: Text('ENNOVA23PRD', style: const TextStyle(color: Colors.white)),
                ),
                DropdownMenuItem<String>(
                  value: 'ENNOVA25PRD',
                  child: Text('ENNOVA25PRD', style: const TextStyle(color: Colors.white)),
                ),
                DropdownMenuItem<String>(
                  value: 'ENNOVA26PRD',
                  child: Text('ENNOVA26PRD', style: const TextStyle(color: Colors.white)),
                ),
                DropdownMenuItem<String>(
                  value: 'ENNOVA27PRD',
                  child: Text('ENNOVA27PRD', style: const TextStyle(color: Colors.white)),
                ),
                DropdownMenuItem<String>(
                  value: 'ENNOVA28PRD',
                  child: Text('ENNOVA28PRD', style: const TextStyle(color: Colors.white)),
                ),
                DropdownMenuItem<String>(
                  value: 'ENNOVA30PRD',
                  child: Text('ENNOVA30PRD', style: const TextStyle(color: Colors.white)),
                ),
                DropdownMenuItem<String>(
                  value: 'ENNOVA31PRD',
                  child: Text('ENNOVA31PRD', style: const TextStyle(color: Colors.white)),
                ),
                DropdownMenuItem<String>(
                  value: 'ENNOVA33PRD',
                  child: Text('ENNOVA33PRD', style: const TextStyle(color: Colors.white)),
                ),
                DropdownMenuItem<String>(
                  value: 'ENNOVA34PRD',
                  child: Text('ENNOVA34PRD', style: const TextStyle(color: Colors.white)),
                ),
                DropdownMenuItem<String>(
                  value: 'FRPRODICEBESA',
                  child: Text('FRPRODICEBESA', style: const TextStyle(color: Colors.white)),
                ),
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
                labelStyle: TextStyle(color: Colors.white),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey),
                ),
              ),
              style: const TextStyle(color: Colors.white),
              maxLines: 5,
            ),
            const SizedBox(height: 20),
            Center(
              child: ElevatedButton(
                onPressed: _registerTicket,
                child: const Text('Registrar Ticket'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
