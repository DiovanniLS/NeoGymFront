import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:neogym/components/universal_app_bar.dart';
import 'package:neogym/models/professional.dart';
import 'package:neogym/services/agendamento_service.dart';
import 'package:neogym/services/vinculo_service.dart';

class AddAtividade extends StatefulWidget {
  const AddAtividade({super.key});

  @override
  State<AddAtividade> createState() => _AddAtividadeState();
}

class _AddAtividadeState extends State<AddAtividade> {
  final titleController = TextEditingController();

  final AgendamentoService _agendamentoService = AgendamentoService();
  final VinculoService _vinculoService = VinculoService();

  DateTime selectedDate = DateTime.now();

  List<Professional> profissionais = [];
  Professional? profissionalSelecionado;

  bool loadingProfissionais = true;
  bool saving = false;

  @override
  void initState() {
    super.initState();
    _carregarProfissionais();
  }

  @override
  void dispose() {
    titleController.dispose();
    super.dispose();
  }

  Future<void> _carregarProfissionais() async {
    try {
      final resultado =
      await _vinculoService.buscarProfissionaisVinculados();

      if (!mounted) return;

      setState(() {
        profissionais = resultado;
        loadingProfissionais = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        loadingProfissionais = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Não foi possível carregar os profissionais vinculados.',
          ),
        ),
      );
    }
  }

  Future<void> pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );

    if (picked != null) {
      setState(() {
        selectedDate = DateTime(
          picked.year,
          picked.month,
          picked.day,
          selectedDate.hour,
          selectedDate.minute,
        );
      });
    }
  }

  Future<void> pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(selectedDate),
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(
            alwaysUse24HourFormat: true,
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        selectedDate = DateTime(
          selectedDate.year,
          selectedDate.month,
          selectedDate.day,
          picked.hour,
          picked.minute,
        );
      });
    }
  }

  String formatSmartDate(DateTime date) {
    final now = DateTime.now();

    if (date.day == now.day &&
        date.month == now.month &&
        date.year == now.year) {
      return "Hoje";
    }

    final tomorrow = now.add(
      const Duration(days: 1),
    );

    if (date.day == tomorrow.day &&
        date.month == tomorrow.month &&
        date.year == tomorrow.year) {
      return "Amanhã";
    }

    return DateFormat(
      "dd/MM",
      "pt_BR",
    ).format(date);
  }

  String formatTimeBR(DateTime date) {
    return DateFormat(
      "HH:mm",
      "pt_BR",
    ).format(date);
  }

  Future<void> saveActivity() async {
    final titulo = titleController.text.trim();

    if (titulo.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Informe o nome da atividade.",
          ),
        ),
      );

      return;
    }

    if (profissionalSelecionado == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Selecione um profissional.",
          ),
        ),
      );

      return;
    }

    if (selectedDate.isBefore(DateTime.now())) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Selecione uma data e horário futuros.",
          ),
        ),
      );

      return;
    }

    setState(() {
      saving = true;
    });

    try {
      final profissional = profissionalSelecionado!;

      final profissionalId = int.tryParse(profissional.id);

      if (profissionalId == null) {
        throw Exception(
          'ID do profissional inválido: ${profissional.id}',
        );
      }

      final agendamento =
      await _agendamentoService.criarAgendamento(
        profissionalId: profissionalId,
        tipoProfissional: profissional.type,
        titulo: titulo,
        dataHora: selectedDate,
      );

      if (!mounted) return;

      Navigator.pop(
        context,
        agendamento,
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "Não foi possível criar o agendamento.",
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          saving = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: UniversalAppBar(
        title: "Nova atividade",
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            if (loadingProfissionais)
              const Padding(
                padding: EdgeInsets.only(bottom: 16),
                child: LinearProgressIndicator(),
              )
            else if (profissionais.isEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.grey,
                  ),
                ),
                child: const Text(
                  "Você não possui profissionais vinculados.",
                ),
              )
            else
              DropdownButtonFormField<Professional>(
                value: profissionalSelecionado,
                decoration: const InputDecoration(
                  labelText: "Profissional",
                  border: OutlineInputBorder(),
                ),
                items: profissionais.map((profissional) {
                  return DropdownMenuItem<Professional>(
                    value: profissional,
                    child: Text(
                      profissional.name,
                    ),
                  );
                }).toList(),
                onChanged: saving
                    ? null
                    : (value) {
                  setState(() {
                    profissionalSelecionado = value;
                  });
                },
              ),

            const SizedBox(height: 16),

            TextField(
              controller: titleController,
              enabled: !saving,
              decoration: const InputDecoration(
                labelText: "Nome da atividade",
              ),
            ),

            const SizedBox(height: 16),

            GestureDetector(
              onTap: saving ? null : pickTime,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.grey,
                  ),
                ),
                child: Row(
                  mainAxisAlignment:
                  MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      formatTimeBR(selectedDate),
                    ),
                    const Icon(
                      Icons.access_time,
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            GestureDetector(
              onTap: saving ? null : pickDate,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.grey,
                  ),
                ),
                child: Row(
                  mainAxisAlignment:
                  MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      formatSmartDate(selectedDate),
                    ),
                    const Icon(
                      Icons.calendar_today,
                    ),
                  ],
                ),
              ),
            ),

            const Spacer(),

            ElevatedButton(
              onPressed:
              saving || profissionais.isEmpty
                  ? null
                  : saveActivity,
              style: ElevatedButton.styleFrom(
                minimumSize:
                const Size(double.infinity, 50),
              ),
              child: saving
                  ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                ),
              )
                  : const Text("Salvar"),
            ),
          ],
        ),
      ),
    );
  }
}