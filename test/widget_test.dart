import 'package:crowd_managment_app/home.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import './mock.dart';

void main() async {
  TestWidgetsFlutterBinding.ensureInitialized();
  setupFirebaseAuthMocks();

  var testCount = 0;

  setUpAll(() async {
    final app = await Firebase.initializeApp(
      name: '$testCount',
      options: const FirebaseOptions(
        apiKey: '',
        appId: '',
        messagingSenderId: '',
        projectId: '',
      ),
    );
  });

  testWidgets('Home Page Test', (WidgetTester tester) async {
    final instance = FakeFirebaseFirestore();
    await instance.collection('place_info').add({
      'place_name': 'Jury Mall',
      'cover_image': 'https://binjubair.com/img/projects/large/img_004_01.jpg',
      'location': ''
    });

    Widget testWidget =  const MediaQuery(
        data: MediaQueryData(),
        child: MaterialApp(home: HomeScreen())
    );

    await tester.pumpWidget(testWidget);

    expect(find.byKey(const Key("searchForm")), findsWidgets);

    expect(find.text("Jury Mall"), findsWidgets);

    expect(find.text('Get Directions'), findsWidgets);
  });
}
