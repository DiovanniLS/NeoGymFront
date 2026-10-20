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

class _EditarPerfilScreenState
    extends State<EditarPerfilScreen> {
  final nomeController = TextEditingController();
  final emailController = TextEditingController();
  final especialidadeController = TextEditingController();
  final apresentacaoController = TextEditingController();
  final areasAtuacaoController = TextEditingController();
  final horariosDisponiveisController = TextEditingController();

  final PerfilProfissionalService _perfilProfissionalService =
  PerfilProfissionalService();

  bool _ehPersonal = false;

  String cref = '';
  String estadoCref = '';
  String statusCref = '';

  final UsuarioService _usuarioService =
  UsuarioService();

  final ImagePicker _imagePicker = ImagePicker();

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
    final authViewModel =
    context.read<AuthViewModel>();

    final usuario = authViewModel.user;

    _ehPersonal = usuario?.tipo
        .toString()
        .toUpperCase()
        .contains('PERSONAL') ??
        false;

    if (usuario != null) {
      nomeController.text = usuario.nome;
      emailController.text = usuario.email;
    }

    try {
      final imagem =
      await _usuarioService.buscarFoto();

      if (!mounted) return;

      setState(() {
        foto = imagem;
        carregando = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        carregando = false;
      });
    }

    if (_ehPersonal) {
      try {
        final perfil =
        await _perfilProfissionalService.buscarMeuPerfil();

        especialidadeController.text =
            perfil['especialidade']?.toString() ?? '';

        apresentacaoController.text =
            perfil['apresentacao']?.toString() ?? '';

        areasAtuacaoController.text =
            perfil['areasAtuacao']?.toString() ?? '';

        horariosDisponiveisController.text =
            perfil['horariosDisponiveis']?.toString() ?? '';

        cref = perfil['cref']?.toString() ?? '';
        estadoCref = perfil['estadoCref']?.toString() ?? '';
        statusCref = perfil['statusCref']?.toString() ?? '';
      } catch (e) {
        if (mounted) {
          _mostrarMensagem(
            'Não foi possível carregar os dados profissionais.',
          );
        }
      }
    }
  }

  Future<void> _selecionarFoto() async {
    final arquivo =
    await _imagePicker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
      maxWidth: 1200,
    );

    if (arquivo == null) {
      return;
    }

    final bytes = await arquivo.readAsBytes();

    if (!mounted) return;

    setState(() {
      caminhoFotoSelecionada = arquivo.path;
      foto = bytes;
    });
  }

  Future<void> _salvar() async {
    final nome = nomeController.text.trim();
    final email = emailController.text.trim();

    if (nome.isEmpty) {
      _mostrarMensagem(
        'Informe seu nome.',
      );
      return;
    }

    if (email.isEmpty) {
      _mostrarMensagem(
        'Informe seu e-mail.',
      );
      return;
    }

    if (_ehPersonal && especialidadeController.text.trim().isEmpty) {
      _mostrarMensagem('Informe sua especialidade principal.');
      return;
    }

    setState(() {
      salvando = true;
    });



    try {
      final usuarioAtualizado =
      await _usuarioService.atualizarPerfil(
        nome: nome,
        email: email,
      );

      if (caminhoFotoSelecionada != null) {
        await _usuarioService.atualizarFoto(
          caminhoFotoSelecionada!,
        );
      }

      if (!mounted) return;

      context
          .read<AuthViewModel>()
          .setUser(usuarioAtualizado);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Perfil atualizado com sucesso.',
          ),
        ),
      );

      if (_ehPersonal) {
        await _perfilProfissionalService.atualizarMeuPerfil(
          especialidade: especialidadeController.text.trim(),
          apresentacao: apresentacaoController.text.trim(),
          areasAtuacao: areasAtuacaoController.text.trim(),
          horariosDisponiveis: horariosDisponiveisController.text.trim(),
        );
      }

      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;

      _mostrarMensagem(
        'Não foi possível atualizar o perfil.',
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
              onTap: salvando
                  ? null
                  : _selecionarFoto,
              child: Stack(
                alignment:
                Alignment.bottomRight,
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
                    padding:
                    const EdgeInsets.all(8),
                    decoration:
                    const BoxDecoration(
                      color: Colors.blue,
                      shape:
                      BoxShape.circle,
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
              decoration:
              const InputDecoration(
                labelText: 'Nome',
                border:
                OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 16),

            TextField(
              controller: emailController,
              enabled: !salvando,
              keyboardType:
              TextInputType.emailAddress,
              decoration:
              const InputDecoration(
                labelText: 'E-mail',
                border:
                OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 30),

            if (_ehPersonal) ...[
              const SizedBox(height: 28),

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
                decoration: const InputDecoration(
                  labelText: 'Especialidade principal',
                  hintText: 'Ex.: Musculação e hipertrofia',
                  border: OutlineInputBorder(),
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
                  hintText: 'Apresente sua experiência e metodologia.',
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
                decoration: const InputDecoration(
                  labelText: 'Áreas de atuação',
                  hintText:
                  'Uma área por linha\nHipertrofia\nEmagrecimento\nTreinamento funcional',
                  alignLabelWithHint: true,
                  border: OutlineInputBorder(),
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
                  title: const Text('Registro profissional'),
                  subtitle: Text(
                    cref.isEmpty
                        ? 'CREF não informado'
                        : '$cref${estadoCref.isEmpty ? '' : ' - $estadoCref'}',
                  ),
                  trailing: Text(
                    statusCref.isEmpty ? 'Não informado' : statusCref,
                    style: const TextStyle(fontSize: 12),
                  ),
                ),
              ),
            ],

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed:
                salvando ? null : _salvar,
                style:
                ElevatedButton.styleFrom(
                  minimumSize:
                  const Size(
                    double.infinity,
                    50,
                  ),
                ),
                child: salvando
                    ? const SizedBox(
                  width: 22,
                  height: 22,
                  child:
                  CircularProgressIndicator(
                    strokeWidth: 2,
                  ),
                )
                    : const Text(
                  'Salvar alterações',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}