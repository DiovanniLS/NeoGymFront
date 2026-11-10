import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import 'package:neogym/components/universal_app_bar.dart';
import 'package:neogym/services/usuario_service.dart';

import '../../view_model/auth_view_model.dart';
import '../services/perfil_profissional_service.dart';

class EditarPerfilScreen extends StatefulWidget {
  const EditarPerfilScreen({super.key});

  @override
  State<EditarPerfilScreen> createState() =>
      _EditarPerfilScreenState();
}

class _EditarPerfilScreenState extends State<EditarPerfilScreen> {
  final nomeController = TextEditingController();
  final emailController = TextEditingController();
  final especialidadeController = TextEditingController();
  final apresentacaoController = TextEditingController();
  final areasAtuacaoController = TextEditingController();
  final horariosDisponiveisController = TextEditingController();

  final PerfilProfissionalService _perfilProfissionalService =
  PerfilProfissionalService();

  final UsuarioService _usuarioService = UsuarioService();

  final ImagePicker _imagePicker = ImagePicker();

  bool _ehPersonal = false;
  bool _ehNutricionista = false;

  bool get _ehProfissional => _ehPersonal || _ehNutricionista;

  String get _nomeRegistro => _ehNutricionista ? 'CRN' : 'CREF';

  String registroProfissional = '';
  String estadoRegistro = '';
  String statusRegistro = '';

  Uint8List? foto;
  String? caminhoFotoSelecionada;

  bool carregando = true;
  bool salvando = false;

  @override
  void initState() {
    super.initState();
    _carregarPerfil();
  }

  Future<void> _carregarPerfil() async {
    final authViewModel = context.read<AuthViewModel>();
    final usuario = authViewModel.user;

    final tipo = usuario?.tipo.toString().toUpperCase() ?? '';

    _ehPersonal = tipo.contains('PERSONAL');
    _ehNutricionista = tipo.contains('NUTRICIONISTA');

    if (usuario != null) {
      nomeController.text = usuario.nome;
      emailController.text = usuario.email;
    }

    try {
      foto = await _usuarioService.buscarFoto();
    } catch (e) {
      debugPrint('Erro ao carregar foto do usuário: $e');
    }

    if (!mounted) return;

    if (_ehProfissional) {
      try {
        final perfil =
        await _perfilProfissionalService.buscarMeuPerfil(
          isNutricionista: _ehNutricionista,
        );

        if (!mounted) return;

        especialidadeController.text =
            perfil['especialidade']?.toString() ?? '';

        apresentacaoController.text =
            perfil['apresentacao']?.toString() ?? '';

        areasAtuacaoController.text =
            perfil['areasAtuacao']?.toString() ?? '';

        horariosDisponiveisController.text =
            perfil['horariosDisponiveis']?.toString() ?? '';

        if (_ehNutricionista) {
          registroProfissional = perfil['crn']?.toString() ?? '';
          estadoRegistro = perfil['estadoCrn']?.toString() ?? '';
          statusRegistro = perfil['statusCrn']?.toString() ?? '';
        } else {
          registroProfissional = perfil['cref']?.toString() ?? '';
          estadoRegistro = perfil['estadoCref']?.toString() ?? '';
          statusRegistro = perfil['statusCref']?.toString() ?? '';
        }
      } catch (e) {
        debugPrint('Erro ao carregar perfil profissional: $e');

        if (mounted) {
          _mostrarMensagem(
            'Não foi possível carregar os dados profissionais.',
          );
        }
      }
    }

    if (!mounted) return;

    setState(() {
      carregando = false;
    });
  }

