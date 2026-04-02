class Activity {
  final String title;
  final String time;
  final DateTime dateTime;
  bool done;

  Activity({
    required this.title,
    required this.time,
    required this.dateTime,
    this.done = false,
  });
}

List<Activity> activities = [
  Activity(
    title: "Funcional",
    time: "18:00",
    dateTime: DateTime.now(),
  ),

  Activity(
    title: "Musculação",
    time: "20:00",
    dateTime: DateTime.now(),
  ),

  Activity(
    title: "Cardio",
    time: "07:00",
    dateTime: DateTime.now().add(const Duration(days: 1)),
  ),
];