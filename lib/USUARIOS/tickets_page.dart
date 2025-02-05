import 'tickets.dart';
import '../homepage_usu.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'json.dart';

class TicketsPage extends StatelessWidget {
  final List<String> tickets;

  TicketsPage({Key? key, required this.tickets}) : super(key: key);

  void _showNotifications(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('No tienes notificaciones nuevas.')),
    );
  }

  void _logout(BuildContext context) {
    Navigator.popUntil(context, (route) => route.isFirst);
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
     
     
      body: Container(
        color: Colors.black,
        child: tickets.isNotEmpty
            ? ListView.builder(
                itemCount: tickets.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(
                      tickets[index],
                      style: const TextStyle(color: Colors.white),
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              JsonPage(ticket: tickets[index]),
                        ),
                      );
                    },
                  );
                },
              )
            : const Center(
                child: Text(
                  'No hay tickets disponibles',
                  style: TextStyle(color: Colors.white),
                ),
              ),
      ),
    );
  }
}
