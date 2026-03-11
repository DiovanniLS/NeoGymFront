import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/gym.dart';

class PlacesService {

  static const apiKey = "AIzaSyBl3RxHZFB4SoCIq5wnE12USlS8rUreSts";

  static Future<List<Gym>> searchGyms(
      double lat,
      double lng
      ) async {

    final url = Uri.parse(
        "https://maps.googleapis.com/maps/api/place/nearbysearch/json"
            "?location=$lat,$lng"
            "&radius=2000"
            "&type=gym"
            "&key=$apiKey"
    );

    final response = await http.get(url);

    final data = jsonDecode(response.body);

    final List gyms = data["results"];

    return gyms.map((e) => Gym.fromJson(e)).toList();
  }
}