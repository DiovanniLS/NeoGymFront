import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

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

  @override
  void initState() {
    super.initState();
    initMap();
  }

  Future<void> initMap() async{
    final pos = await LocationService.getUserLocation();

    userLocation = LatLng(pos.latitude, pos.longitude);

    final gyms = await PlacesService.searchGyms(
        pos.latitude,
        pos.longitude
    );

    Set<Marker> gymMarkers = gyms.map((Gym gym){
      return Marker(
          markerId: MarkerId(gym.name),
        position: LatLng(gym.lat, gym.lng),
        infoWindow: InfoWindow(
          title: gym.name
        )
      );
    }).toSet();

    setState(() {
      markers = gymMarkers;
    });

    mapController?.animateCamera(CameraUpdate.newLatLngZoom(userLocation!, 15)
    );
}

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      body: GoogleMap(

        initialCameraPosition: CameraPosition(
          target: userLocation ?? const LatLng(-23.5505, -46.6333),
          zoom: 14,
        ),

        myLocationEnabled: true,

        markers: markers,

        onMapCreated: (controller) {
          mapController = controller;
        },

      ),

    );
  }
}
