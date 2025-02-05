import 'dart:convert';
import 'package:PRETTYCORE/homepage_crm.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:encrypt/encrypt.dart' as encrypt;
import 'homepage_crm.dart';
import 'homepage_usu.dart';
import 'package:shared_preferences/shared_preferences.dart'; // Importa el paquete

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _obscurePassword = true; // Estado para controlar la visibilidad de la contraseña

  final String publicKeyPem = '''
-----BEGIN PUBLIC KEY-----
MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAr5vl8Vx9mibdm9fbjbT4
DEEEGnelccVTBeF16pnL+qOoXkxQXTdfttQfozh4sYGZ1+CWW4fuYcYPXgqB29Oh
jeAKMMPP7bqSst+pgFeVRZfI7jEdjcgduyf/Dm1iU7oo4fFDX11Wvoqsy1JTdp1G
HUUbSXlLPJrWK42YVT+9+dJ+O8igxCbSb2OA0cXHC1JrJFcDMS76mWZI/hZJd5WF
KfyLjWnOFrM9fJILq3pJF0uIfQfMY8oy7n6P7Yng3GR1pUixHJoaiRe6HghFkFxK
Nt12cksSTjOCbZisTs9PLu2qsv7eYlVlIjLdDOa089qcfKbjzL4vaV5+iI9+4Gx4
YwIDAQAB
-----END PUBLIC KEY-----
  ''';

  dynamic _publicKey;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadPublicKey();
    });
  }

  void _loadPublicKey() {
    try {
      final publicKey = encrypt.RSAKeyParser().parse(publicKeyPem);
      _publicKey = publicKey;
      print('✅ Clave pública cargada correctamente.');
    } catch (e) {
      print('❌ Error al cargar la clave pública: $e');
      _publicKey = null;
    }
  }

  String _encryptPassword(String password) {
    try {
      if (_publicKey == null) {
        throw Exception('La clave pública no ha sido inicializada correctamente.');
      }

      final encrypter = encrypt.Encrypter(encrypt.RSA(publicKey: _publicKey));
      final encrypted = encrypter.encrypt(password);
      return encrypted.base64;
    } catch (e) {
      print('❌ Error al encriptar la contraseña: $e');
      return '';
    }
  }

  Future<void> _login(BuildContext context) async {
    final String username = _usernameController.text.trim();
    final String password = _passwordController.text.trim();

    if (username.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Usuario y contraseña son obligatorios')),
      );
      return;
    }

    if (_publicKey == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error: Clave pública no inicializada.')),
      );
      return;
    }

    final encryptedPassword = _encryptPassword(password);

    if (encryptedPassword.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error al encriptar la contraseña')),
      );
      return;
    }

    final url = Uri.parse('http://ecore.ath.cx:8091/api/Flutter');
    final headers = {'Content-Type': 'application/json'};
    final body = json.encode({
      'id': username,
      'password': encryptedPassword,
    });

    try {
      final response = await http.post(url, headers: headers, body: body);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

if (data['operationResult'] != null && data['operationResult']['success'] == true) {
  final prefs = await SharedPreferences.getInstance();
  prefs.setBool('isLoggedIn', true);
  prefs.setString('responseData', json.encode(data)); // Almacena la responseData

  var usuario = data['usuarios'][0];
  final userType = usuario['tipo']; // 0 para CRM, 1 para Usu
  prefs.setInt('userType', userType);
  prefs.setString('username', username); // Guardar solo el nombre de usuario

  // Navegar a la página correspondiente
  if (userType == 0) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => HomePageCRM(responseData: data),
      ),
    );
  } else {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => HomePageUsu(responseData: data),
      ),
    );
  }
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Login fallido o errores en la API')),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Usuario o contraseña incorrectos')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Contraseña o Usuario incorrecto')),
      );
      print('❌ Error al conectar con el servidor: $e');
    }
  }

Future<void> _logout() async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.clear(); // Limpia todos los datos

  if (mounted) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LoginPage()),
    );
  }
}
  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: Colors.black,
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Image.asset(
              'IMG/ALIENx.png',
              height: 300,
              width: 300,
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _usernameController,
              decoration: const InputDecoration(
                labelText: 'Usuario',
                labelStyle: TextStyle(color: Colors.white),
              ),
              style: const TextStyle(color: Colors.white),
            ),
            TextField(
              controller: _passwordController,
              obscureText: _obscurePassword,
              decoration: InputDecoration(
                labelText: 'Contraseña',
                labelStyle: const TextStyle(color: Colors.white),
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscurePassword ? Icons.visibility : Icons.visibility_off,
                    color: Colors.white,
                  ),
                  onPressed: () {
                    setState(() {
                      _obscurePassword = !_obscurePassword;
                    });
                  },
                ),
              ),
              style: const TextStyle(color: Colors.white),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => _login(context),
              child: const Text('Iniciar Sesión'),
            ),
          ],
        ),
      ),
    );
  }
}