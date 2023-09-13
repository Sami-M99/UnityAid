import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:unityaid/models/myLocation.dart';
import 'package:unityaid/models/myProfile.dart';
import 'package:unityaid/service/userProvider.dart';
import 'models/helpRequests.dart';
import 'package:provider/provider.dart';
import 'service/firebaseOptions.dart';
import 'pages/loginScreen.dart';
import 'pages/mainScreen.dart';
import 'pages/signupScreen.dart';
import 'pages/welcomeScreen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  MyApp({Key? key});

  final _auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [ChangeNotifierProvider(create: (_) => UserProviders())],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        routes: {
          "/loginScreen": (context) => LoginScreen(),
          "/mainScreen": (context) => MainScreen(),
          "/signupScreen": (context) => SignUpScreen(),
          "/welcomeScreen": (context) => WelcomeScreen(),
          "/myLocation": (context) => MyLocation(),
          "/myProfile": (context) => MyProfile(),
          "/nearbyUser": (context) => MyApp(),
          "/helpRequests": (context) => HelpRequests(),
        },
        home: _auth.currentUser != null ? MainScreen() : WelcomeScreen(),
      ),
    );
  }
}
