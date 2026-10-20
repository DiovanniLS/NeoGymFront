class PreferenciasHidratacao {
  final int usuarioId;
  final int metaMl;
  final int passoMl;
  final DateTime atualizadoEm;

  const PreferenciasHidratacao({
    required this.usuarioId,
    required this.metaMl,
    required this.passoMl,
    required this.atualizadoEm,
  });

  factory PreferenciasHidratacao.fromMap(
      Map<String, Object?> map,
      ) {
    return PreferenciasHidratacao(
      usuarioId: (map['usuario_id'] as num).toInt(),
      metaMl: (map['meta_ml'] as num).toInt(),
      passoMl: (map['passo_ml'] as num).toInt(),
      atualizadoEm: DateTime.parse(
        map['atualizado_em'] as String,
      ),
    );
  }
}

class HidratacaoDia {
  final int usuarioId;
  final String data;
  final int totalMl;
  final int metaMl;
  final DateTime atualizadoEm;

  const HidratacaoDia({
    required this.usuarioId,
    required this.data,
    required this.totalMl,
    required this.metaMl,
    required this.atualizadoEm,
  });

  factory HidratacaoDia.fromMap(
      Map<String, Object?> map,
      ) {
    return HidratacaoDia(
      usuarioId: (map['usuario_id'] as num).toInt(),
      data: map['data'] as String,
      totalMl: (map['total_ml'] as num).toInt(),
      metaMl: (map['meta_ml'] as num).toInt(),
      atualizadoEm: DateTime.parse(
        map['atualizado_em'] as String,
      ),
    );
  }
}