import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MyLocation extends StatefulWidget {
  const MyLocation({Key? key}) : super(key: key);

  @override
  State<MyLocation> createState() => _MyLocationState();
}

class _MyLocationState extends State<MyLocation> {
  late GoogleMapController googleMapController;

  String location = 'Press Button';
  String Address = 'Adres';

  static const CameraPosition initialCameraPosition =
      CameraPosition(target: LatLng(41.372417, 36.227572), zoom: 14);

  Set<Marker> markers = {};

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Mevcut Konum"),
        backgroundColor: Color(0xFF000116),
        centerTitle: true,
      ),
      body: Column(children: [
        Expanded(
          child: GoogleMap(
            initialCameraPosition: initialCameraPosition,
            markers: markers,
            zoomControlsEnabled: false,
            mapType: MapType.normal,
            onMapCreated: (GoogleMapController controller) {
              googleMapController = controller;
            },
          ),
        ),
        Container(
          width: 400,
          child: Text(
            Address,
            textAlign: TextAlign.center,
          ),
          color: Colors.yellow[700],
        ),
      ]),
      floatingActionButton: Padding(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: FloatingActionButton.extended(
          onPressed: () async {
            Position position = await determinePosition();

            location =
                'Lat: ${position.latitude} , Long: ${position.longitude}';
            print(location);
            print('**********************');
            GetAddressFromLatLong(position);

            googleMapController.animateCamera(CameraUpdate.newCameraPosition(
                CameraPosition(
                    target: LatLng(position.latitude, position.longitude),
                    zoom: 14)));

            markers.clear();

            markers.add(Marker(
                markerId: const MarkerId('currentLocation'),
                position: LatLng(position.latitude, position.longitude)));

            setState(() {});
          },
          label: const Text("Şimdiki Konum"),
          icon: const Icon(Icons.location_history),
          backgroundColor: Color.fromARGB(255, 3, 6, 59),
        ),
      ),
    );
  }

  Future<Position> determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();

    if (!serviceEnabled) {
      return Future.error('Location services are disabled');
    }

    permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();

      if (permission == LocationPermission.denied) {
        return Future.error("Location permission denied");
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error('Location permissions are permanently denied');
    }

    Position position = await Geolocator.getCurrentPosition();

    return position;
  }

  Future<void> GetAddressFromLatLong(Position position) async {
    List<Placemark> placemarks =
        await placemarkFromCoordinates(position.latitude, position.longitude);
    // print(placemarks);
    Placemark place = placemarks[0];
    Address =
        '${place.subThoroughfare},${place.thoroughfare},  ${place.street}, ${place.postalCode}, ${place.subAdministrativeArea} / ${place.administrativeArea}, ${place.country}';
    print(Address);
  }
}
