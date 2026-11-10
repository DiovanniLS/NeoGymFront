import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
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

  final ImagePicker _imagePicker = ImagePicker();

  File? identityDocument;
  File? professionalDocument;

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

  Future<void> selecionarImagem({
    required bool isIdentity,
  }) async {
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Escolher da galeria'),
              onTap: () => Navigator.pop(
                context,
                ImageSource.gallery,
              ),
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Tirar foto'),
              onTap: () => Navigator.pop(
                context,
                ImageSource.camera,
              ),
            ),
          ],
        ),
      ),
    );

    if (source == null) return;

    try {
      final XFile? imagem = await _imagePicker.pickImage(
        source: source,
        imageQuality: 85,
        maxWidth: 2400,
        maxHeight: 2400,
      );

      if (imagem == null) return;

      final arquivo = File(imagem.path);
      final tamanho = await arquivo.length();

      if (tamanho > 5 * 1024 * 1024) {
        mostrarMensagem(
          'A imagem deve ter no máximo 5 MB.',
        );
        return;
      }

      if (!mounted) return;

      setState(() {
        if (isIdentity) {
          identityDocument = arquivo;
        } else {
          professionalDocument = arquivo;
        }
      });
    } catch (_) {
      if (!mounted) return;

      mostrarMensagem(
        'Não foi possível selecionar a imagem.',
      );
    }
  }

  Widget stepTwo() {
    final documentosSelecionados =
        identityDocument != null &&
            professionalDocument != null;

    return Column(
      key: const ValueKey(2),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          'Envie seus documentos para validação',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'As imagens serão utilizadas para validar '
              'sua identidade e seu registro profissional.',
        ),
        const SizedBox(height: 20),
        documentoCard(
          titulo: 'Documento de identidade',
          descricao: 'RG ou CNH',
          arquivo: identityDocument,
          onSelecionar: () => selecionarImagem(
            isIdentity: true,
          ),
        ),
        documentoCard(
          titulo: widget.proType == 'Nutri'
              ? 'Comprovante do CRN'
              : 'Comprovante do CREF',
          descricao: 'Imagem do registro profissional',
          arquivo: professionalDocument,
          onSelecionar: () => selecionarImagem(
            isIdentity: false,
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 50,
          child: ElevatedButton(
            onPressed: isLoading || !documentosSelecionados
                ? null
                : finalizarCadastro,
            style: ElevatedButton.styleFrom(
              backgroundColor: NeoGymColors.primary,
            ),
            child: isLoading
                ? const CircularProgressIndicator(
              color: Colors.white,
              strokeWidth: 2,
            )
                : const Text('Enviar cadastro'),
          ),
        ),
      ],
    );
  }


  Widget documentoCard({
    required String titulo,
    required String descricao,
    required File? arquivo,
    required VoidCallback onSelecionar,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: onSelecionar,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.image_outlined),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          titulo,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          arquivo == null
                              ? descricao
                              : 'Imagem selecionada',
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    arquivo == null
                        ? Icons.add_a_photo_outlined
                        : Icons.check_circle,
                    color: arquivo == null
                        ? Colors.grey
                        : Colors.green,
                  ),
                ],
              ),
              if (arquivo != null) ...[
                const SizedBox(height: 12),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.file(
                    arquivo,
                    height: 180,
                    width: double.infinity,
                    fit: BoxFit.contain,
                  ),
                ),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton.icon(
                    onPressed: onSelecionar,
                    icon: const Icon(Icons.refresh),
                    label: const Text('Trocar imagem'),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  bool validarStepOne() {
    final nome = nameValue.text.trim();
    final email = emailValue.text.trim();
    final senha = passValue.text;
    final confirmarSenha = rememberValue.text;
    final registro = registerValue.text.trim();
    final uf = stateRegisterValue.text.trim().toUpperCase();

    if (nome.isEmpty ||
        email.isEmpty ||
        senha.isEmpty ||
        confirmarSenha.isEmpty ||
        registro.isEmpty ||
        uf.isEmpty) {
      mostrarMensagem('Preencha todos os campos.');
      return false;
    }

    final emailValido = RegExp(
      r'^[^@\s]+@[^@\s]+\.[^@\s]+$',
    ).hasMatch(email);

    if (!emailValido) {
      mostrarMensagem('Informe um e-mail válido.');
      return false;
    }

    if (senha.length < 8) {
      mostrarMensagem('A senha deve ter pelo menos 8 caracteres.');
      return false;
    }

    if (senha != confirmarSenha) {
      mostrarMensagem('As senhas não coincidem.');
      return false;
    }

    if (!RegExp(r'^[A-Za-z]{2}$').hasMatch(uf)) {
      mostrarMensagem('Informe uma UF válida, como SP.');
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
    if (identityDocument == null || professionalDocument == null) {
      mostrarMensagem('Envie os dois documentos para continuar.');
      return;
    }

    FocusScope.of(context).unfocus();

    setState(() => isLoading = true);

    try {
      await authService.cadastrarProfissional(
        isNutri: widget.proType == 'Nutri',
        nome: nameValue.text.trim(),
        email: emailValue.text.trim().toLowerCase(),
        senha: passValue.text,
        registro: registerValue.text.trim(),
        estadoRegistro: stateRegisterValue.text.trim().toUpperCase(),
        identidade: identityDocument!,
        documentoProfissional: professionalDocument!,
      );

      if (!mounted) return;

      Navigator.pushNamed(context, '/selectWorkPlace');
    } catch (e) {
      if (!mounted) return;

      mostrarMensagem(
        'Não foi possível cadastrar o profissional. Verifique os dados e tente novamente.',
      );
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

                    child: currentStep == 1
                        ? stepOne()
                        : stepTwo(),
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
                : () {
              if (!validarStepOne()) return;

              FocusScope.of(context).unfocus();

              setState(() {
                currentStep = 2;
              });
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
}
