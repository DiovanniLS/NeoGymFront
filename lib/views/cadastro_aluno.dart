import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:neogym/Resources/neo_gym_colors.dart';
import 'package:neogym/Views/escolher_academia.dart';
import 'package:neogym/components/input_field.dart';

class CadastroAluno extends StatefulWidget {
  const CadastroAluno({super.key});

  @override
  State<CadastroAluno> createState() => _CadastroAlunoState();
}

class _CadastroAlunoState extends State<CadastroAluno> {
  final TextEditingController nameValue = TextEditingController();
  final TextEditingController emailValue = TextEditingController();
  final TextEditingController passValue = TextEditingController();
  final TextEditingController confirmPassValue = TextEditingController();
  final TextEditingController pesoValue = TextEditingController();
  final TextEditingController alturaValue = TextEditingController();

  final Dio dio = Dio(
    BaseOptions(
      baseUrl: 'https://neogym-production.up.railway.app/api/v1',
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 15),
      sendTimeout: const Duration(seconds: 15),
      headers: {
        'Content-Type': 'application/json',
      },
    ),
  );

  bool rememberPass = false;
  bool isPasswordVisible = false;
  bool isLoading = false;

  @override
  void dispose() {
    nameValue.dispose();
    emailValue.dispose();
    passValue.dispose();
    confirmPassValue.dispose();
    pesoValue.dispose();
    alturaValue.dispose();
    super.dispose();
  }

  Future<void> cadastrarAluno() async {
    FocusScope.of(context).unfocus();

    if (nameValue.text.trim().isEmpty ||
        emailValue.text.trim().isEmpty ||
        passValue.text.trim().isEmpty ||
        confirmPassValue.text.trim().isEmpty) {
      mostrarMensagem('Preencha todos os campos');
      return;
    }

    if (passValue.text != confirmPassValue.text) {
      mostrarMensagem('As senhas não coincidem');
      return;
    }

    if (passValue.text.length < 6) {
      mostrarMensagem('A senha deve ter pelo menos 6 caracteres');
      return;
    }
    final peso = double.tryParse(
      pesoValue.text.replaceAll(',', '.'),
    );

    final altura = double.tryParse(
      alturaValue.text.replaceAll(',', '.'),
    );

    if (peso == null || altura == null) {
      mostrarMensagem('Peso ou altura inválidos');
      return;
    }

    try {
      setState(() {
        isLoading = true;
      });


      await dio.post(
        '/auth/cadastro/aluno',
        data: {
          "nome": nameValue.text.trim(),
          "email": emailValue.text.trim(),
          "senha": passValue.text.trim(),
          "academiaId": null,
          "peso": peso,
          "altura": altura,
          "metaAguaMl": 2000,
        },
      );

      if (!mounted) return;

      mostrarMensagem('Cadastro realizado com sucesso!');

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const EscolherAcademia()),
      );
    } on DioException catch (e) {

      if (e.response != null) {
        final data = e.response?.data;

        if (data is Map && data['message'] != null) {
          mensagemErro = data['message'];
        } else {
          mensagemErro = 'Erro ${e.response?.statusCode}';
        }
      } else {
        mensagemErro = 'Sem resposta do servidor (timeout ou crash)';
      }

      mostrarMensagem(mensagemErro);
    } catch (e) {
      mostrarMensagem('Erro inesperado');
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  void mostrarMensagem(String mensagem) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(mensagem), behavior: SnackBarBehavior.floating),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          'Cadastro Aluno',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [IconButton(onPressed: () {}, icon: const Icon(Icons.menu))],
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
            child: Column(
              children: [
                const SizedBox(height: 60),

                SvgPicture.asset(
                  'assets/images/logo_NG.svg',
                  colorFilter: const ColorFilter.mode(
                    Color(0xFFFF6B00),
                    BlendMode.srcIn,
                  ),
                ),

                const SizedBox(height: 60),

                InputField(
                  controller: nameValue,
                  icon: Icons.person,
                  hint: 'Digite seu nome completo',
                ),

                const SizedBox(height: 16),

                InputField(
                  controller: emailValue,
                  icon: Icons.email,
                  hint: 'Digite seu email',
                ),

                const SizedBox(height: 16),

                InputField(
                  controller: passValue,
                  hint: 'Digite sua senha',
                  icon: Icons.lock,
                  obscure: !isPasswordVisible,
                  suffix: IconButton(
                    icon: Icon(
                      isPasswordVisible
                          ? Icons.visibility
                          : Icons.visibility_off,
                      color: NeoGymColors.primary,
                    ),
                    onPressed: () {
                      setState(() {
                        isPasswordVisible = !isPasswordVisible;
                      });
                    },
                  ),
                ),

                const SizedBox(height: 16),

                InputField(
                  controller: confirmPassValue,
                  hint: 'Repita sua senha',
                  icon: Icons.lock,
                  obscure: !isPasswordVisible,
                  suffix: IconButton(
                    icon: Icon(
                      isPasswordVisible
                          ? Icons.visibility
                          : Icons.visibility_off,
                      color: NeoGymColors.primary,
                    ),
                    onPressed: () {
                      setState(() {
                        isPasswordVisible = !isPasswordVisible;
                      });
                    },
                  ),
                ),

                const SizedBox(height: 16),

                InputField(
                  controller: pesoValue,
                  icon: Icons.monitor_weight,
                  hint: 'Digite seu peso',
                  keyboardType: TextInputType.number,

                  suffix: const Padding(
                    padding: EdgeInsets.all(14),
                    child: Text(
                      'kg',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                InputField(
                  controller: alturaValue,
                  icon: Icons.height,
                  hint: 'Digite sua altura',
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  suffix: const Padding(
                    padding: EdgeInsets.all(14),
                    child: Text(
                      'm',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),

                CheckboxListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text(
                    'Lembrar senha',
                    style: TextStyle(fontSize: 16),
                  ),
                  value: rememberPass,
                  activeColor: NeoGymColors.primary,
                  checkColor: Colors.white,
                  side: const BorderSide(color: NeoGymColors.primary, width: 2),
                  controlAffinity: ListTileControlAffinity.leading,
                  onChanged: (value) {
                    setState(() {
                      rememberPass = value ?? false;
                    });
                  },
                ),

                const SizedBox(height: 24),

                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: isLoading ? null : cadastrarAluno,
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: isLoading
                        ? const SizedBox(
                            height: 22,
                            width: 22,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text(
                            "Cadastrar",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
