import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'homepage_crm.dart';
import 'homepage_usu.dart';
import 'login_page.dart';
import 'dart:convert';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        brightness: Brightness.dark,
        // Aplicar la fuente League Spartan a todo el texto de la aplicación
        textTheme: GoogleFonts.leagueSpartanTextTheme(
          Theme.of(context).textTheme,
        ),
      ),
      home: FutureBuilder<bool>(
        future: _checkLoginStatus(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else {
            if (snapshot.data == true) {
              return HomePageLoader(); // Cargar la página de inicio
            } else {
              return LoginPage();
            }
          }
        },
      ),
      debugShowCheckedModeBanner: false,
    );
  }

  Future<bool> _checkLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('isLoggedIn') ?? false;
  }
}

class HomePageLoader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Widget>(
      future: _getHomePage(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return LoginPage(); // En caso de error, redirigir a LoginPage
        } else {
          return snapshot.data ?? LoginPage(); // Redirigir a la página correspondiente
        }
      },
    );
  }

  Future<Widget> _getHomePage() async {
    final prefs = await SharedPreferences.getInstance();
    final userType = prefs.getInt('userType') ?? 0;
    final responseData = prefs.getString('responseData');

    if (responseData == null) {
      return LoginPage();
    }

    try {
      final decodedResponseData = json.decode(responseData);
      if (userType == 0) {
        return HomePageCRM(responseData: decodedResponseData);
      } else {
        return HomePageUsu(responseData: decodedResponseData);
      }
    } catch (e) {
      print('Error al decodificar responseData: $e');
      return LoginPage();
    }
  }
}