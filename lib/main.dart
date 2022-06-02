import 'package:crowd_managment_app/api/notification_api.dart';
import 'package:crowd_managment_app/camera.dart';
import 'package:crowd_managment_app/checkout.dart';
import 'package:crowd_managment_app/info.dart';
import 'package:crowd_managment_app/login.dart';
import 'package:crowd_managment_app/home.dart';
import 'package:crowd_managment_app/register.dart';
import 'package:crowd_managment_app/splash.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await NotificationApi.init(initScheduled: true);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Crowd Management App',
      theme: ThemeData(
        primarySwatch: Colors.brown,
      ),
      home: const SplashScreen(),
      routes: {
        HomeScreen.screenRoute: (context) =>  const HomeScreen(),
        LoginScreen.screenRoute: (context) => const LoginScreen(),
        RegisterScreen.screenRoute: (context) => const RegisterScreen(),
        CameraScreen.screenRoute: (context) => const CameraScreen(),
        InfoScreen.screenRoute: (context) => const InfoScreen(),
        CheckoutScreen.screenRoute: (context) => const CheckoutScreen(),
      },
    );
  }
}
