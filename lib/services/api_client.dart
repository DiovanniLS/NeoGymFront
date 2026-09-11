  import 'package:dio/dio.dart';
  import '../storage/token_storage.dart';

  class ApiClient {
    static final Dio dio = Dio(
      BaseOptions(
        baseUrl: 'http://192.168.20.75:8080/api/v1',
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 15),
        sendTimeout: const Duration(seconds: 15),
        headers: {
          'Content-Type': 'application/json',
        },
      ),
    );

    static void setup() {
      print('>>> APICLIENT SETUP');

      dio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) async {
            final token = await TokenStorage.getAccessToken();

            print('>>> TOKEN EXISTE: ${token != null}');

            if (token != null) {
              options.headers['Authorization'] = 'Bearer $token';
            }

            print('REQUEST: ${options.method} ${options.uri}');
            print('AUTH: ${options.headers['Authorization'] != null}');

            handler.next(options);
          },
          onResponse: (response, handler) {
            print('STATUS: ${response.statusCode}');
            print('RESPONSE: ${response.data}');
            handler.next(response);
          },
          onError: (error, handler) {
            print('ERRO: ${error.response?.statusCode}');
            print('URL: ${error.requestOptions.uri}');
            print('RESPOSTA: ${error.response?.data}');
            handler.next(error);
          },
        ),
      );
    }
  }