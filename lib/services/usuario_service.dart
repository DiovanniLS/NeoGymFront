import 'dart:typed_data';

import 'package:dio/dio.dart';

import '../models/user_model.dart';
import 'api_client.dart';

class UsuarioService {
  final Dio _dio;

  UsuarioService([Dio? dio]) : _dio = dio ?? ApiClient.dio;

  // Cache compartilhado entre as instâncias do serviço.
  static final Map<int, Uint8List?> _cacheFotos = {};
  static final Map<int, Future<Uint8List?>> _requisicoesFotos = {};

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

  Future<void> atualizarFoto(
      String caminhoArquivo, {
        int? usuarioId,
      }) async {
    final formData = FormData.fromMap({
      'foto': await MultipartFile.fromFile(caminhoArquivo),
    });

    await _dio.post(
      '/usuarios/me/foto',
      data: formData,
    );

    // Remove a versão anterior depois que o upload for bem-sucedido.
    if (usuarioId != null) {
      invalidarCacheFoto(usuarioId);
    }
  }

  /// Busca a foto do usuário autenticado.
  Future<Uint8List?> buscarFoto() async {
    try {
      final response = await _dio.get(
        '/usuarios/me/foto',
        options: Options(responseType: ResponseType.bytes),
      );

      if (response.data == null) return null;

      return Uint8List.fromList(
        List<int>.from(response.data as List),
      );
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        return null;
      }

      rethrow;
    }
  }

  /// Busca a foto de qualquer usuário pelo ID do usuário.
  ///
  /// Requer o endpoint GET /usuarios/{usuarioId}/foto no backend.
  Future<Uint8List?> buscarFotoPorUsuarioId(int usuarioId) {
    if (_cacheFotos.containsKey(usuarioId)) {
      return Future.value(_cacheFotos[usuarioId]);
    }

    return _requisicoesFotos.putIfAbsent(usuarioId, () async {
      try {
        final response = await _dio.get(
          '/usuarios/$usuarioId/foto',
          options: Options(responseType: ResponseType.bytes),
        );

        if (response.data == null) {
          _cacheFotos[usuarioId] = null;
          return null;
        }

        final bytes = Uint8List.fromList(
          List<int>.from(response.data as List),
        );

        _cacheFotos[usuarioId] = bytes;
        return bytes;
      } on DioException catch (e) {
        if (e.response?.statusCode == 404) {
          _cacheFotos[usuarioId] = null;
          return null;
        }

        rethrow;
      } finally {
        _requisicoesFotos.remove(usuarioId);
      }
    });
  }

  static void invalidarCacheFoto(int usuarioId) {
    _cacheFotos.remove(usuarioId);
    _requisicoesFotos.remove(usuarioId);
  }
}