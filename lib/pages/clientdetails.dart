import 'dart:convert';

import 'package:ambulexdesign/components/Utils.dart';
import 'package:ambulexdesign/components/mydrawer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart';
import 'package:intl/intl.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class ClientDetails extends StatefulWidget {
  final String clientId;
  const ClientDetails({super.key, required this.clientId});

  @override
  State<ClientDetails> createState() => _ClientDetailsState();
}

class _ClientDetailsState extends State<ClientDetails> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  String erid = '';
  String name = '';
  String address = '';
  String type = '';
  String building = '';
  String category = '';
  String action = '';
  String gender = '';
  String age = '';
  String description = '';
  double dlon = 0.0;
  double dlat = 0.0;
  double mylat = 0.0;
  double mylon = 0.0;
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
    String id = await storage.read(key: "erid").toString();

    setState(() {
      erid = id;
    });

    getReport(widget.clientId);
  }

  getReport(String clientId) async {
    try {
      setState(() {
        isLoading = LoadingAnimationWidget.staggeredDotsWave(
            color: Colors.orange, size: 64);
      });
      final response = await get(
        Uri.parse("${getUrl()}reports/merged/$clientId"),
      );

      var data = json.decode(response.body);
      setState(() {
        userData = data;
        isLoading = null;
      });
      setState(() {
        name = data["Name"];
        address = data["Address"];
        type = data["Type"];
        building = data["BuildingName"];
        category = data["Category"];
        action = data["Action"];
        gender = data["Gender"];
        age = data["Age"];
        description = data["Description"];
        dlat = double.parse(data["DLatitude"]);
        dlon = double.parse(data["DLongitude"]);
        mylat = double.parse(data["MyLatitude"]);
        mylon = double.parse(data["MyLongitude"]);
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
          title: Row(
            children: [
              const Flexible(
                flex: 1,
                fit: FlexFit.tight,
                child: Text(
                  "Patient Details",
                  style: TextStyle(color: Colors.white),
                ),
              ),
              GestureDetector(
                onTap: () {
                  Navigator.pop(context);
                },
                child: const Icon(Icons.arrow_back),
              )
            ],
          ),
          backgroundColor: const Color.fromRGBO(0, 96, 177, 1),
          iconTheme: const IconThemeData(color: Colors.white),
        ),
        drawer: const MyDrawer(),
        body: Stack(
          children: [
            Container(
              width: MediaQuery.of(context).size.width,
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
              decoration: const BoxDecoration(
                  gradient: LinearGradient(
                colors: [
                  Color.fromRGBO(0, 96, 177, 1),
                  Color.fromRGBO(0, 96, 177, 1)
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              )),
              child: SizedBox(
                height: MediaQuery.of(context).size.height,
                child: SafeArea(
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        const SizedBox(
                          height: 16,
                        ),
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.blue.withOpacity(0.4),
                            borderRadius: BorderRadius.circular(15),
                            border: Border.all(
                              color: Colors.blue,
                              width: 6,
                            ),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
                            child: Column(
                              children: [
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.person,
                                      color: Colors.orange,
                                    ),
                                    const SizedBox(
                                      width: 6,
                                    ),
                                    Text(
                                      userData.isNotEmpty
                                          ? userData["Name"]
                                          : "",
                                      style: const TextStyle(
                                        fontSize: 20,
                                        color: Colors.white,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(
                                  height: 6,
                                ),
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.phone,
                                      color: Colors.orange,
                                    ),
                                    const SizedBox(
                                      width: 6,
                                    ),
                                    Expanded(
                                      child: Text(
                                        "${userData.isNotEmpty ? userData["Phone"] : ""}",
                                        softWrap: true,
                                        style: const TextStyle(
                                          fontSize: 18,
                                          color: Colors.white70,
                                          fontWeight: FontWeight.w400,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.email,
                                      color: Colors.orange,
                                    ),
                                    const SizedBox(
                                      width: 6,
                                    ),
                                    Expanded(
                                      child: Text(
                                        "${userData.isNotEmpty ? userData["Email"] : ""}",
                                        softWrap: true,
                                        style: const TextStyle(
                                          fontSize: 18,
                                          color: Colors.white70,
                                          fontWeight: FontWeight.w400,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                Row(
                                  children: [
                                    Icon(
                                      userData.isNotEmpty &&
                                              userData["Gender"] == "Female"
                                          ? Icons.female
                                          : Icons.male,
                                      color: Colors.orange,
                                    ),
                                    const SizedBox(
                                      width: 6,
                                    ),
                                    Expanded(
                                      child: Text(
                                        "Age: ${userData.isNotEmpty ? userData["Age"] : ""}",
                                        softWrap: true,
                                        style: const TextStyle(
                                          fontSize: 18,
                                          color: Colors.white70,
                                          fontWeight: FontWeight.w400,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(
                          height: 16,
                        ),
                        userData.isNotEmpty
                            ? Container(
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  color: Colors.blue.withOpacity(0.4),
                                  borderRadius: BorderRadius.circular(15),
                                  border: Border.all(
                                    color: Colors.blue,
                                    width: 6,
                                  ),
                                ),
                                child: Padding(
                                  padding:
                                      const EdgeInsets.fromLTRB(12, 12, 12, 12),
                                  child: Row(
                                    children: [
                                      Material(
                                        color: userData["Type"] == "GBV"
                                            ? Colors.orange
                                            : Colors.red,
                                        child: Padding(
                                          padding: const EdgeInsets.all(12),
                                          child: Text(
                                            userData.isNotEmpty
                                                ? userData["Type"]
                                                : "",
                                            style: const TextStyle(
                                              fontSize: 24,
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(
                                        width: 12,
                                      ),
                                      Column(
                                        children: [
                                          Text(
                                            "${DateFormat('EEEE, MMMM d, y').format(parsePostgresTimestamp(userData["createdAt"]))} \n${DateFormat('HH:mm').format(parsePostgresTimestamp(userData["createdAt"]))}",
                                            style: const TextStyle(
                                                color: Colors.white70,
                                                fontSize: 18,
                                                fontWeight: FontWeight.w400),
                                          )
                                        ],
                                      )
                                    ],
                                  ),
                                ),
                              )
                            : const SizedBox(),
                        const SizedBox(
                          height: 16,
                        ),
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.blue.withOpacity(0.4),
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
                            child: Column(
                              children: [
                                const Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Icon(
                                      Icons.place,
                                      color: Colors.orange,
                                    ),
                                    Text(
                                      "Client Location",
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    Text(""),
                                  ],
                                ),
                                const Divider(),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    const Icon(
                                      Icons.location_city,
                                      color: Colors.orange,
                                    ),
                                    Text(
                                      ' City: $address',
                                      style: const TextStyle(
                                          fontSize: 16,
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    const Text(""),
                                  ],
                                ),
                                const Divider(),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    const Icon(
                                      Icons.house,
                                      color: Colors.orange,
                                    ),
                                    Text(
                                      ' Building name: $building',
                                      style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    const Text(""),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(
                          height: 16,
                        ),
                        const Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            "EMT Report",
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 22,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                        const SizedBox(
                          height: 16,
                        ),
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.blue.withOpacity(0.4),
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
                            child: Column(
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    const Icon(
                                      Icons.category,
                                      color: Colors.orange,
                                    ),
                                    const SizedBox(
                                      width: 4,
                                    ),
                                    Expanded(
                                      child: Text(
                                        ' Category: $category',
                                        softWrap: true,
                                        style: const TextStyle(
                                            fontSize: 16,
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                    const Text(""),
                                  ],
                                ),
                                const Divider(),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    const Icon(
                                      Icons.comment,
                                      color: Colors.orange,
                                    ),
                                    const SizedBox(
                                      width: 4,
                                    ),
                                    Expanded(
                                      child: Text(
                                        "Description: $description",
                                        softWrap: true,
                                        style: const TextStyle(
                                            fontSize: 16,
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                    const Text(""),
                                  ],
                                ),
                                const Divider(),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    const Icon(
                                      Icons.line_axis,
                                      color: Colors.orange,
                                    ),
                                    const SizedBox(
                                      width: 4,
                                    ),
                                    Expanded(
                                      child: Text(
                                        "Action: $action",
                                        softWrap: true,
                                        style: const TextStyle(
                                            fontSize: 16,
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                    const Text(""),
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
            ),
            Center(
              child: isLoading,
            )
          ],
        ),
      ),
    );
  }
}
