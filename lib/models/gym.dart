class Gym {
  final String name;
  final double lat;
  final double lng;

  Gym({
    required this.name,
    required this.lat,
    required this.lng,
  });

  factory Gym.fromMap(Map<String, dynamic> map) {
    final location = map["geometry"]?["location"];

    return Gym(
      name: map["name"] ?? "",
      lat: (location?["lat"] ?? 0).toDouble(),
      lng: (location?["lng"] ?? 0).toDouble(),
    );
  }
}