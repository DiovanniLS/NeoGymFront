import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:neogym/services/usuario_service.dart';

class FotoPerfil extends StatefulWidget {
  final double radius;
  final IconData fallbackIcon;

  const FotoPerfil({
    super.key,
    this.radius = 28,
    this.fallbackIcon = Icons.person,
  });

  @override
  State<FotoPerfil> createState() => _FotoPerfilState();
}

class _FotoPerfilState extends State<FotoPerfil> {
  final UsuarioService _usuarioService = UsuarioService();

  Uint8List? _foto;
  bool _carregando = true;

  @override
  void initState() {
    super.initState();
    _carregarFoto();
  }

  Future<void> _carregarFoto() async {
    try {
      final foto = await _usuarioService.buscarFoto();

      if (!mounted) return;

      setState(() {
        _foto = foto;
        _carregando = false;
      });
    } catch (_) {
      if (!mounted) return;

      setState(() {
        _carregando = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_carregando) {
      return CircleAvatar(
        radius: widget.radius,
        child: SizedBox(
          width: widget.radius * 0.5,
          height: widget.radius * 0.5,
          child: const CircularProgressIndicator(
            strokeWidth: 2,
          ),
        ),
      );
    }

    return CircleAvatar(
      radius: widget.radius,
      backgroundImage:
      _foto != null ? MemoryImage(_foto!) : null,
      child: _foto == null
          ? Icon(
        widget.fallbackIcon,
        size: widget.radius,
      )
          : null,
    );
  }
}