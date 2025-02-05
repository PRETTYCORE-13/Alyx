import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class PagosPerfilPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3, // Número de pestañas
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            'REGRESAR',
            style: GoogleFonts.leagueSpartan(
              fontWeight: FontWeight.bold,
            ),
          ),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'INFORMACIÓN'),
              Tab(text: 'FACTURAS'),
              Tab(text: 'ARCHIVOS'),
            ],
          ),
        ),
        body: TabBarView(  // Aquí quitamos 'const'
          children: [
            Center(child: Text(
              'Contenido de Tab 2',
              style: TextStyle(color: Colors.white), // Color de texto blanco
            )),
            Center(child: Text(
              'Contenido de Tab 3',
              style: TextStyle(color: Colors.white), // Color de texto blanco
            )),
          ],
        ),
      ),
    );
  }
}
