import 'package:charts_flutter/flutter.dart' as charts;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart' as url;

class InfoScreen extends StatefulWidget {
  static const String screenRoute = "info_screen";

  final String? place;

  const InfoScreen({Key? key, this.place}) : super(key: key);

  @override
  State<InfoScreen> createState() => _InfoScreenState();
}

class _InfoScreenState extends State<InfoScreen> {
  String? place;
  String? subplace;

  List<int> leaveTime = [];
  List<int> subLeaveTime = [];

  List<Visitors> placeData = [];
  List<Visitors> subplaceData = [];

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    place = widget.place;
  }

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
      body: SingleChildScrollView(
        child: Container(
          alignment: Alignment.center,
          child: Column(
            children: [
              const SizedBox(
                height: 15,
              ),
              createChart(),
              const SizedBox(
                height: 30,
              ),
              getLocation(place)
            ],
          ),
        ),
      ),
    );
  }

  Widget placeChart() {
    List<charts.Series<Visitors, String>> _seriesPieData = [];
    List<Visitors>? mydata;

    _generateData(mydata) {
      _seriesPieData = [];
      _seriesPieData.add(
        charts.Series(
          domainFn: (Visitors visitors, _) => visitors.day,
          measureFn: (Visitors visitors, _) => visitors.count,
          colorFn: (Visitors visitors, __) =>
              charts.Color.fromHex(code: visitors.color),
          labelAccessorFn: (Visitors visitors, _) =>
          '${visitors.count.toString()} 🧔',
          id: 'Visitors',
          data: mydata,
        ),
      );
    }

    Widget _buildChart(BuildContext context, List<Visitors>? data) {
      mydata = data;
      _generateData(mydata);
      return Column(
        children: [
          SizedBox(
            height: 250,
            width: 350,
            child: charts.BarChart(_seriesPieData, animate: true, barRendererDecorator: charts.BarLabelDecorator<String>(),
                domainAxis: const charts.OrdinalAxisSpec()),
          ),
          const SizedBox(
            height: 5,
          ),
          getSuggestedTime(leaveTime)
        ],
      );
    }

    Widget _buildBody(BuildContext context) {
      return StreamBuilder<QuerySnapshot>(
        stream: _firestore.collection('visitors').snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          List<QueryDocumentSnapshot> list = snapshot.data!.docs;

          List<Visitors> v = [];

          List<String> days = [];
          List<String> addedDays = [];

          for (var l in list) {
            String pn = l.get('linked_to');

            if (pn == place) {
              Timestamp time = l.get('entery_time');
              Timestamp? leave;

              days.add(DateFormat('EEE').format(time.toDate()));

              if(l.get('leave_time') != ''){
                leave = l.get('leave_time');
              }

              if(leave != null){
                leaveTime.add(leave.microsecondsSinceEpoch);
              }
            }
          }

          for (var d in days) {
            if (!addedDays.contains(d)) {
              int numberOfVisitors = countOccurrences(days, d);
              String color = '';

              if (numberOfVisitors == 400) {
                color = '#c0392b';
              } else if (numberOfVisitors >= 370) {
                color = '#d35400';
              } else if (numberOfVisitors >= 250) {
                color = '#f39c12';
              } else if (numberOfVisitors >= 125) {
                color = '#27ae60';
              } else {
                color = '#27ae60';
              }

              v.add(Visitors(d, numberOfVisitors, color));
            }
            addedDays.add(d);
          }

          if(v.isEmpty){
            return const Text("Data Not Available!", style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 24,
              color: Colors.red,
            ),);
          } else {
            return _buildChart(context, v);
          }
        },
      );
    }

    return Container(
      child: _buildBody(context),
    );
  }

  Widget subPlaceChart() {
    List<charts.Series<Visitors, String>> _seriesPieData = [];
    List<Visitors>? mydata;

    _generateData(mydata) {
      _seriesPieData = [];
      _seriesPieData.add(
        charts.Series(
          domainFn: (Visitors visitors, _) => visitors.day,
          measureFn: (Visitors visitors, _) => visitors.count,
          colorFn: (Visitors visitors, _) =>
              charts.Color.fromHex(code: visitors.color),
          labelAccessorFn: (Visitors visitors, _) =>
          '${visitors.count.toString()} 🧔',
          id: 'Visitors',
          data: mydata,
        ),
      );
    }

    Widget _buildChart(BuildContext context, List<Visitors>? visitors) {
      mydata = visitors;
      _generateData(mydata);
      return Column(
        children: [
          SizedBox(
            height: 250,
            width: 350,
            child: charts.BarChart(_seriesPieData, animate: true, barRendererDecorator: charts.BarLabelDecorator<String>(),
                domainAxis: const charts.OrdinalAxisSpec()),
          ),
          const SizedBox(
            height: 5,
          ),
          getSuggestedTime(subLeaveTime)
        ],
      );
    }

    Widget _buildBody(BuildContext context) {
      return StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('visitors').snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          List<QueryDocumentSnapshot> list = snapshot.data!.docs;

          List<Visitors> v = [];

          List<String> days = [];
          List<String> addedDays = [];

          for (var l in list) {
            String pn = l.get('linked_to');

            if (pn == subplace) {
              Timestamp time = l.get('entery_time');
              days.add(DateFormat('EEE').format(time.toDate()));

              Timestamp? subleave;

              if(l.get('leave_time') != ''){
                subleave = l.get('leave_time');
              }

              if(subleave != null){
                subLeaveTime.add(subleave.microsecondsSinceEpoch);
              }
            }
          }

          for (var d in days) {
            if (!addedDays.contains(d)) {
              int numberOfVisitors = countOccurrences(days, d);
              String color = '';

              if (numberOfVisitors == 500) {
                color = '#c0392b';
              } else if (numberOfVisitors >= 370) {
                color = '#d35400';
              } else if (numberOfVisitors >= 250) {
                color = '#f39c12';
              } else if (numberOfVisitors >= 125) {
                color = '#27ae60';
              } else {
                color = '#27ae60';
              }

              v.add(Visitors(d, numberOfVisitors, color));
            }
            addedDays.add(d);
          }

          if(v.isEmpty){
            return const Text("Data Not Available!", style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 24,
              color: Colors.red,
            ),);
          } else {
            return _buildChart(context, v);
          }
        },
      );
    }

    return Container(
      child: _buildBody(context),
    );
  }

  Widget createChart(){
    CollectionReference places =
    FirebaseFirestore.instance.collection('place_info');

    return FutureBuilder<DocumentSnapshot>(
      future: places.doc(place).get(),
      builder: (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
        if (snapshot.hasError) {
          return Container();
        }

        if (snapshot.hasData && !snapshot.data!.exists) {
          return const Text("No Data Available!", style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 24,
            color: Colors.red,
          ),);
        }

        if (snapshot.connectionState == ConnectionState.done) {
          Map<String, dynamic> data =
          snapshot.data!.data() as Map<String, dynamic>;

          if(data['linked_to'] != null){

            place = data['linked_to'];

            subplace = getSlug(data['place_name']);

            return Column(
              children: [
                placeChart(),
                const SizedBox(height: 10,),
                subPlaceChart()
              ],
            );
          } else {
            return Column(
              children: [
                const SizedBox(height: 10,),
                placeChart()
              ],
            );
          }
        }

        return Container();
      },
    );
  }

}

