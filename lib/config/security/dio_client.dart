import 'package:dio/dio.dart';

final dio = Dio();

Future<void> enviarTokenAlBackend(String token) async {
  try {
    final response = await dio.post(
      'http://192.168.1.154:8080/books-api/api/setToken', // reemplaza con tu backend real
      data: {
        'token': token,
      },
      options: Options(
        headers: {
          'Content-Type': 'application/json',
        },
      ),
    );

    print('Respuesta del servidor: ${response.data}');
  } catch (e) {
    print('Error al enviar token: $e');
  }
}

