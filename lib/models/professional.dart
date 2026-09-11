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
  });

  factory Professional.fromMap(Map<String, dynamic> map) {
    return Professional(
      id: map["id"]?.toString() ?? "",

      // NOVO
      usuarioId: map["usuarioId"] ?? 0,

      name: map["name"] ?? "",
      specialty: map["specialty"] ?? "",
      rating: (map["rating"] ?? 0).toDouble(),
      image: map["image"] ?? "",
      distance: (map["distance"] ?? 0).toDouble(),
      isOnline: map["online"] ?? false,
      type: map["type"] ?? "Todos",
      lat: map["lat"]?.toDouble(),
      lng: map["lng"]?.toDouble(),
      radiusKm: (map["radiusKm"] ?? 5).toDouble(),
      workplaces: (map["workplaces"] as List<dynamic>? ?? [])
          .map((workplace) => Workplace.fromMap(workplace))
          .toList(),
    );
  }
}