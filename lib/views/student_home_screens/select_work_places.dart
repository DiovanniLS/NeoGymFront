import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../../Resources/neo_gym_colors.dart';
import '../../services/location_service.dart';

class SelectWorkPlaces extends StatefulWidget {
  final bool isProfessional;

  const SelectWorkPlaces({
    super.key,
    this.isProfessional = false,
  });

  @override
  State<SelectWorkPlaces> createState() => _SelectWorkPlacesState();
}

class _SelectWorkPlacesState extends State<SelectWorkPlaces> {
  LatLng? userLocation;

  LatLng? selectedCenter;

  double radiusKm = 3;

  @override
  void initState() {
    super.initState();

    initMap();
  }

  Future<void> initMap() async {
    try {
      final pos = await LocationService.getUserLocation();

      if (!mounted) return;

      setState(() {
        userLocation = LatLng(
          pos.latitude,
          pos.longitude,
        );
      });
    } catch (e) {
      debugPrint(
        'Erro ao obter localização: $e',
      );
    }
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

          // ====================================================
          // MAPA
          // ====================================================

          FlutterMap(
            options: MapOptions(
              initialCenter: userLocation!,
              initialZoom: 14,

              // Clicar no mapa para escolher
              // o centro da área de atuação.
              onTap: (tapPosition, point) {
                setState(() {
                  selectedCenter = point;
                });
              },
            ),

            children: [

              // =================================================
              // OPEN STREET MAP
              // =================================================

              TileLayer(
                urlTemplate:
                'https://tile.openstreetmap.org/{z}/{x}/{y}.png',

                // Troque pelo package name real
                // do seu aplicativo.
                userAgentPackageName:
                'com.neogym.app',
              ),

              // =================================================
              // RAIO DE ATUAÇÃO
              // =================================================

              if (selectedCenter != null)
                CircleLayer(
                  circles: [
                    CircleMarker(
                      point: selectedCenter!,

                      /*
                       * radius está em METROS
                       * por causa de:
                       *
                       * useRadiusInMeter: true
                       */
                      radius: radiusKm * 1000,

                      useRadiusInMeter: true,

                      color: Colors.blue.withOpacity(
                        0.15,
                      ),

                      borderColor: Colors.blue,

                      borderStrokeWidth: 2,
                    ),
                  ],
                ),

              // =================================================
              // MARCADORES
              // =================================================

              MarkerLayer(
                markers: [

                  // ===============================================
                  // LOCALIZAÇÃO ATUAL DO USUÁRIO
                  // ===============================================

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
                            blurRadius: 7,
                          ),
                        ],
                      ),

                      child: const Icon(
                        Icons.person,
                        color: Colors.white,
                        size: 21,
                      ),
                    ),
                  ),

                  // ===============================================
                  // CENTRO DA ÁREA ESCOLHIDA
                  // ===============================================

                  if (selectedCenter != null)
                    Marker(
                      point: selectedCenter!,

                      width: 50,
                      height: 50,

                      child: Container(
                        decoration: BoxDecoration(
                          color: NeoGymColors.primary,

                          shape: BoxShape.circle,

                          border: Border.all(
                            color: Colors.white,
                            width: 3,
                          ),

                          boxShadow: const [
                            BoxShadow(
                              color: Colors.black26,
                              blurRadius: 7,
                            ),
                          ],
                        ),

                        child: const Icon(
                          Icons.location_on,
                          color: Colors.white,
                          size: 28,
                        ),
                      ),
                    ),
                ],
              ),

              // =================================================
              // ATRIBUIÇÃO OSM
              // =================================================

              const RichAttributionWidget(
                attributions: [
                  TextSourceAttribution(
                    'OpenStreetMap contributors',
                  ),
                ],
              ),
            ],
          ),

          // ====================================================
          // INSTRUÇÃO
          // ====================================================

          Positioned(
            top: 50,
            left: 16,
            right: 16,

            child: Card(
              elevation: 6,

              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(
                  20,
                ),
              ),

              child: const Padding(
                padding: EdgeInsets.symmetric(
                  vertical: 12,
                  horizontal: 16,
                ),

                child: Row(
                  children: [
                    Icon(
                      Icons.touch_app,
                    ),

                    SizedBox(
                      width: 10,
                    ),

                    Expanded(
                      child: Text(
                        'Toque no mapa para escolher '
                            'o centro da sua área de atuação.',
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // ====================================================
          // RAIO
          // ====================================================

          Positioned(
            bottom: 140,
            left: 16,
            right: 16,

            child: Card(
              elevation: 10,

              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(
                  20,
                ),
              ),

              child: Padding(
                padding: const EdgeInsets.all(
                  16,
                ),

                child: Column(
                  children: [

                    const Text(
                      'Raio de atuação',

                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),

                    const SizedBox(
                      height: 10,
                    ),

                    Text(
                      '${radiusKm.toInt()} km',

                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: NeoGymColors.primary,
                      ),
                    ),

                    Slider(
                      value: radiusKm,

                      min: 1,

                      max: 20,

                      divisions: 19,

                      label:
                      '${radiusKm.toInt()} km',

                      onChanged:
                      selectedCenter == null
                          ? null
                          : (value) {
                        setState(() {
                          radiusKm =
                              value;
                        });
                      },
                    ),

                    const Row(
                      mainAxisAlignment:
                      MainAxisAlignment
                          .spaceBetween,

                      children: [
                        Text(
                          '1 km',
                        ),

                        Text(
                          '20 km',
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),

          // ====================================================
          // CONFIRMAR
          // ====================================================

          Positioned(
            bottom: 30,
            left: 16,
            right: 16,

            child: SizedBox(
              height: 52,

              child: ElevatedButton.icon(
                onPressed:
                selectedCenter == null
                    ? null
                    : () {
                  debugPrint(
                    'Área selecionada:',
                  );

                  debugPrint(
                    'Latitude: '
                        '${selectedCenter!.latitude}',
                  );

                  debugPrint(
                    'Longitude: '
                        '${selectedCenter!.longitude}',
                  );

                  debugPrint(
                    'Raio: '
                        '$radiusKm km',
                  );

                  Navigator
                      .pushReplacementNamed(
                    context,
                    '/homePro',
                  );
                },

                icon: const Icon(
                  Icons.check,
                ),

                label: const Text(
                  'Salvar área de atuação',
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}