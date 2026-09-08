enum EventType {
  training,
  evaluation,
  consultation,
  other,
}

class AgendaEvent {
  final int? id;
  final String clientName;
  final String title;
  final DateTime dateTime;
  final int durationMinutes;
  final EventType type;
  final String? observation;
  bool completed;

  AgendaEvent({
    this.id,
    required this.clientName,
    required this.title,
    required this.dateTime,
    required this.durationMinutes,
    required this.type,
    this.observation,
    this.completed = false,
  });
}