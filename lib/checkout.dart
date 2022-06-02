import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'api/notification_api.dart';

class CheckoutScreen extends StatefulWidget {
  static const String screenRoute = "checkout_screen";

  final String? userid;

  const CheckoutScreen({Key? key, this.userid})
      : super(key: key);

  @override
  _CheckoutScreenState createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {

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
              height: 145,
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
                  const Text("Are You Out Yet?",
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold)),
                  const SizedBox(
                    height: 20,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton(
                        style: ButtonStyle(
                            shape: MaterialStateProperty.all<
                                    RoundedRectangleBorder>(
                                RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(18.0),
                                    side:
                                        const BorderSide(color: Colors.brown))),
                            minimumSize:
                                MaterialStateProperty.all(const Size(106, 41))),
                        onPressed: () async {
                          await updateUser(widget.userid);

                          NotificationApi.cancelAll();

                          const SnackBar snackBar = SnackBar(backgroundColor: Colors.green, content: Text("Done, We hope u enjoyed ur stay"),);

                          ScaffoldMessenger.of(context)..removeCurrentSnackBar()..showSnackBar(snackBar);
                        },
                        child: const Text("Yes"),
                      ),
                      const SizedBox(
                        width: 5,
                      ),
                      ElevatedButton(
                        style: ButtonStyle(
                            shape: MaterialStateProperty.all<
                                    RoundedRectangleBorder>(
                                RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(18.0),
                                    side:
                                        const BorderSide(color: Colors.brown))),
                            minimumSize:
                                MaterialStateProperty.all(const Size(106, 41))),
                        onPressed: () {
                          const snackBar = SnackBar(backgroundColor: Colors.green, content: Text("OK, Enjoy shopping"),);

                          ScaffoldMessenger.of(context)..removeCurrentSnackBar()..showSnackBar(snackBar);
                        },
                        child: const Text("No"),
                      ),
                    ],
                  )
                ],
              ),
            ),
          ]),
        ));
  }
}

Future<void> updateUser(visitorID) {
  CollectionReference users = FirebaseFirestore.instance.collection('visitors');

  return users
      .doc(visitorID)
      .update({'leave_time': Timestamp.now()})
      .then((value) => '')
      .catchError((error) => '');
}