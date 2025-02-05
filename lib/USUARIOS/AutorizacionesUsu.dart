// AutorizacionesUsu - Página principal
import 'package:flutter/material.dart';

void main() {
  runApp(AutorizacionesUsuApp());
}

class AutorizacionesUsuApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AutorizacionesUsu',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: AutorizacionesUsuHomePage(),
    );
  }
}

class AutorizacionesUsuHomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('AutorizacionesUsu'),
      ),
      body: Center(
        child: Text(
          'Bienvenido a AutorizacionesUsu',
          style: TextStyle(fontSize: 20),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        child: Icon(Icons.add),
        tooltip: 'Nueva autorización',
      ),
    );
  }
}
