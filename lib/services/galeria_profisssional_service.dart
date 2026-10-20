import 'dart:typed_data';

import 'package:dio/dio.dart';

import 'package:neogym/services/api_client.dart';

import '../models/foto_galeria_profisssional.dart';

class GaleriaProfissionalService {
  final Dio _dio;

  GaleriaProfissionalService([Dio? dio])
      : _dio = dio ?? ApiClient.dio;

  Future<List<FotoGaleriaProfissional>> listarFotos(
      int usuarioId,
      ) async {
    final response = await _dio.get(
      '/profissionais/$usuarioId/fotos',
    );

    final List<dynamic> data = response.data as List<dynamic>;

    return data
        .map(
          (item) => FotoGaleriaProfissional.fromJson(
        Map<String, dynamic>.from(item),
      ),
    )
        .toList();
  }

  Future<Uint8List> carregarFoto({
    required int usuarioId,
    required int fotoId,
  }) async {
    final response = await _dio.get<List<int>>(
      '/profissionais/$usuarioId/fotos/$fotoId',
      options: Options(
        responseType: ResponseType.bytes,
      ),
    );

    final bytes = response.data;

    if (bytes == null || bytes.isEmpty) {
      throw Exception('A foto está vazia.');
    }

    return Uint8List.fromList(bytes);
  }

  Future<FotoGaleriaProfissional> adicionarFoto(
      String caminhoArquivo,
      ) async {
    final formData = FormData.fromMap({
      'foto': await MultipartFile.fromFile(
        caminhoArquivo,
      ),
    });

    final response = await _dio.post(
      '/personais/me/fotos',
      data: formData,
    );

    return FotoGaleriaProfissional.fromJson(
      Map<String, dynamic>.from(response.data),
    );
  }

  Future<void> excluirFoto(int fotoId) async {
    await _dio.delete('/personais/me/fotos/$fotoId');
  }
}