import 'dart:typed_data';

import 'package:dio/dio.dart';

import '../models/user_model.dart';
import 'api_client.dart';

class UsuarioService {
  final Dio _dio;

  UsuarioService([Dio? dio]) : _dio = dio ?? ApiClient.dio;

  Future<UserModel> atualizarPerfil({
    required String nome,
    required String email,
  }) async {
    final response = await _dio.put(
      '/usuarios/me',
      data: {
        'nome': nome,
        'email': email,
      },
    );

    return UserModel(
      usuarioId: response.data['id'],
      nome: response.data['nome'],
      email: response.data['email'],
      tipo: response.data['tipo'],
    );
  }

  Future<void> atualizarFoto(String caminhoArquivo) async {
    final formData = FormData.fromMap({
      'foto': await MultipartFile.fromFile(
        caminhoArquivo,
      ),
    });

    await _dio.post(
      '/usuarios/me/foto',
      data: formData,
    );
  }

  Future<Uint8List?> buscarFoto() async {
    try {
      final response = await _dio.get(
        '/usuarios/me/foto',
        options: Options(
          responseType: ResponseType.bytes,
        ),
      );

      return Uint8List.fromList(
        response.data,
      );
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        return null;
      }

      rethrow;
    }
  }
}