import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:neogym/Resources/neo_gym_colors.dart';
import 'package:neogym/Views/escolher_perfil.dart';
import 'package:neogym/services/auth_service.dart';
import 'package:provider/provider.dart';

import '../models/user_model.dart';
import '../view_model/AuthViewModel.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController emailValue = TextEditingController();
  final TextEditingController passValue = TextEditingController();

  final AuthService authService = AuthService();

  bool isPasswordVisible = false;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    loginAnonimo();
  }

  Future<void> loginAnonimo() async {
    try {
      await FirebaseAuth.instance.signInAnonymously();
      print("Login anônimo feito");
    } catch (e) {
      print("Erro login anônimo: $e");
    }
  }
  @override
  void dispose() {
    emailValue.dispose();
    passValue.dispose();
    super.dispose();
  }

  Future<void> fazerLogin() async {
    FocusScope.of(context).unfocus();

    if (emailValue.text.trim().isEmpty ||
        passValue.text.trim().isEmpty) {
      mostrarMensagem('Preencha todos os campos');
      return;
    }

    try {
      setState(() => isLoading = true);

      final loginResponse = await authService.login(
        email: emailValue.text.trim(),
        senha: passValue.text.trim(),
      );


      final user = UserModel(
        nome: loginResponse.nome,
        email: loginResponse.email,
        tipo: loginResponse.tipo,
      );

      context.read<AuthViewModel>().setUser(user);

      Navigator.pushReplacementNamed(context, '/home');

    } on DioException catch (e) {
      final data = e.response?.data;

      String msg = 'Erro ao fazer login';

      if (data is Map && data['message'] != null) {
        msg = data['message'];
      } else if (e.message != null) {
        msg = e.message!;
      }


      mostrarMensagem(msg);

    } catch (e) {

      mostrarMensagem('Erro inesperado');
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  void mostrarMensagem(String mensagem) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mensagem),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              children: [
                SvgPicture.asset(
                  'assets/images/logo+nome.svg',
                  height: 90,
                  colorFilter: const ColorFilter.mode(
                    NeoGymColors.primary,
                    BlendMode.srcIn,
                  ),
                ),

                const SizedBox(height: 20),

                const Text(
                  "Bem-vindo",
                  style: TextStyle(
                    fontSize: 34,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 40),

                Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        TextField(
                          controller: emailValue,
                          decoration: InputDecoration(
                            hintText: "Digite seu e-mail",
                            prefixIcon: const Icon(
                              Icons.email,
                              color: NeoGymColors.primary,
                            ),
                            filled: true,
                            fillColor: Colors.grey[100],
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),

                        const SizedBox(height: 16),

                        TextField(
                          controller: passValue,
                          obscureText: !isPasswordVisible,
                          decoration: InputDecoration(
                            hintText: "Digite sua senha",
                            prefixIcon: const Icon(
                              Icons.lock,
                              color: NeoGymColors.primary,
                            ),
                            suffixIcon: IconButton(
                              icon: Icon(
                                isPasswordVisible
                                    ? Icons.visibility
                                    : Icons.visibility_off,
                                color: NeoGymColors.primary,
                              ),
                              onPressed: () {
                                setState(() {
                                  isPasswordVisible =
                                  !isPasswordVisible;
                                });
                              },
                            ),
                            filled: true,
                            fillColor: Colors.grey[100],
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),

                        const SizedBox(height: 24),

                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton(
                            onPressed:
                            isLoading ? null : fazerLogin,
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                              NeoGymColors.primary,
                              shape: RoundedRectangleBorder(
                                borderRadius:
                                BorderRadius.circular(12),
                              ),
                            ),
                            child: isLoading
                                ? const SizedBox(
                              width: 22,
                              height: 22,
                              child:
                              CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                                : const Text("Entrar"),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("Não possui conta?"),
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                            const EscolherPerfil(),
                          ),
                        );
                      },
                      child: const Text(
                        "Criar conta",
                        style: TextStyle(
                          color: NeoGymColors.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}