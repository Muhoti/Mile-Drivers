// ignore_for_file: use_build_context_synchronously, prefer_typing_uninitialized_variables

import 'dart:async';
import 'dart:convert';
import 'package:miledrivers/Components/MyTextInput.dart';
import 'package:miledrivers/Components/SubmitButton.dart';
import 'package:miledrivers/components/ForgotPasswordDialog.dart';
import 'package:miledrivers/components/MySelectInput.dart';
import 'package:miledrivers/components/TextOakar.dart';
import 'package:miledrivers/components/Utils.dart';
import 'package:miledrivers/pages/Login.dart';
import 'package:miledrivers/pages/Privacy.dart';
import 'package:miledrivers/pages/home.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class Register extends StatefulWidget {
  const Register({super.key});

  @override
  State<Register> createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  String name = '';
  String email = '';
  String password = '';
  String phone = '';
  String gender = '';
  String vehicletype = '';
  String error = '';
  bool successful = false;
  var isLoading;
  bool termsAccepted = false;

  final storage = const FlutterSecureStorage();

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  void _openDrawer() {
    _scaffoldKey.currentState?.openDrawer();
  }

  void resetPassword() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return const ForgotPasswordDialog();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Register',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: Scaffold(
        key: _scaffoldKey,
        body: Stack(
          children: [
            Container(
              height: double.infinity,
              width: double.infinity,
              decoration: const BoxDecoration(color: Colors.amber),
              padding: const EdgeInsets.fromLTRB(24, 50, 24, 0),
              child: SingleChildScrollView(
                child: Form(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Padding(
                          padding: const EdgeInsets.fromLTRB(48, 24, 48, 0),
                          child: Image.asset(
                            'assets/images/logo.png',
                            width: 200, // Set the desired width
                          ),
                        ),
                        const Text(
                          'Mile Driver',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 28, color: Colors.black87),
                        ),
                        const SizedBox(
                          height: 16,
                        ),
                        const Text(
                          "Register",
                          style: TextStyle(
                            fontSize: 34,
                            fontWeight: FontWeight.w500,
                            color: Colors.black87,
                          ),
                        ),
                        MyTextInput(
                          title: 'Full Name',
                          lines: 1,
                          value: '',
                          type: TextInputType.text,
                          onSubmit: (value) {
                            setState(() {
                              name = value;
                            });
                          },
                        ),
                        MyTextInput(
                          title: 'Email',
                          lines: 1,
                          value: '',
                          type: TextInputType.emailAddress,
                          onSubmit: (value) {
                            setState(() {
                              email = value;
                            });
                          },
                        ),
                        MyTextInput(
                          title: 'Password',
                          lines: 1,
                          value: '',
                          type: TextInputType.visiblePassword,
                          onSubmit: (value) {
                            setState(() {
                              password = value;
                            });
                          },
                        ),
                        MyTextInput(
                          title: 'Phone Number',
                          lines: 1,
                          value: '',
                          type: TextInputType.phone,
                          onSubmit: (value) {
                            setState(() {
                              phone = value;
                            });
                          },
                        ),
                        MySelectInput(
                          onSubmit: (value) {
                            setState(() {
                              gender = value;
                            });
                          },
                          list: const [
                            "--Select Gender--",
                            "Male",
                            "Female",
                          ],
                          label: 'Select Gender',
                          value: gender,
                        ),
                        MySelectInput(
                          onSubmit: (value) {
                            setState(() {
                              vehicletype = value;
                            });
                          },
                          list: const [
                            "--Select Vehicle Type--",
                            "Economy",
                            "Mile Motorbike",
                            "Mile XL",
                            "Green",
                            "Women Only",
                          ],
                          label: 'Select Vehicle Type',
                          value: vehicletype,
                        ),
                        Row(
                          children: [
                            Checkbox(
                              value: termsAccepted,
                              onChanged: (value) {
                                setState(() {
                                  termsAccepted = value!;
                                });
                              },
                            ),
                            GestureDetector(
                              onTap: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (_) => const Privacy()));
                              },
                              child: const Text(
                                'I accept the Terms & Conditions',
                                style: TextStyle(
                                  color: Colors.black87,
                                  fontSize: 16.0,
                                  decoration: TextDecoration.underline,
                                  decorationColor: Colors.black87,
                                ),
                              ),
                            ),
                          ],
                        ),
                        TextOakar(label: error),
                        const SizedBox(
                          height: 16,
                        ),
                        Align(
                          alignment: Alignment.bottomCenter,
                          child: SubmitButton(
                            label: "Register",
                            onButtonPressed: () async {
                              if (!termsAccepted) {
                                setState(() {
                                  error = 'Please accept Terms & Conditions';
                                });
                                return;
                              }
                              setState(() {
                                error = "";
                                isLoading = LoadingAnimationWidget.twistingDots(
                                  leftDotColor: Colors.black87,
                                  rightDotColor: Colors.deepOrange,
                                  size: 100,
                                );
                              });
                              var res = await submitData(name, email, password,
                                  phone, gender, vehicletype);
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
                                await storage.write(
                                    key: 'mdjwt', value: res.token);
                                Timer(const Duration(seconds: 2), () {
                                  Navigator.pushReplacement(
                                      context,
                                      MaterialPageRoute(
                                          builder: (_) => const Home()));
                                });
                              }
                            },
                          ),
                        ),
                        TextButton(
                            onPressed: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (_) => const Login()));
                            },
                            child: const Text(
                              "Login",
                              style: TextStyle(
                                  color: Colors.black87, fontSize: 16),
                            )),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            Center(child: isLoading),
          ],
        ),
      ),
    );
  }
}

Future<Message> submitData(String name, String email, String password,
    String phone, String gender, String vehicletype) async {
  if (password.length < 5) {
    return Message(
      token: null,
      success: null,
      error: "Password is too short!",
    );
  }

  if (name.isEmpty ||
      email.isEmpty | password.isEmpty ||
      phone.isEmpty ||
      gender.isEmpty ||
      vehicletype.isEmpty) {
    return Message(
      token: null,
      success: null,
      error: "All Fields Must Be Filled!",
    );
  }

  try {
    final response = await post(
      Uri.parse("${getUrl()}drivers/register"),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'Name': name,
        'Email': email,
        'Password': password,
        'Phone': phone,
        'Gender': gender,
        'VehicleType': vehicletype,
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
  } catch (e) {
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
