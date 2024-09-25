import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:mile_driver/components/MyTextInput.dart';
import 'package:mile_driver/components/SubmitButton.dart';
import 'package:mile_driver/components/TextOakar.dart';
import 'dart:convert';

import 'package:mile_driver/components/Utils.dart';
import 'package:mile_driver/components/mydrawer.dart';
import 'package:mile_driver/pages/Home.dart';

class PayHero extends StatefulWidget {
  final double tripCost;
  final String phone;

  const PayHero({super.key, required this.tripCost, required this.phone});

  @override
  _PayHeroState createState() => _PayHeroState();
}

class _PayHeroState extends State<PayHero> {
  final storage = const FlutterSecureStorage();
  final TextEditingController _phoneController = TextEditingController();
  bool _isLoading = false;
  String userid = '';
  String error = '';
  bool successful = false;
  String cost = "";
  String phone = "";
  Timer? _pollingTimer;

  @override
  void initState() {
    super.initState();
    getToken();
  }

  @override
  void dispose() {
    _pollingTimer?.cancel();
    super.dispose();
  }

  getToken() async {
    try {
      var token = await storage.read(key: "milesjwt");
      var decoded = parseJwt(token.toString());
      var _phone = widget.phone;

      _phone.startsWith('0')
          ? _phone = '254${_phone.substring(1)}'
          : _phone = _phone;

      print("phone gotten: $_phone");

      setState(() {
        phone = _phone;
        userid = decoded["UserID"];
        cost = widget.tripCost.toString();
      });
    } catch (e) {
      // Handle any exceptions or errors that occur
      print("Error fetching initial data: $e");
    }
  }

  Future<void> _makePayment() async {
    setState(() {
      _isLoading = true;
      error = "Awaiting Payment...";
    });

    final response = await makepayment(phone, cost);

    // Print the whole response data for debugging
    print("_make payment: ${response.data}");

    setState(() {
      _isLoading = false;
      if (response.error == null) {
        error = "STK Push Initiated";
        successful = true;
      } else {
        error = response.error!;
        successful = false;
      }
    });
  }

  Future<Message> makepayment(String phone, String amount) async {
    if (phone.isEmpty) {
      return Message(
          error: "Phone number is empty!", token: null, success: null);
    }

    try {
      final response = await post(
        Uri.parse("${getUrl()}processrequest"),
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
        body: jsonEncode({
          "phone_number": phone,
          "amount": double.tryParse(amount) ?? 0,
        }),
      ).timeout(const Duration(seconds: 60));

      if (response.statusCode == 200 || response.statusCode == 201) {
        var a = jsonDecode(response.body);
        String checkoutRequestID = a['data']['CheckoutRequestID'];
        print("STK Push initiated: $checkoutRequestID");

        // Start polling for the payment result
        pollForPaymentStatus(checkoutRequestID);

        return Message.fromJson(jsonDecode(response.body));
      } else {
        // Handle error responses
        try {
          return Message(
              error: jsonDecode(response.body)['error'] ?? "Server Error!");
        } catch (e) {
          return Message(error: "Unexpected server response: ${response.body}");
        }
      }
    } catch (e) {
      print("wallet error: $e");
      return Message(error: "Connection to server failed! Error: $e");
    }
  }

  Future<void> pollForPaymentStatus(String checkoutRequestID) async {
    print("request id: $checkoutRequestID");
    _pollingTimer = Timer.periodic(const Duration(seconds: 10), (timer) async {
      try {
        final response = await get(
          Uri.parse("${getUrl()}payment-status/$checkoutRequestID"),
          headers: {'Content-Type': 'application/json; charset=UTF-8'},
        );

        if (response.statusCode == 200) {
          var result = jsonDecode(response.body);

          print("payment status: $result");

          if (result['success']) {
            setState(() {
              error = "Payment successful";
              successful = true;
              _isLoading = false;
            });

            timer.cancel();
            if (error == "Payment successful") {
              await saveTransactionToDatabase(result, userid);
            }

            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const Home()),
            );
          } else {
            setState(() {
              error = result['message'];
              successful = false;
              _isLoading = false;
            });
            timer.cancel(); // Stop polling after failure
          }
        }
      } catch (e) {
        print("Error polling payment status: $e");
      }
    });
  }

  Future<Message> saveTransactionToDatabase(result, userid) async {
    print("saved result: ${result["phoneNumber"]}");

    try {
      final response = await post(
        Uri.parse("${getUrl()}transaction/create"),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, String>{
          "UserID": userid,
          "Phone": result["phoneNumber"].toString(),
          "Amount": result["amount"].toString(),
          "Receipt": result["receipt"].toString(),
          "Date": DateTime.now().toString(),
          "Type": "ride_payment"
        }),
      );

      print("body is ${response.body}");

      if (response.statusCode == 200 || response.statusCode == 203) {
        print("response status: ${response.statusCode}");

        return Message.fromJson(jsonDecode(response.body));
      } else {
        return Message(
          token: null,
          success: null,
          error: "Server Error! Connection Failed!",
        );
      }
    } catch (e) {
      print("error transactions: $e");
      return Message(
        token: null,
        success: null,
        error: "Connection to server failed!",
      );
    }
  }

  
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pay With M-PESA',
      theme: ThemeData(
        primarySwatch: Colors.amber,
      ),
      home: Scaffold(
        drawer: const MyDrawer(),
        appBar: AppBar(
          title: Row(
            children: [
              const Flexible(
                flex: 1,
                fit: FlexFit.tight,
                child: Text(
                  "Pay With M-PESA",
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
                          'Mile Rider',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 28, color: Colors.black87),
                        ),
                        const SizedBox(
                          height: 16,
                        ),
                        const Text(
                          "Pay With M-PESA",
                          style: TextStyle(
                            fontSize: 34,
                            fontWeight: FontWeight.w500,
                            color: Colors.black87,
                          ),
                        ),
                        MyTextInput(
                          title: 'Enter Phone Number For Making Payment',
                          lines: 1,
                          value: phone,
                          type: TextInputType.phone,
                          onSubmit: (value) {
                            setState(() {
                              phone = value;
                            });
                          },
                        ),
                        TextOakar(label: error, issuccessful: successful),
                        const SizedBox(height: 20),
                        _isLoading
                            ? Column(
                                children: [
                                  Center(
                                      child: LoadingAnimationWidget
                                          .staggeredDotsWave(
                                              color: Colors.white, size: 100)),
                                ],
                              )
                            : SubmitButton(
                                label: "Make Payment",
                                onButtonPressed: _makePayment,
                              ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class Message {
  var token;
  var success;
  var error;
  var status;
  var reference;
  var MpesaReceiptNumber;
  var data; // Adding data field to hold payment details

  Message({
    this.token,
    this.success,
    required this.error,
    this.status,
    this.reference,
    this.MpesaReceiptNumber,
    this.data,
  });

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      token: json['token'],
      success: json['success'],
      error: json['error'],
      status: json['status'],
      reference: json['reference'],
      MpesaReceiptNumber: json['MpesaReceiptNumber'],
      data: json['data'], // Parse the data field from the response
    );
  }
}
