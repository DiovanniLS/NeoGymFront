
  import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
  import '../models/login_response.dart';
  import '../storage/token_storage.dart';
  import 'api_client.dart';

  class AuthService {
    final Dio dio = ApiClient.dio;

    Future<void> cadastrarAluno({
      required String nome,
      required String email,
      required String senha,
    }) async {
      await dio.post(
        '/auth/cadastro/aluno',
        data: {
          "nome": nome,
          "email": email,
          "senha": senha,
          "academiaId": null,
          "peso": 80.5,
          "altura": 1.75,
          "metaAguaMl": 2500
        },
      );
    }

    Future<LoginResponse> login({
      required String email,
      required String senha,
    }) async {
      final response = await dio.post(
        '/auth/login',
        data: {
          "email": email,
          "senha": senha,
        },
      );

      final loginResponse = LoginResponse.fromJson(response.data);

      await TokenStorage.saveTokens(
        accessToken: loginResponse.accessToken,
        refreshToken: loginResponse.refreshToken,
      );

      await TokenStorage.saveUserId(
        loginResponse.usuarioId,
      );

      return loginResponse;
    }

    Future<void> cadastrarProfissional({
      required bool isNutri,
      required String nome,
      required String email,
      required String senha,
      required String registro,
      required String estadoRegistro,
      required File identidade,
      required File documentoProfissional,
    }) async {
      final Map<String, dynamic> dados = {
        'nome': nome.trim(),
        'email': email.trim(),
        'senha': senha,
        if (isNutri) ...{
          'crn': registro.trim().toUpperCase(),
          'estadoCrn': estadoRegistro.trim().toUpperCase(),
        } else ...{
          'cref': registro.trim().toUpperCase(),
          'estadoCref': estadoRegistro.trim().toUpperCase(),
        },
      };

      final formData = FormData.fromMap({
        'dados': MultipartFile.fromString(
          jsonEncode(dados),
          contentType: DioMediaType.parse('application/json'),
        ),
        'documentoIdentidade': await MultipartFile.fromFile(
          identidade.path,
          filename: identidade.path.split(Platform.pathSeparator).last,
        ),
        'documentoProfissional': await MultipartFile.fromFile(
          documentoProfissional.path,
          filename: documentoProfissional.path
              .split(Platform.pathSeparator)
              .last,
        ),
      });

      final endpoint = isNutri
          ? '/auth/cadastro/nutricionista'
          : '/auth/cadastro/personal';

      await dio.post(
        endpoint,
        data: formData,
        options: Options(
          contentType: Headers.multipartFormDataContentType,
        ),
      );

// Autentica o usuário após o cadastro.
      await login(
        email: email.trim(),
        senha: senha,
      );
    }

  }