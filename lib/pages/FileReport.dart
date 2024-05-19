import 'dart:async';
import 'dart:convert';

import 'package:miledrivers/Components/MyTextInput.dart';
import 'package:miledrivers/Components/SubmitButton.dart';
import 'package:miledrivers/components/MySelectInput.dart';
import 'package:miledrivers/components/TextOakar.dart';
import 'package:miledrivers/components/Utils.dart';
import 'package:miledrivers/components/mydrawer.dart';
import 'package:miledrivers/pages/complete.dart';
import 'package:miledrivers/pages/home.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart';
import 'package:intl/intl.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class FileReport extends StatefulWidget {
  final String clientId;
  const FileReport({super.key, required this.clientId});

  @override
  State<FileReport> createState() => _FileReportState();
}

class _FileReportState extends State<FileReport> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  String erid = '';
  String name = '';
  String address = '';
  String type = '';
  String building = '';
  String category = 'Abdominal Conditions';
  String action = '';
  String gender = '';
  String age = '';
  String time = "";
  String description = '';
  double dlon = 0.0;
  double dlat = 0.0;
  double mylat = 0.0;
  double mylon = 0.0;
  Map<String, dynamic> userData = {};
  String? value;
  var isLoading = null;
  bool successful = false;

  String error = '';

  final itemsList = [
    'Abdominal Conditions',
    'Cardiac Conditions',
    'Pulmonary Conditions',
    'Head Injuries',
    'Burns and Scalds',
    'Fractures',
    'Epilepsy',
    'Stroke',
    'Fainting',
    'Hypertension and Hypotension',
    'Hyperglycemia and Hypoglycemia',
    'Poisoning',
    'Bites'
  ];
  final storage = const FlutterSecureStorage();

  void _openDrawer() {
    _scaffoldKey.currentState?.openDrawer();
  }

  @override
  void initState() {
    getStoredValues();
    setState(() {
      time = DateTime.now().toIso8601String();
    });
    super.initState();
  }

  getStoredValues() async {
    String? id = await storage.read(key: "erid");
    print("file report $id");

    setState(() {
      erid = id.toString();
    });
    print("file report $erid");

    getReport(widget.clientId);
  }

  getReport(String clientId) async {
    try {
      setState(() {
        isLoading = LoadingAnimationWidget.staggeredDotsWave(
          color: Colors.orange,
          size: 100,
        );
      });
      final response = await get(
        Uri.parse("${getUrl()}reports/merged/$clientId"),
      );

      var data = json.decode(response.body);
      print("client details: $data");
      setState(() {
        userData = data;
        isLoading = null;
      });
    } catch (e) {
      setState(() {
        isLoading = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Row(
          children: [
            const Flexible(
              flex: 1,
              fit: FlexFit.tight,
              child: Text(
                "Patient Report",
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
        backgroundColor: Color.fromRGBO(0, 96, 177, 1),
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
                      const Padding(
                        padding: EdgeInsets.fromLTRB(0, 12, 0, 0),
                        child: Row(
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Patient Details",
                                  style: TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                SizedBox(
                                  height: 16,
                                ),
                              ],
                            ),
                          ],
                        ),
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
                                    userData.isNotEmpty ? userData["Name"] : "",
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
                                    Icons.gps_fixed,
                                    color: Colors.orange,
                                  ),
                                  const SizedBox(
                                    width: 6,
                                  ),
                                  Expanded(
                                    child: Text(
                                      "${userData.isNotEmpty ? userData["City"] : ""}, ${userData.isNotEmpty ? userData["Address"] : ""}, ${userData.isNotEmpty ? userData["Landmark"] : ""}, ${userData.isNotEmpty ? userData["BuildingName"] : ""}, ${userData.isNotEmpty ? userData["HouseNumber"] : ""},",
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
                                      "${userData.isNotEmpty ? userData["Age"] : ""}",
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
                          : SizedBox(),
                      const SizedBox(
                        height: 24,
                      ),
                      const Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          "File Report",
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
                              MySelectInput(
                                onSubmit: (value) {
                                  setState(() {
                                    category = value;
                                  });
                                },
                                list: itemsList,
                                value: category,
                                label: 'Select Emergency Category',
                              ),
                              MyTextInput(
                                title: 'Action Taken',
                                lines: 2,
                                value: '',
                                type: TextInputType.text,
                                onSubmit: (value) {
                                  setState(() {
                                    action = value;
                                  });
                                },
                              ),
                              MyTextInput(
                                title: 'Description',
                                lines: 5,
                                value: '',
                                type: TextInputType.multiline,
                                onSubmit: (value) {
                                  setState(() {
                                    description = value;
                                  });
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                      TextOakar(label: error, issuccessful: successful),
                      const SizedBox(
                        height: 24,
                      ),
                      SubmitButton(
                        label: "Submit Report",
                        onButtonPressed: () async {
                          setState(() {
                            isLoading =
                                LoadingAnimationWidget.staggeredDotsWave(
                              color: Colors.orange,
                              size: 100,
                            );
                          });

                          var res = await updateReport(
                            widget.clientId,
                            erid,
                            action,
                            description,
                            time,
                            category,
                          );
                          setState(() {
                            isLoading = null;
                            if (res.error == null) {
                              successful = true;
                              error = res.success;
                            } else {
                              successful = false;
                              error = res.error;
                            }
                          });
                          if (res.error == null) {
                            Timer(const Duration(seconds: 2), () {
                              Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                      builder: (_) => const Home()));
                            });
                          }
                        },
                      ),
                      const SizedBox(
                        height: 24,
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
    );
  }

  DateTime parsePostgresTimestamp(String timestamp) {
    return DateTime.parse(timestamp)
        .toLocal(); // Parse timestamp and convert to local time
  }
}

Future<Message> updateReport(
  String id,
  String erid,
  String action,
  String description,
  String time,
  String category,
) async {
  print("FILE REPORT: $id, $erid, $action, $description, $time, $category");
  if (action == "" || description == "" || time == "") {
    return Message(
      token: null,
      success: null,
      error: "Fill all fields",
    );
  }

  final response = await put(
    Uri.parse("${getUrl()}reports/${id}"),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
    },
    body: jsonEncode(<String, String>{
      'Action': action,
      'ER_ID': erid,
      'Description': description,
      'Time': time,
      'Status': 'Resolved',
      'Category': category
    }),
  );

  if (response.statusCode == 200 || response.statusCode == 203) {
    return Message.fromJson(jsonDecode(response.body));
  } else {
    return Message(
      token: null,
      success: null,
      error: "Connection to server failed!",
    );
  }
}

class Message {
  var token;
  var success;
  var error;

  Message({
    required this.token,
    required this.success,
    required this.error,
  });

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      token: json['token'],
      success: json['success'],
      error: json['error'],
    );
  }
}
