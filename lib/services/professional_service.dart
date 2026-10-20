import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../models/professional.dart';
import 'api_client.dart';
import 'location_service.dart';

class ProfessionalService {
  final Dio dio = ApiClient.dio;

  List<String> _converterLinhas(dynamic valor) {
    if (valor == null) return [];

    if (valor is List) {
      return valor
          .map((item) => item.toString().trim())
          .where((item) => item.isNotEmpty)
          .toList();
    }

    return valor
        .toString()
        .split(RegExp(r'\r?\n'))
        .map((item) => item.trim())
        .where((item) => item.isNotEmpty)
        .toList();
  }

  Future<List<Professional>> getProfessionals() async {
    final position = await LocationService.getUserLocation();
    try {

      final response = await dio.get(
        '/profissionais/proximos',
        queryParameters: {
          'latitude': position.latitude,
          'longitude': position.longitude,
          'raioKm': 10,
          'pagina': 0,
          'tamanho': 20,
        },
      );

      final data = response.data;

      if (data is! Map || data['content'] is! List) {
        throw const FormatException(
          'Formato inválido na resposta de profissionais.',
        );
      }

      final List<dynamic> content = data['content'];

      final profissionais = content.map((item) {
        final Map<String, dynamic> profissional =
        Map<String, dynamic>.from(item as Map);

        final tipo =
        profissional['tipo']?.toString().toUpperCase();

        final areas = _converterLinhas(
          profissional['areasAtuacao'],
        );

        final horarios = _converterLinhas(
          profissional['horariosDisponiveis'],
        );

        return Professional.fromMap({
          'id': profissional['id']?.toString() ?? '',
          'usuarioId': profissional['usuarioId'],
          'name': profissional['nome'] ?? '',
          'email': profissional['email'] ?? '',

          // Especialidade real cadastrada pelo profissional.
          'specialty': profissional['especialidade'] ?? '',

          // Dados adicionais do perfil.
          'apresentacao': profissional['apresentacao'] ?? '',
          'areasAtuacao': areas,
          'horariosDisponiveis': horarios,

          // Dados complementares já utilizados pelo aplicativo.
          'rating': 0.0,
          'distance':
          (profissional['distanciaKm'] as num?)?.toDouble() ?? 0.0,
          'image': '',
          'online': false,
          'type': tipo == 'PERSONAL' ? 'Personal' : 'Nutri',
          'workplaces': [],
        });
      }).toList();

      for (final profissional in profissionais) {
        debugPrint(
          'Profissional: ${profissional.name} | '
              'Especialidade: ${profissional.specialty} | '
              'Apresentação: ${profissional.apresentacao} | '
              'Áreas: ${profissional.areasAtuacao} | '
              'Horários: ${profissional.horariosDisponiveis}',
        );
      }

      return profissionais;
    } on DioException catch (e) {
      debugPrint('Erro ao buscar profissionais: ${e.message}');
      debugPrint('Status: ${e.response?.statusCode}');
      debugPrint('Resposta: ${e.response?.data}');
      rethrow;
    } catch (e, stackTrace) {
      debugPrint('Erro ao processar profissionais: $e');
      debugPrintStack(stackTrace: stackTrace);
      rethrow;
    }
  }
}