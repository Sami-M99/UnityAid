import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:rflutter_alert/rflutter_alert.dart';

import '../service/authoMethod.dart';

class MyProfile extends StatefulWidget {
  const MyProfile({Key? key}) : super(key: key);

  @override
  State<MyProfile> createState() => _MyProfileState();
}

class _MyProfileState extends State<MyProfile> {
  late GoogleMapController googleMapController;
  String location = 'Press Button';
  String Address = 'Address';
  Set<Marker> markers = {};

  String tel = "";
  String fullName = "";
  String email = "";
  String adress = "";
  String password = "";
  double lat = 0;
  double long = 0;
  @override
  void initState() {
    super.initState();
    getAll();
  }

  void getAll() async {
    DocumentSnapshot snap = await FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .get();

    setState(() {
      fullName = (snap.data() as Map<String, dynamic>)["fullName"] ?? "";
      email = (snap.data() as Map<String, dynamic>)["email"] ?? "";
      password = (snap.data() as Map<String, dynamic>)["password"] ?? "";
      tel = (snap.data() as Map<String, dynamic>)["tel"] ?? "";
      adress = (snap.data() as Map<String, dynamic>)["adress"] ?? "";
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Color(0xFF000116),
        appBar: AppBar(
          title: Text("$fullName"),
          backgroundColor: Color(0xFF000116),
          centerTitle: true,
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  fullNameFormField("$fullName"),
                  SizedBox(height: 30),
                  emailFormField("$email"),
                  // SizedBox(height: 30),
                  // passwordFormField("$password"),
                  SizedBox(height: 30),
                  telFormField("$tel"),
                  SizedBox(height: 30),
                  adressFormField("$adress"),
                  SizedBox(height: 30),
                  getCurrentAddress(),
                  SizedBox(height: 30),
                  update(),
                ],
              ),
            ),
          ),
        ));
  }

  TextEditingController _fullNameController = TextEditingController();
  TextEditingController _adressController = TextEditingController();
  TextEditingController _emailController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();
  TextEditingController _telControlller = TextEditingController();

  TextFormField fullNameFormField(String fullname) {
    _fullNameController.text =
        fullname; // Set the initial value using the controller
    return TextFormField(
      style: const TextStyle(color: Color.fromARGB(255, 5, 3, 3)),
      decoration: customInputDecoration("Enter your full name"),
      controller:
          _fullNameController, // Use the controller to manage the field's value
    );
  }

  TextFormField emailFormField(String email) {
    _emailController.text = email;
    return TextFormField(
      style: const TextStyle(color: Color.fromARGB(255, 5, 3, 3)),
      decoration: customInputDecoration("Enter your email"),
      controller: _emailController,
    );
  }

  // TextFormField passwordFormField(String password) {
  //   _passwordController.text = password;
  //   return TextFormField(
  //     style: const TextStyle(color: Color.fromARGB(255, 5, 3, 3)),
  //     decoration: customInputDecoration("Enter your password"),
  //     controller: _passwordController,
  //   );
  // }

  TextFormField telFormField(String tel) {
    _telControlller.text = tel; // Set the initial value using the controller
    return TextFormField(
      style: const TextStyle(color: Color.fromARGB(255, 5, 3, 3)),
      decoration: customInputDecoration("Enter your number"),
      controller:
          _telControlller, // Use the controller to manage the field's value
    );
  }

  TextFormField adressFormField(String address) {
    _adressController.text =
        address; // Set the initial value using the controller
    return TextFormField(
      style: const TextStyle(color: Color.fromARGB(255, 5, 3, 3)),

      decoration: customInputDecoration("Enter your Adress"),
      controller:
          _adressController, // Use the controller to manage the field's value
    );
  }

  InputDecoration customInputDecoration(String hintText) {
    return InputDecoration(
      hintText: hintText,
      hintStyle: const TextStyle(
        color: Colors.grey,
      ),
      enabledBorder: const UnderlineInputBorder(
        borderSide: BorderSide(
          color: Colors.grey,
        ),
      ),
      focusedBorder: const UnderlineInputBorder(
        borderSide: BorderSide(
          color: Colors.grey,
        ),
      ),
      filled: true, // Add this line to enable filling the field
      fillColor: Colors.white, // Set the fill color for the field
    );
  }

  Widget update() {
    return Container(
      height: 60,
      width: 150,
      child: ElevatedButton(
        onPressed: () {
          Authomethod().updateUser(
              fullName: _fullNameController.text,
              email: email,
              password: password,
              tel: _telControlller.text,
              adress: _adressController.text,
              lat: lat,
              long: long);
          print('**********************');
          updateAlert();
        },
        child: Text(
          'Güncelle',
          style: TextStyle(color: Colors.black87),
        ),
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          backgroundColor: Color.fromARGB(255, 235, 234, 234),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(50),
          ),
          shadowColor: Colors.amber,
        ),
      ),
    );
  }

  Widget getCurrentAddress() {
    return Container(
      height: 50,
      width: 110,
      child: ElevatedButton(
        onPressed: () async {
          Position position = await determinePosition();

          location = 'Lat: ${position.latitude} , Long: ${position.longitude}';
          print(location);
          print('**********************');
          List<Placemark> placemarks = await placemarkFromCoordinates(
              position.latitude, position.longitude);
          Placemark place = placemarks[0];

          lat = position.latitude;
          long = position.longitude;
          _adressController.text =
              '${place.subThoroughfare},${place.thoroughfare},  ${place.street}, ${place.postalCode}, ${place.subAdministrativeArea} / ${place.administrativeArea}, ${place.country}';
        },
        child: Text(
          'Adresi Alın',
          style: TextStyle(color: Colors.black87),
        ),
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          backgroundColor: Color.fromARGB(255, 235, 234, 234),
          shadowColor: Colors.amber,
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

  void updateAlert() async {
    Alert(
      context: context,
      title: "Bilgileriniz Güncellendi",
      buttons: [
        DialogButton(
          child: Text(
            "OK",
            style: TextStyle(color: Colors.white, fontSize: 20),
          ),
          onPressed: () => Navigator.pop(context),
          width: 120,
          color: Color.fromARGB(255, 3, 6, 59),
        )
      ],
    ).show();
  }
}
