import 'package:flutter/material.dart';
import 'package:neogym/components/cadastro_stepper.dart';
import 'package:neogym/components/input_field.dart';
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
  int currentStep = 1;

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
        actions: [IconButton(onPressed: () {}, icon: Icon(Icons.menu))],
        title: Text(
          widget.proType == 'Nutri'
              ? 'Cadastro Nutricionista'
              : "Cadastro Personal Trainer",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 24),
          child: Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            elevation: 4,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (currentStep > 1)
                    IconButton(
                      icon: const Icon(
                        Icons.arrow_back,
                        color: NeoGymColors.primary,
                      ),
                      onPressed: () {
                        setState(() {
                          currentStep--;
                        });
                      },
                    ),

                  SizedBox(height: 16),

                  CadastroStepper(step: currentStep),

                  const SizedBox(height: 30),

                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 350),
                    transitionBuilder: (child, animation) {
                      return FadeTransition(opacity: animation, child: child);
                    },
                    child: currentStep == 1 ? stepOne() : stepTwo(),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget stepOne() {
    return Column(
      key: const ValueKey(1),
      children: [

        InputField(
          controller: nameValue,
          hint: "Digite seu nome completo",
          icon: Icons.person,
        ),

        const SizedBox(height: 16),

        InputField(
          controller: emailValue,
          hint: "Digite seu e-mail",
          icon: Icons.email,
        ),

        const SizedBox(height: 16),

        InputField(
          controller: phoneValue,
          hint: "(00) 00000-0000",
          icon: Icons.phone,
          keyboardType: TextInputType.phone,
          formatters: [
            PhoneInputFormatter()
          ],
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

        const SizedBox(height: 16),

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
          checkColor: Colors.white,
          side: const BorderSide(
            color: NeoGymColors.primary,
            width: 2,
          ),
          controlAffinity: ListTileControlAffinity.leading,
        ),

        const SizedBox(height: 24),

        SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton(
            onPressed: () {
              setState(() {
                currentStep = 2;
              });
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: NeoGymColors.primary,
            ),
            child: const Text("Próxima etapa"),
          ),
        ),

      ],
    );
  }

  Widget stepTwo() {
    return Column(
      key: const ValueKey(2),
      children: [
        const Text(
          "Envie seus documentos para validação",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),

        const SizedBox(height: 30),

        uploadCard(
          icon: Icons.badge,
          title: "RG ou CNH",
          subtitle: "Foto do documento de identidade",
        ),

        const SizedBox(height: 20),

        uploadCard(
          icon: Icons.assignment_ind,
          title: widget.proType == 'Nutri' ? "Registro CRN" : "Registro CREF",
          subtitle: widget.proType == 'Nutri'
              ? "Documento profissional do nutricionista"
              : "Documento profissional do personal trainer",
        ),

        const SizedBox(height: 30),

        SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton(
            onPressed: () {
              // finalizar cadastro
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: NeoGymColors.primary,
            ),
            child: const Text("Finalizar cadastro"),
          ),
        ),
      ],
    );
  }

  Widget uploadCard({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 4,
      child: Container(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(icon, color: NeoGymColors.primary, size: 32),

            const SizedBox(width: 16),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),

                  Text(subtitle, style: TextStyle(color: Colors.grey[600])),
                ],
              ),
            ),

            const Icon(Icons.upload_file),
          ],
        ),
      ),
    );
  }
}
