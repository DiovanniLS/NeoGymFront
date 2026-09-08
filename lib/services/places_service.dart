import 'dart:convert';
import 'dart:math';

import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';

import '../models/gym.dart';

class PlacesService {
  static const String _overpassUrl =
      'https://overpass-api.de/api/interpreter';

  static const String _osrmUrl =
      'https://router.project-osrm.org';

  /// =========================================================
  /// BUSCAR ACADEMIAS PRÓXIMAS
  /// =========================================================

  static Future<List<Gym>> searchGyms(
      double lat,
      double lng, {
        int radius = 5000,
      }) async {
    final query = '''
[out:json][timeout:25];

(
  node["leisure"="fitness_centre"]
    (around:$radius,$lat,$lng);

  way["leisure"="fitness_centre"]
    (around:$radius,$lat,$lng);

  relation["leisure"="fitness_centre"]
    (around:$radius,$lat,$lng);

  node["amenity"="gym"]
    (around:$radius,$lat,$lng);

  way["amenity"="gym"]
    (around:$radius,$lat,$lng);

  relation["amenity"="gym"]
    (around:$radius,$lat,$lng);
);

out center tags;
''';

    final response = await http.post(
      Uri.parse(_overpassUrl),
      headers: {
        'User-Agent': 'NeoGym/1.0',
      },
      body: {
        'data': query,
      },
    );

    if (response.statusCode != 200) {
      throw Exception(
        'Erro ao buscar academias: ${response.statusCode}',
      );
    }

    final Map<String, dynamic> data =
    jsonDecode(response.body);

    final List<dynamic> elements =
        data['elements'] ?? [];

    final List<Gym> gyms = [];

    for (final element in elements) {
      final tags =
      Map<String, dynamic>.from(element['tags'] ?? {});

      double? gymLat;
      double? gymLng;

      /*
       * NODE
       *
       * node possui diretamente:
       *
       * lat
       * lon
       */
      if (element['lat'] != null &&
          element['lon'] != null) {
        gymLat = (element['lat'] as num).toDouble();
        gymLng = (element['lon'] as num).toDouble();
      }

      /*
       * WAY / RELATION
       *
       * Como usamos:
       *
       * out center tags;
       *
       * o Overpass devolve:
       *
       * center: {
       *   lat: ...
       *   lon: ...
       * }
       */
      else if (element['center'] != null) {
        final center =
        Map<String, dynamic>.from(element['center']);

        if (center['lat'] != null &&
            center['lon'] != null) {
          gymLat = (center['lat'] as num).toDouble();
          gymLng = (center['lon'] as num).toDouble();
        }
      }

      if (gymLat == null || gymLng == null) {
        continue;
      }

      String name = tags['name']?.toString().trim() ?? '';

      if (name.isEmpty) {
        name = 'Academia';
      }

      gyms.add(
        Gym(
          name: name,
          lat: gymLat,
          lng: gymLng,
        ),
      );
    }

    return gyms;
  }

  /// =========================================================
  /// BUSCAR ACADEMIA POR NOME
  /// =========================================================
  ///
  /// Como já estamos buscando as academias próximas,
  /// podemos filtrar localmente.
  ///
  /// Isso evita fazer outra consulta diferente no servidor.
  /// =========================================================

  static Future<List<Gym>> searchGymByName(
      String query,
      double lat,
      double lng, {
        int radius = 5000,
      }) async {
    final gyms = await searchGyms(
      lat,
      lng,
      radius: radius,
    );

    final search = query
        .trim()
        .toLowerCase();

    if (search.isEmpty) {
      return gyms;
    }

    return gyms.where((gym) {
      return gym.name
          .toLowerCase()
          .contains(search);
    }).toList();
  }

  /// =========================================================
  /// TRAÇAR ROTA
  /// =========================================================

  static Future<List<LatLng>> getRouteCoordinates(
      double originLat,
      double originLng,
      double destLat,
      double destLng,
      ) async {
    final url = Uri.parse(
      '$_osrmUrl/route/v1/driving/'
          '$originLng,$originLat;'
          '$destLng,$destLat'
          '?overview=full'
          '&geometries=geojson'
          '&steps=false',
    );

    final response = await http.get(url);

    if (response.statusCode != 200) {
      return [];
    }

    final data = jsonDecode(response.body);

    if (data['code'] != 'Ok') {
      return [];
    }

    final routes = data['routes'] as List<dynamic>;

    if (routes.isEmpty) {
      return [];
    }

    final coordinates =
    routes[0]['geometry']['coordinates']
    as List<dynamic>;

    return coordinates.map((coordinate) {
      /*
       * OSRM/GeoJSON:
       *
       * [longitude, latitude]
       *
       * LatLng:
       *
       * LatLng(latitude, longitude)
       */
      return LatLng(
        (coordinate[1] as num).toDouble(),
        (coordinate[0] as num).toDouble(),
      );
    }).toList();
  }

  /// =========================================================
  /// INFORMAÇÕES DA ROTA
  /// =========================================================

  static Future<Map<String, dynamic>> getRouteInfo(
      double originLat,
      double originLng,
      double destLat,
      double destLng,
      ) async {
    final url = Uri.parse(
      '$_osrmUrl/route/v1/driving/'
          '$originLng,$originLat;'
          '$destLng,$destLat'
          '?overview=false'
          '&steps=false',
    );

    final response = await http.get(url);

    if (response.statusCode != 200) {
      return {};
    }

    final data = jsonDecode(response.body);

    if (data['code'] != 'Ok') {
      return {};
    }

    final routes = data['routes'] as List<dynamic>;

    if (routes.isEmpty) {
      return {};
    }

    final route = routes[0];

    final double distanceMeters =
    (route['distance'] as num).toDouble();

    final double durationSeconds =
    (route['duration'] as num).toDouble();

    return {
      'distance': _formatDistance(distanceMeters),
      'duration': _formatDuration(durationSeconds),

      // caso precise dos valores puros depois
      'distanceMeters': distanceMeters,
      'durationSeconds': durationSeconds,
    };
  }

  static String _formatDistance(double meters) {
    if (meters < 1000) {
      return '${meters.round()} m';
    }

    return '${(meters / 1000).toStringAsFixed(1)} km';
  }

  static String _formatDuration(double seconds) {
    final minutes = (seconds / 60).round();

    if (minutes < 60) {
      return '$minutes min';
    }

    final hours = minutes ~/ 60;
    final remainingMinutes = minutes % 60;

    if (remainingMinutes == 0) {
      return '${hours}h';
    }

    return '${hours}h ${remainingMinutes}min';
  }

  /// =========================================================
  /// DISTÂNCIA EM LINHA RETA
  /// =========================================================

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

    return 12742 * asin(sqrt(a));
  }
}