// ignore_for_file: use_build_context_synchronously, prefer_typing_uninitialized_variables

import 'dart:async';
import 'dart:convert';
import 'package:miledrivers/Components/MyTextInput.dart';
import 'package:miledrivers/Components/SubmitButton.dart';
import 'package:miledrivers/components/ForgotPasswordDialog.dart';
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
  String phone = '';
  String password = '';
  String error = '';
  bool successful = false;
  var isLoading;
  bool termsAccepted = false; // Added boolean to track terms acceptance

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
              decoration: const BoxDecoration(
                  color: Colors.amber),
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
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (_) => const Login()));
                          },
                          child: const Text(
                            'Login',
                            style: TextStyle(
                              color: Colors.black87,
                              fontSize: 16.0,
                              decoration: TextDecoration.underline,
                              decorationColor: Colors.black87,
                            ),
                          ),
                        ),
                        const SizedBox(
                          height: 12,
                        ),
                        Center(
                          child: GestureDetector(
                            onTap: () => resetPassword(),
                            child: const Text(
                              "Reset Password",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w400,
                                color: Colors.black54,
                                 decoration: TextDecoration.underline,
                                  decorationColor: Colors.black54,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(
                          height: 16,
                        ),
                        Align(
                          alignment: Alignment.bottomCenter,
                          child: SubmitButton(
                            label: "Register",
                            onButtonPressed: () async {
                              if (!termsAccepted) {
                                // Show error message if terms not accepted
                                setState(() {
                                  error = 'Please accept Terms & Conditions';
                                });
                                return;
                              }
                              setState(() {
                                isLoading =
                                    LoadingAnimationWidget.staggeredDotsWave(
                                  color: Colors.white,
                                  size: 100,
                                );
                              });
                              var res = await submitData(phone, password);
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
                                await storage.write(key: 'mdjwt', value: res.token);
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

Future<Message> submitData(String phone, String password) async {
  if (password.length < 5) {
    return Message(
      token: null,
      success: null,
      error: "Password is too short!",
    );
  }

  try {
    final response = await post(
      Uri.parse("${getUrl()}erteams/register"),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{'Phone': phone, 'Password': password}),
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
