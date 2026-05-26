import 'package:neogym/models/work_place.dart';

class Professional {
  final String id;
  final String name;
  final String specialty;
  final double rating;
  final String image;
  final double distance;
  final bool isOnline;
  final String type;

  final List<Workplace> workplaces;

  Professional({
    required this.id,
    required this.name,
    required this.specialty,
    required this.rating,
    required this.image,
    required this.distance,
    required this.isOnline,
    required this.type,
    required this.workplaces,
  });

  factory Professional.fromMap(Map<String, dynamic> map) {
    return Professional(
      id: map["id"] ?? "",

      name: map["name"] ?? "",

      specialty: map["specialty"] ?? "",

      rating: (map["rating"] ?? 0).toDouble(),

      image: map["image"] ?? "",

      distance: (map["distance"] ?? 0).toDouble(),

      isOnline: map["online"] ?? false,

      type: map["type"] ?? "Todos",

      workplaces: (map["workplaces"] as List<dynamic>? ?? [])
          .map((workplace) => Workplace.fromMap(workplace))
          .toList(),
    );
  }
}
