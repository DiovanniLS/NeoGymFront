import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:neogym/services/usuario_service.dart';

class FotoUsuario extends StatefulWidget {
  final int? usuarioId;
  final double width;
  final double height;
  final double borderRadius;
  final BoxFit fit;
  final IconData fallbackIcon;
  final double iconSize;

  const FotoUsuario({
    super.key,
    required this.usuarioId,
    this.width = 48,
    this.height = 48,
    this.borderRadius = 1000,
    this.fit = BoxFit.cover,
    this.fallbackIcon = Icons.person,
    this.iconSize = 28,
  });

  @override
  State<FotoUsuario> createState() => _FotoUsuarioState();
}

class _FotoUsuarioState extends State<FotoUsuario> {
  late Future<Uint8List?>? _fotoFuture;

  @override
  void initState() {
    super.initState();
    _carregarFoto();
  }

  @override
  void didUpdateWidget(covariant FotoUsuario oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.usuarioId != widget.usuarioId) {
      _carregarFoto();
    }
  }

  void _carregarFoto() {
    final id = widget.usuarioId;

    _fotoFuture = id == null
        ? null
        : UsuarioService().buscarFotoPorUsuarioId(id);
  }

  Widget _placeholder(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: widget.width,
      height: widget.height,
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(widget.borderRadius),
      ),
      alignment: Alignment.center,
      child: Icon(
        widget.fallbackIcon,
        size: widget.iconSize,
        color: theme.colorScheme.onSurfaceVariant,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_fotoFuture == null) {
      return _placeholder(context);
    }

    return FutureBuilder<Uint8List?>(
      future: _fotoFuture,
      builder: (context, snapshot) {
        final bytes = snapshot.data;

        if (snapshot.hasError || bytes == null || bytes.isEmpty) {
          return _placeholder(context);
        }

        return ClipRRect(
          borderRadius: BorderRadius.circular(widget.borderRadius),
          child: Image.memory(
            bytes,
            width: widget.width,
            height: widget.height,
            fit: widget.fit,
            errorBuilder: (_, __, ___) => _placeholder(context),
          ),
        );
      },
    );
  }
}