import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import 'package:neogym/Resources/neo_gym_colors.dart';

import '../models/gym.dart';
import '../services/location_service.dart';
import '../services/places_service.dart';

class EscolherAcademia extends StatefulWidget {
  const EscolherAcademia({super.key});

  @override
  State<EscolherAcademia> createState() =>
      _EscolherAcademiaState();
}

class _EscolherAcademiaState
    extends State<EscolherAcademia> {

  final MapController mapController = MapController();

  LatLng? userLocation;

  List<Marker> markers = [];

  Gym? selectedGym;

  final TextEditingController searchController =
  TextEditingController();

  bool loadingGyms = false;

  /// Caso queira mostrar rota nessa própria tela
  List<LatLng> routePoints = [];

  @override
  void initState() {
    super.initState();

    initMap();
  }

  @override
  void dispose() {
    searchController.dispose();

    super.dispose();
  }

  Future<void> initMap() async {
    try {
      setState(() {
        loadingGyms = true;
      });

      final pos =
      await LocationService.getUserLocation();

      final location = LatLng(
        pos.latitude,
        pos.longitude,
      );

      final gyms =
      await PlacesService.searchGyms(
        pos.latitude,
        pos.longitude,
      );

      if (!mounted) return;

      userLocation = location;

      _updateMarkers(gyms);

      setState(() {
        loadingGyms = false;
      });
    } catch (e) {
      debugPrint(
        'Erro ao carregar mapa: $e',
      );

      if (!mounted) return;

      setState(() {
        loadingGyms = false;
      });
    }
  }

  /// =========================================================
  /// CRIAR MARKERS
  /// =========================================================

  void _updateMarkers(List<Gym> gyms) {
    final List<Marker> newMarkers = [];

    for (final gym in gyms) {
      newMarkers.add(
        Marker(
          point: LatLng(
            gym.lat,
            gym.lng,
          ),

          width: 50,
          height: 50,

          child: GestureDetector(
            onTap: () {
              debugPrint(
                'Clicou na academia: ${gym.name}',
              );

              setState(() {
                selectedGym = gym;
                routePoints = [];
              });
            },

            child: Image.asset(
              'assets/icons/academia.png',
              width: 45,
              height: 45,
            ),
          ),
        ),
      );
    }

    /// Marcador do usuário
    if (userLocation != null) {
      newMarkers.add(
        Marker(
          point: userLocation!,

          width: 45,
          height: 45,

          child: Container(
            decoration: BoxDecoration(
              color: Colors.blue,
              shape: BoxShape.circle,

              border: Border.all(
                color: Colors.white,
                width: 4,
              ),

              boxShadow: const [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 8,
                ),
              ],
            ),

            child: const Icon(
              Icons.person,
              color: Colors.white,
              size: 22,
            ),
          ),
        ),
      );
    }

    setState(() {
      markers = newMarkers;
    });
  }

  /// =========================================================
  /// BUSCAR
  /// =========================================================

  Future<void> searchGym(String value) async {
    if (userLocation == null) {
      return;
    }

    try {
      setState(() {
        loadingGyms = true;
        selectedGym = null;
        routePoints = [];
      });

      final gyms =
      await PlacesService.searchGymByName(
        value,
        userLocation!.latitude,
        userLocation!.longitude,
      );

      if (!mounted) return;

      _updateMarkers(gyms);

      /// Se encontrou academia, centraliza
      /// na primeira encontrada.
      if (gyms.isNotEmpty) {
        mapController.move(
          LatLng(
            gyms.first.lat,
            gyms.first.lng,
          ),
          14,
        );
      }

      setState(() {
        loadingGyms = false;
      });
    } catch (e) {
      debugPrint(
        'Erro ao pesquisar academia: $e',
      );

      if (!mounted) return;

      setState(() {
        loadingGyms = false;
      });
    }
  }

  /// =========================================================
  /// MOSTRAR ROTA
  /// =========================================================

  Future<void> showRoute() async {
    if (userLocation == null ||
        selectedGym == null) {
      return;
    }

    final points =
    await PlacesService.getRouteCoordinates(
      userLocation!.latitude,
      userLocation!.longitude,
      selectedGym!.lat,
      selectedGym!.lng,
    );

    if (!mounted) return;

    setState(() {
      routePoints = points;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (userLocation == null) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      body: Stack(
        children: [

          /// ===============================
          /// MAPA
          /// ===============================
          FlutterMap(
            mapController: mapController,

            options: MapOptions(
              initialCenter: userLocation!,
              initialZoom: 14,

              onTap: (tapPosition, point) {
                debugPrint(
                  'Clicou no mapa: $point',
                );
              },
            ),

            children: [

              /// MAPA OPENSTREETMAP
              TileLayer(
                urlTemplate:
                'https://tile.openstreetmap.org/{z}/{x}/{y}.png',

                /// Troque pelo package name real
                /// caso o seu seja diferente.
                userAgentPackageName:
                'com.neogym.app',
              ),

              /// ===============================
              /// ROTA
              /// ===============================
              if (routePoints.isNotEmpty)
                PolylineLayer(
                  polylines: [
                    Polyline(
                      points: routePoints,
                      strokeWidth: 5,
                      color: NeoGymColors.primary,
                    ),
                  ],
                ),

              /// ===============================
              /// MARCADORES
              /// ===============================
              MarkerLayer(
                markers: markers,
              ),

              /// Obrigatório dar crédito
              /// ao OpenStreetMap.
              RichAttributionWidget(
                attributions: const [
                  TextSourceAttribution(
                    'OpenStreetMap contributors',
                  ),
                ],
              ),
            ],
          ),

          /// ===============================
          /// SEARCH
          /// ===============================
          buildSearchBar(),

          /// ===============================
          /// LOADING
          /// ===============================
          if (loadingGyms)
            const Positioned(
              top: 115,
              left: 0,
              right: 0,
              child: Center(
                child: CircularProgressIndicator(),
              ),
            ),

          /// ===============================
          /// ACADEMIA SELECIONADA
          /// ===============================
          buildSelectedGymCard(),
        ],
      ),
    );
  }

  /// =========================================================
  /// SEARCH BAR
  /// =========================================================

  Widget buildSearchBar() {
    return Positioned(
      top: 50,
      left: 16,
      right: 16,

      child: Material(
        elevation: 6,

        borderRadius:
        BorderRadius.circular(30),

        child: TextField(
          controller: searchController,

          onSubmitted: searchGym,

          decoration: InputDecoration(
            hintText: 'Buscar academia...',

            prefixIcon: Icon(
              Icons.search,
              color: NeoGymColors.primary,
            ),

            suffixIcon: IconButton(
              onPressed: () {
                searchController.clear();

                searchGym('');
              },

              icon: Icon(
                Icons.cancel,
                color: NeoGymColors.primary,
              ),
            ),

            border: InputBorder.none,

            contentPadding:
            const EdgeInsets.symmetric(
              vertical: 15,
            ),
          ),
        ),
      ),
    );
  }

  /// =========================================================
  /// CARD ACADEMIA
  /// =========================================================

  Widget buildSelectedGymCard() {
    if (selectedGym == null) {
      return const SizedBox.shrink();
    }

    String message =
        'Academia próxima da sua localização';

    final distance =
    PlacesService.calculateDistance(
      userLocation!.latitude,
      userLocation!.longitude,
      selectedGym!.lat,
      selectedGym!.lng,
    );

    if (distance > 2) {
      message =
      'Essa academia parece um pouco distante de você';
    }

    if (distance > 5) {
      message =
      'Essa academia fica bem longe da sua localização';
    }

    return Positioned(
      bottom: 30,
      left: 16,
      right: 16,

      child: Card(
        elevation: 10,

        shape: RoundedRectangleBorder(
          borderRadius:
          BorderRadius.circular(20),
        ),

        child: Padding(
          padding:
          const EdgeInsets.all(16),

          child: Column(
            mainAxisSize:
            MainAxisSize.min,

            children: [
              Row(
                children: [
                  const Icon(
                    Icons.fitness_center,
                    size: 40,
                  ),

                  const SizedBox(width: 12),

                  Expanded(
                    child: Column(
                      crossAxisAlignment:
                      CrossAxisAlignment.start,

                      children: [
                        Text(
                          selectedGym!.name,

                          style:
                          const TextStyle(
                            fontSize: 18,
                            fontWeight:
                            FontWeight.bold,
                          ),
                        ),

                        const SizedBox(
                          height: 4,
                        ),

                        Text(message),

                        const SizedBox(
                          height: 4,
                        ),

                        Text(
                          '${distance.toStringAsFixed(1)} km',
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              Row(
                children: [

                  /// VER ROTA
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: showRoute,

                      icon: const Icon(
                        Icons.route,
                      ),

                      label: const Text(
                        'Ver rota',
                      ),
                    ),
                  ),

                  const SizedBox(width: 10),

                  /// SELECIONAR
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.of(context)
                            .pushNamed(
                          '/home',
                          arguments:
                          selectedGym,
                        );
                      },

                      child: const Text(
                        'Selecionar',
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}