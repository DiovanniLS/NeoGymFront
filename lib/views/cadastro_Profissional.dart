import 'package:flutter/material.dart';
import 'package:neogym/components/cadastro_stepper.dart';
import 'package:neogym/components/input_field.dart';

import '../Resources/neo_gym_colors.dart';
import '../services/auth_service.dart';

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
  final TextEditingController passValue = TextEditingController();
  final TextEditingController rememberValue = TextEditingController();
  final TextEditingController registerValue = TextEditingController();
  final TextEditingController stateRegisterValue = TextEditingController();

  bool isPasswordVisible = false;
  bool isLoading = false;

  int currentStep = 1;

  final AuthService authService = AuthService();

  @override
  void dispose() {
    nameValue.dispose();
    emailValue.dispose();
    passValue.dispose();
    rememberValue.dispose();
    registerValue.dispose();
    stateRegisterValue.dispose();
    super.dispose();
  }

  bool validarStepOne() {
    if (nameValue.text.isEmpty ||
        emailValue.text.isEmpty ||
        passValue.text.isEmpty ||
        rememberValue.text.isEmpty ||
        registerValue.text.isEmpty ||
        stateRegisterValue.text.isEmpty) {
      mostrarMensagem('Preencha todos os campos');
      return false;
    }

    if (passValue.text != rememberValue.text) {
      mostrarMensagem('As senhas não coincidem');
      return false;
    }

    return true;
  }

  void mostrarMensagem(String mensagem) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(mensagem)),
    );
  }

  Future<void> finalizarCadastro() async {
    try {
      setState(() => isLoading = true);

      await authService.cadastrarProfissional(
        isNutri: widget.proType == 'Nutri',
        nome: nameValue.text.trim(),
        email: emailValue.text.trim(),
        senha: passValue.text.trim(),
        registro: registerValue.text.trim(),
        estadoRegistro: stateRegisterValue.text.trim(),
      );

      if (!mounted) return;

      Navigator.pushNamed(context, "/selectWorkPlace");
    } catch (e) {
      mostrarMensagem('Erro ao cadastrar');
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        actions: [
          IconButton(onPressed: () {}, icon: const Icon(Icons.menu))
        ],
        title: Text(
          widget.proType == 'Nutri'
              ? 'Cadastro Nutricionista'
              : "Cadastro Personal Trainer",
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),

      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),

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
                      icon: const Icon(Icons.arrow_back),
                      onPressed: () {
                        setState(() {
                          currentStep--;
                        });
                      },
                    ),

                  const SizedBox(height: 16),

                  CadastroStepper(step: currentStep),

                  const SizedBox(height: 30),

                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 350),
                    transitionBuilder: (child, animation) {
                      return FadeTransition(
                        opacity: animation,
                        child: child,
                      );
                    },

                    child: stepOne(),
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
          controller: registerValue,
          hint: widget.proType == 'Nutri'
              ? "Digite seu CRN"
              : "Digite seu CREF",
          icon: Icons.badge,
        ),

        const SizedBox(height: 16),

        InputField(
          controller: stateRegisterValue,
          hint: "UF do registro (SP)",
          icon: Icons.map,
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
          title: const Text('Lembrar senha'),
          value: rememberPass,
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
            onPressed: isLoading
                ? null
                : () async {
              if (!validarStepOne()) return;

              await finalizarCadastro();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: NeoGymColors.primary,
            ),
            child: isLoading
                ? const CircularProgressIndicator(
              color: Colors.white,
              strokeWidth: 2,
            )
                : const Text("Finalizar cadastro"),
          ),
        ),
      ],
    );
  }

// ======================================================
// 📁 DOCUMENTOS (DESATIVADO TEMPORARIAMENTE)
// ======================================================

// File? identityDocument;
// File? professionalDocument;

// final ImagePicker picker = ImagePicker();

/// 📸 Seleção de documentos (CÂMERA / GALERIA)
/*
Future<void> pickDocument(
  bool isIdentity,
  ImageSource source,
) async {

  final XFile? image = await picker.pickImage(
    source: source,
    imageQuality: 70,
  );

  if (image == null) return;

  final file = File(image.path);

  final fileSize = await file.length();
  final fileSizeMb = fileSize / (1024 * 1024);

  if (fileSizeMb > 5) {
    mostrarMensagem('Imagem muito grande');
    return;
  }

  setState(() {
    if (isIdentity) {
      identityDocument = file;
    } else {
      professionalDocument = file;
    }
  });
}
*/

/// 🚀 FINALIZAR CADASTRO (UPLOAD DOCUMENTOS)
/*
Future<void> finalizarCadastro() async {

  if (identityDocument == null ||
      professionalDocument == null) {

    mostrarMensagem('Envie os documentos');
    return;
  }

  try {
    setState(() {
      isLoading = true;
    });

    await authService.cadastrarProfissional(
      isNutri: widget.proType == 'Nutri',

      nome: nameValue.text.trim(),
      email: emailValue.text.trim(),
      senha: passValue.text.trim(),

      registro: registerValue.text.trim(),
      estadoRegistro: stateRegisterValue.text.trim(),

      identidade: identityDocument!,
      documentoProfissional: professionalDocument!,
    );

    if (!mounted) return;

    Navigator.pushNamed(context, "/selectWorkPlace");

  } catch (e) {
    mostrarMensagem('Erro ao cadastrar');
  } finally {
    if (mounted) {
      setState(() {
        isLoading = false;
      });
    }
  }
}
*/

/// 📌 STEP 2 (TELA DE UPLOAD)
/*
Widget stepTwo() {
  return Column(
    children: [

      const Text("Envie seus documentos para validação"),

      uploadCard(
        icon: Icons.badge,
        title: "RG ou CNH",
        subtitle: "Foto do documento de identidade",
        file: identityDocument,
        onTap: () => showImageSourceSelector(true),
      ),

      uploadCard(
        icon: Icons.assignment_ind,
        title: widget.proType == 'Nutri'
            ? "Registro CRN"
            : "Registro CREF",
        subtitle: widget.proType == 'Nutri'
            ? "Documento profissional do nutricionista"
            : "Documento profissional do personal trainer",
        file: professionalDocument,
        onTap: () => showImageSourceSelector(false),
      ),

      SizedBox(
        width: double.infinity,
        height: 50,
        child: ElevatedButton(
          onPressed: isLoading ? null : finalizarCadastro,
          child: const Text("Finalizar cadastro"),
        ),
      ),
    ],
  );
}
*/

/// 🧱 CARD DE UPLOAD
/*
Widget uploadCard({
  required IconData icon,
  required String title,
  required String subtitle,
  required File? file,
  required VoidCallback onTap,
}) {
  return InkWell(
    onTap: onTap,
    child: Card(
      child: Row(
        children: [

          Icon(icon),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                Text(title),

                Text(
                  file != null
                      ? "Documento enviado ✅"
                      : subtitle,
                ),
              ],
            ),
          ),

          file != null
              ? Image.file(file, width: 50, height: 50)
              : const Icon(Icons.upload_file),
        ],
      ),
    ),
  );
}
*/
}
