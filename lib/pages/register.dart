import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:file_picker/file_picker.dart';
import 'package:http/http.dart' as http;
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:miledrivers/components/ForgotPasswordDialog.dart';
import 'package:miledrivers/components/MySelectInput.dart';
import 'package:miledrivers/components/MyTextInput.dart';
import 'package:miledrivers/components/SubmitButton.dart';
import 'package:miledrivers/components/TextOakar.dart';
import 'package:miledrivers/components/TextSmall.dart';
import 'package:miledrivers/components/Utils.dart';
import 'package:miledrivers/pages/Home.dart';
import 'package:miledrivers/pages/Login.dart';
import 'package:miledrivers/pages/Privacy.dart';

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
  String logbook = '';
  String license = '';
  String _logbook = '';
  String _license = '';

  String error = '';
  bool successful = false;
  var isLoading;
  bool termsAccepted = false;

  final storage = const FlutterSecureStorage();

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  void _openDrawer() {
    _scaffoldKey.currentState?.openDrawer();
  }

  Future<String> convertFileToBase64(File file) async {
    List<int> fileBytes = await file.readAsBytes();
    String base64String = base64Encode(fileBytes);
    return base64String;
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
                        const Row(
                          children: [
                            TextSmall(label: "Logbook (PDF only)"),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.fromLTRB(8, 4, 8, 4),
                          decoration: BoxDecoration(
                              borderRadius:
                                  const BorderRadius.all(Radius.circular(5)),
                              border:
                                  Border.all(color: Colors.white70, width: 1)),
                          child: Row(
                            children: [
                              Flexible(
                                flex: 1,
                                fit: FlexFit.tight,
                                child: logbook.isNotEmpty
                                    ? GestureDetector(
                                        onTap: () {
                                          setState(() {
                                            _logbook = '';
                                            logbook = '';
                                          });
                                        },
                                        child: Text(_logbook,
                                            style: const TextStyle(
                                                fontSize: 18,
                                                color: Colors.white)),
                                      )
                                    : const Text(
                                        'Pick logbook',
                                        style: TextStyle(
                                            fontSize: 18, color: Colors.white),
                                      ),
                              ),
                              const SizedBox(
                                width: 12,
                              ),
                              ElevatedButton(
                                onPressed: () async {
                                  FilePickerResult? result =
                                      await FilePicker.platform.pickFiles(
                                    type: FileType.custom,
                                    allowedExtensions: ['pdf'],
                                  );

                                  if (result != null) {
                                    PlatformFile file = result.files.single;
                                    File pickedFile = File(file.path!);
                                    String fileName = file.name!;
                                    String data =
                                        await convertFileToBase64(pickedFile);
                                    setState(() {
                                      logbook = data;
                                      _logbook = fileName;
                                    });
                                  }
                                },
                                child: const Text('Upload Logbook'),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(
                          height: 16,
                        ),
                        const Row(
                          children: [
                            TextSmall(label: "Driver's license (PDF only)"),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.fromLTRB(8, 4, 8, 4),
                          decoration: BoxDecoration(
                              borderRadius:
                                  const BorderRadius.all(Radius.circular(5)),
                              border:
                                  Border.all(color: Colors.white70, width: 1)),
                          child: Row(
                            children: [
                              Flexible(
                                flex: 1,
                                fit: FlexFit.tight,
                                child: logbook.isNotEmpty
                                    ? GestureDetector(
                                        onTap: () {
                                          setState(() {
                                            _license = '';
                                            license = '';
                                          });
                                        },
                                        child: Text(_license,
                                            style: const TextStyle(
                                                fontSize: 18,
                                                color: Colors.white)),
                                      )
                                    : const Text(
                                        'Pick license',
                                        style: TextStyle(
                                            fontSize: 18, color: Colors.white),
                                      ),
                              ),
                              const SizedBox(
                                width: 12,
                              ),
                              ElevatedButton(
                                onPressed: () async {
                                  FilePickerResult? result =
                                      await FilePicker.platform.pickFiles(
                                    type: FileType.custom,
                                    allowedExtensions: ['pdf'],
                                  );

                                  if (result != null) {
                                    PlatformFile file = result.files.single;
                                    File pickedFile = File(file.path!);
                                    String fileName = file.name!;
                                    String data =
                                        await convertFileToBase64(pickedFile);
                                    setState(() {
                                      license = data;
                                      _license = fileName;
                                    });
                                  }
                                },
                                child: const Text('Upload License'),
                              ),
                            ],
                          ),
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
                        TextOakar(label: error, issuccessful: successful),
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
                                  phone, gender, vehicletype, logbook, license);
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

Future<Message> submitData(
    String name,
    String email,
    String password,
    String phone,
    String gender,
    String vehicletype,
    String logbook,
    String license) async {
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
    final response = await http.post(
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
        'DLicense': license,
        'Logbook': logbook
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
