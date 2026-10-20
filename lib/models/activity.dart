class Activity {
  final int? id;
  final String title;
  final DateTime dateTime;
  final bool done;

  Activity({
    this.id,
    required this.title,
    required this.dateTime,
    required this.done,
  });
}