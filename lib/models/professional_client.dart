import 'client_status.dart';

class ProfessionalClient {
  final int id;
  final int usuarioId;
  final String name;
  final String email;
  final ClientStatus status;
  final String lastActivity;

  ProfessionalClient({
    required this.id,
    required this.usuarioId,
    required this.name,
    required this.email,
    required this.status,
    required this.lastActivity,
  });
}