import 'package:crowd_managment_app/camera.dart';
import 'package:flutter/material.dart';
import 'register.dart';
import 'show_alert_dialog.dart';
import 'package:firebase_auth/firebase_auth.dart';

class LoginScreen extends StatefulWidget {
  static const String screenRoute = "login_screen";

  const LoginScreen({Key? key, String? placename, String? visitors})
      : super(key: key);

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  TextEditingController email = TextEditingController();
  TextEditingController password = TextEditingController();

  final _auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            title: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Image.asset(
              'assets/images/logo.png',
              fit: BoxFit.contain,
              height: 32,
            ),
            Container(
                padding: const EdgeInsets.all(8.0),
                child: const Text('Crowd Management App'))
          ],
        )),
        body: Container(
          alignment: Alignment.center,
          child: Column(children: [
            const SizedBox(
              height: 50,
            ),
            Container(
              width: 366,
              height: 290,
              padding: const EdgeInsets.all(15.0),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: Colors.brown[300],
                border: Border.all(
                  color: const Color.fromRGBO(138, 129, 124, 1),
                  width: 1,
                ),
              ),
              child: Column(
                children: [
                  TextFormField(
                    keyboardType: TextInputType.emailAddress,
                    controller: email,
                    decoration: const InputDecoration(
                      hintText: 'Enter your Email',
                      filled: true,
                      fillColor: Colors.white,
                    ),
                    style: const TextStyle(color: Colors.black),
                  ),
                  const SizedBox(
                    height: 30,
                  ),
                  TextFormField(
                    controller: password,
                    decoration: const InputDecoration(
                      hintText: 'Enter your Password',
                      filled: true,
                      fillColor: Colors.white,
                    ),
                    obscureText: true,
                    enableSuggestions: false,
                    autocorrect: false,
                    style: const TextStyle(color: Colors.black),
                  ),
                  const SizedBox(
                    height: 30,
                  ),
                  ElevatedButton(
                    style: ButtonStyle(
                        shape:
                            MaterialStateProperty.all<RoundedRectangleBorder>(
                                RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(18.0),
                                    side:
                                        const BorderSide(color: Colors.brown))),
                        minimumSize:
                            MaterialStateProperty.all(const Size(212, 41))),
                    onPressed: () async {
                      try {
                        await _auth.signInWithEmailAndPassword(
                            email: email.text, password: password.text);
                        Navigator.pop(context);
                      } on FirebaseAuthException catch (e) {
                        showAlertDialog(
                            "Login failed",
                            "${e.message}",
                            context,
                            () => Navigator.of(context, rootNavigator: true)
                                .pop());
                      }
                    },
                    child: const Text("Login"),
                  ),
                  const SizedBox(
                    height: 5,
                  ),
                  ElevatedButton(
                      style: ButtonStyle(
                          shape: MaterialStateProperty.all<
                                  RoundedRectangleBorder>(
                              RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(18.0),
                                  side: const BorderSide(color: Colors.brown))),
                          minimumSize:
                              MaterialStateProperty.all(const Size(212, 41))),
                      onPressed: () {
                        Navigator.popAndPushNamed(
                            context, RegisterScreen.screenRoute);
                      },
                      child: const Text("Open an account"))
                ],
              ),
            ),
            const SizedBox(
              height: 200,
            ),
            ElevatedButton.icon(
              style: ButtonStyle(
                  shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                      RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18.0),
                          side: const BorderSide(color: Colors.brown))),
                  minimumSize: MaterialStateProperty.all(const Size(212, 41))),
              onPressed: () =>
                  Navigator.pushNamed(context, CameraScreen.screenRoute),
              icon: const Icon(Icons.qr_code),
              label: const Text("SignIn to Location"),
            )
          ]),
        ));
  }
}