  Future<void> _selecionarFoto() async {
    try {
      final arquivo = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
        maxWidth: 1200,
      );

      if (arquivo == null || !mounted) return;

      final bytes = await arquivo.readAsBytes();

      if (!mounted) return;

      setState(() {
        caminhoFotoSelecionada = arquivo.path;
        foto = bytes;
      });
    } catch (e) {
      if (!mounted) return;

      _mostrarMensagem('Não foi possível selecionar a foto.');
    }
  }

  Future<void> _salvar() async {
    if (salvando) return;

    final nome = nomeController.text.trim();
    final email = emailController.text.trim();

    if (nome.isEmpty) {
      _mostrarMensagem('Informe seu nome.');
      return;
    }

    if (email.isEmpty) {
      _mostrarMensagem('Informe seu e-mail.');
      return;
    }

    if (_ehProfissional &&
        especialidadeController.text.trim().isEmpty) {
      _mostrarMensagem('Informe sua especialidade principal.');
      return;
    }

    setState(() {
      salvando = true;
    });

    try {
      // Atualiza os dados básicos da conta.
      final usuarioAtualizado =
      await _usuarioService.atualizarPerfil(
        nome: nome,
        email: email,
      );

      // Atualiza os dados específicos do profissional.
      if (_ehProfissional) {
        await _perfilProfissionalService.atualizarMeuPerfil(
          especialidade: especialidadeController.text.trim(),
          apresentacao: apresentacaoController.text.trim(),
          areasAtuacao: areasAtuacaoController.text.trim(),
          horariosDisponiveis: horariosDisponiveisController.text.trim(),
          isNutricionista: _ehNutricionista,
        );
      }

      // Envia a foto selecionada, se houver.
      if (caminhoFotoSelecionada != null) {
        await _usuarioService.atualizarFoto(
          caminhoFotoSelecionada!,
        );
      }

      if (!mounted) return;

      // Atualiza os dados do usuário mantidos no aplicativo.
      context.read<AuthViewModel>().setUser(usuarioAtualizado);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Perfil atualizado com sucesso.'),
        ),
      );

      Navigator.pop(context);
    } catch (e) {
      debugPrint('Erro ao salvar perfil: $e');

      if (!mounted) return;

      _mostrarMensagem(
        'Não foi possível atualizar o perfil. Verifique os dados e tente novamente.',
      );
    } finally {
      if (mounted) {
        setState(() {
          salvando = false;
        });
      }
    }
  }

  void _mostrarMensagem(String mensagem) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mensagem),
      ),
    );
  }

  @override
  void dispose() {
    nomeController.dispose();
    emailController.dispose();
    especialidadeController.dispose();
    apresentacaoController.dispose();
    areasAtuacaoController.dispose();
    horariosDisponiveisController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const UniversalAppBar(
        title: 'Editar perfil',
      ),
      body: carregando
          ? const Center(
        child: CircularProgressIndicator(),
      )
          : SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            GestureDetector(
              onTap: salvando ? null : _selecionarFoto,
              child: Stack(
                alignment: Alignment.bottomRight,
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundImage: foto != null
                        ? MemoryImage(foto!)
                        : null,
                    child: foto == null
                        ? const Icon(
                      Icons.person,
                      size: 50,
                    )
                        : null,
                  ),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: const BoxDecoration(
                      color: Colors.blue,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.camera_alt,
                      color: Colors.white,
                      size: 18,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 10),

            const Text(
              'Toque na foto para alterar',
              style: TextStyle(
                color: Colors.grey,
                fontSize: 13,
              ),
            ),

            const SizedBox(height: 30),

            TextField(
              controller: nomeController,
              enabled: !salvando,
              decoration: const InputDecoration(
                labelText: 'Nome',
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 16),

            TextField(
              controller: emailController,
              enabled: !salvando,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                labelText: 'E-mail',
                border: OutlineInputBorder(),
              ),
            ),

            if (_ehProfissional) ...[
              const SizedBox(height: 30),

              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Perfil profissional',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              const SizedBox(height: 16),

              TextField(
                controller: especialidadeController,
                enabled: !salvando,
                decoration: InputDecoration(
                  labelText: 'Especialidade principal',
                  hintText: _ehNutricionista
                      ? 'Ex.: Nutrição esportiva'
                      : 'Ex.: Musculação e hipertrofia',
                  border: const OutlineInputBorder(),
                ),
              ),

              const SizedBox(height: 16),

              TextField(
                controller: apresentacaoController,
                enabled: !salvando,
                maxLines: 4,
                maxLength: 3000,
                decoration: const InputDecoration(
                  labelText: 'Sobre você',
                  hintText:
                  'Apresente sua experiência e metodologia.',
                  alignLabelWithHint: true,
                  border: OutlineInputBorder(),
                ),
              ),

              const SizedBox(height: 16),

              TextField(
                controller: areasAtuacaoController,
                enabled: !salvando,
                maxLines: 3,
                maxLength: 2000,
                decoration: InputDecoration(
                  labelText: 'Áreas de atuação',
                  hintText: _ehNutricionista
                      ? 'Uma área por linha\nNutrição esportiva\nReeducação alimentar'
                      : 'Uma área por linha\nHipertrofia\nEmagrecimento\nTreinamento funcional',
                  alignLabelWithHint: true,
                  border: const OutlineInputBorder(),
                ),
              ),

              const SizedBox(height: 16),

              TextField(
                controller: horariosDisponiveisController,
                enabled: !salvando,
                maxLines: 4,
                maxLength: 2000,
                decoration: const InputDecoration(
                  labelText: 'Horários disponíveis',
                  hintText:
                  'Um horário por linha\nSegunda a sexta: 08:00–12:00\nSegunda a sexta: 14:00–18:00',
                  alignLabelWithHint: true,
                  border: OutlineInputBorder(),
                ),
              ),

              const SizedBox(height: 16),

              Card(
                child: ListTile(
                  leading: const Icon(Icons.badge_outlined),
                  title: Text(
                    'Registro profissional ($_nomeRegistro)',
                  ),
                  subtitle: Text(
                    registroProfissional.isEmpty
                        ? '$_nomeRegistro não informado'
                        : '$registroProfissional'
                        '${estadoRegistro.isEmpty ? '' : ' - $estadoRegistro'}',
                  ),
                  trailing: Text(
                    statusRegistro.isEmpty
                        ? 'Não informado'
                        : statusRegistro,
                    style: const TextStyle(fontSize: 12),
                  ),
                ),
              ),
            ],

            const SizedBox(height: 24),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: salvando ? null : _salvar,
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(
                    double.infinity,
                    50,
                  ),
                ),
                child: salvando
                    ? const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                  ),
                )
                    : const Text('Salvar alterações'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}