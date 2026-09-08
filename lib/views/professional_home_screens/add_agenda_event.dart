import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:neogym/Resources/neo_gym_colors.dart';
import 'package:neogym/components/universal_app_bar.dart';
import 'package:neogym/models/agenda_event.dart';

class AddAgendaEvent extends StatefulWidget {
  final AgendaEvent? event;

  const AddAgendaEvent({
    super.key,
    this.event,
  });

  @override
  State<AddAgendaEvent> createState() => _AddAgendaEventState();
}

class _AddAgendaEventState extends State<AddAgendaEvent> {
  final titleController = TextEditingController();
  final observationController = TextEditingController();

  DateTime selectedDate = DateTime.now();

  String? selectedClient;

  EventType selectedType = EventType.training;

  int selectedDuration = 60;

  // Depois isso pode vir da API
  final List<String> clients = [
    "Lucas Almeida",
    "Ana Souza",
    "Marcos Silva",
    "Juliana Santos",
  ];

  final List<int> durations = [
    30,
    45,
    60,
    90,
    120,
  ];

  @override
  void initState() {
    super.initState();

    final event = widget.event;

    if (event != null) {
      titleController.text = event.title;
      observationController.text = event.observation ?? "";

      selectedClient = event.clientName;
      selectedDate = event.dateTime;
      selectedType = event.type;
      selectedDuration = event.durationMinutes;
    }
  }

  @override
  void dispose() {
    titleController.dispose();
    observationController.dispose();

    super.dispose();
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
      initialTime: TimeOfDay(
        hour: selectedDate.hour,
        minute: selectedDate.minute,
      ),
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

    final today = DateTime(
      now.year,
      now.month,
      now.day,
    );

    final selected = DateTime(
      date.year,
      date.month,
      date.day,
    );

    final tomorrow = today.add(
      const Duration(days: 1),
    );

    if (selected == today) {
      return "Hoje";
    }

    if (selected == tomorrow) {
      return "Amanhã";
    }

    return DateFormat(
      "dd/MM/yyyy",
      "pt_BR",
    ).format(date);
  }

  String formatTimeBR(DateTime date) {
    return DateFormat(
      "HH:mm",
      "pt_BR",
    ).format(date);
  }

  String eventTypeLabel(EventType type) {
    switch (type) {
      case EventType.training:
        return "Treino";

      case EventType.evaluation:
        return "Avaliação física";

      case EventType.consultation:
        return "Consulta";

      case EventType.other:
        return "Outro";
    }
  }

  IconData eventTypeIcon(EventType type) {
    switch (type) {
      case EventType.training:
        return Icons.fitness_center;

      case EventType.evaluation:
        return Icons.assignment_outlined;

      case EventType.consultation:
        return Icons.medical_information_outlined;

      case EventType.other:
        return Icons.event_outlined;
    }
  }

  void saveEvent() {
    if (selectedClient == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Selecione um aluno",
          ),
        ),
      );

      return;
    }

    if (titleController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Informe o nome da atividade",
          ),
        ),
      );

      return;
    }

    final event = AgendaEvent(
      id: widget.event?.id,
      clientName: selectedClient!,
      title: titleController.text.trim(),
      dateTime: selectedDate,
      durationMinutes: selectedDuration,
      type: selectedType,
      observation:
      observationController.text.trim().isEmpty
          ? null
          : observationController.text.trim(),
      completed: widget.event?.completed ?? false,
    );

    Navigator.pop(
      context,
      event,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: UniversalAppBar(
        title: widget.event != null
            ? "Editar agendamento"
            : "Novo agendamento",
      ),

      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Aluno",
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),

              const SizedBox(height: 8),

              DropdownButtonFormField<String>(
                value: selectedClient,
                decoration: InputDecoration(
                  hintText: "Selecione um aluno",
                  prefixIcon: const Icon(
                    Icons.person_outline,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                items: clients.map((client) {
                  return DropdownMenuItem(
                    value: client,
                    child: Text(client),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    selectedClient = value;
                  });
                },
              ),

              const SizedBox(height: 20),

              const Text(
                "Atividade",
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),

              const SizedBox(height: 8),

              TextField(
                controller: titleController,
                decoration: InputDecoration(
                  hintText: "Ex: Treino de superiores",
                  prefixIcon: const Icon(
                    Icons.edit_outlined,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              const Text(
                "Tipo",
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),

              const SizedBox(height: 8),

              DropdownButtonFormField<EventType>(
                value: selectedType,
                decoration: InputDecoration(
                  prefixIcon: Icon(
                    eventTypeIcon(selectedType),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                items: EventType.values.map((type) {
                  return DropdownMenuItem(
                    value: type,
                    child: Text(
                      eventTypeLabel(type),
                    ),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value == null) return;

                  setState(() {
                    selectedType = value;
                  });
                },
              ),

              const SizedBox(height: 20),

              const Text(
                "Data e horário",
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),

              const SizedBox(height: 8),

              Row(
                children: [
                  Expanded(
                    child: InkWell(
                      borderRadius:
                      BorderRadius.circular(12),
                      onTap: pickDate,
                      child: Container(
                        height: 58,
                        padding:
                        const EdgeInsets.symmetric(
                          horizontal: 14,
                        ),
                        decoration: BoxDecoration(
                          borderRadius:
                          BorderRadius.circular(12),
                          border: Border.all(
                            color: Colors.grey.shade400,
                          ),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.calendar_today_outlined,
                            ),

                            const SizedBox(width: 10),

                            Expanded(
                              child: Text(
                                formatSmartDate(
                                  selectedDate,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(width: 12),

                  Expanded(
                    child: InkWell(
                      borderRadius:
                      BorderRadius.circular(12),
                      onTap: pickTime,
                      child: Container(
                        height: 58,
                        padding:
                        const EdgeInsets.symmetric(
                          horizontal: 14,
                        ),
                        decoration: BoxDecoration(
                          borderRadius:
                          BorderRadius.circular(12),
                          border: Border.all(
                            color: Colors.grey.shade400,
                          ),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.access_time,
                            ),

                            const SizedBox(width: 10),

                            Text(
                              formatTimeBR(
                                selectedDate,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              const Text(
                "Duração",
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),

              const SizedBox(height: 8),

              DropdownButtonFormField<int>(
                value: selectedDuration,
                decoration: InputDecoration(
                  prefixIcon: const Icon(
                    Icons.timer_outlined,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                items: durations.map((duration) {
                  return DropdownMenuItem(
                    value: duration,
                    child: Text(
                      formatDuration(duration),
                    ),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value == null) return;

                  setState(() {
                    selectedDuration = value;
                  });
                },
              ),

              const SizedBox(height: 20),

              const Text(
                "Observação",
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),

              const SizedBox(height: 8),

              TextField(
                controller: observationController,
                maxLines: 4,
                decoration: InputDecoration(
                  hintText:
                  "Adicione alguma observação sobre o atendimento...",
                  alignLabelWithHint: true,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),

              const SizedBox(height: 32),

              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                    NeoGymColors.primary,
                    foregroundColor:
                    Colors.white,
                  ),
                  onPressed: saveEvent,
                  icon: const Icon(
                    Icons.check,
                  ),
                  label: Text(
                    widget.event != null
                        ? "Salvar alterações"
                        : "Adicionar à agenda",
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String formatDuration(int minutes) {
    if (minutes < 60) {
      return "$minutes minutos";
    }

    if (minutes == 60) {
      return "1 hora";
    }

    if (minutes == 90) {
      return "1 hora e 30 minutos";
    }

    if (minutes == 120) {
      return "2 horas";
    }

    return "$minutes minutos";
  }
}