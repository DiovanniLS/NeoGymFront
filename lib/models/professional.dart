import 'package:neogym/models/work_place.dart';

class Professional {
  final String id;
  final int usuarioId; // NOVO
  final String name;
  final String specialty;
  final double rating;
  final String image;
  final double distance;
  final bool isOnline;
  final String type;
  final double? lat;
  final double? lng;
  final double radiusKm;
  final List<Workplace> workplaces;
  final String apresentacao;
  final List<String> areasAtuacao;
  final List<String> horariosDisponiveis;

  Professional({
    required this.id,
    required this.usuarioId, // NOVO
    required this.name,
    required this.specialty,
    required this.rating,
    required this.image,
    required this.distance,
    required this.isOnline,
    required this.type,
    required this.workplaces,
    this.lat,
    this.lng,
    this.radiusKm = 5,
    this.apresentacao = '',
    this.areasAtuacao = const [],
    this.horariosDisponiveis = const [],
  });

  factory Professional.fromMap(Map<String, dynamic> map) {
    return Professional(
      id: map['id']?.toString() ?? '',
      usuarioId: _intValue(map['usuarioId']),

      name: (map['name'] ?? map['nome'] ?? '').toString(),

      specialty: (
          map['specialty'] ??
              map['especialidade'] ??
              ''
      ).toString(),

      rating: _doubleValue(map['rating']),
      image: (map['image'] ?? '').toString(),

      distance: _doubleValue(
        map['distance'] ?? map['distanciaKm'],
      ),

      isOnline: map['online'] == true ||
          map['isOnline'] == true,

      type: (
          map['type'] ??
              map['tipo'] ??
              'Todos'
      ).toString(),

      lat: map['lat'] == null
          ? null
          : _doubleValue(map['lat']),

      lng: map['lng'] == null
          ? null
          : _doubleValue(map['lng']),

      radiusKm: _doubleValue(map['radiusKm'], fallback: 5),

      workplaces: (map['workplaces'] as List<dynamic>? ?? [])
          .map(
            (workplace) => Workplace.fromMap(
          Map<String, dynamic>.from(workplace),
        ),
      )
          .toList(),

      apresentacao: (
          map['apresentacao'] ?? ''
      ).toString(),

      areasAtuacao: _listaTexto(
        map['areasAtuacao'],
      ),

      horariosDisponiveis: _listaTexto(
        map['horariosDisponiveis'],
      ),
    );
  }
}

int _intValue(dynamic value) {
  if (value is num) return value.toInt();

  return int.tryParse(value?.toString() ?? '') ?? 0;
}

double _doubleValue(
    dynamic value, {
      double fallback = 0,
    }) {
  if (value is num) return value.toDouble();

  return double.tryParse(
    value?.toString() ?? '',
  ) ??
      fallback;
}

List<String> _listaTexto(dynamic value) {
  if (value is List) {
    return value
        .map((item) => item.toString().trim())
        .where((item) => item.isNotEmpty)
        .toList();
  }

  if (value is! String || value.trim().isEmpty) {
    return [];
  }

  return value
      .split(RegExp(r'[\n,;]'))
      .map((item) => item.trim())
      .where((item) => item.isNotEmpty)
      .toList();
}