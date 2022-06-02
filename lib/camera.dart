import 'dart:convert';
import 'dart:developer';
import 'dart:math' as math;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crowd_managment_app/api/notification_api.dart';
import 'package:crowd_managment_app/show_alert_dialog.dart';
import 'package:flutter/material.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';

class CameraScreen extends StatefulWidget {
  const CameraScreen({Key? key}) : super(key: key);

  static const screenRoute = 'camera_screen';

  @override
  State<StatefulWidget> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  Barcode? result;
  QRViewController? controller;
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');

  math.Random random = math.Random();

  @override
  void initState() {
    super.initState();
  }

  FirebaseFirestore firestore = FirebaseFirestore.instance;

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
              const SizedBox(
                height: 10,
              ),
              Container(
                  padding: const EdgeInsets.all(8.0),
                  child: const Text('Crowd Management App'))
            ],
          )),
      body: Container(
        alignment: Alignment.center,
        child: Column(
          children: [
            Expanded(flex: 4, child: _buildQrView(context)),
          ],
        ),
      ),
    );
  }

  Widget _buildQrView(BuildContext context) {
    var scanArea = (MediaQuery
        .of(context)
        .size
        .width < 400 ||
        MediaQuery
            .of(context)
            .size
            .height < 400)
        ? 150.0
        : 300.0;

    return QRView(
      key: qrKey,
      onQRViewCreated: _onQRViewCreated,
      overlay: QrScannerOverlayShape(
          borderColor: Colors.brown,
          borderRadius: 10,
          borderLength: 30,
          borderWidth: 10,
          cutOutSize: scanArea),
      onPermissionSet: (ctrl, p) => _onPermissionSet(context, ctrl, p),
    );
  }

  void _onQRViewCreated(QRViewController controller) {
    setState(() {
      this.controller = controller;
    });
    controller.scannedDataStream.listen((scanData) async {
      var data = scanData.code;
      Map<String, dynamic> user = {};

      if (data != null) {
        user = jsonDecode(data);
      }

      int count = await getCount(firestore, user['placename']);

      if (scanData.code != result?.code) {
        if (count < int.parse(user['visitorsNumber'])) {
          showModalBottomSheet(
              context: context,
              shape: const RoundedRectangleBorder(
                  borderRadius:
                  BorderRadius.vertical(top: Radius.circular(30))),
              builder: (context) =>
                  Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text("Welcome to ${user['placename']}"),
                        const SizedBox(
                          height: 5,
                        ),
                        Text(
                            "You are Visitor number $count/${user['visitorsNumber']}"),
                        const SizedBox(
                          height: 10,
                        ),
                        ElevatedButton(
                            onPressed: () {
                              firestore.collection('visitors').add({
                                "placename": user['placename'],
                                "entery_time": Timestamp.now(),
                                "leave_time": '',
                                "linked_to": user['placename']
                                    .toString()
                                    .replaceAll(' ', '_')
                                    .toLowerCase()
                              }).then((value) async {
                                NotificationApi.showScheduledNotification(
                                    id: random.nextInt(500),
                                    scheduled: DateTime.now()
                                        .add(const Duration(minutes: 10)),
                                    title: 'Are you out yet?',
                                    body: 'Are you out yet?',
                                    payload: value.id);
                              }).catchError((err) =>
                                  showAlertDialog(
                                      "Error",
                                      err.toString(),
                                      context,
                                          () =>
                                          Navigator.of(context,
                                              rootNavigator: true)
                                              .pop()));

                              Navigator.of(context).pop();
                            },
                            child: const Text("OK"))
                      ],
                    ),
                  ));
        }
      }

      result = scanData;
    });
  }

  void _onPermissionSet(BuildContext context, QRViewController ctrl, bool p) {
    log('${DateTime.now().toIso8601String()}_onPermissionSet $p');
    if (!p) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('no Permission')),
      );
    }
  }

  @override
  void dispose() {
    super.dispose();
    controller?.dispose();
  }
}

String getSlug(String placeName) {
  return placeName.toLowerCase().replaceAll(" ", "_").toString();
}

Future<int> getCount(firestore, placename) async {
  int count = await firestore.collection('visitors').get().then((value) {
    int c = 0;

    for (var d in value.docs) {
      Timestamp entryTime = d.get("entery_time");
      if (d.get('linked_to') == getSlug(placename) &&
          entryTime.toDate().isSameDate(Timestamp.now().toDate())) {
        c = c + 1;
      }
    }

    return c;
  });

  return count + 1;
}

extension DateOnlyCompare on DateTime {
  bool isSameDate(DateTime other) {
    return year == other.year && month == other.month && day == other.day;
  }
}
