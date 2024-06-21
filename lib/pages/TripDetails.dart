import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart';
import 'package:intl/intl.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:miledrivers/components/Utils.dart';
import 'package:miledrivers/components/mydrawer.dart';

class TripDetails extends StatefulWidget {
  final String tripid;
  const TripDetails({super.key, required this.tripid});

  @override
  State<TripDetails> createState() => _TripDetailsState();
}

class _TripDetailsState extends State<TripDetails> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  String driverid = '';
  String name = '';
  String destination = '';
  String type = '';
  String building = '';
  String category = '';
  String gender = '';
  String description = '';
  Map<String, dynamic> userData = {};
  final storage = const FlutterSecureStorage();
  var isLoading;

  void _openDrawer() {
    _scaffoldKey.currentState?.openDrawer();
  }

  @override
  void initState() {
    getStoredValues();
    super.initState();
  }

  Future<void> getStoredValues() async {
    String id = await storage.read(key: "driverid").toString();

    setState(() {
      driverid = id;
    });

    getReport(widget.tripid);
  }

  getReport(String tripid) async {
    try {
      setState(() {
        isLoading = LoadingAnimationWidget.staggeredDotsWave(
            color: Colors.white, size: 64);
      });
      final response = await get(
        Uri.parse("${getUrl()}trips/$tripid"),
      );

      var data = json.decode(response.body);
      setState(() {
        userData = data;
        isLoading = null;
      });
      setState(() {
        name = data["ClientName"];
        destination = "${data["DestLatitude"]}, ${data["DestLongitude"]}";
        type = data["TripPrice"];
        building = data["ClientName"];
        category = data["CabCategory"];
        gender = data["ClientGender"];
        description = data["Description"];
      });
    } catch (e) {
      setState(() {
        isLoading = null;
      });
    }
  }

  DateTime parsePostgresTimestamp(String timestamp) {
    return DateTime.parse(timestamp)
        .toLocal(); // Parse timestamp and convert to local time
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          title: const Text(
            "Trip Details",
            style: TextStyle(color: Colors.black87),
          ),
          backgroundColor: Colors.amber,
          iconTheme: const IconThemeData(color: Colors.black),
          leading: IconButton(
            icon: const Icon(Icons.menu),
            onPressed: _openDrawer,
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ],
        ),
        drawer: const MyDrawer(),
        body: Stack(
          children: [
            Container(
              width: MediaQuery.of(context).size.width,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: const BoxDecoration(color: Colors.white),
              child: SafeArea(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      const SizedBox(height: 16),
                      Card(
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                "Client Information",
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                              ),
                              const Divider(color: Colors.black87),
                              Row(
                                children: [
                                  const Icon(
                                    Icons.person,
                                    color: Colors.black87,
                                  ),
                                  const SizedBox(width: 10),
                                  Text(
                                    userData.isNotEmpty
                                        ? userData["ClientName"]
                                        : "",
                                    style: const TextStyle(
                                      fontSize: 18,
                                      color: Colors.black87,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),
                              Row(
                                children: [
                                  const Icon(
                                    Icons.phone,
                                    color: Colors.black87,
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Text(
                                      userData.isNotEmpty
                                          ? userData["ClientPhone"]
                                          : "",
                                      style: const TextStyle(
                                        fontSize: 18,
                                        color: Colors.black87,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      userData.isNotEmpty
                          ? Card(
                              elevation: 4,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      "Location Information",
                                      style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black87,
                                      ),
                                    ),
                                    const Divider(color: Colors.black87),
                                    Row(
                                      children: [
                                        const Icon(
                                          Icons.place,
                                          color: Colors.black87,
                                        ),
                                        const SizedBox(width: 10),
                                        Text(
                                          userData.isNotEmpty
                                              ? userData["ClientLocation"]
                                              : "",
                                          style: const TextStyle(
                                            fontSize: 18,
                                            color: Colors.black87,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 10),
                                    Row(
                                      children: [
                                        const Icon(
                                          Icons.place_outlined,
                                          color: Colors.black87,
                                        ),
                                        const SizedBox(width: 10),
                                        Expanded(
                                          child: Text(
                                            userData.isNotEmpty
                                                ? userData["ClientDestination"]
                                                : "",
                                            style: const TextStyle(
                                              fontSize: 18,
                                              color: Colors.black87,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            )
                          : const SizedBox(),
                      const SizedBox(height: 16),
                      Card(
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                "Trip Information",
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                              ),
                              const Divider(color: Colors.black87),
                              Row(
                                children: [
                                  const Icon(
                                    Icons.price_change,
                                    color: Colors.black87,
                                  ),
                                  const SizedBox(width: 10),
                                  Text(
                                    userData.isNotEmpty
                                        ? "${userData["TripPrice"]}/-"
                                        : "",
                                    style: const TextStyle(
                                      fontSize: 18,
                                      color: Colors.black87,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),
                              Row(
                                children: [
                                  const Icon(
                                    Icons.calendar_month,
                                    color: Colors.black87,
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Text(
                                      userData.isNotEmpty
                                          ? "${DateFormat('EEEE, MMMM d, y').format(parsePostgresTimestamp(userData["createdAt"]))} ${DateFormat('HH:mm').format(parsePostgresTimestamp(userData["createdAt"]))}"
                                          : "",
                                      style: const TextStyle(
                                        fontSize: 18,
                                        color: Colors.black87,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            if (isLoading != null)
              Center(
                child: isLoading,
              ),
          ],
        ),
      ),
    );
  }
}
