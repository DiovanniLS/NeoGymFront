import 'dart:typed_data';
import 'package:flutter/services.dart';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../Resources/neo_gym_colors.dart';
import '../models/gym.dart';
import '../services/location_service.dart';
import '../services/places_service.dart';

class MapScreen extends StatefulWidget {
  final Gym? gym;

  const MapScreen({super.key, this.gym});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  GoogleMapController? mapController;

  LatLng? userLocation;
  LatLng? gymLocation;
  Gym? selectedGym;

  Set<Marker> markers = {};
  Set<Polyline> polylines = {};

  String? distance;
  String? duration;
  TextEditingController searchController = TextEditingController();
  BitmapDescriptor? gymIcon;

  @override
  void initState() {
    super.initState();
    initMap();
  }

  Future<void> initMap() async {
    final pos = await LocationService.getUserLocation();

    userLocation = LatLng(pos.latitude, pos.longitude);

    gymLocation = widget.gym != null
        ? LatLng(widget.gym!.lat, widget.gym!.lng)
        : null;
    gymIcon ??= await getCustomMarker("assets/icons/academia.png");
    selectedGym = widget.gym;

    setState(() {});
  }

  void _fitCamera() {
    if (mapController == null || userLocation == null || gymLocation == null)
      return;

    mapController!.animateCamera(
      CameraUpdate.newLatLngBounds(
        LatLngBounds(
          southwest: LatLng(
            userLocation!.latitude < gymLocation!.latitude
                ? userLocation!.latitude
                : gymLocation!.latitude,
            userLocation!.longitude < gymLocation!.longitude
                ? userLocation!.longitude
                : gymLocation!.longitude,
          ),
          northeast: LatLng(
            userLocation!.latitude > gymLocation!.latitude
                ? userLocation!.latitude
                : gymLocation!.latitude,
            userLocation!.longitude > gymLocation!.longitude
                ? userLocation!.longitude
                : gymLocation!.longitude,
          ),
        ),
        100,
      ),
    );
  }

  Future<void> loadRoute() async {
    if (userLocation == null || gymLocation == null) return;

    final points = await PlacesService.getRouteCoordinates(
      userLocation!.latitude,
      userLocation!.longitude,
      gymLocation!.latitude,
      gymLocation!.longitude,
    );

    setState(() {
      polylines = {
        Polyline(
          polylineId: const PolylineId("route"),
          color: Colors.blue,
          width: 5,
          points: points,
        ),
      };
    });

    final info = await PlacesService.getRouteInfo(
      userLocation!.latitude,
      userLocation!.longitude,
      gymLocation!.latitude,
      gymLocation!.longitude,
    );

    setState(() {
      distance = info["distance"];
      duration = info["duration"];

      markers = {
        Marker(markerId: const MarkerId("user"), position: userLocation!),
        Marker(
          markerId: const MarkerId("gym"),
          position: gymLocation!,
          icon: gymIcon ?? BitmapDescriptor.defaultMarker,
        ),
      };
    });
  }

  @override
  Widget build(BuildContext context) {
    if (userLocation == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    Widget buildSearchBar() {
      return Positioned(
        top: 50,
        left: 16,
        right: 16,
        child: Material(
          elevation: 6,
          borderRadius: BorderRadius.circular(30),
          child: TextField(
            controller: searchController,
            onSubmitted: (value) async {
              final pos = await LocationService.getUserLocation();

              final gyms = await PlacesService.searchGymByName(
                value,
                pos.latitude,
                pos.longitude,
              );

              Set<Marker> gymMarkers = {};

              for (var gym in gyms) {
                gymMarkers.add(
                  Marker(
                    markerId: MarkerId(gym.name),
                    position: LatLng(gym.lat, gym.lng),
                    icon: gymIcon!,

                    onTap: () async {
                      setState(() {
                        selectedGym = gym;
                        gymLocation = LatLng(gym.lat, gym.lng);
                      });

                      await loadRoute();
                      _fitCamera();
                    },
                  ),
                );
              }

              setState(() {
                markers = {
                  ...gymMarkers,

                  if (userLocation != null)
                    Marker(
                      markerId: const MarkerId("user"),
                      position: userLocation!,
                    ),
                };
              });
            },
            decoration: InputDecoration(
              hintText: "Buscar academia...",
              prefixIcon: Icon(Icons.search, color: NeoGymColors.primary),
              suffixIcon: IconButton(
                onPressed: () {
                  searchController.text = '';
                },
                icon: Icon(Icons.cancel, color: NeoGymColors.primary),
              ),
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(vertical: 15),
            ),
          ),
        ),
      );
    }

    return Scaffold(
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: userLocation!,
              zoom: 14,
            ),
            markers: markers,
            polylines: polylines,
            myLocationEnabled: true,
            onMapCreated: (controller) async {
              mapController = controller;

              if (gymLocation != null) {
                await loadRoute();
                _fitCamera();
              }
            },
          ),
          buildSearchBar(),
          buildBottomCard(),
        ],
      ),
    );
  }

  Widget buildBottomCard() {
    String message = "Academia próxima 💪";

    if (distance != null) {
      final km = double.tryParse(distance!.replaceAll(RegExp('[^0-9.]'), ''));

      if (km != null) {
        if (km > 5) {
          message = "Tá longe, mas bora manter o foco 🔥";
        } else if (km > 2) {
          message = "Distância média, já dá um aquecimento 😅";
        }
      }
    }

    return Positioned(
      bottom: 50,
      left: 16,
      right: 16,
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        elevation: 10,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Row(
                children: [
                  Icon(Icons.fitness_center, size: 28),
                  SizedBox(width: 10),

                  Expanded(
                    child: Text(
                      selectedGym?.name ?? "Academia",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ],
              ),

              SizedBox(height: 8),

              Text(
                "${distance ?? '--'} • ${duration ?? '--'}",
                style: TextStyle(color: Colors.grey[600]),
              ),

              SizedBox(height: 8),

              Text(message),

              SizedBox(height: 10),

              ElevatedButton(onPressed: () {}, child: Text("Iniciar treino")),
            ],
          ),
        ),
      ),
    );
  }

  Future<BitmapDescriptor> getCustomMarker(String path) async {
    final ByteData data = await rootBundle.load(path);
    final Uint8List bytes = data.buffer.asUint8List();

    final codec = await ui.instantiateImageCodec(
      bytes,
      targetWidth: 100, // tamanho do ícone
    );

    final frame = await codec.getNextFrame();
    final byteData = await frame.image.toByteData(
      format: ui.ImageByteFormat.png,
    );

    return BitmapDescriptor.fromBytes(byteData!.buffer.asUint8List());
  }
}
