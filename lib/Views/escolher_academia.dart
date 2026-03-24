import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:neogym/Resources/neo_gym_colors.dart';
import 'package:neogym/Views/home.dart';

import '../services/location_service.dart';
import '../services/places_service.dart';
import '../models/gym.dart';

class EscolherAcademia extends StatefulWidget {
  const EscolherAcademia({super.key});

  @override
  State<EscolherAcademia> createState() => _EscolherAcademiaState();
}

class _EscolherAcademiaState extends State<EscolherAcademia> {
  GoogleMapController? mapController;

  LatLng? userLocation;

  Set<Marker> markers = {};

  Gym? selectedGym;
  BitmapDescriptor? gymIcon;

  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    initMap();
  }

  Future<void> initMap() async {
    final pos = await LocationService.getUserLocation();

    userLocation = LatLng(pos.latitude, pos.longitude);

    gymIcon ??= await BitmapDescriptor.fromAssetImage(
      const ImageConfiguration(size: Size(64, 64)),
      "assets/images/academia.png",
    );

    final gyms = await PlacesService.searchGyms(pos.latitude, pos.longitude);

    Set<Marker> gymMarkers = {};

    for (var gym in gyms) {
      gymMarkers.add(
        Marker(
          markerId: MarkerId(gym.name),
          position: LatLng(gym.lat, gym.lng),
          icon: gymIcon!,

          onTap: () {
            print("clicou na academia");

            setState(() {
              selectedGym = gym;
            });
          },
        ),
      );
    }

    gymMarkers.add(
      Marker(
        markerId: const MarkerId("user"),
        position: userLocation!,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
      ),
    );

    setState(() {
      markers = gymMarkers;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (userLocation == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      body: Stack(
        children: [
          GoogleMap(
            key: const ValueKey("mapa"),

            initialCameraPosition: CameraPosition(
              target: userLocation!,
              zoom: 14,
            ),

            markers: markers,

            myLocationEnabled: true,

            onMapCreated: (controller) {
              mapController = controller;
            },

            onTap: (pos) {
              print("clicou no mapa");
            },
          ),

          buildSearchBar(),

          buildSelectedGymCard(),
        ],
      ),
    );
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

                  onTap: () {
                    setState(() {
                      selectedGym = gym;
                    });
                  },
                ),
              );
            }

            setState(() {
              markers = gymMarkers;
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

  Widget buildSelectedGymCard() {
    if (selectedGym == null) return const SizedBox.shrink();

    String message = "Academia próxima da sua localização";
    if (selectedGym != null && userLocation != null) {

      final distance = PlacesService.calculateDistance(
        userLocation!.latitude,
        userLocation!.longitude,
        selectedGym!.lat,
        selectedGym!.lng,
      );

      if (distance > 2) {
        message = "Essa academia parece um pouco distante de você";
      }

      if (distance > 5) {
        message = "Essa academia fica bem longe da sua localização";
      }
    }


    return Positioned(
      bottom: 30,
      left: 16,
      right: 16,
      child: Card(
        elevation: 10,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Icon(Icons.fitness_center, size: 40),

              SizedBox(width: 12),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      selectedGym!.name,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    SizedBox(height: 4),

                    Text(message),
                  ],
                ),
              ),

              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pushNamed("/home");
                },
                child: Text("Selecionar"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
