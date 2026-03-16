import 'dart:convert';
import 'dart:math';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import '../models/gym.dart';

class PlacesService {

  static final apiKey = dotenv.env['PLACES_KEY'];

  /// Buscar academias próximas
  static Future<List<Gym>> searchGyms(
      double lat,
      double lng,
      ) async {

    print("API KEY: $apiKey");
    final url = Uri.parse(
        "https://maps.googleapis.com/maps/api/place/nearbysearch/json"
            "?location=$lat,$lng"
            "&radius=5000"
            "&type=gym"
            "&keyword=academia"
            "&key=$apiKey"
    );

    final response = await http.get(url);

    print("STATUS HTTP: ${response.statusCode}");
    print("BODY: ${response.body}");

    final data = jsonDecode(response.body);

    final List gyms = data["results"];

    return gyms.map((e) => Gym.fromJson(e)).toList();
  }

  /// Buscar academia por nome
  static Future<List<Gym>> searchGymByName(
      String query,
      double lat,
      double lng,
      ) async {

    final url = Uri.parse(
        "https://maps.googleapis.com/maps/api/place/textsearch/json"
            "?query=$query+gym"
            "&location=$lat,$lng"
            "&radius=5000"
            "&key=$apiKey"
    );

    final response = await http.get(url);

    final data = jsonDecode(response.body);

    final List gyms = data["results"];

    return gyms.map((e) => Gym.fromJson(e)).toList();
  }

  static double calculateDistance(
      double lat1,
      double lon1,
      double lat2,
      double lon2,
      ) {
    const p = 0.017453292519943295;
    final a = 0.5 -
        (cos((lat2 - lat1) * p) / 2) +
        cos(lat1 * p) *
            cos(lat2 * p) *
            (1 - cos((lon2 - lon1) * p)) /
            2;

    return 12742 * asin(sqrt(a)); // distância em KM
  }
}