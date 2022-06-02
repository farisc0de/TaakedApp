import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crowd_managment_app/api/notification_api.dart';
import 'package:crowd_managment_app/camera.dart';
import 'package:crowd_managment_app/checkout.dart';
import 'package:crowd_managment_app/info.dart';
import 'package:crowd_managment_app/login.dart';
import 'package:crowd_managment_app/show_alert_dialog.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart' as url;

class HomeScreen extends StatefulWidget {
  static const String screenRoute = "home_screen";

  const HomeScreen({Key? key, User? user}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _auth = FirebaseAuth.instance;

  DateTime dateTime = DateTime.now();

  User? signedUser;

  String? place;
  String? subPlace;

  bool enableButton = false;

  String? role;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  TextEditingController searchTerm = TextEditingController();

  @override
  void initState() {
    super.initState();
    getCurrentUser();
    listenNotifications();
  }

  void listenNotifications() => NotificationApi.onNotifications.stream.listen(onClickNotification);

  void onClickNotification(String? payload) =>
      Navigator.of(context).push(MaterialPageRoute(
          builder: (context) => CheckoutScreen(
            userid: payload,
          )));

  void getCurrentUser() {
    final user = _auth.currentUser;

    if (user != null) {
      signedUser = user;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.brown[300],
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
                child: const Text('Crowd Management App')),
          ],
        ),
        actions: [
          PopupMenuButton<MenuItem>(
              onSelected: (value) {
                if (value == MenuItem.login) {
                  Navigator.pushNamed(context, LoginScreen.screenRoute);
                }

                if (value == MenuItem.logout) {
                  _auth.signOut();

                  setState(() {
                    signedUser = null;
                  });
                }

                if (value == MenuItem.about) {
                  showAboutDialog(
                      context: context,
                      applicationName: "Crowd Management App",
                      applicationVersion: "1.0",
                      children: [const Text("This is a capstone project")]);
                }
              },
              itemBuilder: (context) =>
                  getItem(signedUser, _firestore, context))
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(
                height: 10,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 350,
                    child: TextFormField(
                      key: const Key("searchForm"),
                      controller: searchTerm,
                      decoration: const InputDecoration(
                        icon: Icon(Icons.search),
                        border: OutlineInputBorder(),
                        hintText: 'Enter a search term',
                      ),
                      onFieldSubmitted: (searchTerm) async {
                        bool searchResult = await search(getSlug(searchTerm));
                        if (searchResult) {
                          place = getSlug(searchTerm);

                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => InfoScreen(
                                    place: place,
                                  )));
                        } else {
                          showAlertDialog(
                              "Place Not Found",
                              "Sorry, Place not found!",
                              context,
                                  () => Navigator.of(context, rootNavigator: true)
                                  .pop());
                        }
                      } ,
                    ),
                  ),
                ],
              ),
              const SizedBox(
                height: 10,
              ),
              Container(
                alignment: Alignment.center,
                child: Column(children: [
                  const SizedBox(
                    height: 10,
                  ),
                  Column(children: [
                    StreamBuilder(
                      stream: _firestore.collection('place_info').snapshots(),
                      builder:
                          (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                        return snapshot.hasData
                            ? Container(
                          key: Key("place"),
                                padding: const EdgeInsets.all(8.0),
                                child: GridView.builder(
                                  physics: const NeverScrollableScrollPhysics(),
                                  shrinkWrap: true,
                                  gridDelegate:
                                      const SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 2,
                                    crossAxisSpacing: 5.0,
                                    mainAxisSpacing: 5.0,
                                  ),
                                  itemBuilder:
                                      (BuildContext context, int index) {
                                    return GestureDetector(
                                      onTap: () async {
                                        place = snapshot.data?.docs[index].id;

                                        DateTime? newDate =
                                            await showDatePicker(
                                                context: context,
                                                initialDate: dateTime,
                                                firstDate: DateTime(
                                                    DateTime.now().year),
                                                lastDate: DateTime(
                                                    DateTime.now().year + 5));

                                        if (newDate == null) return;

                                        TimeOfDay? newTime =
                                            await showTimePicker(
                                          context: context,
                                          initialTime: TimeOfDay(
                                              hour: DateTime.now().hour,
                                              minute: DateTime.now().minute),
                                        );

                                        if (newTime == null) return;

                                        final newDateTime = DateTime(
                                            newDate.year,
                                            newDate.month,
                                            newDate.day,
                                            newTime.hour,
                                            newTime.minute);

                                        setState(() {
                                          dateTime = newDateTime;
                                        });

                                        setState(() {
                                          enableButton = true;
                                        });
                                      },
                                      child: Container(
                                          decoration: BoxDecoration(
                                              image: DecorationImage(
                                                colorFilter: ColorFilter.mode(
                                                    Colors.black
                                                        .withOpacity(0.5),
                                                    BlendMode.srcOver),
                                                image: NetworkImage(snapshot
                                                    .data?.docs[index]
                                                    .get('cover_image')),
                                                fit: BoxFit.cover,
                                              ),
                                              color: Colors.white,
                                              borderRadius:
                                                  const BorderRadius.all(
                                                      Radius.circular(10))),
                                          child: Column(
                                            mainAxisSize: MainAxisSize.max,
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              const Align(
                                                alignment: Alignment.topRight,
                                                child: Icon(Icons.arrow_forward_ios, color: Colors.white, size: 18,),
                                              ),
                                              Align(
                                                alignment: Alignment.bottomLeft,
                                                child: Text(
                                                  snapshot.data?.docs[index]
                                                      .get('place_name'),
                                                  style: const TextStyle(
                                                      fontSize: 18,
                                                      fontWeight: FontWeight.bold,
                                                      color: Colors.white),
                                                ),
                                              )
                                            ],
                                          )),
                                    );
                                  },
                                  itemCount: snapshot.data?.docs.length,
                                ),
                              )
                            : Container();
                      },
                    ),
                  ]),
                  showStatistics(enableButton),
                  Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          getLocation(place),
                          const SizedBox(
                            width: 3,
                          ),
                          ElevatedButton.icon(
                            style: ButtonStyle(
                                shape: MaterialStateProperty.all<
                                        RoundedRectangleBorder>(
                                    RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(18.0),
                                        side: const BorderSide(
                                            color: Colors.brown)))),
                            onPressed: () => Navigator.pushNamed(
                                context, CameraScreen.screenRoute),
                            icon: const Icon(
                              Icons.qr_code,
                            ),
                            label: const Text("SignIn to Location"),
                          )
                        ],
                      )
                    ],
                  ),
                  const SizedBox(
                    height: 15,
                  ),
                ]),
                // DropDown Selector
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
    NotificationApi.onNotifications.close();
  }

  Widget showStatistics(enableButton){
    if(enableButton){
      return Container(
          padding: const EdgeInsets.all(5.0),
          child: ElevatedButton.icon(
              style: ButtonStyle(
                  shape: MaterialStateProperty.all<
                      RoundedRectangleBorder>(
                      RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18.0),
                          side: const BorderSide(
                              color: Colors.brown)))),
              onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => InfoScreen(
                        place: place,
                      ))),
              icon: const Icon(Icons.bar_chart),
              label: const Text("Show Location Statistics")));
    } else {
      return Container(
          padding: const EdgeInsets.all(5.0),
          child: ElevatedButton.icon(
              style: ButtonStyle(
                  shape: MaterialStateProperty.all<
                      RoundedRectangleBorder>(
                      RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18.0),
                          side: const BorderSide(
                              color: Colors.brown)))),
              onPressed: null,
              icon: const Icon(Icons.bar_chart),
              label: const Text("Show Location Statistics")));
    }

  }

  DropdownMenuItem<String> buildMenuItem(String item) => DropdownMenuItem(
        value: item,
        child: Text(item),
      );
}

