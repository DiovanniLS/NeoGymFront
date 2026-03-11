import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:neogym/Resources/neo_gym_colors.dart';
import 'package:neogym/components/input_field.dart';

class CadastroAluno extends StatefulWidget {
  const CadastroAluno({super.key});

  @override
  State<CadastroAluno> createState() => _LoginPageState();
}

class _LoginPageState extends State<CadastroAluno> {
  bool rememberPass = false;
  final TextEditingController nameValue = TextEditingController();
  final TextEditingController emailValue = TextEditingController();
  final TextEditingController passValue = TextEditingController();
  final TextEditingController rememberValue = TextEditingController();
  bool isPasswordVisible = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        actions: [IconButton(onPressed: () {}, icon: Icon(Icons.menu))],
        title: Text(
          'Cadastro Aluno',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(height: 60),
                SvgPicture.asset(
                  'assets/images/logo_NG.svg',
                  colorFilter: const ColorFilter.mode(
                    Color(0xFFFF6B00),
                    BlendMode.srcIn,
                  ),
                ),
                 SizedBox(height: 60,),
                 InputField(
                    controller: nameValue,
                    icon: Icons.person,
                    hint: 'Digite seu Nome completo',
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
                  hint: "Digite sua senha",
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
                  controller: rememberValue,
                  hint: "Repita sua senha",
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
                CheckboxListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text(
                    'Lembrar senha',
                    style: TextStyle(fontSize: 16),
                  ),
                  value: rememberPass,
                  onChanged: (bool? value) {
                    setState(() {
                      rememberPass = value ?? false;
                    });
                  },
                  activeColor: NeoGymColors.primary,
                  // cor do quadrado marcado
                  checkColor: Colors.white,
                  // cor do tick
                  side: const BorderSide(color: NeoGymColors.primary, width: 2),
                  // borda não marcada
                  controlAffinity:
                      ListTileControlAffinity.leading, // checkbox à esquerda
                ),
                const SizedBox(height: 24),

                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
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
