import 'package:flutter/material.dart';
import 'package:neogym/Resources/neo_gym_colors.dart';
import 'package:neogym/components/swipeable_card.dart';
import 'package:neogym/components/universal_app_bar.dart';

class ProfessionalAgendaScreen extends StatefulWidget {
  const ProfessionalAgendaScreen({super.key});

  @override
  State<ProfessionalAgendaScreen> createState() =>
      _ProfessionalAgendaScreenState();
}

class _ProfessionalAgendaScreenState
    extends State<ProfessionalAgendaScreen> {

  final List<AgendaEvent> events = [
    AgendaEvent(
      id: 1,
      clientName: "Lucas Almeida",
      title: "Treino personalizado",
      dateTime: DateTime.now().copyWith(
        hour: 9,
        minute: 0,
      ),
      durationMinutes: 60,
      type: EventType.training,
    ),
    AgendaEvent(
      id: 2,
      clientName: "Ana Souza",
      title: "Avaliação física",
      dateTime: DateTime.now().copyWith(
        hour: 10,
        minute: 30,
      ),
      durationMinutes: 45,
      type: EventType.evaluation,
    ),
    AgendaEvent(
      id: 3,
      clientName: "Marcos Silva",
      title: "Treino personalizado",
      dateTime: DateTime.now()
          .add(const Duration(days: 1))
          .copyWith(
        hour: 14,
        minute: 0,
      ),
      durationMinutes: 60,
      type: EventType.training,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final grouped = groupByDay(events);

    return Scaffold(
      appBar: UniversalAppBar(
        title: "Minha agenda",
      ),

      body: events.isEmpty
          ? _buildEmptyState()
          : ListView(
        padding: const EdgeInsets.all(16),
        children: grouped.entries.map((entry) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                entry.key,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 10),

              ...entry.value.map(
                    (event) => buildEventCard(event),
              ),

              const SizedBox(height: 20),
            ],
          );
        }).toList(),
      ),

      floatingActionButton: FloatingActionButton(
        backgroundColor: NeoGymColors.primary,
        foregroundColor: Colors.white,
        onPressed: () {
          Navigator.pushNamed(context, "/addEventoAgenda");
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget buildEventCard(AgendaEvent event) {
    return SwipeableCard(
      leading: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: getTypeColor(event.type).withOpacity(0.12),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(
          getTypeIcon(event.type),
          color: getTypeColor(event.type),
        ),
      ),

      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            event.title,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              decoration: event.completed
                  ? TextDecoration.lineThrough
                  : null,
            ),
          ),

          const SizedBox(height: 5),

          Row(
            children: [
              const Icon(
                Icons.person_outline,
                size: 17,
                color: Colors.grey,
              ),

              const SizedBox(width: 5),

              Expanded(
                child: Text(
                  event.clientName,
                  style: const TextStyle(
                    color: Colors.black87,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 5),

          Row(
            children: [
              const Icon(
                Icons.access_time,
                size: 17,
                color: Colors.grey,
              ),

              const SizedBox(width: 5),

              Text(
                "${formatTime(event.dateTime)}"
                    " • ${event.durationMinutes} min",
                style: const TextStyle(
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        ],
      ),

      trailing: Checkbox(
        value: event.completed,
        activeColor: NeoGymColors.primary,
        onChanged: (value) {
          setState(() {
            event.completed = value ?? false;
          });

          if (value == true) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  "Atendimento com ${event.clientName} concluído 💪",
                ),
                duration: const Duration(seconds: 1),
              ),
            );
          }
        },
      ),

      onTap: () {
        showEventDetails(event);
      },

      onDelete: () {
        setState(() {
          events.remove(event);
        });
      },
    );
  }

  void showEventDetails(AgendaEvent event) {
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(
            20,
            10,
            20,
            30,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                event.title,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 20),

              buildDetailRow(
                Icons.person_outline,
                "Aluno",
                event.clientName,
              ),

              buildDetailRow(
                Icons.calendar_today_outlined,
                "Data",
                formatCompleteDate(event.dateTime),
              ),

              buildDetailRow(
                Icons.access_time,
                "Horário",
                formatTime(event.dateTime),
              ),

              buildDetailRow(
                Icons.timer_outlined,
                "Duração",
                "${event.durationMinutes} minutos",
              ),

              const SizedBox(height: 20),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pop(context);

                    setState(() {
                      event.completed = true;
                    });
                  },
                  icon: const Icon(Icons.check),
                  label: const Text(
                    "Marcar como concluído",
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget buildDetailRow(
      IconData icon,
      String title,
      String value,
      ) {
    return Padding(
      padding: const EdgeInsets.only(
        bottom: 14,
      ),
      child: Row(
        children: [
          Icon(
            icon,
            color: NeoGymColors.primary,
          ),

          const SizedBox(width: 12),

          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: Colors.grey,
                  fontSize: 12,
                ),
              ),

              Text(
                value,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(30),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.calendar_month_outlined,
              size: 80,
              color: Colors.grey.shade400,
            ),

            const SizedBox(height: 20),

            const Text(
              "Nenhum atendimento agendado",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 8),

            const Text(
              "Seus próximos atendimentos aparecerão aqui.",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Map<String, List<AgendaEvent>> groupByDay(
      List<AgendaEvent> list,
      ) {
    final Map<String, List<AgendaEvent>> map = {};

    final sorted = List<AgendaEvent>.from(list);

    sorted.sort(
          (a, b) => a.dateTime.compareTo(b.dateTime),
    );

    for (final event in sorted) {
      final key = formatDay(event.dateTime);

      map.putIfAbsent(key, () => []);

      map[key]!.add(event);
    }

    return map;
  }

  String formatDay(DateTime date) {
    final now = DateTime.now();

    final today = DateTime(
      now.year,
      now.month,
      now.day,
    );

    final eventDay = DateTime(
      date.year,
      date.month,
      date.day,
    );

    final tomorrow = today.add(
      const Duration(days: 1),
    );

    if (eventDay == today) {
      return "Hoje";
    }

    if (eventDay == tomorrow) {
      return "Amanhã";
    }

    return "${date.day.toString().padLeft(2, '0')}/"
        "${date.month.toString().padLeft(2, '0')}";
  }

  String formatTime(DateTime date) {
    return "${date.hour.toString().padLeft(2, '0')}:"
        "${date.minute.toString().padLeft(2, '0')}";
  }

  String formatCompleteDate(DateTime date) {
    return "${date.day.toString().padLeft(2, '0')}/"
        "${date.month.toString().padLeft(2, '0')}/"
        "${date.year}";
  }

  IconData getTypeIcon(EventType type) {
    switch (type) {
      case EventType.training:
        return Icons.fitness_center;

      case EventType.evaluation:
        return Icons.assignment_outlined;

      case EventType.consultation:
        return Icons.medical_information_outlined;

      case EventType.other:
        return Icons.event;
    }
  }

  Color getTypeColor(EventType type) {
    switch (type) {
      case EventType.training:
        return NeoGymColors.primary;

      case EventType.evaluation:
        return Colors.orange;

      case EventType.consultation:
        return Colors.blue;

      case EventType.other:
        return Colors.grey;
    }
  }
}

enum EventType {
  training,
  evaluation,
  consultation,
  other,
}

class AgendaEvent {
  final int id;

  final String clientName;

  final String title;

  final DateTime dateTime;

  final int durationMinutes;

  final EventType type;

  bool completed;

  AgendaEvent({
    required this.id,
    required this.clientName,
    required this.title,
    required this.dateTime,
    required this.durationMinutes,
    required this.type,
    this.completed = false,
  });
}