import 'package:flutter/material.dart';
import 'dart:convert'; // Importar para usar jsonEncode

class JsonPage extends StatelessWidget {
  final String ticket;

  JsonPage({Key? key, required this.ticket}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Convertir el ticket a formato JSON
    String jsonTicket = jsonEncode({'ticket': ticket});

    return Scaffold(
      appBar: AppBar(
        title: const Text('Ticket en JSON'),
      ),
      body: Container(
        color: Colors.black,
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              Text(
                jsonTicket,
                style: const TextStyle(color: Colors.white, fontSize: 16),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
