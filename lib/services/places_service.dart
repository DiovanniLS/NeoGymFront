import 'dart:convert';
import 'dart:math';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
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

  static Future<List<LatLng>> getRouteCoordinates(
      double originLat,
      double originLng,
      double destLat,
      double destLng,
      ) async {
    final url =
        "https://maps.googleapis.com/maps/api/directions/json?"
        "origin=$originLat,$originLng&destination=$destLat,$destLng"
        "&key=$apiKey";

    final response = await http.get(Uri.parse(url));
    final data = json.decode(response.body);

    if (data["routes"].isEmpty) return [];

    final points = data["routes"][0]["overview_polyline"]["points"];

    return _decodePolyline(points);
  }

  static List<LatLng> _decodePolyline(String encoded) {
    List<LatLng> polyline = [];

    int index = 0, len = encoded.length;
    int lat = 0, lng = 0;

    while (index < len) {
      int b, shift = 0, result = 0;

      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);

      int dlat = (result & 1) != 0 ? ~(result >> 1) : (result >> 1);
      lat += dlat;

      shift = 0;
      result = 0;

      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);

      int dlng = (result & 1) != 0 ? ~(result >> 1) : (result >> 1);
      lng += dlng;

      polyline.add(LatLng(lat / 1E5, lng / 1E5));
    }

    return polyline;
  }

  static Future<Map<String, dynamic>> getRouteInfo(
      double originLat,
      double originLng,
      double destLat,
      double destLng,
      ) async {
    final url =
    "https://maps.googleapis.com/maps/api/directions/json?"
    "origin=$originLat,$originLng"
    "&destination=$destLat,$destLng"
    "&mode=driving"
    "&key=$apiKey";

    final response = await http.get(Uri.parse(url));
    final data = json.decode(response.body);

    if (data["routes"].isEmpty) return {};

    final leg = data["routes"][0]["legs"][0];


    return {
      "distance": leg["distance"]["text"],
      "duration": leg["duration"]["text"],
    };
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