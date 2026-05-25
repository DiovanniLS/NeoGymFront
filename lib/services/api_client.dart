import 'package:dio/dio.dart';
import '../storage/token_storage.dart';

class ApiClient {
  static final Dio dio = Dio(
    BaseOptions(
      baseUrl: 'http://10.0.2.2:8080/api/v1',
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      headers: {
        'Content-Type': 'application/json',
      },
    ),
  );

  static void setup() {
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await TokenStorage.getAccessToken();

          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }

          handler.next(options);
        },
      ),
    );
  }
}