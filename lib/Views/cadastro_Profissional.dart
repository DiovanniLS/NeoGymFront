import 'package:flutter/material.dart';
import 'package:neogym/Views/envio_documento.dart';
import 'package:neogym/components/cadastro_stepper.dart';
import 'package:neogym/utils/phone_input_formatter.dart';

import '../Resources/neo_gym_colors.dart';

class CadastroProfissional extends StatefulWidget {

  final String proType;
  const CadastroProfissional({super.key, required this.proType});

  @override
  State<CadastroProfissional> createState() => _CadastroProfissionalState();
}


class _CadastroProfissionalState extends State<CadastroProfissional> {

  bool rememberPass = false;
  final TextEditingController nameValue = TextEditingController();
  final TextEditingController emailValue = TextEditingController();
  final TextEditingController phoneValue = TextEditingController();
  final TextEditingController passValue = TextEditingController();
  final TextEditingController rememberValue = TextEditingController();
  bool isPasswordVisible = false;




  @override
  void dispose() {
    nameValue.dispose();
    emailValue.dispose();
    phoneValue.dispose();
    passValue.dispose();
    rememberValue.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        actions: [
          IconButton(onPressed: (){}, icon: Icon(Icons.menu))
        ],
        title: Text( widget.proType == 'Nutri' ? 'Cadastro Nutricionista' : "Cadastro Personal Trainer", style: TextStyle(fontWeight: FontWeight.bold),),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 24),
          child: Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadiusGeometry.circular(16),
            ),
            elevation: 4,
            child: Container(
              padding: EdgeInsetsGeometry.all(16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CadastroStepper(step: 1),
                  Container(
                    margin: EdgeInsets.only(top: 30),
                    child: TextField(
                      controller: nameValue,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.grey[100],
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
                      fillColor: Colors.grey[100],
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
                    keyboardType: TextInputType.phone,
                    inputFormatters: [
                      PhoneInputFormatter()
                    ],
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.grey[100],
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
                      fillColor: Colors.grey[100],
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
                      fillColor: Colors.grey[100],
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
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => EnvioDocumento(
                              nome: nameValue.text,
                              email: emailValue.text,
                              telefone: phoneValue.text,
                              tipo: widget.proType,
                            ),
                          ),
                        );
                      },
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
      ),
    );
  }

}
