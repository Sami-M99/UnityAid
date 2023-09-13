import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:unityaid/service/user.dart';

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'User List',
        home: Scaffold(
            appBar: AppBar(
              backgroundColor: Color(0xFF000116),
            ),
            body: NearByPlacesScreen()));
  }
}

class NearByPlacesScreen extends StatefulWidget {
  const NearByPlacesScreen({Key? key}) : super(key: key);

  @override
  State<NearByPlacesScreen> createState() => _NearByPlacesScreenState();
}

class _NearByPlacesScreenState extends State<NearByPlacesScreen> {
  // double currentlat = 0.0;
  // double currentlong = 0.0;

  @override
  void initState() {
    super.initState();
    getAllUsers();
  }

  late List<Users> users = [];

  void getAllUsers() async {
    QuerySnapshot querySnapshot =
        await FirebaseFirestore.instance.collection('users').get();

    List<DocumentSnapshot> documents = querySnapshot.docs;

    users = documents.map((doc) {
      var snapshot = doc.data() as Map<String, dynamic>;

      return Users(
        fullName: snapshot["fullName"] ?? "",
        email: snapshot["email"] ?? "",
        password: snapshot["password"] ?? "",
        tel: snapshot["tel"] ?? "",
        adress: snapshot["adress"] ?? "",
        lat: snapshot["lat"] ?? 0,
        long: snapshot["long"] ?? 0,
      );
    }).toList();

    DocumentSnapshot snap = await FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .get();

    // currentlat = (snap.data() as Map<String, dynamic>)["lat"] ?? 0.0;
    // currentlong = (snap.data() as Map<String, dynamic>)["long"] ?? 0.0;

    Users nearestUser = Users(
        fullName: (snap.data() as Map<String, dynamic>)["fullName"] ?? "",
        email: (snap.data() as Map<String, dynamic>)["email"] ?? "",
        password: (snap.data() as Map<String, dynamic>)["password"] ?? "",
        tel: (snap.data() as Map<String, dynamic>)["tel"] ?? "",
        adress: (snap.data() as Map<String, dynamic>)["adress"] ?? "",
        lat: (snap.data() as Map<String, dynamic>)["lat"] ?? 0,
        long: (snap.data() as Map<String, dynamic>)["long"] ?? 0);

    double nearestPath = 0;

    for (var user in users) {
      if (user.email != (snap.data() as Map<String, dynamic>)["email"]) {
        double distanceInMeters = Geolocator.distanceBetween(
            nearestUser.lat, nearestUser.long, user.lat, user.long);

        if (nearestPath == 0 || distanceInMeters < nearestPath) {
          nearestPath = distanceInMeters;
          nearestUser = user;
        }

        print("${user.fullName} =>  $distanceInMeters");
        print('------------------');

        // if (distanceInMeters < nearestPath) {
        //   nearestPath = distanceInMeters;
        //   nearestUser = user;
        // }
      }
    }
    print('------------------');
    print('Nearest Path  == $nearestPath');
    print('********************');
    print('En Yakin kisi => ${nearestUser.email}');
    // print(currentUser.email);

    setState(() {});

    // void sendMessageToNearestUser(String userEmail) async {
    // Get the document reference of the nearest user based on their email
    QuerySnapshot querySnapshotWhere = await FirebaseFirestore.instance
        .collection('users')
        .where('email', isEqualTo: nearestUser.email)
        .get();

    // Get the first document from the query result (assuming email is unique)
    DocumentSnapshot userDoc = querySnapshotWhere.docs[0];

    // Get the user's document ID
    String userId = userDoc.id;

    await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('messages')
        .add({
      'sender': (snap.data() as Map<String, dynamic>)["email"],
      'message': 'yardim et.'
    });

    print('Message sent to: ${nearestUser.email}');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text(
          "Tabaliniz alindi",
          style: TextStyle(
              fontSize: 25,
              color: Color(0xFF000116),
              fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
