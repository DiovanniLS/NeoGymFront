import 'package:flutter/material.dart';
import 'package:neogym/Resources/neo_gym_colors.dart';
import 'package:neogym/components/swipeable_card.dart';
import 'package:neogym/components/universal_app_bar.dart';
import 'package:neogym/models/activity.dart';

import 'add_atividade.dart';

class ActivitiesScreen extends StatefulWidget {
  const ActivitiesScreen({super.key});

  @override
  State<ActivitiesScreen> createState() => _ActivitiesScreenState();
}

class _ActivitiesScreenState extends State<ActivitiesScreen> {
  @override
  Widget build(BuildContext context) {
    final grouped = groupByDay(activities);

    return Scaffold(
      appBar: UniversalAppBar(title: "Próximas atividades"),
      body: ListView(
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

              ...entry.value.map((activity) => buildCard(activity)),

              const SizedBox(height: 20),
            ],
          );
        }).toList(),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final newActivity = await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddAtividade()),
          );

          if (newActivity != null) {
            setState(() {
              activities.add(newActivity);
            });
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Map<String, List<Activity>> groupByDay(List<Activity> list) {
    final Map<String, List<Activity>> map = {};

    list.sort((a, b) => a.dateTime.compareTo(b.dateTime));

    for (var item in list) {
      final key = formatDay(item.dateTime);

      map.putIfAbsent(key, () => []);
      map[key]!.add(item);
    }

    return map;
  }

  Widget buildCard(Activity activity) {
    return SwipeableCard(
      leading: Icon(
        activity.done ? Icons.check_circle : Icons.schedule,
        color: activity.done ? NeoGymColors.primary : Colors.black,
      ),
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            activity.title,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              decoration: activity.done ? TextDecoration.lineThrough : null,
            ),
          ),
          Text(activity.time),
        ],
      ),
      onTap: () async {
        final result = await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => AddAtividade(activity: activity),
          ),
        );

        if (result != null) {
          setState(() {
            final index = activities.indexOf(activity);
            if (index != -1) {
              activities[index] = result;
            }
          });
        }
      },
      trailing: Checkbox(
          value: activity.done,
          onChanged: (value) {
            setState(() {
              activity.done = value!;
            });

            if (value == true) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text("${activity.title} concluído 💪"),
                  duration: const Duration(seconds: 1),
                ),
              );
            }
          }
      ),
      onDelete: (){
        setState(() {
          activities.remove(activity);
        });
      },
    );
  }


  String formatDay(DateTime date) {
    final now = DateTime.now();

    if (date.day == now.day &&
        date.month == now.month &&
        date.year == now.year) {
      return "Hoje";
    }

    final tomorrow = now.add(const Duration(days: 1));

    if (date.day == tomorrow.day &&
        date.month == tomorrow.month &&
        date.year == tomorrow.year) {
      return "Amanhã";
    }

    return "${date.day}/${date.month}";
  }
}
