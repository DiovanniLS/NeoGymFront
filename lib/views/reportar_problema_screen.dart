import 'package:flutter/material.dart';
import 'package:neogym/components/universal_app_bar.dart';

class ReportarProblemaScreen extends StatefulWidget {
  const ReportarProblemaScreen({super.key});

  @override
  State<ReportarProblemaScreen> createState() =>
      _ReportarProblemaScreenState();
}

class _ReportarProblemaScreenState
    extends State<ReportarProblemaScreen> {
  final assuntoController = TextEditingController();
  final descricaoController = TextEditingController();

  bool enviando = false;

  @override
  void dispose() {
    assuntoController.dispose();
    descricaoController.dispose();
    super.dispose();
  }

  Future<void> enviar() async {
    if (assuntoController.text.trim().isEmpty ||
        descricaoController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Preencha o assunto e a descrição.',
          ),
        ),
      );
      return;
    }

    setState(() {
      enviando = true;
    });

    try {
      // Futuramente:
      // await SuporteService().reportarProblema(...);

      await Future.delayed(
        const Duration(milliseconds: 500),
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Problema enviado com sucesso.',
          ),
        ),
      );

      Navigator.pop(context);
    } finally {
      if (mounted) {
        setState(() {
          enviando = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const UniversalAppBar(
        title: 'Reportar problema',
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              controller: assuntoController,
              decoration: const InputDecoration(
                labelText: 'Assunto',
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 16),

            Expanded(
              child: TextField(
                controller: descricaoController,
                maxLines: null,
                expands: true,
                textAlignVertical:
                TextAlignVertical.top,
                decoration: const InputDecoration(
                  labelText: 'Descreva o problema',
                  hintText:
                  'Conte o que aconteceu...',
                  border: OutlineInputBorder(),
                ),
              ),
            ),

            const SizedBox(height: 16),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: enviando ? null : enviar,
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(
                    double.infinity,
                    50,
                  ),
                ),
                child: enviando
                    ? const SizedBox(
                  width: 22,
                  height: 22,
                  child:
                  CircularProgressIndicator(
                    strokeWidth: 2,
                  ),
                )
                    : const Text(
                  'Enviar problema',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}