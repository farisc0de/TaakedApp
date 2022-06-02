import 'package:crowd_managment_app/home.dart';
import 'package:crowd_managment_app/login.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'show_alert_dialog.dart';

class RegisterScreen extends StatefulWidget {
  static const String screenRoute = "register_screen";

  const RegisterScreen({Key? key}) : super(key: key);

  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _auth = FirebaseAuth.instance;
  final fullNameTB = TextEditingController();
  final emailTB = TextEditingController();
  final passwordTB = TextEditingController();

  String? email;

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
            width: 375,
            height: 320,
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
                    controller: fullNameTB,
                    decoration: const InputDecoration(
                      hintText: 'Enter your full name',
                      filled: true,
                      fillColor: Colors.white,
                    ),
                    style: const TextStyle(color: Colors.black)),
                const SizedBox(
                  height: 15,
                ),
                TextFormField(
                    controller: emailTB,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(
                      hintText: 'Enter your email address',
                      filled: true,
                      fillColor: Colors.white,
                    ),
                    onChanged: (value) {
                      email = value;
                    },
                    style: const TextStyle(color: Colors.black)),
                const SizedBox(
                  height: 15,
                ),
                TextFormField(
                    controller: passwordTB,
                    decoration: const InputDecoration(
                      hintText: 'Enter your password',
                      filled: true,
                      fillColor: Colors.white,
                    ),
                    obscureText: true,
                    enableSuggestions: false,
                    autocorrect: false,
                    style: const TextStyle(color: Colors.black)),
                const SizedBox(
                  height: 10,
                ),
                ElevatedButton(
                  style: ButtonStyle(
                      shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                          RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18.0),
                              side: const BorderSide(color: Colors.brown))),
                      minimumSize:
                          MaterialStateProperty.all(const Size(212, 41))),
                  onPressed: () async {
                    try {
                      final newUser =
                          await _auth.createUserWithEmailAndPassword(
                              email: emailTB.text, password: passwordTB.text);

                      newUser.user?.updateDisplayName(fullNameTB.text);

                      Navigator.popAndPushNamed(
                          context, HomeScreen.screenRoute);
                    } on FirebaseAuthException catch (e) {
                      showAlertDialog(
                          "Failed",
                          "Account not created: ${e.message}",
                          context,
                          () =>
                              Navigator.of(context, rootNavigator: true).pop());
                    }
                  },
                  child: const Text("Register"),
                ),
                const SizedBox(
                  height: 5,
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
                    onPressed: () {
                      Navigator.popAndPushNamed(
                          context, LoginScreen.screenRoute);
                    },
                    child: const Text("Login to your account"))
              ],
            ),
          )
        ]),
      ),
    );
  }
}
