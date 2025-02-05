import 'package:flutter/material.dart';

// La clase ConfiguracionEn que extiende de StatelessWidget
class ConfiguracionEn extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Configuración'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'Página de configuración',
              style: TextStyle(fontSize: 24),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Acción que se ejecuta al presionar el botón
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Configuración guardada')),
                );
              },
              child: Text('Guardar configuración'),
            ),
          ],
        ),
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(
    home: ConfiguracionEn(),
  ));
}
