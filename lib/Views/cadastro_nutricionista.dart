import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:neogym/utils/phone_input_formatter.dart';

import '../Resources/neo_gym_colors.dart';

class CadastroNutricionista extends StatefulWidget {
  const CadastroNutricionista({super.key});

  @override
  State<CadastroNutricionista> createState() => _CadastroNutricionistaState();
}

class _CadastroNutricionistaState extends State<CadastroNutricionista> {

  bool rememberPass = false;
  final TextEditingController nameValue = TextEditingController();
  final TextEditingController emailValue = TextEditingController();
  final TextEditingController phoneValue = TextEditingController();
  final TextEditingController passValue = TextEditingController();
  final TextEditingController rememberValue = TextEditingController();
  bool isPasswordVisible = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        actions: [
          IconButton(onPressed: (){}, icon: Icon(Icons.menu))
        ],
        title: Text('Cadastro Nutricionista', style: TextStyle(fontWeight: FontWeight.bold),),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 60),
                  child: buildStepIndicator(),
                ),
                Container(
                  margin: EdgeInsets.only(top: 60),
                  child: TextField(
                    controller: emailValue,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.white,
                      hintText: "Digite seu nome completo",
                      prefixIcon: const Icon(Icons.person, color: NeoGymColors.primary,),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: emailValue,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.white,
                    hintText: "Digite seu e-mail",
                    prefixIcon: const Icon(Icons.email, color: NeoGymColors.primary),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: phoneValue,
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    PhoneInputFormatter()
                  ],
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.white,
                    hintText: '(00) 00000-0000 ',
                    prefixIcon: const Icon(Icons.phone, color: NeoGymColors.primary,),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  obscureText: !isPasswordVisible,
                  controller: passValue,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.white,
                    hintText: "Digite sua senha",
                    prefixIcon: const Icon(Icons.lock, color: NeoGymColors.primary,),
                    suffixIcon: IconButton(
                      icon: Icon(
                        isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                        color: NeoGymColors.primary,
                      ),
                      onPressed: () {
                        setState(() {
                          isPasswordVisible = !isPasswordVisible;
                        });
                      },
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 16,),
                TextField(
                  obscureText: !isPasswordVisible,
                  controller: rememberValue,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.white,
                    hintText: "Repita sua senha",
                    prefixIcon: const Icon(Icons.lock, color: NeoGymColors.primary,),
                    suffixIcon: IconButton(
                      icon: Icon(
                        isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                        color: NeoGymColors.primary,
                      ),
                      onPressed: () {
                        setState(() {
                          isPasswordVisible = !isPasswordVisible;
                        });
                      },
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
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
                  onChanged: (bool? value) {
                    setState(() {
                      rememberPass = value ?? false;
                    });
                  },
                  activeColor: NeoGymColors.primary, // cor do quadrado marcado
                  checkColor: Colors.white, // cor do tick
                  side: const BorderSide(color: NeoGymColors.primary, width: 2), // borda não marcada
                  controlAffinity: ListTileControlAffinity.leading, // checkbox à esquerda
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
                      "Próxima Etapa",
                      style: TextStyle(fontSize: 16),
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

  Widget buildStepIndicator() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: const BoxDecoration(
                  color: NeoGymColors.primary,
                  shape: BoxShape.circle,
                ),
                child: const Center(
                  child: Text(
                    "1",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                "Cadastro de dados pessoais",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12),
              ),
            ],
          ),
        ),

        Container(
          width: 40,
          height: 2,
          margin: const EdgeInsets.only(top: 15),
          color: Colors.grey,
        ),

        Expanded(
          child: Column(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: Colors.grey[400],
                  shape: BoxShape.circle,
                ),
                child: const Center(
                  child: Text(
                    "2",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                "Validação de documentos",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12),
              ),
            ],
          ),
        ),
      ],
    );
  }

}