enum MenuItem { login, logout, about, contactUs }

FutureBuilder<DocumentSnapshot> getLocation(documentId) {
  CollectionReference users =
      FirebaseFirestore.instance.collection('place_info');

  return FutureBuilder<DocumentSnapshot>(
    future: users.doc(documentId).get(),
    builder: (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
      if (snapshot.hasError) {
        return ElevatedButton.icon(
          style: ButtonStyle(
              shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                  RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18.0),
                      side: const BorderSide(color: Colors.brown)))),
          onPressed: null,
          icon: const Icon(Icons.map),
          label: const Text("Get Directions"),
        );
      }

      if (snapshot.hasData && !snapshot.data!.exists) {
        return ElevatedButton.icon(
          style: ButtonStyle(
              shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                  RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18.0),
                      side: const BorderSide(color: Colors.brown)))),
          onPressed: null,
          icon: const Icon(Icons.map),
          label: const Text("Get Directions"),
        );
      }

      if (snapshot.connectionState == ConnectionState.done) {
        Map<String, dynamic> data =
            snapshot.data!.data() as Map<String, dynamic>;

        if (data['location'] != null) {
          return ElevatedButton.icon(
            style: ButtonStyle(
                shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                    RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18.0),
                        side: const BorderSide(color: Colors.brown)))),
            onPressed: () => url.launchUrl(
                Uri.parse("https://maps.google.com/?q=${data['location'].latitude.toString()},${data['location'].longitude.toString()}"),  mode: url.LaunchMode.externalApplication),
            icon: const Icon(Icons.map),
            label: const Text("Get Directions"),
          );
        } else {
          return ElevatedButton.icon(
            style: ButtonStyle(
                shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                    RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18.0),
                        side: const BorderSide(color: Colors.brown)))),
            onPressed: null,
            icon: const Icon(Icons.map),
            label: const Text("Get Directions"),
          );
        }
      }

      return const Text("loading");
    },
  );
}

List<PopupMenuItem<MenuItem>> getItem(
    User? user, FirebaseFirestore firestore, BuildContext context) {
  List<PopupMenuItem<MenuItem>> items = [];

  items.add(PopupMenuItem(
      value: MenuItem.about,
      child: SizedBox(
          width: 50,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: const [
              Icon(
                Icons.question_answer,
                color: Colors.brown,
              ),
              SizedBox(
                width: 5,
              ),
              Text("About")
            ],
          ))));

  if (user != null) {
    items.add(PopupMenuItem(
        value: MenuItem.logout,
        child: SizedBox(
            width: 50,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: const [
                Icon(
                  Icons.logout,
                  color: Colors.brown,
                ),
                SizedBox(
                  width: 5,
                ),
                Text("Logout")
              ],
            ))));
  } else {
    items.add(PopupMenuItem(
        value: MenuItem.login,
        child: SizedBox(
            width: 50,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: const [
                Icon(
                  Icons.login,
                  color: Colors.brown,
                ),
                SizedBox(
                  width: 5,
                ),
                Text("Login")
              ],
            ))));
  }

  return items;
}

Future<bool> search(placeName) {
  Future<bool> itemExist = FirebaseFirestore.instance
      .collection('place_info')
      .doc(placeName)
      .get()
      .then((value) {
    return value.exists;
  });

  return itemExist;
}

String getSlug(String placeName) {
  return placeName.toLowerCase().replaceAll(" ", "_").toString();
}
