import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'info_cliente.dart';  // Importas la página infoCliente
import 'fac_cliente.dart';

class PagosPerfilPage extends StatelessWidget {
  final String diasCredito;
  final String razonSocial;
  final String calle;
  final String colonia;
  final String codigoPostal;
  final String estado;
  final String frecuencia;
  final String edoCredito;
  final String rfc;
  final String tipoFac;


  // Modifica el constructor para aceptar estos nuevos parámetros
PagosPerfilPage({
    required this.diasCredito,
    required this.razonSocial,
    required this.calle,
    required this.colonia,
    required this.codigoPostal,
    required this.estado,
    required this.frecuencia,
    required this.edoCredito,
    required this.rfc,
    required this.tipoFac,
  });


  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
appBar: AppBar(
  automaticallyImplyLeading: false, // Desactiva la flecha hacia atrás
  title: Text(
    'INFORMACIÓN',
    style: GoogleFonts.leagueSpartan(
      fontWeight: FontWeight.bold,
    ),
  ),
  bottom: const TabBar(
    tabs: [
      Tab(text: 'FISCAL'),
      Tab(text: 'COMERCIAL'),
    ],
  ),
),
        body: TabBarView(
          children: [
            // Pasa los valores a InfoCliente
            FacCliente(
              razonSocial: razonSocial,
              diasCredito: diasCredito,
              frecuencia: frecuencia,
              edoCredito: edoCredito,
              rfc: rfc,
              tipoFac: tipoFac,
            ),
            InfoCliente(
              calle: calle,
              colonia: colonia,
              codigoPostal: codigoPostal,
              estado: estado,
            ),
          ],
        ),
      ),
    );
  }
}
