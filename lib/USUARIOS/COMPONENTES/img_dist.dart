import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert'; // Para trabajar con json
import 'dart:typed_data'; // Para trabajar con Uint8List
import 'package:shared_preferences/shared_preferences.dart'; // Para usar SharedPreferences

class FloatingBubble extends StatelessWidget {
  final String id;

  FloatingBubble({required this.id});

  // Método para obtener la imagen desde la API o desde la caché
  Future<Uint8List> _fetchImageBytes() async {
    final prefs = await SharedPreferences.getInstance();
    final lastUpdated = prefs.getInt('imageLastUpdated_$id') ?? 0;
    final now = DateTime.now().millisecondsSinceEpoch;
    final cacheDuration = 60 * 60 * 1000; // 60 minutos en milisegundos

    // Verificar si los datos están en caché y no han expirado
    if (now - lastUpdated < cacheDuration) {
      final cachedImage = prefs.getString('cachedImage_$id');
      if (cachedImage != null && cachedImage.isNotEmpty) {
        try {
          return base64Decode(cachedImage);
        } catch (e) {
          print('Error al decodificar la imagen en caché: $e');
        }
      }
    }

    // Si no hay datos en caché o han expirado, obtener nuevos datos de la API
    final url = Uri.parse('http://ecore.ath.cx:8091/api/Flutter/Ima/$id');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);

      // Imprimir la respuesta completa para verificar la estructura de los datos
      print('Decoded response: $data');

      if (data['operationResult'] != null && data['operationResult']['success'] == true) {
        // Verifica que la lista de imágenes no sea nula o vacía
        if (data['imagen'] != null && data['imagen'].isNotEmpty) {
          final base64String = data['imagen'][0]['img'];
          try {
            // Decodificamos la imagen base64
            final imageBytes = base64Decode(base64String);

            // Guardar la imagen en caché
            await prefs.setString('cachedImage_$id', base64String);
            await prefs.setInt('imageLastUpdated_$id', now);

            return imageBytes;
          } catch (e) {
            throw Exception('Error al decodificar la imagen base64: $e');
          }
        } else {
          throw Exception('No image data available in response.');
        }
      } else {
        throw Exception('Failed to load image: ${data['operationResult']['errors']}');
      }
    } else {
      throw Exception('Failed to load image: ${response.statusCode}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 20,  // Asegura que la burbuja esté en la parte superior
      right: 10, // Asegura que esté en la parte derecha
      child: Material(
        color: Colors.transparent, // Fondo transparente para que no tape contenido
        child: CircleAvatar(
          radius: 30,  // Aumentamos el radio para hacer la burbuja más grande
          backgroundColor: const Color.fromARGB(255, 255, 255, 255), // Color de fondo de la burbuja
          child: FutureBuilder<Uint8List>(
            future: _fetchImageBytes(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return CircularProgressIndicator(color: Colors.white);
              } else if (snapshot.hasError) {
                return Icon(Icons.error, color: Colors.white);
              } else if (snapshot.hasData) {
                return ClipOval(
                  child: Image.memory(
                    snapshot.data!,
                    fit: BoxFit.cover,
                    width: 60,  // Ancho de la imagen igual al diámetro de la burbuja
                    height: 60, // Alto de la imagen igual al diámetro de la burbuja
                  ),
                );
              } else {
                return Icon(Icons.image, color: Colors.white);
              }
            },
          ),
        ),
      ),
    );
  }
}