// lib/in_cliente/info_cliente.dart
import 'package:flutter/material.dart';
import '../homepage_usu.dart';

class InfoCliente extends StatelessWidget {
  final String calle;
  final String colonia;
  final String codigoPostal;
  final String estado;

  // Modifica el constructor para recibir los parámetros
  InfoCliente({
    required this.calle,
    required this.colonia,
    required this.codigoPostal,
    required this.estado,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize:
            Size.fromHeight(0), // Establece la altura del AppBar en 0
        child: AppBar(
            // No es necesario agregar nada aquí
            ),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Calle: $calle',
                  style: TextStyle(fontSize: 18, color: Colors.white),
                ),
                SizedBox(height: 10),
                Text(
                  'Colonia: $colonia',
                  style: TextStyle(fontSize: 18, color: Colors.white),
                ),
                SizedBox(height: 10),
                Text(
                  'Codigo Postal: $codigoPostal',
                  style: TextStyle(fontSize: 18, color: Colors.white),
                ),
                SizedBox(height: 10),
                Text(
                  'Estado: $estado',
                  style: TextStyle(fontSize: 18, color: Colors.white),
                ),
                SizedBox(height: 10),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
