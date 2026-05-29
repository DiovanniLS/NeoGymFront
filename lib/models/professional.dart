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

  final double? lat;

  final double? lng;

  final double radiusKm;

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

    this.lat,
    this.lng,

    this.radiusKm = 5,
  });

  factory Professional.fromMap(
      Map<String, dynamic> map,
      ) {

    return Professional(

      id: map["id"] ??
          DateTime.now().toString(),

      name: map["name"] ?? "",

      specialty:
      map["specialty"] ?? "",

      rating:
      (map["rating"] ?? 0)
          .toDouble(),

      image: map["image"] ?? "",

      distance:
      (map["distance"] ?? 0)
          .toDouble(),

      isOnline:
      map["online"] ?? false,

      type:
      map["type"] ?? "Todos",

      lat:
      (map["lat"])?.toDouble(),

      lng:
      (map["lng"])?.toDouble(),

      radiusKm:
      (map["radiusKm"] ?? 5)
          .toDouble(),

      workplaces:
      (map["workplaces"]
      as List<dynamic>? ?? [])

          .map(
            (workplace) =>
            Workplace.fromMap(
              workplace,
            ),
      ).toList(),
    );
  }
}

final List<Map<String, dynamic>> professionals = [
  {
    "id": "1",

    "name": "João Silva",

    "specialty":
    "Personal Trainer",

    "rating": 4.8,

    "distance": 2.3,

    "image":
    "https://i.pravatar.cc/150?img=3",

    "online": true,

    "type": "Personal",

    "lat": -23.684712,

    "lng": -46.622892,

    "radiusKm": 5,

    "workplaces": [
      {
        "id": "1",

        "name":
        "Smart Fit Paulista",

        "type": "Academia",

        "lat": -23.5,

        "lng": -46.6,

        "address":
        "Av. Paulista"
      },

      {
        "id": "2",

        "name":
        "BlueFit Diadema",

        "type": "Academia",

        "lat": -23.7,

        "lng": -46.5,

        "address":
        "Centro Diadema"
      }
    ]
  },

  {
    "id": "2",

    "name": "Maria Souza",

    "specialty":
    "Nutricionista",

    "rating": 4.9,

    "distance": 4.1,

    "image":
    "https://i.pravatar.cc/150?img=5",

    "online": false,

    "type": "Nutri",

    "lat": -23.701122,

    "lng": -46.551223,

    "radiusKm": 8,

    "workplaces": [],
  },
];