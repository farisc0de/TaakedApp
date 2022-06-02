import 'package:flutter/material.dart';
import 'home.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.brown[300],
      body: Container(
        padding: const EdgeInsets.all(30.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Align(
                alignment: Alignment.topLeft,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  SizedBox(height: 25,),
                  Text("Welcome to,", textAlign: TextAlign.left, style: TextStyle(
                    fontSize: 32,
                    color: Colors.white
                  )),
                  Text("Taaked",  style: TextStyle(
                      fontSize: 64,
                      color: Colors.white,
                      fontWeight: FontWeight.bold
                  ))
                ],
              ),
            ),
            const SizedBox(height: 400,),
            Align(
              alignment: Alignment.bottomRight,
              child: GestureDetector(child: const Icon(Icons.arrow_circle_right_outlined, size: 64, color: Colors.white,), onTap: () => Navigator.popAndPushNamed(context, HomeScreen.screenRoute),),
            ),
          ],
        ),
      ),
    );
  }
}