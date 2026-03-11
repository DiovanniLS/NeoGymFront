class Gym {

  final String name;
  final double lat;
  final double lng;

  Gym({
    required this.name,
    required this.lat,
    required this.lng,
  });

  factory Gym.fromJson(Map json) {
    return Gym(
      name: json["name"],
      lat: json["geometry"]["location"]["lat"],
      lng: json["geometry"]["location"]["lng"],
    );
  }
}