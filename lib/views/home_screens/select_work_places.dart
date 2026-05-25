import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../Resources/neo_gym_colors.dart';
import '../../models/work_place.dart';
import '../../services/location_service.dart';
import '../../services/places_service.dart';

class SelectWorkPlaces extends StatefulWidget {
  final bool allowMultiple;
  final bool isProfessional;

  const SelectWorkPlaces({
    super.key,
    this.allowMultiple = false,
    this.isProfessional = false,
  });

  @override
  State<SelectWorkPlaces> createState() => _SelectWorkPlacesState();
}

class _SelectWorkPlacesState extends State<SelectWorkPlaces> {
  GoogleMapController? mapController;

  LatLng? userLocation;

  Set<Marker> markers = {};

  List<Workplace> selectedWorkplaces = [];

  BitmapDescriptor? gymIcon;

  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    initMap();
  }

  Future<void> initMap() async {
    final pos = await LocationService.getUserLocation();

    userLocation = LatLng(
      pos.latitude,
      pos.longitude,
    );

    gymIcon = await getCustomMarker(
      "assets/icons/academia.png",
    );

    final gyms = await PlacesService.searchGyms(
      pos.latitude,
      pos.longitude,
    );

    await loadMarkers(gyms);
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
            initialCameraPosition: CameraPosition(
              target: userLocation!,
              zoom: 14,
            ),
            markers: markers,
            myLocationEnabled: true,
            onMapCreated: (controller) {
              mapController = controller;
            },
          ),

          buildSearchBar(),

          buildSelectedWorkplacesCard(),
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

          onChanged: (value) async {

            if (value.trim().isEmpty) {

              final pos = await LocationService.getUserLocation();

              final gyms = await PlacesService.searchGyms(
                pos.latitude,
                pos.longitude,
              );

              await loadMarkers(gyms);

              return;
            }

            final pos = await LocationService.getUserLocation();

            final gyms = await PlacesService.searchGymByName(
              value,
              pos.latitude,
              pos.longitude,
            );

            await loadMarkers(gyms);
          },

          decoration: InputDecoration(
            hintText: "Buscar local...",
            prefixIcon: Icon(Icons.search, color: NeoGymColors.primary),

            suffixIcon: IconButton(
              onPressed: () async {
                searchController.clear();

                final pos = await LocationService.getUserLocation();

                final gyms = await PlacesService.searchGyms(
                  pos.latitude,
                  pos.longitude,
                );

                await loadMarkers(gyms);
              },
              icon: Icon(Icons.cancel, color: NeoGymColors.primary),
            ),

            border: InputBorder.none,

            contentPadding: const EdgeInsets.symmetric(vertical: 15),
          ),
        ),
      ),
    );
  }

  Widget buildSelectedWorkplacesCard() {
    if (selectedWorkplaces.isEmpty) {
      return const SizedBox.shrink();
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
          child: Column(
            children: [
              Row(
                children: [
                  const Icon(Icons.work),

                  const SizedBox(width: 10),

                  Expanded(
                    child: Text(
                      "${selectedWorkplaces.length} locais selecionados",
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              ...selectedWorkplaces.map(
                (workplace) => ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.location_on),
                  title: Text(workplace.name),
                  subtitle: Text(workplace.type),
                ),
              ),

              const SizedBox(height: 10),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context, selectedWorkplaces);
                  },
                  child: const Text("Confirmar"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<BitmapDescriptor> getCustomMarker(String path) async {
    final ByteData data = await rootBundle.load(path);

    final Uint8List bytes = data.buffer.asUint8List();

    final codec = await ui.instantiateImageCodec(bytes, targetWidth: 100);

    final frame = await codec.getNextFrame();

    final byteData = await frame.image.toByteData(
      format: ui.ImageByteFormat.png,
    );

    return BitmapDescriptor.fromBytes(byteData!.buffer.asUint8List());
  }



  Future<void> loadMarkers(List<dynamic> gyms) async {
    Set<Marker> gymMarkers = {};

    for (var gym in gyms) {

      final workplace = Workplace(
        id: DateTime.now().toString(),
        name: gym.name,
        address: "",
        lat: gym.lat,
        lng: gym.lng,
        type: "Academia",
      );

      final isSelected = selectedWorkplaces.any(
            (w) => w.name == workplace.name,
      );

      gymMarkers.add(
        Marker(
          markerId: MarkerId(gym.name),
          position: LatLng(gym.lat, gym.lng),

          icon: isSelected
              ? BitmapDescriptor.defaultMarkerWithHue(
            BitmapDescriptor.hueGreen,
          )
              : gymIcon!,

          onTap: () {
            setState(() {

              final alreadySelected =
              selectedWorkplaces.any(
                    (w) => w.name == workplace.name,
              );

              if (alreadySelected) {

                selectedWorkplaces.removeWhere(
                      (w) => w.name == workplace.name,
                );

              } else {

                if (!widget.allowMultiple) {
                  selectedWorkplaces.clear();
                }

                selectedWorkplaces.add(workplace);
              }

              // recarrega markers
              loadMarkers(gyms);
            });
          },
        ),
      );
    }

    gymMarkers.add(
      Marker(
        markerId: const MarkerId("user"),
        position: userLocation!,
        icon: BitmapDescriptor.defaultMarkerWithHue(
          BitmapDescriptor.hueAzure,
        ),
      ),
    );

    setState(() {
      markers = gymMarkers;
    });
  }
}
