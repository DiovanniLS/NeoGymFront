class Professional {
  final String id;
  final String name;
  final String specialty;
  final double rating;
  final String image;
  final double distance;
  final bool isOnline;
  final String type;

  Professional({
    required this.id,
    required this.name,
    required this.specialty,
    required this.rating,
    required this.image,
    required this.distance,
    required this.isOnline,
    required this.type,
  });

  factory Professional.fromMap(Map<String, dynamic> map) {
    return Professional(
      id: DateTime.now().toString(),
      name: map["name"] ?? "",
      specialty: map["specialty"] ?? "",
      rating: (map["rating"] ?? 0).toDouble(),
      image: map["image"] ?? "",
      distance: (map["distance"] ?? 0).toDouble(),
      isOnline: map["online"] ?? false,
      type: map["type"] ?? "Todos",
    );
  }

}

final List<Map<String, dynamic>> professionals = [
  {
    "name": "João Silva",
    "specialty": "Personal Trainer",
    "rating": 4.8,
    "distance": 2.3,
    "image": "https://i.pravatar.cc/150?img=3",
    "online": true,
    "type": "Personal"
  },
  {
    "name": "Maria Souza",
    "specialty": "Nutricionista",
    "rating": 4.9,
    "distance": 1.2,
    "image": "https://i.pravatar.cc/150?img=5",
    "online": false,
    "type": "Nutri"
  },
];