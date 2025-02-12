import 'dart:convert';
import 'homepage_crm.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:encrypt/encrypt.dart' as encrypt;
import 'homepage_crm.dart';
import 'homepage_usu.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _obscurePassword = true;

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
        throw Exception(
            'La clave pública no ha sido inicializada correctamente.');
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
    try {
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

      print('Enviando solicitud de inicio de sesión...');
      final response = await http.post(url, headers: headers, body: body);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print('Respuesta de la API: $data');

        if (data['operationResult'] != null &&
            data['operationResult']['success'] == true) {
          final prefs = await SharedPreferences.getInstance();
          prefs.setBool('isLoggedIn', true);
          prefs.setString('responseData', json.encode(data));

          var usuario = data['usuarios'][0];
          final userType = usuario['tipo'];
          prefs.setInt('userType', userType);
          prefs.setString('username', username);

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
        const SnackBar(content: Text('Error al conectar con el servidor')),
      );
      print('❌ Error al conectar con el servidor: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SingleChildScrollView(
        child: Container(
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
                decoration: InputDecoration(
                  labelText: 'Usuario',
                  labelStyle: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                  ),
                  enabledBorder: const UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.white),
                  ),
                  focusedBorder: const UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.white),
                  ),
                ),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _passwordController,
                obscureText: _obscurePassword,
                decoration: InputDecoration(
                  labelText: 'Contraseña',
                  labelStyle: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                  ),
                  enabledBorder: const UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.white),
                  ),
                  focusedBorder: const UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.white),
                  ),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword
                          ? Icons.visibility
                          : Icons.visibility_off,
                      color: Colors.white,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscurePassword = !_obscurePassword;
                      });
                    },
                  ),
                ),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: 20),
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => ForgotPasswordPage()),
                  );
                },
                child: const Text(
                  '¿Olvidaste tu contraseña?',
                  style: TextStyle(
                    color: Colors.purple,
                    fontSize: 18,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => _login(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 99, 21, 112),
                  minimumSize: const Size(double.infinity, 50),
                ),
                child: const Text(
                  'Iniciar Sesión',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ForgotPasswordPage extends StatelessWidget {
  final TextEditingController _emailController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black, // Fondo negro para el Scaffold
      appBar: AppBar(
        title: const Text(
          'Recupera tu cuenta o actívala',
          style: TextStyle(fontSize: 22), // Tamaño de fuente 18
        ),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        child: Container(
          color: Colors.black,
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              TextField(
                controller: _emailController,
                decoration: InputDecoration(
                  labelText: 'Correo Electrónico',
                  labelStyle: TextStyle(
                    color: Colors.white,
                    fontSize: 22, // Tamaño de fuente 18
                  ),
                  enabledBorder: const UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.white),
                  ),
                  focusedBorder: const UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.white),
                  ),
                ),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18, // Tamaño de fuente 18
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  final email = _emailController.text.trim();
                  if (email.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Por favor, ingresa tu correo electrónico',
                          style: TextStyle(fontSize: 18), // Tamaño de fuente 18
                        ),
                      ),
                    );
                    return;
                  }

                  final url =
                      Uri.parse('http://ecore.ath.cx:8091/api/Flutter/PassCod');
                  final headers = {'Content-Type': 'application/json'};
                  final body = json.encode({
                    'id': email,
                  });

                  try {
                    final response =
                        await http.post(url, headers: headers, body: body);
                    if (response.statusCode == 200) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ConfirmCodePage(email: email),
                        ),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Error al enviar el código',
                            style:
                                TextStyle(fontSize: 18), // Tamaño de fuente 18
                          ),
                        ),
                      );
                    }
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Error de conexión',
                          style: TextStyle(fontSize: 18), // Tamaño de fuente 18
                        ),
                      ),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      const Color.fromARGB(255, 99, 21, 112), // Color morado
                  minimumSize:
                      const Size(double.infinity, 50), // Botón más largo
                ),
                child: const Text(
                  'Continuar',
                  style: TextStyle(
                    fontSize: 18, // Tamaño de fuente 18
                    color: Colors.white, // Texto blanco
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ConfirmCodePage extends StatefulWidget {
  final String email;

  ConfirmCodePage({required this.email});

  @override
  _ConfirmCodePageState createState() => _ConfirmCodePageState();
}

class _ConfirmCodePageState extends State<ConfirmCodePage> {
  final TextEditingController _codeController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  bool _obscurePassword = true;

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
        throw Exception(
            'La clave pública no ha sido inicializada correctamente.');
      }

      final encrypter = encrypt.Encrypter(encrypt.RSA(publicKey: _publicKey));
      final encrypted = encrypter.encrypt(password);
      return encrypted.base64;
    } catch (e) {
      print('❌ Error al encriptar la contraseña: $e');
      return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black, // Fondo negro para el Scaffold
      appBar: AppBar(
        title: const Text('Confirma tu cuenta'),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        child: Container(
          color: Colors.black,
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Text(
                'Enviamos un código por correo electrónico a ${widget.email}',
                style: const TextStyle(fontSize: 20, color: Colors.white),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _codeController,
                decoration: const InputDecoration(
                  labelText: 'Ingresa el código',
                  labelStyle: TextStyle(
                    color: Colors.white,
                    fontSize: 22, // ✅ Tamaño de fuente para el label
                  ),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.white),
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.white),
                  ),
                ),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize:
                      18, // ✅ Tamaño de fuente para el texto que escribe el usuario
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _newPasswordController,
                obscureText: _obscurePassword,
                decoration: InputDecoration(
                  labelText: 'Nueva Contraseña',
                  labelStyle: const TextStyle(
                    color: Colors.white,
                    fontSize: 22, // ✅ Tamaño de fuente para el label
                  ),
                  enabledBorder: const UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.white),
                  ),
                  focusedBorder: const UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.white),
                  ),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword
                          ? Icons.visibility
                          : Icons.visibility_off,
                      color: Colors.white,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscurePassword = !_obscurePassword;
                      });
                    },
                  ),
                ),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize:
                      18, // ✅ Tamaño de fuente para el texto que escribe el usuario
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  final code = _codeController.text.trim();
                  final newPassword = _newPasswordController.text.trim();

                  if (code.isEmpty || newPassword.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text(
                              'Por favor, ingresa el código y la nueva contraseña')),
                    );
                    return;
                  }

                  if (_publicKey == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content:
                              Text('Error: Clave pública no inicializada.')),
                    );
                    return;
                  }

                  final encryptedPassword = _encryptPassword(newPassword);

                  if (encryptedPassword.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text('Error al encriptar la contraseña')),
                    );
                    return;
                  }

                  final url = Uri.parse(
                      'http://ecore.ath.cx:8091/api/Flutter/Password');
                  final headers = {'Content-Type': 'application/json'};
                  final body = json.encode({
                    'id': widget.email,
                    'password': encryptedPassword,
                    'tipo': 0,
                    'codigo': code,
                  });

                  try {
                    final response =
                        await http.post(url, headers: headers, body: body);
                    final responseData = json.decode(response.body);

                    // Imprimir la respuesta de la API en la consola
                    print('Respuesta de la API: $responseData');

                    if (response.statusCode == 200) {
                      // Verificar si operationResult es true y no hay errores
                      if (responseData['operationResult'] != null &&
                          responseData['operationResult']['success'] == true &&
                          responseData['operationResult']['errors'].isEmpty) {
                        // Verificar el campo "respuesta"
                        if (responseData['respuesta'] != null &&
                            responseData['respuesta'].isNotEmpty &&
                            responseData['respuesta'][0]['respuesta'] ==
                                'ERROR') {
                          // Si hay un mensaje de ERROR en "respuesta"
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content:
                                    Text('Error al actualizar la contraseña')),
                          );
                        } else {
                          // Si no hay errores, mostrar mensaje de éxito
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text(
                                    'Contraseña actualizada correctamente')),
                          );
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                                builder: (context) => LoginPage()),
                          );
                        }
                      } else {
                        // Si operationResult es false o hay errores
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              responseData['operationResult']['errors']
                                      .join(', ') ??
                                  'Error al actualizar la contraseña',
                            ),
                          ),
                        );
                      }
                    } else {
                      // Si el código de estado no es 200
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text('Error al actualizar la contraseña')),
                      );
                    }
                  } catch (e) {
                    // Si hay un error de conexión
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Error de conexión')),
                    );
                    print('❌ Error de conexión: $e');
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      const Color.fromARGB(255, 99, 21, 112), // Color morado
                  minimumSize:
                      const Size(double.infinity, 50), // Botón más largo
                ),
                child: const Text(
                  'Continuar',
                  style: TextStyle(
                    fontSize: 18, // Tamaño de fuente 18
                    color: Colors.white, // Texto blanco
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
