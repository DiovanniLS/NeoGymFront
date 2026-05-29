import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:neogym/views/professional_home_screens/professional_home_content.dart';

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
  GoogleMapController? mapController;

  LatLng? userLocation;

  LatLng? selectedCenter;
  double radiusKm = 3;

  @override
  void initState() {
    super.initState();
    initMap();
  }

  Future<void> initMap() async {
    final pos = await LocationService.getUserLocation();

    userLocation = LatLng(pos.latitude, pos.longitude);

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    if (userLocation == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
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

            myLocationEnabled: true,

            onMapCreated: (controller) {
              mapController = controller;
            },

            onTap: (LatLng pos) {
              setState(() {
                selectedCenter = pos;
              });
            },

            markers: {
              if (selectedCenter != null)
                Marker(
                  markerId: const MarkerId("center"),
                  position: selectedCenter!,
                ),
            },

            circles: {
              if (selectedCenter != null)
                Circle(
                  circleId: const CircleId("radius"),
                  center: selectedCenter!,
                  radius: radiusKm * 1000,
                  fillColor: Colors.blue.withOpacity(0.15),
                  strokeColor: Colors.blue,
                  strokeWidth: 2,
                ),
            },
          ),

          // 🎚️ RAIO
          Positioned(
            bottom: 140,
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
                  children: [
                    const Text(
                      "Raio de atuação",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),

                    const SizedBox(height: 10),

                    Text("${radiusKm.toInt()} km"),

                    Slider(
                      value: radiusKm,
                      min: 1,
                      max: 20,
                      divisions: 19,
                      label: "${radiusKm.toInt()} km",
                      onChanged: (value) {
                        setState(() {
                          radiusKm = value;
                        });
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),

          // 💾 CONFIRMAR
          Positioned(
            bottom: 30,
            left: 16,
            right: 16,
            child: ElevatedButton(
              onPressed: selectedCenter == null
                  ? null
                  : () {
                Navigator.pushReplacementNamed(context, "/homePro");
              },
              child: const Text("Salvar área de atuação"),
            ),
          ),
        ],
      ),
    );
  }
}