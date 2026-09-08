enum ClientStatus {
  active,
  pending,
  inactive,
}

class ProfessionalClient {
  final int id;
  final String name;
  final String email;
  final ClientStatus status;
  final String lastActivity;

  ProfessionalClient({
    required this.id,
    required this.name,
    required this.email,
    required this.status,
    required this.lastActivity,
  });
}