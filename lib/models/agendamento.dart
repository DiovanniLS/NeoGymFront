class Agendamento {
  final int id;
  final int alunoId;
  final int profissionalId;
  final String tipoProfissional;
  final String? profissionalNome;
  final String titulo;
  final String? descricao;
  final DateTime dataHora;
  final String status;
  final DateTime criadoEm;

  Agendamento({
    required this.id,
    required this.alunoId,
    required this.profissionalId,
    required this.tipoProfissional,
    required this.profissionalNome,
    required this.titulo,
    this.descricao,
    required this.dataHora,
    required this.status,
    required this.criadoEm,
  });

  factory Agendamento.fromJson(Map<String, dynamic> json) {
    return Agendamento(
      id: json['id'],
      alunoId: json['alunoId'],
      profissionalId: json['profissionalId'],
      tipoProfissional: json['tipoProfissional'] ?? '',
      profissionalNome: json['profissionalNome'],
      titulo: json['titulo'] ?? '',
      descricao: json['descricao'],
      dataHora: DateTime.parse(json['dataHora']),
      status: json['status'] ?? 'AGENDADA',
      criadoEm: DateTime.parse(json['criadoEm']),
    );
  }
}