
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import 'package:neogym/Resources/neo_gym_colors.dart';
import 'package:neogym/components/universal_app_bar.dart';


import '../../models/foto_galeria_profisssional.dart';
import '../../services/galeria_profisssional_service.dart';
import '../../view_model/auth_view_model.dart';


class GaleriaProfissionalScreen extends StatefulWidget {
  const GaleriaProfissionalScreen({super.key});

  @override
  State<GaleriaProfissionalScreen> createState() =>
      _GaleriaProfissionalScreenState();
}

class _GaleriaProfissionalScreenState
    extends State<GaleriaProfissionalScreen> {
  final GaleriaProfissionalService _service =
  GaleriaProfissionalService();

  final ImagePicker _picker = ImagePicker();

  late int _usuarioId;
  late Future<List<FotoGaleriaProfissional>> _future;

  @override
  void initState() {
    super.initState();

    final usuario = context.read<AuthViewModel>().user;
    _usuarioId = usuario?.usuarioId ?? 0;

    _future = _usuarioId > 0
        ? _service.listarFotos(_usuarioId)
        : Future.error(
      StateError('Usuário não autenticado.'),
    );
  }

  Future<void> _recarregar() async {
    final future = _service.listarFotos(_usuarioId);

    setState(() {
      _future = future;
    });

    try {
      await future;
    } catch (_) {
      // O FutureBuilder apresentará o erro.
    }
  }

  Future<void> _adicionarFoto() async {
    final imagem = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
      maxWidth: 1600,
    );

    if (imagem == null || !mounted) return;

    final tamanho = await imagem.length();

    if (tamanho > 5 * 1024 * 1024) {
      _mensagem('A foto deve ter no máximo 5 MB.');
      return;
    }

    try {
      await _service.adicionarFoto(imagem.path);

      if (!mounted) return;

      await _recarregar();

      if (!mounted) return;

      _mensagem('Foto adicionada à galeria.');
    } catch (e) {
      if (!mounted) return;

      _mensagem(_mensagemErro(e));
    }
  }

  Future<void> _excluirFoto(
      FotoGaleriaProfissional foto,
      ) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Excluir foto?'),
        content: const Text(
          'A foto será removida da sua galeria profissional.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );

    if (confirmar != true || !mounted) return;

    try {
      await _service.excluirFoto(foto.id);

      if (!mounted) return;

      await _recarregar();

      if (!mounted) return;

      _mensagem('Foto removida.');
    } catch (e) {
      if (!mounted) return;

      _mensagem(_mensagemErro(e));
    }
  }

  void _mensagem(String texto) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(texto)),
    );
  }

  String _mensagemErro(Object erro) {
    final texto = erro.toString();

    if (texto.contains('409') ||
        texto.contains('limite de 8 fotos')) {
      return 'Você já atingiu o limite de 8 fotos.';
    }

    if (texto.contains('5 MB')) {
      return 'A foto deve ter no máximo 5 MB.';
    }

    if (texto.contains('Formato não permitido')) {
      return 'Utilize uma foto JPEG, PNG ou WebP.';
    }

    return 'Não foi possível concluir a operação. '
        'Verifique sua conexão e tente novamente.';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const UniversalAppBar(
        title: 'Galeria profissional',
      ),
      body: FutureBuilder<List<FotoGaleriaProfissional>>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState ==
              ConnectionState.waiting &&
              !snapshot.hasData) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (snapshot.hasError && !snapshot.hasData) {
            return _estadoErro();
          }

          final fotos = snapshot.data ?? [];

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 18, 20, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Mostre seu trabalho',
                      style: TextStyle(
                        fontSize: 21,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Adicione fotos dos seus treinos, espaços e '
                          'atividades profissionais para os alunos conhecerem '
                          'melhor seu trabalho.',
                    ),
                    const SizedBox(height: 10),
                    Text(
                      '${fotos.length} de 8 fotos',
                      style: TextStyle(
                        color: NeoGymColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: RefreshIndicator(
                  onRefresh: _recarregar,
                  child: fotos.isEmpty
                      ? ListView(
                    physics:
                    const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(24),
                    children: const [
                      SizedBox(height: 65),
                      Icon(
                        Icons.photo_library_outlined,
                        size: 68,
                        color: Colors.grey,
                      ),
                      SizedBox(height: 16),
                      Text(
                        'Sua galeria está vazia',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Adicione sua primeira foto usando '
                            'o botão abaixo.',
                        textAlign: TextAlign.center,
                      ),
                    ],
                  )
                      : GridView.builder(
                    physics:
                    const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(16),
                    gridDelegate:
                    const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 0.86,
                    ),
                    itemCount: fotos.length,
                    itemBuilder: (context, index) {
                      final foto = fotos[index];

                      return _FotoGaleriaTile(
                        service: _service,
                        usuarioId: _usuarioId,
                        foto: foto,
                        onDelete: () => _excluirFoto(foto),
                      );
                    },
                  ),
                ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _adicionarFoto,
        backgroundColor: NeoGymColors.primary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add_photo_alternate_outlined),
        label: const Text('Adicionar foto'),
      ),
    );
  }

  Widget _estadoErro() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.cloud_off_outlined,
              size: 48,
            ),
            const SizedBox(height: 12),
            const Text(
              'Não foi possível carregar sua galeria.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: _recarregar,
              child: const Text('Tentar novamente'),
            ),
          ],
        ),
      ),
    );
  }
}

