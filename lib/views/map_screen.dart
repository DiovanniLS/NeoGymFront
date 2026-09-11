import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';

import '../Resources/neo_gym_colors.dart';
import '../models/gym.dart';
import '../services/location_service.dart';
import '../services/places_service.dart';
import '../view_model/professional_viewmodel.dart';

enum MapMode {
  gyms,
  professionals,
}

class MapScreen extends StatefulWidget {
  final Gym? gym;

  const MapScreen({
    super.key,
    this.gym,
  });

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final MapController mapController = MapController();

  MapMode currentMode = MapMode.gyms;

  LatLng? userLocation;
  LatLng? gymLocation;

  Gym? selectedGym;

  List<Marker> markers = [];
  List<Polyline> polylines = [];
  List<CircleMarker> circles = [];

  String? distance;
  String? duration;

  final TextEditingController searchController =
  TextEditingController();

  bool mapReady = false;
  bool loading = false;

  @override
  void initState() {
    super.initState();

    initMap();
  }

  @override
  void dispose() {
    searchController.dispose();
    mapController.dispose();

    super.dispose();
  }

  // ==========================================================
  // INICIALIZAÇÃO
  // ==========================================================

  Future<void> initMap() async {
    try {
      final pos =
      await LocationService.getUserLocation();

      final location = LatLng(
        pos.latitude,
        pos.longitude,
      );

      Gym? initialGym = widget.gym;

      LatLng? initialGymLocation;

      if (initialGym != null) {
        initialGymLocation = LatLng(
          initialGym.lat,
          initialGym.lng,
        );
      }

      if (!mounted) return;

      setState(() {
        userLocation = location;

        selectedGym = initialGym;

        gymLocation = initialGymLocation;

        markers = [
          _buildUserMarker(location),

          if (initialGym != null)
            _buildGymMarker(initialGym),
        ];
      });

      /*
       * Se o mapa já tiver terminado de carregar,
       * podemos carregar a rota imediatamente.
       *
       * Normalmente quem dispara isso será o
       * onMapReady.
       */
      if (mapReady &&
          gymLocation != null) {
        await loadRoute();

        _fitCamera();
      }
    } catch (e) {
      debugPrint(
        'Erro ao iniciar mapa: $e',
      );
    }
  }

  // ==========================================================
  // MARKER USUÁRIO
  // ==========================================================

