import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:neogym/components/universal_app_bar.dart';
import 'package:neogym/models/activity.dart';

class AddAtividade extends StatefulWidget {
  const AddAtividade({super.key});

  @override
  State<AddAtividade> createState() => _AddAtividadeState();
}

class _AddAtividadeState extends State<AddAtividade> {
  final titleController = TextEditingController();

  DateTime selectedDate = DateTime.now().toLocal();

  final List<String> days = [
    "Hoje",
    "Amanhã",
    "Segunda",
    "Terça",
    "Quarta",
    "Quinta",
    "Sexta",
  ];

  Future<void> pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );

    if (picked != null) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  Future<void> pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
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

    if (date.day == now.add(const Duration(days: 1)).day &&
        date.month == now.month) {
      return "Amanhã";
    }

    return DateFormat("dd/MM", "pt_BR").format(date);
  }
  String formatTimeBR(DateTime date) {
    return DateFormat("HH:mm", "pt_BR").format(date);
  }

  void saveActivity() {
    if (titleController.text.isEmpty) return;

    final newActivity = Activity(
      title: titleController.text,
      time: formatTimeBR(selectedDate),
      dateTime: selectedDate,
    );

    Navigator.pop(context, newActivity);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: UniversalAppBar(title: "Nova Atividade"),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(labelText: "Nome da atividade"),
            ),
            const SizedBox(height: 16),

            GestureDetector(
              onTap: pickTime,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "${selectedDate.hour.toString().padLeft(2, '0')}:${selectedDate.minute.toString().padLeft(2, '0')}",
                    ),
                    const Icon(Icons.access_time),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            GestureDetector(
              onTap: pickDate,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      formatSmartDate(selectedDate),
                    ),
                    const Icon(Icons.calendar_today),
                  ],
                ),
              ),
            ),

            const Spacer(),

            ElevatedButton(
                onPressed: saveActivity,
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50)
                ),
                child: const Text("Salvar")
            )
          ],
        ),
      ),
    );
  }
}
