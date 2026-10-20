import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';

import '../Resources/neo_gym_colors.dart';
import '../models/gym.dart';
import '../models/professional.dart';
import '../services/location_service.dart';
import '../services/places_service.dart';
import '../view_model/professional_view_model.dart';

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

  String? locationError;
  List<Professional> nearbyProfessionals = [];
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
    if (mounted) {
      setState(() {
        locationError = null;
        loading = true;
      });
    }

    try {
      final pos = await LocationService.getUserLocation();

      final location = LatLng(
        pos.latitude,
        pos.longitude,
      );

      final initialGym = widget.gym;

      final LatLng? initialGymLocation = initialGym == null
          ? null
          : LatLng(initialGym.lat, initialGym.lng);

      if (!mounted) return;

      setState(() {
        userLocation = location;
        selectedGym = initialGym;
        gymLocation = initialGymLocation;
        loading = false;

        markers = [
          _buildUserMarker(location),
          if (initialGym != null) _buildGymMarker(initialGym),
        ];
      });

      if (initialGym == null) {
        // A tela já começa carregando as academias próximas.
        await loadGymMode();
      } else if (mapReady) {
        await loadRoute();
        _fitCamera();
      }
    } catch (e, stackTrace) {
      debugPrint('Erro ao iniciar mapa: $e');
      debugPrintStack(stackTrace: stackTrace);

      if (!mounted) return;

      setState(() {
        loading = false;
        locationError =
        'Não foi possível obter sua localização. '
            'Verifique a permissão e tente novamente.';
      });
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
    if (userLocation == null) return;

    setState(() {
      loading = true;

      selectedGym = null;
      gymLocation = null;

      polylines = [];
      circles = [];

      distance = null;
      duration = null;

      nearbyProfessionals = [];

      markers = [
        _buildUserMarker(userLocation!),
      ];
    });

    try {
      final gyms = await PlacesService.searchGyms(
        userLocation!.latitude,
        userLocation!.longitude,
      );

      if (!mounted) return;

      final gymMarkers = <Marker>[
        _buildUserMarker(userLocation!),
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
      debugPrint('Erro ao carregar academias: $e');

      if (!mounted) return;

      setState(() {
        loading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Não foi possível carregar as academias.'),
        ),
      );
    }
  }

  // ==========================================================
  // MODO PROFISSIONAIS
  // ==========================================================

  Future<void> loadProfessionalMode() async {
    if (userLocation == null) return;

    setState(() {
      loading = true;

      selectedGym = null;
      gymLocation = null;

      polylines = [];
      circles = [];

      distance = null;
      duration = null;

      nearbyProfessionals = [];

      markers = [
        _buildUserMarker(userLocation!),
      ];
    });

    try {
      final viewModel = context.read<ProfessionalViewModel>();

      await viewModel.loadProfessionals();

      if (!mounted) return;

      setState(() {
        nearbyProfessionals = [...viewModel.professionals]
          ..sort((a, b) => a.distance.compareTo(b.distance));

        markers = [
          _buildUserMarker(userLocation!),
        ];

        loading = false;
      });
    } catch (e) {
      debugPrint('Erro ao carregar profissionais: $e');

      if (!mounted) return;

      setState(() {
        loading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Não foi possível carregar os profissionais.'),
        ),
      );
    }
  }

  // ==========================================================
  // BUSCAR ACADEMIA
  // ==========================================================

  Future<void> searchGym(String value) async {
    if (userLocation == null) return;

    final query = value.trim();

    if (query.isEmpty) {
      await loadGymMode();
      return;
    }

    setState(() {
      loading = true;

      selectedGym = null;
      gymLocation = null;

      polylines = [];
      circles = [];

      distance = null;
      duration = null;

      markers = [
        _buildUserMarker(userLocation!),
      ];
    });

    try {
      final gyms = await PlacesService.searchGymByName(
        query,
        userLocation!.latitude,
        userLocation!.longitude,
      );

      if (!mounted) return;

      final gymMarkers = <Marker>[
        _buildUserMarker(userLocation!),
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

      if (gyms.isNotEmpty && mapReady) {
        mapController.move(
          LatLng(gyms.first.lat, gyms.first.lng),
          14,
        );
      } else if (gyms.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Nenhuma academia encontrada.'),
          ),
        );
      }
    } catch (e) {
      debugPrint('Erro na pesquisa: $e');

      if (!mounted) return;

      setState(() {
        loading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Erro ao pesquisar academias.'),
        ),
      );
    }
  }


  // ==========================================================
  // card profissional
  // ==========================================================

  Widget buildProfessionalBottomCard() {
    return Positioned(
      bottom: 24,
      left: 16,
      right: 16,
      child: Card(
        elevation: 10,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Icon(Icons.people_alt_outlined),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Profissionais próximos',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              const Text(
                'A localização exata dos profissionais '
                    'ainda não está disponível no mapa.',
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 8),
              if (nearbyProfessionals.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: Text(
                    'Nenhum profissional encontrado próximo de você.',
                  ),
                )
              else
                ...nearbyProfessionals.take(3).map(
                      (prof) => ListTile(
                    contentPadding: EdgeInsets.zero,
                    dense: true,
                    leading: const CircleAvatar(
                      child: Icon(Icons.fitness_center),
                    ),
                    title: Text(
                      prof.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    subtitle: Text(
                      prof.specialty.isEmpty
                          ? 'Profissional'
                          : prof.specialty,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    trailing: Text(
                      '${prof.distance.toStringAsFixed(1)} km',
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  // ==========================================================
  //
  // ==========================================================

  // ==========================================================
  // BUILD
  // ==========================================================

  @override
  Widget build(BuildContext context) {
    if (userLocation == null) {
      return Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (locationError == null) ...[
                  const CircularProgressIndicator(),
                  const SizedBox(height: 16),
                  const Text('Obtendo sua localização...'),
                ] else ...[
                  const Icon(
                    Icons.location_off,
                    size: 48,
                    color: Colors.grey,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    locationError!,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: initMap,
                    icon: const Icon(Icons.refresh),
                    label: const Text('Tentar novamente'),
                  ),
                ],
              ],
            ),
          ),
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

          // ==========================================
          // card profissionais
          // ==========================================

          if (currentMode == MapMode.professionals)
            buildProfessionalBottomCard(),
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
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _fitCamera,
                      icon: const Icon(Icons.directions),
                      label: const Text('Centralizar rota'),
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