  Marker _buildUserMarker(
      LatLng position,
      ) {
    return Marker(
      point: position,

      width: 46,
      height: 46,

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
              blurRadius: 7,
            ),
          ],
        ),

        child: const Icon(
          Icons.person,
          color: Colors.white,
          size: 22,
        ),
      ),
    );
  }

  // ==========================================================
  // MARKER ACADEMIA
  // ==========================================================

  Marker _buildGymMarker(
      Gym gym, {
        bool clickable = false,
      }) {
    return Marker(
      point: LatLng(
        gym.lat,
        gym.lng,
      ),

      width: 55,
      height: 55,

      child: GestureDetector(
        onTap: clickable
            ? () async {
          setState(() {
            selectedGym = gym;

            gymLocation = LatLng(
              gym.lat,
              gym.lng,
            );

            distance = null;
            duration = null;
          });

          await loadRoute();

          _fitCamera();
        }
            : null,

        child: Image.asset(
          'assets/icons/academia.png',

          width: 50,
          height: 50,

          fit: BoxFit.contain,
        ),
      ),
    );
  }

  // ==========================================================
  // AJUSTAR CÂMERA ENTRE USUÁRIO E ACADEMIA
  // ==========================================================

  void _fitCamera() {
    if (!mapReady ||
        userLocation == null ||
        gymLocation == null) {
      return;
    }

    mapController.fitCamera(
      CameraFit.coordinates(
        coordinates: [
          userLocation!,
          gymLocation!,
        ],

        padding:
        const EdgeInsets.all(80),

        maxZoom: 16,
      ),
    );
  }

  // ==========================================================
  // CARREGAR ROTA
  // ==========================================================

  Future<void> loadRoute() async {
    if (userLocation == null ||
        gymLocation == null) {
      return;
    }

    try {
      setState(() {
        loading = true;
      });

      final points =
      await PlacesService
          .getRouteCoordinates(
        userLocation!.latitude,
        userLocation!.longitude,
        gymLocation!.latitude,
        gymLocation!.longitude,
      );

      final info =
      await PlacesService.getRouteInfo(
        userLocation!.latitude,
        userLocation!.longitude,
        gymLocation!.latitude,
        gymLocation!.longitude,
      );

      if (!mounted) return;

      final List<Marker> routeMarkers = [
        _buildUserMarker(
          userLocation!,
        ),
      ];

      if (selectedGym != null) {
        routeMarkers.add(
          _buildGymMarker(
            selectedGym!,
          ),
        );
      }

      setState(() {
        polylines = points.isEmpty
            ? []
            : [
          Polyline(
            points: points,
            color:
            NeoGymColors.primary,
            strokeWidth: 5,
          ),
        ];

        distance =
            info['distance']?.toString();

        duration =
            info['duration']?.toString();

        markers = routeMarkers;

        circles = [];

        loading = false;
      });
    } catch (e) {
      debugPrint(
        'Erro ao carregar rota: $e',
      );

      if (!mounted) return;

      setState(() {
        loading = false;
      });
    }
  }

  // ==========================================================
  // MODO ACADEMIAS
  // ==========================================================

  Future<void> loadGymMode() async {
    if (userLocation == null) {
      return;
    }

    try {
      setState(() {
        loading = true;

        polylines = [];
        circles = [];

        distance = null;
        duration = null;
      });

      final gyms =
      await PlacesService.searchGyms(
        userLocation!.latitude,
        userLocation!.longitude,
      );

      if (!mounted) return;

      final List<Marker> gymMarkers = [
        _buildUserMarker(
          userLocation!,
        ),
      ];

      for (final gym in gyms) {
        gymMarkers.add(
          _buildGymMarker(
            gym,
            clickable: true,
          ),
        );
      }

      setState(() {
        markers = gymMarkers;

        loading = false;
      });
    } catch (e) {
      debugPrint(
        'Erro ao carregar academias: $e',
      );

      if (!mounted) return;

      setState(() {
        loading = false;
      });
    }
  }

  // ==========================================================
  // MODO PROFISSIONAIS
  // ==========================================================

  Future<void> loadProfessionalMode() async {
    if (userLocation == null) {
      return;
    }

    try {
      setState(() {
        loading = true;

        polylines = [];
        circles = [];

        distance = null;
        duration = null;
      });

      final viewModel =
      context.read<ProfessionalViewModel>();

      await viewModel.loadProfessionals();

      final professionals =
          viewModel.professionals;

      final List<Marker> profMarkers = [
        _buildUserMarker(userLocation!),
      ];

      for (final prof in professionals) {
        // Neste momento o backend ainda não
        // retorna latitude/longitude do profissional.
        //
        // Então não conseguimos colocar o
        // marcador dele no mapa ainda.
        //
        // A distância continua disponível:
        // prof.distance
      }

      if (!mounted) return;

      setState(() {
        markers = profMarkers;

        circles = [];

        polylines = [];

        selectedGym = null;
        gymLocation = null;

        distance = null;
        duration = null;

        loading = false;
      });
    } catch (e) {
      debugPrint(
        'Erro ao carregar profissionais: $e',
      );

      if (!mounted) return;

      setState(() {
        loading = false;
      });
    }
  }

  // ==========================================================
  // BUSCAR ACADEMIA
  // ==========================================================

  Future<void> searchGym(
      String value,
      ) async {
    if (userLocation == null) {
      return;
    }

    try {
      setState(() {
        loading = true;

        polylines = [];

        distance = null;
        duration = null;
      });

      final gyms =
      await PlacesService
          .searchGymByName(
        value,
        userLocation!.latitude,
        userLocation!.longitude,
      );

      if (!mounted) return;

      final List<Marker>
      gymMarkers = [
        _buildUserMarker(
          userLocation!,
        ),
      ];

      for (final gym in gyms) {
        gymMarkers.add(
          _buildGymMarker(
            gym,
            clickable: true,
          ),
        );
      }

      setState(() {
        markers = gymMarkers;

        circles = [];

        loading = false;
      });

      // Centraliza na primeira academia
      // encontrada.
      if (gyms.isNotEmpty &&
          mapReady) {
        mapController.move(
          LatLng(
            gyms.first.lat,
            gyms.first.lng,
          ),
          14,
        );
      }
    } catch (e) {
      debugPrint(
        'Erro na pesquisa: $e',
      );

      if (!mounted) return;

      setState(() {
        loading = false;
      });
    }
  }

  // ==========================================================
  // BUILD
  // ==========================================================

  @override
  Widget build(BuildContext context) {
    if (userLocation == null) {
      return const Scaffold(
        body: Center(
          child:
          CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      body: Stack(
        children: [

          // ==========================================
          // MAPA OPENSTREETMAP
          // ==========================================

          FlutterMap(
            mapController:
            mapController,

            options: MapOptions(
              initialCenter:
              userLocation!,

              initialZoom: 14,

              onMapReady: () {
                mapReady = true;

                if (gymLocation !=
                    null) {
                  loadRoute().then((_) {
                    if (mounted) {
                      _fitCamera();
                    }
                  });
                }
              },

              onTap:
                  (tapPosition, point) {
                debugPrint(
                  'Mapa: '
                      '${point.latitude}, '
                      '${point.longitude}',
                );
              },
            ),

            children: [

              // ======================================
              // BASE DO MAPA
              // ======================================

              TileLayer(
                urlTemplate:
                'https://tile.openstreetmap.org/{z}/{x}/{y}.png',

                /*
                 * Coloque aqui o package
                 * real do NeoGym.
                 */
                userAgentPackageName:
                'com.neogym.app',
              ),

              // ======================================
              // RAIO DOS PROFISSIONAIS
              // ======================================

              if (circles.isNotEmpty)
                CircleLayer(
                  circles: circles,
                ),

              // ======================================
              // ROTA
              // ======================================

              if (polylines.isNotEmpty)
                PolylineLayer(
                  polylines:
                  polylines,
                ),

              // ======================================
              // MARKERS
              // ======================================

              MarkerLayer(
                markers: markers,
              ),

              // ======================================
              // ATRIBUIÇÃO
              // ======================================

              const RichAttributionWidget(
                attributions: [
                  TextSourceAttribution(
                    'OpenStreetMap contributors',
                  ),
                ],
              ),
            ],
          ),

          // ==========================================
          // SELETOR DE MODO
          // ==========================================

          Positioned(
            top: 50,
            left: 16,
            right: 16,

            child: Row(
              children: [

                Expanded(
                  child: ChoiceChip(
                    label:
                    const Text(
                      'Academias',
                    ),

                    selected:
                    currentMode ==
                        MapMode
                            .gyms,

                    onSelected: (_) {
                      setState(() {
                        currentMode =
                            MapMode
                                .gyms;

                        selectedGym =
                        null;

                        gymLocation =
                        null;
                      });

                      loadGymMode();
                    },
                  ),
                ),

                const SizedBox(
                  width: 10,
                ),

                Expanded(
                  child: ChoiceChip(
                    label:
                    const Text(
                      'Profissionais',
                    ),

                    selected:
                    currentMode ==
                        MapMode
                            .professionals,

                    onSelected: (_) {
                      setState(() {
                        currentMode =
                            MapMode
                                .professionals;
                      });

                      loadProfessionalMode();
                    },
                  ),
                ),
              ],
            ),
          ),

          // ==========================================
          // PESQUISA
          // ==========================================

          if (currentMode ==
              MapMode.gyms)
            buildSearchBar(),

          // ==========================================
          // LOADING
          // ==========================================

          if (loading)
            const Positioned(
              top: 170,
              left: 0,
              right: 0,

              child: Center(
                child:
                CircularProgressIndicator(),
              ),
            ),

          // ==========================================
          // CARD
          // ==========================================

          if (currentMode ==
              MapMode.gyms)
            buildBottomCard(),
        ],
      ),
    );
  }

  // ==========================================================
  // BARRA DE PESQUISA
  // ==========================================================

  Widget buildSearchBar() {
    return Positioned(
      /*
       * Antes você tinha:
       *
       * ChoiceChip top: 50
       * SearchBar top: 50
       *
       * então eles se sobrepunham.
       */

      top: 105,
      left: 16,
      right: 16,

      child: Material(
        elevation: 6,

        borderRadius:
        BorderRadius.circular(
          30,
        ),

        child: TextField(
          controller:
          searchController,

          onSubmitted: searchGym,

          decoration: InputDecoration(
            hintText:
            'Buscar academia...',

            prefixIcon: Icon(
              Icons.search,
              color:
              NeoGymColors.primary,
            ),

            suffixIcon: IconButton(
              onPressed: () {
                searchController
                    .clear();

                loadGymMode();
              },

              icon: Icon(
                Icons.cancel,
                color:
                NeoGymColors.primary,
              ),
            ),

            border:
            InputBorder.none,

            contentPadding:
            const EdgeInsets
                .symmetric(
              vertical: 15,
            ),
          ),
        ),
      ),
    );
  }

  // ==========================================================
  // CARD INFERIOR
  // ==========================================================

  Widget buildBottomCard() {
    String message =
        'Academia próxima 💪';

    if (distance != null) {
      /*
       * O novo service devolve algo como:
       *
       * 1.5 km
       * 850 m
       */

      if (distance!.contains('km')) {
        final number =
        distance!
            .replaceAll(
          'km',
          '',
        )
            .trim();

        final km =
        double.tryParse(number);

        if (km != null) {
          if (km > 5) {
            message =
            'Tá longe, mas bora manter o foco 🔥';
          } else if (km > 2) {
            message =
            'Distância média, já dá um aquecimento 😅';
          }
        }
      }
    }

    return Positioned(
      bottom: 50,
      left: 16,
      right: 16,

      child: Card(
        shape:
        RoundedRectangleBorder(
          borderRadius:
          BorderRadius.circular(
            20,
          ),
        ),

        elevation: 10,

        child: Padding(
          padding:
          const EdgeInsets.all(
            16,
          ),

          child: Column(
            mainAxisSize:
            MainAxisSize.min,

            crossAxisAlignment:
            CrossAxisAlignment
                .center,

            children: [

              Row(
                children: [

                  const Icon(
                    Icons
                        .fitness_center,
                    size: 28,
                  ),

                  const SizedBox(
                    width: 10,
                  ),

                  Expanded(
                    child: Text(
                      selectedGym
                          ?.name ??
                          'Selecione uma academia',

                      style:
                      const TextStyle(
                        fontWeight:
                        FontWeight
                            .bold,

                        fontSize: 16,
                      ),
                    ),
                  ),
                ],
              ),

              if (selectedGym != null)
                ...[
                  const SizedBox(
                    height: 8,
                  ),

                  Text(
                    '${distance ?? '--'}'
                        ' • '
                        '${duration ?? '--'}',

                    style: TextStyle(
                      color: Colors
                          .grey[600],
                    ),
                  ),

                  const SizedBox(
                    height: 8,
                  ),

                  Text(message),

                  const SizedBox(
                    height: 10,
                  ),

                  SizedBox(
                    width:
                    double.infinity,

                    child:
                    ElevatedButton(
                      onPressed: () {
                        // iniciar treino
                      },

                      child:
                      const Text(
                        'Iniciar treino',
                      ),
                    ),
                  ),
                ],
            ],
          ),
        ),
      ),
    );
  }
}