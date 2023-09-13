// ignore_for_file: prefer_const_constructors, avoid_print

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:just_audio/just_audio.dart';
import 'package:unityaid/models/helpRequests.dart';
import 'package:unityaid/models/myLocation.dart';
import 'package:unityaid/pages/welcomeScreen.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:volume_watcher/volume_watcher.dart';

import '../models/myProfile.dart';
import '../service/user.dart';
import '../utils/custombutton.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({Key? key}) : super(key: key);

  @override
  State<MainScreen> createState() => _MainScreen();
}

class _MainScreen extends State<MainScreen> {
  DateTime? lastMessageSentTime;
  final _auth = FirebaseAuth.instance;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Color(0xFF000116),
        appBar: AppBar(
          backgroundColor: Color.fromARGB(255, 5, 8, 26),
          title: Center(child: Text('Ana Sayfa')),
          leading: Builder(
            builder: (BuildContext context) {
              return IconButton(
                icon: Icon(Icons.close_rounded, size: 35),
                onPressed: () {
                  closeAlert();
                },
                tooltip: "Hesaptan Çıkış",
              );
            },
          ),
          actions: [
            Row(
              children: [
                Padding(
                  padding: EdgeInsets.only(right: 16),
                  child: IconButton(
                    icon: Icon(Icons.person, size: 35),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => MyProfile()),
                      );
                    },
                    tooltip: "Bilgilerinizi gösterir",
                  ),
                ),
              ],
            ),
          ],
        ),
        body: Center(
          child: Column(
            children: [
              const SizedBox(height: 30),
              Image.asset(
                'assets/logo.png',
                width: 230,
              ),
              const SizedBox(height: 10),
              const Text(
                "Bir El Uzat, Bir Fark Yarat!",
                style: TextStyle(
                  color: Colors.white,
                  fontFamily: 'Poppins',
                  fontStyle: FontStyle.italic,
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 60),
              Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                Column(children: [
                  CustomButton(
                    icon: Icons.help_outline,
                    text: "Yardım İste",
                    onPressed: () async {
                      if (canSendMessage()) {
                        getAllUsers();
                        sendMessageToNearestUser();
                        lastMessageSentTime =
                            DateTime.now(); // Update the timestamp
                      } else {
                        showWaitMessage();
                      }
                    },
                    // getAllUsers();
                    // sendMessageToNearestUser();
                    // // Navigator.push(
                    // //   context,
                    // //   MaterialPageRoute(builder: (context) => MyApp()),
                    // // );
                  ),
                ]),
                const SizedBox(width: 100),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CustomButton(
                      icon: Icons.volume_up_rounded,
                      // icon: Icons.speaker,
                      // icon: Icons.speaker_phone,
                      text: "  Alarm Sesi",
                      onPressed: () async {
                        playAudio();
                      },
                    ),
                  ],
                ),
              ]),
              const SizedBox(height: 50),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Column(children: [
                    CustomButton(
                      icon: Icons.groups,
                      text: "Yardım Talepleri",
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => HelpRequests()),
                        );
                      },
                    ),
                  ]),
                  const SizedBox(width: 100),
                  Column(children: [
                    CustomButton(
                      icon: Icons.location_on,
                      text: " Konum Aç",
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => MyLocation()),
                        );
                      },
                    ),
                  ]),
                ],
              ),
            ],
          ),
        ));
  }

  void getAllUsers() async {
    late List<Users> users = [];
    late Users currentUser;
    late Users nearestUser;

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

    currentUser = Users(
        fullName: (snap.data() as Map<String, dynamic>)["fullName"] ?? "",
        email: (snap.data() as Map<String, dynamic>)["email"] ?? "",
        password: (snap.data() as Map<String, dynamic>)["password"] ?? "",
        tel: (snap.data() as Map<String, dynamic>)["tel"] ?? "",
        adress: (snap.data() as Map<String, dynamic>)["adress"] ?? "",
        lat: (snap.data() as Map<String, dynamic>)["lat"] ?? 0,
        long: (snap.data() as Map<String, dynamic>)["long"] ?? 0);

    double nearestPath = 0;

    Map<double, Users> userDistances = {};

    for (var user in users) {
      if (user.email != currentUser.email) {
        double distanceInMeters = Geolocator.distanceBetween(
            currentUser.lat, currentUser.long, user.lat, user.long);

        userDistances[distanceInMeters] = user;
        print("${user.fullName} =>  $distanceInMeters");
        print("${user.fullName} => ${user.lat} ----  ${user.long}");
        print(
            "${currentUser.fullName} => ${currentUser.lat} ----  ${currentUser.long}");
        print('------------------');

        // if (nearestPath == 0 || distanceInMeters < nearestPath) {
        //   nearestPath = distanceInMeters;
        //   nearestUser = user;
        // }
      }
    }

    print('+++++++++++++++++++++');
    // print('En Yakın Yol  == $nearestPath');
    // print('En Yakin kişi => ${nearestUser.email}');

    final sortedUserDistances = userDistances.entries.toList()
      ..sort((a, b) => a.key.compareTo(b.key));

    if (sortedUserDistances.length >= 3) {
      for (int i = 0; i < 3; i++) {
        // Get the document reference of the nearest user based on their email
        QuerySnapshot querySnapshotWhere = await FirebaseFirestore.instance
            .collection('users')
            .where('email', isEqualTo: sortedUserDistances[i].value.email)
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
          'sender': (snap.data() as Map<String, dynamic>)["fullName"],
          'address': (snap.data() as Map<String, dynamic>)["adress"],
          'message': 'Acil yardıma ihtiyacı var. Lütfen yardım edin.',
          'date': DateTime.now()
        });

        print(
            '${i + 1}. En Yakin kişi  ==> ${sortedUserDistances[i].value.fullName}');
        print('${i + 1}. En Yakın Yol  ==> ${sortedUserDistances[i].key}');
        print('----------');
      }
    } else {
      print('Maalesef 3\'ten az kullanıcı var.');
    }

    setState(() {});
  }

  void sendMessageToNearestUser() async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Center(child: Text('Talebiniz alındı')),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(
                'OK',
                style:
                    TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        );
      },
    );
  }

  bool canSendMessage() {
    if (lastMessageSentTime == null) {
      return true;
    } else {
      Duration difference = DateTime.now().difference(lastMessageSentTime!);
      return difference.inMinutes >=
          10; // Check if at least 10 minutes have passed
    }
  }

  void showWaitMessage() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Center(child: Text('Beklemede')),
          content: Text(
              'Talebiniz beklemede, 10 dk sonra tekrar gönderebilirsiniz.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(
                'OK',
                style:
                    TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        );
      },
    );
  }

  void playAudio() async {
    double maxVolume = await VolumeWatcher.getMaxVolume;
    VolumeWatcher.setVolume(maxVolume); // Set the volume to maximum
    AudioPlayer player = AudioPlayer();
    await player.setAsset('assets/emergency-alarm-with-reverb-29431.mp3');
    await player.play();
  }

  void closeAlert() {
    Alert(
      context: context,
      title: "Çıkış",
      desc: "Hesabınızdan çıkmak istediğinizden emin misiniz?",
      buttons: [
        DialogButton(
          child: Text(
            "Evet",
            style: TextStyle(color: Colors.white, fontSize: 20),
          ),
          onPressed: () {
            _auth.signOut();
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => WelcomeScreen()),
            );
          },
          gradient: LinearGradient(colors: [
            Color.fromRGBO(124, 0, 0, 1),
            Color.fromRGBO(194, 2, 2, 1),
          ]),
        ),
        DialogButton(
          child: Text(
            "Hayır",
            style: TextStyle(color: Colors.white, fontSize: 20),
          ),
          onPressed: () => Navigator.pop(context),
          gradient: LinearGradient(colors: [
            Color.fromRGBO(2, 52, 158, 1),
            Color.fromRGBO(2, 29, 88, 1),
          ]),
        )
      ],
    ).show();
  }
}
