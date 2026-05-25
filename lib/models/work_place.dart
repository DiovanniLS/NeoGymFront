class Workplace {
  final String id;
  final String name;
  final String type;
  final double lat;
  final double lng;
  final String address;

  Workplace({
    required this.id,
    required this.name,
    required this.type,
    required this.lat,
    required this.lng,
    required this.address,
  });

  factory Workplace.fromMap(Map<String, dynamic> map) {
    return Workplace(
      id: map["id"] ?? "",
      name: map["name"] ?? "",
      type: map["type"] ?? "",
      lat: (map["lat"] ?? 0).toDouble(),
      lng: (map["lng"] ?? 0).toDouble(),
      address: map["address"] ?? "",
    );
  }
}