class _FotoGaleriaTile extends StatefulWidget {
  final GaleriaProfissionalService service;
  final int usuarioId;
  final FotoGaleriaProfissional foto;
  final VoidCallback? onDelete;

  const _FotoGaleriaTile({
    required this.service,
    required this.usuarioId,
    required this.foto,
    this.onDelete,
  });

  @override
  State<_FotoGaleriaTile> createState() => _FotoGaleriaTileState();
}

class _FotoGaleriaTileState extends State<_FotoGaleriaTile> {
  late Future<Uint8List> _imagem;

  @override
  void initState() {
    super.initState();
    _carregarImagem();
  }

  @override
  void didUpdateWidget(covariant _FotoGaleriaTile oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.foto.id != widget.foto.id ||
        oldWidget.usuarioId != widget.usuarioId) {
      _carregarImagem();
    }
  }

  void _carregarImagem() {
    _imagem = widget.service.carregarFoto(
      usuarioId: widget.usuarioId,
      fotoId: widget.foto.id,
    );
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Stack(
        fit: StackFit.expand,
        children: [
          Container(color: Colors.grey.shade200),
          FutureBuilder<Uint8List>(
            future: _imagem,
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return const Center(
                  child: Icon(
                    Icons.broken_image_outlined,
                    size: 35,
                    color: Colors.grey,
                  ),
                );
              }

              if (!snapshot.hasData) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }

              return Image.memory(
                snapshot.data!,
                fit: BoxFit.cover,
              );
            },
          ),
          if (widget.onDelete != null)
            Positioned(
              top: 7,
              right: 7,
              child: Material(
                color: Colors.black54,
                shape: const CircleBorder(),
                child: IconButton(
                  tooltip: 'Excluir foto',
                  onPressed: widget.onDelete,
                  icon: const Icon(
                    Icons.delete_outline,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}


class GaleriaFotosPublicas extends StatefulWidget {
  final int usuarioId;

  const GaleriaFotosPublicas({
    super.key,
    required this.usuarioId,
  });

  @override
  State<GaleriaFotosPublicas> createState() =>
      _GaleriaFotosPublicasState();
}

class _GaleriaFotosPublicasState
    extends State<GaleriaFotosPublicas> {
  final GaleriaProfissionalService _service =
  GaleriaProfissionalService();

  late Future<List<FotoGaleriaProfissional>> _future;

  @override
  void initState() {
    super.initState();
    _carregar();
  }

  @override
  void didUpdateWidget(covariant GaleriaFotosPublicas oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.usuarioId != widget.usuarioId) {
      _carregar();
    }
  }

  void _carregar() {
    _future = _service.listarFotos(widget.usuarioId);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<FotoGaleriaProfissional>>(
      future: _future,
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const SizedBox.shrink();
        }

        final fotos = snapshot.data!;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 24),
            const Text(
              'Fotos profissionais',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate:
              const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                childAspectRatio: 0.90,
              ),
              itemCount: fotos.length,
              itemBuilder: (context, index) {
                return _FotoGaleriaTile(
                  service: _service,
                  usuarioId: widget.usuarioId,
                  foto: fotos[index],
                );
              },
            ),
          ],
        );
      },
    );
  }
}

