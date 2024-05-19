import 'package:miledrivers/components/MyDrawer.dart';
import 'package:miledrivers/pages/Home.dart';
import 'package:miledrivers/pages/Routing.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'dart:convert';
import 'package:http/http.dart';
import '../Components/Utils.dart';
import 'package:geocoding/geocoding.dart';

class MapPage extends StatefulWidget {
  final String id;
  final double? clat;
  final double? clon;

  const MapPage(
      {super.key, required this.id, required this.clat, required this.clon});

  @override
  State<StatefulWidget> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  String name = "";
  String address = "";
  String building = "";
  String customerID = "";
  double mylat = 0.0;
  double mylon = 0.0;
  double dlat = 0.0;
  double dlon = 0.0;
  String location = '';

  @override
  void initState() {
    getReport(widget.id, widget.clat, widget.clon);
    super.initState();
  }

  getReport(String id, double? clat, double? clon) async {
    try {
      final response = await get(
        Uri.parse("${getUrl()}reports/$id"),
      );
      var data = json.decode(response.body);
      print("map page $data parameters: $id, $clat, $clon");
      setState(() {
        name = data["Name"];
        address = data["Address"];
        building = data["BuildingName"];
        customerID = data["ID"];
        dlat = data["Latitude"];
        dlon = data["Longitude"];
        mylat = double.parse(data["MyLatitude"]);
        mylon = double.parse(data["MyLongitude"]);
      });
      print("$name, $dlat, $dlon, $mylat, $mylon");
      List<Placemark> dest = await placemarkFromCoordinates(dlat, dlon);
      List<Placemark> myloc = await placemarkFromCoordinates(
          double.parse(data["MyLatitude"]), double.parse(data["MyLongitude"]));

      print("locations: $dest, $myloc");

      setState(() {
        location =
            "${myloc[0].locality}, ${myloc[0].street}, ${myloc[0].name} \n - \n ${dest[0].locality}, ${dest[0].street}, ${dest[0].subLocality}";
      });

      print(location);
    } catch (e) {}
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "MapPage",
      home: Scaffold(
        drawer: const Drawer(child: MyDrawer()),
        body: Stack(children: <Widget>[
          // mylat != 0.0
          //     ? Routing(
          //         label: name,
          //         mylat: mylat,
          //         mylon: mylon,
          //         dlat: dlat,
          //         dlon: dlon,
          //         id: widget.id,
          //         customerID: customerID,
          //       )
          //     : const SizedBox(),
          Align(
            alignment: AlignmentDirectional.topCenter,
            child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
                child: Container(
                  padding: const EdgeInsets.fromLTRB(12, 5, 12, 5),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.7),
                    borderRadius: const BorderRadius.all(Radius.circular(5)),
                  ),
                  child: Text(
                    location,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 12, color: Colors.white),
                  ),
                )),
          ),
        ]),
      ),
    );
  }
}

class Report {
  final String type;
  final String name;
  final String address;
  final String landmark;
  final String city;
  final String date;
  final String street;
  Report(this.type, this.name, this.address, this.landmark, this.city,
      this.date, this.street);
}
