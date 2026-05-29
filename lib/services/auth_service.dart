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

      return loginResponse;
    }

    Future<void> cadastrarProfissional({
      required bool isNutri,
      required String nome,
      required String email,
      required String senha,
      required String registro,
      required String estadoRegistro,
      //required File identidade,
      //required File documentoProfissional,
    }) async {
      try {

        final formData = FormData.fromMap({
          "nome": nome,
          "email": email,
          "senha": senha,

          if (isNutri) "crn": registro,
          if (!isNutri) "cref": registro,

          if (isNutri)
            "estadoCrn": estadoRegistro,
          if (!isNutri)
            "estadoCref": estadoRegistro,

         // "documentoIdentidade": await MultipartFile.fromFile(
           // identidade.path,
         //   contentType: DioMediaType("image", "jpeg"),
         // ),

         // "documentoProfissional": await MultipartFile.fromFile(
        //    documentoProfissional.path,
         //   contentType: DioMediaType("image", "jpeg"),
        //  ),
        });


        final data = isNutri
            ? {
          "nome": nome,
          "email": email,
          "senha": senha,
          "crn": registro,
          "estadoCrn": estadoRegistro,
        }
            : {
          "nome": nome,
          "email": email,
          "senha": senha,
          "cref": registro,
          "estadoCref": estadoRegistro,
        };

        await dio.post(
          isNutri
              ? '/auth/cadastro/nutricionista'
              : '/auth/cadastro/personal',
          data: data,
        );

      } on DioException catch (e) {
        rethrow;
      } catch (e, stack) {
        print("💥 ERRO GERAL => $e");
        print(stack);
        rethrow;
      }
    }

  }