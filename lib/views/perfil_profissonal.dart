import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import '../models/professional.dart';
import '../services/vinculo_service.dart';

class ProfessionalDetailScreen extends StatefulWidget {
  final Professional prof;

  const ProfessionalDetailScreen({
    super.key,
    required this.prof,
  });

  @override
  State<ProfessionalDetailScreen> createState() =>
      _ProfessionalDetailScreenState();
}

class _ProfessionalDetailScreenState
    extends State<ProfessionalDetailScreen> {


  @override
  void initState() {
    super.initState();
    _carregarStatusVinculo();
  }

  Future<void> _carregarStatusVinculo() async {
    try {
      final status = await _vinculoService.consultarStatusVinculo(
        outroUsuarioId: widget.prof.usuarioId,
      );

      if (!mounted) return;

      setState(() {
        _statusVinculo = status;
        _carregandoVinculo = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _carregandoVinculo = false;
      });
    }
  }

  String _textoVinculo() {
    switch (_statusVinculo) {
      case 'PENDENTE':
        return 'Solicitação enviada';

      case 'ACEITO':
        return 'Vinculado';

      case 'RECUSADO':
        return 'Solicitar vínculo';

      case 'CANCELADO':
        return 'Solicitar vínculo';

      default:
        return 'Solicitar vínculo';
    }
  }

  IconData _iconeVinculo() {
    switch (_statusVinculo) {
      case 'PENDENTE':
        return Icons.hourglass_top;

      case 'ACEITO':
        return Icons.check;

      default:
        return Icons.person_add;
    }
  }

  bool get _podeSolicitar {
    return _statusVinculo == null ||
        _statusVinculo == 'RECUSADO' ||
        _statusVinculo == 'CANCELADO';
  }

  final VinculoService _vinculoService = VinculoService();

  bool _solicitando = false;
  String? _statusVinculo;
  bool _carregandoVinculo = true;

  Future<void> _solicitarVinculo() async {
    setState(() {
      _solicitando = true;
    });

    try {
      await _vinculoService.solicitarVinculo(
        profissionalUsuarioId: widget.prof.usuarioId,
        tipoProfissional: widget.prof.type == 'Personal'
            ? 'PERSONAL'
            : 'NUTRICIONISTA',
      );

      if (!mounted) return;

      setState(() {
        _statusVinculo = 'PENDENTE';
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Solicitação enviada com sucesso!'),
        ),
      );
    } on DioException catch (e) {
      if (!mounted) return;

      final mensagem = e.response?.data is Map
          ? e.response?.data['message']?.toString()
          : null;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            mensagem ?? 'Não foi possível enviar a solicitação.',
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Erro ao solicitar vínculo.'),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _solicitando = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            Stack(
              children: [
                Container(
                  height: 260,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: NetworkImage(widget.prof.image),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),

                Positioned(
                  top: 40,
                  left: 16,
                  child: CircleAvatar(
                    backgroundColor: Colors.black54,
                    child: IconButton(
                      icon: const Icon(
                        Icons.arrow_back,
                        color: Colors.white,
                      ),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                ),

                Positioned(
                  top: 40,
                  right: 16,
                  child: CircleAvatar(
                    backgroundColor: Colors.black54,
                    child: IconButton(
                      icon: const Icon(
                        Icons.more_vert_sharp,
                        color: Colors.white,
                      ),
                      onPressed: () {},
                    ),
                  ),
                ),
              ],
            ),

            Transform.translate(
              offset: const Offset(0, -30),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(30),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            widget.prof.name,
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),

                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: widget.prof.isOnline
                                ? Colors.green
                                : Colors.grey,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            widget.prof.isOnline
                                ? "Online"
                                : "Offline",
                            style: const TextStyle(
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 5),

                    Text(
                      widget.prof.specialty,
                      style: const TextStyle(
                        color: Colors.grey,
                      ),
                    ),

                    const SizedBox(height: 10),

                    Row(
                      children: [
                        const Icon(
                          Icons.star,
                          color: Colors.orange,
                        ),
                        Text("${widget.prof.rating}"),

                        const SizedBox(width: 10),

                        const Icon(Icons.location_on),

                        Text("${widget.prof.distance} km"),
                      ],
                    ),

                    const SizedBox(height: 20),

                    // ============================
                    // SOLICITAÇÃO DE VÍNCULO
                    // ============================

                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _carregandoVinculo ||
                            _solicitando ||
                            !_podeSolicitar
                            ? null
                            : _solicitarVinculo,
                        icon: _carregandoVinculo || _solicitando
                            ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                          ),
                        )
                            : Icon(_iconeVinculo()),
                        label: Text(
                          _carregandoVinculo
                              ? 'Verificando vínculo...'
                              : _solicitando
                              ? 'Enviando...'
                              : _textoVinculo(),
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    const Text(
                      "Sobre",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 5),

                    const Text(
                      "Profissional com experiência em treino personalizado, foco em hipertrofia e emagrecimento.",
                    ),

                    const SizedBox(height: 20),

                    const Text(
                      "Especialidades",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 10),

                    Wrap(
                      spacing: 8,
                      children: const [
                        Chip(label: Text("Hipertrofia")),
                        Chip(label: Text("Emagrecimento")),
                        Chip(label: Text("Funcional")),
                      ],
                    ),

                    const SizedBox(height: 20),

                    const Text(
                      "Horários disponíveis",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 10),

                    Wrap(
                      spacing: 8,
                      children: [
                        OutlinedButton(
                          onPressed: () {},
                          child: const Text("08:00"),
                        ),
                        OutlinedButton(
                          onPressed: () {},
                          child: const Text("10:00"),
                        ),
                        OutlinedButton(
                          onPressed: () {},
                          child: const Text("18:00"),
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}