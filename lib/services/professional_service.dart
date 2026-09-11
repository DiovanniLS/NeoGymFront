import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../models/professional.dart';
import 'api_client.dart';

class ProfessionalService {
  final Dio dio = ApiClient.dio;

  Future<List<Professional>> getProfessionals() async {
    try {
      const latitude = -23.561800;
      const longitude = -46.653400;

      final response = await dio.get(
        '/profissionais/proximos',
        queryParameters: {
          'latitude': latitude,
          'longitude': longitude,
          'raioKm': 10,
          'pagina': 0,
          'tamanho': 20,
        },
      );

      final List<dynamic> content = response.data['content'];

      return content.map((item) {
        final tipo = item['tipo'];

        return Professional.fromMap({
          'id': item['id'].toString(),
          'usuarioId': item['usuarioId'],

          'name': item['nome'],
          'specialty': tipo == 'PERSONAL'
              ? 'Personal Trainer'
              : 'Nutricionista',
          'rating': 0.0,
          'distance': (item['distanciaKm'] ?? 0).toDouble(),
          'image': '',
          'online': false,
          'type': tipo == 'PERSONAL'
              ? 'Personal'
              : 'Nutri',
          'workplaces': [],
        });
      }).toList();
    } on DioException catch (e) {
      debugPrint('Erro ao buscar profissionais: ${e.message}');
      debugPrint('Status: ${e.response?.statusCode}');
      debugPrint('Resposta: ${e.response?.data}');
      rethrow;
    } catch (e) {
      debugPrint('Erro ao buscar localização: $e');
      rethrow;
    }
  }
}