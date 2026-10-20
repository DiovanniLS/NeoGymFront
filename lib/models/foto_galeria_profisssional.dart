class FotoGaleriaProfissional {
  final int id;
  final String contentType;
  final DateTime? criadoEm;

  const FotoGaleriaProfissional({
    required this.id,
    required this.contentType,
    this.criadoEm,
  });

  factory FotoGaleriaProfissional.fromJson(
      Map<String, dynamic> json,
      ) {
    return FotoGaleriaProfissional(
      id: (json['id'] as num).toInt(),
      contentType: json['contentType']?.toString() ?? 'image/jpeg',
      criadoEm: json['criadoEm'] == null
          ? null
          : DateTime.tryParse(json['criadoEm'].toString()),
    );
  }
}