class Visitors {
  String day;
  int count;
  String color;

  Visitors(this.day, this.count, this.color);
}

FutureBuilder<DocumentSnapshot> getLocation(documentId) {
  CollectionReference places =
      FirebaseFirestore.instance.collection('place_info');

  return FutureBuilder<DocumentSnapshot>(
    future: places.doc(documentId).get(),
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
        return ElevatedButton.icon(
          style: ButtonStyle(
              shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                  RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18.0),
                      side: const BorderSide(color: Colors.brown)))),
          onPressed: () => url.launchUrl(Uri.parse("https://maps.google.com/?q=${data['location'].latitude.toString()},${data['location'].longitude.toString()}"), mode: url.LaunchMode.externalApplication),
          icon: const Icon(Icons.map),
          label: const Text("Get Directions"),
        );
      }

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
    },
  );
}

int countOccurrences(List<String>? list, String element) {
  if (list == null || list.isEmpty) {
    return 0;
  }

  var foundElements = list.where((e) => e == element);
  return foundElements.length;
}

Widget getSuggestedTime(List<int> leave) {
  if (leave.isNotEmpty) {
    return Text(
        "Suggested Time: ${DateFormat('hh:mm a').format(DateTime.fromMicrosecondsSinceEpoch(leave.average.toInt()))}");
  } else {
    return Container();
  }
}

String getSlug(String placeName){
  return placeName.toLowerCase().replaceAll(" ", "_").toString();
}

