// lib/in_cliente/info_cliente.dart
import 'package:flutter/material.dart';
import '../homepage_usu.dart';

class FacCliente extends StatelessWidget {
  final String diasCredito;
  final String razonSocial;
  final String frecuencia;
  final String edoCredito;
  final String rfc;
  final String tipoFac;

  // Modifica el constructor para recibir los parámetros
  FacCliente({
    required this.diasCredito,
    required this.razonSocial,
    required this.frecuencia,
    required this.edoCredito,
    required this.rfc,
    required this.tipoFac,
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
                  'Razón Social: $razonSocial',
                  style: TextStyle(fontSize: 18, color: Colors.white),
                ),
                SizedBox(height: 10),
                Text(
                  'Días de Crédito: $diasCredito',
                  style: TextStyle(fontSize: 18, color: Colors.white),
                ),
                SizedBox(height: 10),
                Text(
                  'Frecuencia: $frecuencia',
                  style: TextStyle(fontSize: 18, color: Colors.white),
                ),
                SizedBox(height: 10),
                Text(
                  'Estado de Credito: $edoCredito',
                  style: TextStyle(fontSize: 18, color: Colors.white),
                ),
                SizedBox(height: 10),
                Text(
                  'RFC: $rfc',
                  style: TextStyle(fontSize: 18, color: Colors.white),
                ),
                SizedBox(height: 10),
                Text(
                  'Tipo de Factura: $tipoFac',
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
