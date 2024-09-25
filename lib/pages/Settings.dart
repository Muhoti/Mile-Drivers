// ignore_for_file: file_names, library_private_types_in_public_api, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:mile_driver/components/MyTextInput.dart';
import 'package:mile_driver/components/SubmitButton.dart';
import 'package:mile_driver/components/TextOakar.dart';
import 'package:mile_driver/components/Utils.dart';
import 'package:mile_driver/components/mydrawer.dart';
import 'package:mile_driver/pages/Login.dart';

class Settings extends StatefulWidget {
  const Settings({super.key});

  @override
  State<StatefulWidget> createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  Color mpurple = const Color.fromRGBO(90, 66, 92, 1);
  String date = '';
  final storage = const FlutterSecureStorage();
  bool checkedin = false;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();
  var userDetails;
  String oldPass = "";
  String nePass = "";
  String cPass = "";
  String error = '';
  var isLoading;
  bool successful = false;

  @override
  initState() {
    super.initState();
    getToken();
  }

  getToken() async {
    var token = await storage.read(key: "mdjwt");
    var decoded = parseJwt(token.toString());
    if (decoded["error"] == "Invalid token") {
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (_) => const Login()));
    } else {
      setState(() {
        userDetails = decoded;
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
                  "Settings",
                  style: TextStyle(color: Colors.black87),
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
          backgroundColor: Colors.amber,
          iconTheme: const IconThemeData(color: Colors.black87),
        ),
        drawer: const MyDrawer(),
        body: Container(
          width: MediaQuery.of(context).size.width,
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
          decoration: const BoxDecoration(color: Colors.white54),
          child: Stack(children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(0, 0, 0, 24),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Padding(
                      padding: EdgeInsets.fromLTRB(0, 10, 16, 10),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          "User Details",
                          style: TextStyle(
                              fontSize: 24,
                              color: Colors.amber,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(0, 0, 16, 10),
                      child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            "Name: ${userDetails != null ? userDetails["Name"] : ""}",
                            style: const TextStyle(
                                color: Colors.black87, fontSize: 16),
                          )),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(0, 0, 16, 10),
                      child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            "Phone: ${userDetails != null ? userDetails["Phone"] : ""}",
                            style: const TextStyle(
                                color: Colors.black87, fontSize: 16),
                          )),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(0, 0, 16, 10),
                      child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            "Email: ${userDetails != null ? userDetails["Email"] : ""}",
                            style: const TextStyle(
                                color: Colors.black87, fontSize: 16),
                          )),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(0, 0, 16, 10),
                      child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            "VehicleType: ${userDetails != null ? userDetails["VehicleType"] : ""}",
                            style: const TextStyle(
                                color: Colors.black87, fontSize: 16),
                          )),
                    ),
                    const SizedBox(
                      height: 16,
                    ),
                    const Padding(
                      padding: EdgeInsets.fromLTRB(0, 0, 16, 0),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          "Change Password",
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.amber,
                          ),
                        ),
                      ),
                    ),
                    MyTextInput(
                      title: "Current Password",
                      value: "",
                      onSubmit: (v) {
                        setState(() {
                          oldPass = v;
                        });
                      },
                      lines: 1,
                      type: TextInputType.visiblePassword,
                    ),
                    MyTextInput(
                      title: "New Password",
                      value: "",
                      onSubmit: (v) {
                        setState(() {
                          nePass = v;
                        });
                      },
                      lines: 1,
                      type: TextInputType.visiblePassword,
                    ),
                    MyTextInput(
                      title: "Confirm Password",
                      value: "",
                      onSubmit: (v) {
                        setState(() {
                          cPass = v;
                        });
                      },
                      lines: 1,
                      type: TextInputType.visiblePassword,
                    ),
                    TextOakar(label: error, issuccessful: successful),
                    const SizedBox(
                      height: 16,
                    ),
                    SubmitButton(
                      label: "Submit",
                      onButtonPressed: () async {
                        setState(() {
                          isLoading = LoadingAnimationWidget.staggeredDotsWave(
                            color: const Color.fromARGB(255, 28, 100, 140),
                            size: 100,
                          );
                        });
                        var res = await changePass(
                            oldPass, nePass, cPass, userDetails["UserID"]);
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
                          await storage.write(key: 'miesjwt', value: "");
                          Timer(const Duration(seconds: 1), () {
                            Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                    builder: (_) => const Login()));
                          });
                        }
                      },
                    ),
                  ],
                ),
              ),
            ),
            Center(child: isLoading),
          ]),
        ));
  }
}

Future<Message> changePass(
    String oldPass, String newPass, String cPass, String id) async {
  if (oldPass.length < 5 || newPass.length < 5 || cPass.length < 5) {
    return Message(
      token: null,
      success: null,
      error: "One of the Passwords is too short!",
    );
  }
  if (newPass != cPass) {
    return Message(
      token: null,
      success: null,
      error: "Passwords do not match!",
    );
  }
  if (id == "") {
    return Message(
      token: null,
      success: null,
      error: "You are not logged in!",
    );
  }

  try {
    final response = await http.put(
      Uri.parse("${getUrl()}publicusers/update/$id"),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(
          <String, String>{'NewPassword': newPass, 'Password': oldPass}),
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
  } catch (e) {
    print(e);
    return Message(
      token: null,
      success: null,
      error: "Server connection failed! Check your internet.",
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
